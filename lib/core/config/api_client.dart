import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';
import '../../features/auth/data/datasources/auth_token_storage.dart';
import 'api_config.dart';

/// Callback to trigger logout from outside (e.g., when refresh fails)
typedef LogoutCallback = void Function();

/// HTTP client wrapper using Dio with refresh token support
class ApiClient {
  late final Dio _dio;
  late final Dio _refreshDio; // Separate Dio for refresh calls (no interceptor loop)
  final Logger _logger = Logger();
  AuthTokenStorage? _tokenStorage;
  LogoutCallback? _onLogout;
  bool _isRefreshing = false;

  ApiClient({AuthTokenStorage? tokenStorage}) : _tokenStorage = tokenStorage {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: kIsWeb ? null : const Duration(milliseconds: ApiConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          return handler.next(error);
        },
      ),
    );

    // Add refresh token interceptor
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/')) {
            // Try to refresh token
            if (_tokenStorage != null && !_isRefreshing) {
              _isRefreshing = true;
              try {
                final refreshToken = await _tokenStorage!.getRefreshToken();
                if (refreshToken != null) {
                  final response = await _refreshDio.post(
                    ApiConfig.authRefresh,
                    data: {'refreshToken': refreshToken},
                  );

                  final newToken = response.data['token'] as String;
                  final newRefreshToken = response.data['refreshToken'] as String;

                  await _tokenStorage!.saveToken(newToken);
                  await _tokenStorage!.saveRefreshToken(newRefreshToken);
                  setAuthToken(newToken);

                  // Retry the original request
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await _dio.fetch(opts);
                  return handler.resolve(retryResponse);
                } else {
                  // No refresh token — clear state and trigger logout
                  await _tokenStorage!.clearAll();
                  clearAuthToken();
                  _onLogout?.call();
                }
              } catch (e) {
                // Refresh failed — clear tokens and trigger logout
                await _tokenStorage!.clearAll();
                clearAuthToken();
                _onLogout?.call();
              } finally {
                _isRefreshing = false;
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setTokenStorage(AuthTokenStorage storage) {
    _tokenStorage = storage;
  }

  void setLogoutCallback(LogoutCallback callback) {
    _onLogout = callback;
  }

  /// Set the authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear the authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
