import 'package:dio/dio.dart';
import 'package:mimir/credentials/init.dart';

import 'package:mimir/school/library/init.dart';

class LibrarySession {
  final Dio dio;

  const LibrarySession({required this.dio});

  Future<Response> request(
    String url, {
    Map<String, String>? para,
    data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    Future<Response> fetch() {
      return dio.request(
        url,
        queryParameters: para,
        data: data,
        options: options,
      );
    }

    final response = await fetch();
    final resData = response.data;
    if (resData is String) {
      // renew login
      final credentials = CredentialsInit.storage.libraryCredentials;
      if (credentials != null) {
        if (resData.contains("/opac/reader/doLogin")) {
          await LibraryInit.auth.login(credentials);
          return await fetch();
        }
      }
    }
    return response;
  }
}
