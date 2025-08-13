import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_base/utils/logger.dart';

class ApiService {
  static final log = getLogger(ApiService);
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  late Dio _dio;

  Dio get dio => _dio;

  void init({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));

    // 添加拦截器
    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: log.d,
      ),
      _ErrorInterceptor(),
    ]);

    log.i('ApiService initialized with baseUrl: $baseUrl');
  }

  void enableCache({Duration? maxStale}) {
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      hitCacheOnErrorExcept: [401, 403],
      maxStale: maxStale ?? const Duration(days: 7),
    );

    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    log.i('Cache enabled for ApiService');
  }
}

class _ErrorInterceptor extends Interceptor {
  final log = getLogger(_ErrorInterceptor);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log.e('Network error: ${err.message}',
        error: err, stackTrace: err.stackTrace);

    // 可以在这里添加全局错误处理逻辑
    // 例如：根据错误类型显示不同的错误提示
    // 或者将错误信息发送到错误监控系统

    handler.next(err); // 继续传递错误
  }
}
