import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dio_interceptor.dart';

class AuthApi {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late final Dio _dio;

  AuthApi() {
    _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!));
    _dio.interceptors.add(AuthInterceptor(storage));
  }

  Future<void> signup(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/signup', data: {
        'email': email,
        'password': password,
      });

      print('Signup success: ${response.data}');
    } on DioException catch (e) {
      print('Signup error: ${e.response?.data ?? e.message}');
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final response = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    final cookies = response.headers.map['set-cookie'];
    if (cookies == null) throw Exception('Cookie non presenti nella risposta');

    String? accessToken;
    String? refreshToken;

    for (var cookie in cookies) {
      if (cookie.startsWith('accessToken=')) {
        accessToken = cookie.split(';').first.split('=').last;
      } else if (cookie.startsWith('refreshToken=')) {
        refreshToken = cookie.split(';').first.split('=').last;
      }
    }

    if (accessToken != null && refreshToken != null) {
      await storage.write(key: 'accessToken', value: accessToken);
      await storage.write(key: 'refreshToken', value: refreshToken);
    } else {
      throw Exception('Impossibile estrarre i token dai cookie');
    }

    print('✅ Access Token: $accessToken');
    print('✅ Refresh Token: $refreshToken');
  }

  Future<void> resendVerification(String email) async {
    await _dio.post('/api/auth/resend-verification', data: {
      'email': email,
    });
  }
}
