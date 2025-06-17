import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager {
  final _storage = const FlutterSecureStorage();

  FlutterSecureStorage get storage => _storage;

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }


  Future<String?> get accessToken async => await _storage.read(key: 'accessToken');
  Future<String?> get refreshToken async => await _storage.read(key: 'refreshToken');
  Future<void> saveUserRole(String role) async => await _storage.write(key: 'role', value: role);
  Future<String?> getUserRole() async => await _storage.read(key: 'role');

  Future<void> saveUserId(String id) async => await _storage.write(key: 'userId', value: id);
  Future<String?> getUserId() async => await _storage.read(key: 'userId');

  Future<void> saveUserEmail(String email) async => await _storage.write(key: 'email', value: email);
  Future<String?> getUserEmail() async => await _storage.read(key: 'email');

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await accessToken;
    return token != null;
  }
}
