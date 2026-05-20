import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_app/core/network/api_client.dart';
import 'package:phishguard_app/core/storage/secure_storage.dart';
import 'package:phishguard_app/features/auth/domain/models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider), ref.read(secureStorageProvider));
});

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthRepository(this._apiClient, this._storage);

  Future<UserModel> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data);
    await _saveUser(user);
    return user;
  }

  Future<UserModel> signup(String username, String email, String password) async {
    final response = await _apiClient.post('/auth/signup', data: {
      'username': username,
      'email': email,
      'password': password,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data);
    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<void> _saveUser(UserModel user) async {
    await _storage.saveTokens(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
    );
    await _storage.saveUser(
      userId: user.userId.toString(),
      username: user.username,
      email: user.email,
      language: user.preferredLanguage,
    );
  }
}

// Auth State
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Auth Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _repository.login(email, password);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthError(_parseError(e));
    }
  }

  Future<void> signup(String username, String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _repository.signup(username, email, password);
      state = AuthSuccess(user);
    } catch (e) {
      state = AuthError(_parseError(e));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthInitial();
  }

  String _parseError(dynamic e) {
    // Try to extract the backend's actual error message from Dio response
    try {
      final response = (e as dynamic).response;
      if (response != null) {
        final body = response.data;
        if (body is Map && body['message'] != null) {
          return body['message'].toString();
        }
        final status = response.statusCode;
        if (status == 400) return 'Email or username already registered.';
        if (status == 401 || status == 403) return 'Session expired. Please login again.';
        if (status == 409) return 'Email or username already taken.';
      }
    } catch (_) {}
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Cannot connect to server. Make sure the backend is running.';
    }
    if (msg.contains('401') || msg.contains('403')) return 'Session expired. Please login again.';
    if (msg.contains('400')) return 'Email already registered or invalid data.';
    return 'Something went wrong: $msg';
  }
}
