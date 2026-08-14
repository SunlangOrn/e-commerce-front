import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {"Content-Type": "application/json"},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.instance.getAccessToken();
          if (token != null && !options.path.contains("/auth/signin") &&
              !options.path.contains("/auth/signup") &&
              !options.path.contains("/auth/refresh")) {
            options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          final isUnauthorized = error.response?.statusCode == 401;
          final isRefreshCall = error.requestOptions.path.contains("/auth/refresh");

          if (isUnauthorized && !isRefreshCall) {
            final refreshed = await _tryRefreshToken();
            if (refreshed != null) {
              final retryOptions = error.requestOptions;
              retryOptions.headers["Authorization"] = "Bearer $refreshed";
              try {
                final response = await _dio.fetch(retryOptions);
                return handler.resolve(response);
              } catch (_) {
                // fall through to error
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  Future<String?> _tryRefreshToken() async {
    final refreshToken = await StorageService.instance.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)).post(
        ApiConstants.refresh,
        data: {"refreshToken": refreshToken},
      );
      final data = response.data["data"];
      final newAccess = data["accessToken"] as String;
      final newRefresh = data["refreshToken"] as String;
      await StorageService.instance.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      return newAccess;
    } catch (_) {
      await StorageService.instance.clear();
      return null;
    }
  }
}