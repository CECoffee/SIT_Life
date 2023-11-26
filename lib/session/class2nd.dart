import 'package:dio/dio.dart';
import 'package:sit/session/sso.dart';

import '../network/session.dart';

class Class2ndSession {
  final SsoSession ssoSession;

  Class2ndSession({required this.ssoSession});

  Future<void> _refreshCookie() async {
    await ssoSession.request(
      'https://authserver.sit.edu.cn/authserver/login?service=http%3A%2F%2Fsc.sit.edu.cn%2Flogin.jsp',
      ReqMethod.get,
    );
  }

  bool _needRedirectToLoginPage(String data) {
    return data.startsWith('<script') ||
        data.contains('<meta http-equiv="refresh" content="0;URL=http://my.sit.edu.cn"/>');
  }

  Future<Response> request(
    String url,
    ReqMethod method, {
    Map<String, String>? para,
    data,
    Options? options,
    SessionProgressCallback? onSendProgress,
    SessionProgressCallback? onReceiveProgress,
  }) async {
    Future<Response> fetch() {
      return ssoSession.request(
        url,
        method,
        para: para,
        data: data,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    }

    Response response = await fetch();
    // 如果返回值是登录页面，那就从 SSO 跳转一次以登录.
    if (_needRedirectToLoginPage(response.data as String)) {
      await _refreshCookie();
      response = await fetch();
    }
    return response;
  }
}
