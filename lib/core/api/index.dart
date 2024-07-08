import 'package:cashcase/core/utils/errors.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:logging/logging.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/core/api/interceptors.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

Logger log = Logger('ApiHandler');

abstract class Auth {
  Future<Either<AppError, TokenModel>?> refreshToken() async {
    return null;
  }

  bool? isAuthPath(String path) {
    return null;
  }

  bool? checkTokenExpired(Response? response, {bool test = false}) {
    return null;
  }
}

class ApiHandler {
  static late final Dio _dio;

  static Dio create(Uri uri) {
    final options = BaseOptions(
      receiveDataWhenStatusError: true,
      baseUrl: uri.toString(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
    var dio = Dio(options);
    const retries = [1, 1, 1];
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      retries: retries.length,
      retryDelays: retries.map<Duration>((e) => Duration(seconds: e)).toList(),
    ));

    return dio;
  }

  static bool init(Uri uri, Auth auth) {
    _dio = create(uri);
    _dio.interceptors.add(logger);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: onRequestInterceptor(auth),
      onResponse: onResponseInterceptor(auth, _dio)
    ));
    // TODO: Do a downstream reachabiliy check here.
    return true;
  }

  static Future<Response<T>?> get<T>(String path) async {
    try {
      Response<T> response = await _dio.request(path,
          options: Options(method: 'GET', validateStatus: (_) => true));
      return response;
    } catch (e) {
      log.severe(e);
    }
    return null;
  }

  static Future<Response<T>?> _update<T>(String path, String method, T data,
      {Map<String, String> headers = const {
        'Content-Type': 'application/json'
      }}) async {
    try {
      Response<T> response = await _dio.request(
        path,
        data: data,
        options: Options(
          method: method,
          headers: headers,
          validateStatus: (_) => true,
        ),
      );
      return response;
    } catch (e) {
      log.severe(e);
    }
    return null;
  }

  static Future<Response<T>?> post<T>(String path, dynamic data,
      {Map<String, String> headers = const {
        'Content-Type': 'application/json'
      }}) async {
    return await _update(path, "POST", data, headers: headers);
  }

  static Future<Response<T>?> patch<T>(String path, dynamic data,
      {Map<String, String> headers = const {
        'Content-Type': 'application/json'
      }}) async {
    return await _update(path, "PATCH", data, headers: headers);
  }

  static Future<Response<T>?> put<T>(String path, dynamic data,
      {Map<String, String> headers = const {
        'Content-Type': 'application/json'
      }}) async {
    return await _update(path, "PUT", data, headers: headers);
  }

  static Future<Response<T>?> delete<T>(String path, dynamic data,
      {Map<String, String> headers = const {
        'Content-Type': 'application/json'
      }}) async {
    return await _update(path, "DELETE", data, headers: headers);
  }
}
