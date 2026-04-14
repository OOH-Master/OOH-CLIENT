import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  final FlutterSecureStorage _secureStorage;
  static const String _tokenKey = 'auth_jwt_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  AuthTokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Access token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // Clear all tokens
  Future<void> clearAll() async {
    await deleteToken();
    await deleteRefreshToken();
  }
}
