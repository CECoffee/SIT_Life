import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:sit/credentials/init.dart';
import 'package:sit/session/sso.dart';

/// 应网办 official website
const _ywbUrl = "https://ywb.sit.edu.cn/v1";

class YwbCredentialsException implements Exception {
  final String message;

  const YwbCredentialsException({
    required this.message,
  });

  @override
  String toString() {
    return "YwbCredentialsException: $message";
  }
}

/// 应网办登录地址, POST 请求
const String _officeLoginUrl = "https://xgfy.sit.edu.cn/unifri-flow/login";

class YwbSession {
  bool isLogin = false;
  String? username;
  String? jwtToken;
  final Dio dio;

  YwbSession({
    required this.dio,
  });

  Future<void> _login({
    required String username,
    required String password,
  }) async {
    final Map<String, String> credential = {'account': username, 'userPassword': password, 'remember': 'true'};

    final response =
        await dio.post(_officeLoginUrl, data: credential, options: Options(contentType: Headers.jsonContentType));
    final int code = (response.data as Map)['code'];

    if (code != 0) {
      final String errMessage = (response.data as Map)['msg'];
      throw YwbCredentialsException(message: '($code) $errMessage');
    }
    jwtToken = ((response.data as Map)['data'])['authorization'];
    this.username = username;
    isLogin = true;
  }

  /// 获取当前以毫秒为单位的时间戳.
  static String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// 为时间戳生成签名. 此方案是联鹏习惯的反爬方式.
  static String _sign(String ts) {
    final content = const Utf8Encoder().convert('unifri.com$ts');
    return md5.convert(content).toString();
  }

  Future<Response> request(
    String url, {
    Map<String, String>? para,
    dynamic data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (!isLogin) {
      final credentials = CredentialInit.storage.oaCredentials;
      if (credentials == null) throw OaCredentialsRequiredException(url: url);
      await _login(
        username: credentials.account,
        password: credentials.password,
      );
    }

    Options newOptions = options ?? Options();

    // Make default options.
    final String ts = _getTimestamp();
    final String sign = _sign(ts);
    final Map<String, dynamic> newHeaders = {
      'timestamp': ts,
      'signature': sign,
      'Authorization': jwtToken,
    };

    newOptions.headers == null ? newOptions.headers = newHeaders : newOptions.headers?.addAll(newHeaders);
    newOptions.method = options?.method;

    final response = await dio.request(
      url,
      queryParameters: para,
      data: data,
      options: newOptions,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }
}
