import 'dart:typed_data';
import 'dart:math';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:mimir/credential/entity/credential.dart';
import 'package:mimir/credential/init.dart';
import 'package:mimir/exception/session.dart';
import 'package:mimir/network/session.dart';
import 'package:mimir/route.dart';
import 'package:mimir/session/common.dart';
import 'package:mimir/session/widgets/scope.dart';
import 'package:mimir/utils/logger.dart';
import 'package:synchronized/synchronized.dart';
import 'package:encrypt/encrypt.dart';

import '../utils/dio_utils.dart';

const _neededHeaders = {
  "Accept-Encoding": "gzip, deflate, br",
  'Origin': 'https://authserver.sit.edu.cn',
  "Upgrade-Insecure-Requests": "1",
  "Sec-Fetch-Dest": "document",
  "Sec-Fetch-Mode": "navigate",
  "Sec-Fetch-Site": "same-origin",
  "Sec-Fetch-User": "?1",
  "Referer": "https://authserver.sit.edu.cn/authserver/login",
};

// TODO: improve login flow.
/// Single Sign-On
class SsoSession with DioDownloaderMixin implements ISession {
  static const String _authServerUrl = 'https://authserver.sit.edu.cn/authserver';
  static const String _loginUrl = '$_authServerUrl/login';
  static const String _needCaptchaUrl = '$_authServerUrl/needCaptcha.html';
  static const String _captchaUrl = '$_authServerUrl/captcha.html';
  static const String _loginSuccessUrl = 'https://authserver.sit.edu.cn/authserver/index.do';

  // http客户端对象和缓存
  @override
  final Dio dio;

  final CookieJar cookieJar;

  /// Session错误拦截器
  final void Function(Object error, StackTrace stackTrace)? onError;

  /// 手动验证码
  final Future<String?> Function(Uint8List imageBytes) inputCaptcha;

  /// Lock it to prevent simultaneous login.
  final loginLock = Lock();

  SsoSession({
    required this.dio,
    required this.cookieJar,
    required this.inputCaptcha,
    this.onError,
  });

  Future<bool> checkConnectivity({
    String url = 'http://jwxt.sit.edu.cn/',
  }) async {
    try {
      await _dioRequest(
        url,
        'GET',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 判断该请求是否为登录页
  bool isLoginPage(Response response) {
    return response.realUri.toString().contains(_loginUrl);
  }

  /// 进行登录操作
  Future<void> ensureLoginLocked(String url) async {
    await loginLock.synchronized(() async {
      // 只有用户名与密码均不为空时，才尝试重新登录，否则就抛异常
      final credentials = CredentialInit.storage.oaCredentials;
      if (credentials != null) {
        await _login(credentials);
      } else {
        throw LoginRequiredException(url: url);
      }
    });
  }

  /// - User try to log in actively on a login page.
  Future<Response> loginActiveLocked(OaCredentials credential) async {
    return await loginLock.synchronized(() async {
      return await _login(credential);
    });
  }

  Future<Response> _dioRequest(
    String url,
    String method, {
    Map<String, String>? queryParameters,
    dynamic data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _request(
        url,
        method,
        queryParameters: queryParameters,
        data: data,
        options: options,
      );
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      rethrow;
    }
  }

  Future<Response> _request(
    String url,
    String method, {
    Map<String, String>? queryParameters,
    dynamic data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    options ??= Options();

    /// 正常地请求
    Future<Response> requestNormally() async {
      final response = await dio.request(
        url,
        queryParameters: queryParameters,
        options: options?.copyWith(
          headers: options.headers,
          method: method,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 400;
          },
        ),
        data: data,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      // 处理重定向
      return await DioUtils.processRedirect(dio, response, headers: _neededHeaders);
    }

    // 第一次先正常请求
    final firstResponse = await requestNormally();

    // 如果跳转登录页，那就先登录
    if (isLoginPage(firstResponse)) {
      await ensureLoginLocked(url);
      return await requestNormally();
    } else {
      return firstResponse;
    }
  }

  void _setOnline(bool isOnline) {
    final ctx = $Key.currentContext;
    if (ctx != null && ctx.mounted) {
      OaOnlineManagerState.of(ctx).isOnline = isOnline;
    }
  }

  /// 带异常的登录, 但不处理验证码识别错误问题.
  Future<Response> _login(OaCredentials credentials) async {
    Log.info('尝试登录：${credentials.account}');
    Log.debug('当前登录UA: ${dio.options.headers['User-Agent']}');
    // 在 OA 登录时, 服务端会记录同一 cookie 用户登录次数和输入错误次数,
    // 所以需要在登录前清除所有 cookie, 避免用户重试时出错.
    cookieJar.deleteAll();
    final Response response;
    try {
      response = await _postLoginProcess(credentials);
    } catch (e) {
      _setOnline(false);
      rethrow;
    }
    final page = BeautifulSoup(response.data);

    final emptyPage = BeautifulSoup('');
    // 桌面端报错提示
    final authError = (page.find('span', id: 'msg', class_: 'auth_error') ?? emptyPage).text.trim();
    // TODO: 支持移动端报错提示
    final mobileError = (page.find('span', id: 'errorMsg') ?? emptyPage).text.trim();
    if (authError.isNotEmpty || mobileError.isNotEmpty) {
      final errorMessage = authError + mobileError;
      final type = parseInvalidType(errorMessage);
      _setOnline(false);
      throw OaCredentialsException(message: errorMessage, type: type);
    }

    if (response.realUri.toString() != _loginSuccessUrl) {
      Log.error('未知验证错误,此时url为: ${response.realUri}');
      _setOnline(false);
      throw const UnknownAuthException();
    }
    Log.info('登录成功：${credentials.account}');
    CredentialInit.storage.oaLastAuthTime = DateTime.now();
    _setOnline(true);
    return response;
  }

  static OaCredentialsErrorType parseInvalidType(String errorMessage) {
    if (errorMessage.contains("验证码")) {
      return OaCredentialsErrorType.captcha;
    } else if (errorMessage.contains("冻结")) {
      return OaCredentialsErrorType.frozen;
    }
    return OaCredentialsErrorType.accountPassword;
  }

  /// 登录流程
  Future<Response> _postLoginProcess(OaCredentials credential) async {
    debug(m) => Log.debug(m);

    /// 提取认证页面中的加密盐
    String getSaltFromAuthHtml(String htmlText) {
      final a = RegExp(r'var pwdDefaultEncryptSalt = "(.*?)";');
      final matchResult = a.firstMatch(htmlText)!.group(0)!;
      final salt = matchResult.substring(29, matchResult.length - 2);
      debug('当前页面加密盐: $salt');
      return salt;
    }

    /// 提取认证页面中的Cas Ticket
    String getCasTicketFromAuthHtml(String htmlText) {
      final a = RegExp(r'<input type="hidden" name="lt" value="(.*?)"');
      final matchResult = a.firstMatch(htmlText)!.group(0)!;
      final casTicket = matchResult.substring(38, matchResult.length - 1);
      debug('当前页面CAS Ticket: $casTicket');
      return casTicket;
    }

    /// 获取认证页面内容
    Future<String> getAuthServerHtml() async {
      final response = await dio.get(
        _loginUrl,
        options: Options(headers: Map.from(_neededHeaders)..remove('Referer')),
      );
      return response.data;
    }

    /// 判断是否需要验证码
    Future<bool> needCaptcha(String username) async {
      final response = await dio.get(
        _needCaptchaUrl,
        queryParameters: {
          'username': username,
          'pwdEncrypt2': 'pwdEncryptSalt',
        },
        options: Options(headers: _neededHeaders),
      );
      final needCaptcha = response.data == 'true';
      debug('当前账户: $username, 是否需要验证码: $needCaptcha');
      return needCaptcha;
    }

    /// 获取验证码
    Future<Uint8List> getCaptcha() async {
      final response = await dio.get(
        _captchaUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: _neededHeaders,
        ),
      );
      Uint8List captchaData = response.data;
      return captchaData;
    }

    // 首先获取AuthServer首页
    final html = await getAuthServerHtml();

    // await cookieJar.saveFromResponse(
    //   Uri.parse('https://authserver.sit.edu.cn'),
    //   [Cookie('org.springframework.web.servlet.i18n.CookieLocaleResolver.LOCALE', 'zh')],
    // );

    // 获取首页验证码
    var captcha = '';
    if (await needCaptcha(credential.account)) {
      // 识别验证码
      final captchaImage = await getCaptcha();
      final c = await inputCaptcha(captchaImage);
      if (c != null) {
        captcha = c;
      } else {
        // 用户未输入验证码
        throw const LoginCaptchaCancelledException();
      }
    }
    // 获取casTicket
    final casTicket = getCasTicketFromAuthHtml(html);
    // 获取salt
    final salt = getSaltFromAuthHtml(html);
    // 加密密码
    final hashedPwd = hashPassword(salt, credential.password);
    // 登录系统，获得cookie
    return await _postLoginRequest(credential.account, hashedPwd, captcha, casTicket);
  }

  /// 登录统一认证平台
  Future<Response> _postLoginRequest(String username, String hashedPassword, String captcha, String casTicket) async {
    final requestBody = {
      'username': username,
      'password': hashedPassword,
      'captchaResponse': captcha,
      'lt': casTicket,
      'dllt': 'userNamePasswordLogin',
      'execution': 'e1s1',
      '_eventId': 'submit',
      'rmShown': '1',
    };
    // 登录系统
    final res = await dio.post(_loginUrl,
        data: requestBody,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          followRedirects: false,
          validateStatus: (status) {
            return status! < 400;
          },
          headers: _neededHeaders,
        ));
    // 处理重定向
    return await DioUtils.processRedirect(dio, res, headers: _neededHeaders);
  }

  @override
  Future<Response> request(
    String url,
    ReqMethod method, {
    Map<String, String>? para,
    data,
    SessionOptions? options,
    SessionProgressCallback? onSendProgress,
    SessionProgressCallback? onReceiveProgress,
  }) async {
    Response response = await _dioRequest(
      url,
      method.uppercaseName,
      queryParameters: para,
      data: data,
      options: options?.toDioOptions(),
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }
}

String hashPassword(String salt, String password) {
  var iv = rds(16);
  var encrypt = SsoEncryption(salt, iv);
  return encrypt.aesEncrypt(rds(64) + password);
}

String rds(int num) {
  var chars = 'ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678';
  return List.generate(
    num,
    (index) => chars[Random.secure().nextInt(chars.length)],
  ).join();
}

class SsoEncryption {
  Key? _key;
  IV? _iv;

  SsoEncryption(String key, String iv) {
    _key = Key.fromUtf8(key);
    _iv = IV.fromUtf8(iv);
  }

  String aesEncrypt(String content) {
    return Encrypter(
      AES(
        _key!,
        mode: AESMode.cbc,
        padding: 'PKCS7',
      ),
    )
        .encrypt(
          content,
          iv: _iv,
        )
        .base64;
  }
}