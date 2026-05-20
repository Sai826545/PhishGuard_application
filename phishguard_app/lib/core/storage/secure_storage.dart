import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  static const _languageKey = 'language';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> saveUser({
    required String userId,
    required String username,
    required String email,
    String language = 'en',
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _languageKey, value: language);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);
  Future<String?> getUsername() => _storage.read(key: _usernameKey);
  Future<String?> getEmail() => _storage.read(key: _emailKey);
  Future<String?> getLanguage() => _storage.read(key: _languageKey);

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
