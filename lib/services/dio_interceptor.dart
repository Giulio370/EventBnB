import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;

  AuthInterceptor(this.storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Tentativo di refresh
      final refreshToken = await storage.read(key: 'refreshToken');

      if (refreshToken != null) {
        try {
          final dio = Dio(); // senza interceptor
          final response = await dio.post(
            'http://10.0.2.2:3000/refresh', // cambia se hai prefisso
            options: Options(headers: {
              'Authorization': 'Bearer $refreshToken',
            }),
          );

          final newAccess = response.headers.value('set-cookie')!
              .split(';')
              .firstWhere((c) => c.startsWith('accessToken='))
              .split('=')
              .last;

          await storage.write(key: 'accessToken', value: newAccess);

          // ritenta richiesta fallita con nuovo access token
          final clonedRequest = await _retry(err.requestOptions, newAccess);
          return handler.resolve(clonedRequest);
        } catch (_) {
          await storage.deleteAll(); // logout forzato
          return handler.reject(err);
        }
      }
    }

    return handler.next(err);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions, String accessToken) {
    final dio = Dio();
    final opts = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: opts,
    );
  }
}
