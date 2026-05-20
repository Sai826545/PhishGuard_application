import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_app/core/constants/app_strings.dart';
import 'package:phishguard_app/core/storage/secure_storage.dart';
import 'package:phishguard_app/core/router/app_router.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});

class ApiClient {
  late final Dio _dio;
  final Ref _ref;

  ApiClient(this._ref) {
    _dio = Dio(BaseOptions(
      baseUrl: AppStrings.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(_ref),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}

class _AuthInterceptor extends Interceptor {
  final Ref _ref;

  _AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Token expired — try to refresh
      final storage = _ref.read(secureStorageProvider);
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final dio = Dio(BaseOptions(baseUrl: AppStrings.baseUrl));
          final response = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
          final newToken = response.data['data']['accessToken'];
          await storage.saveTokens(
            accessToken: newToken,
            refreshToken: response.data['data']['refreshToken'],
          );
          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (_) {
          await storage.clearAll();
          _ref.read(appRouterProvider).go('/login');
        }
      } else {
        await storage.clearAll();
        _ref.read(appRouterProvider).go('/login');
      }
    }
    handler.next(err);
  }
}
