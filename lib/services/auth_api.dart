import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../session/session_manager.dart';
import 'dio_interceptor.dart';

class AuthApi {
  final SessionManager session = SessionManager();
  late final Dio _dio;

  AuthApi() {
    _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!));
    _dio.interceptors.add(AuthInterceptor(session.storage));
  }

  Future<void> signup(String email, String password) async {
    final response = await _dio.post('/api/auth/signup', data: {
      'email': email,
      'password': password,
    });

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
      await session.saveTokens(accessToken, refreshToken);
    } else {
      throw Exception('Impossibile estrarre i token dai cookie');
    }

    final user = response.data['user'];
    await session.saveUserRole(user['role']);

// (opzionale)
    await session.saveUserId(user['id']);
    await session.saveUserEmail(user['email']);

  }

  Future<void> resendVerification(String email) async {
    await _dio.post('/api/auth/resend-verification', data: {
      'email': email,
    });
  }
}
