import 'package:dio/dio.dart';
import 'package:cashcase/core/db.dart';
import 'package:logging/logging.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/api/interceptors.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

Logger log = Logger('ApiHandler');

abstract class Auth {
  Future<TokenModel?> refreshToken() async {
    return null;
  }

  bool? isAuth(String path) {
    return null;
  }

  bool? checkTokenExpiry(Response? response, {bool test = false}) {
    return null;
  }

  Future<TokenModel?> login() async {
    return null;
  }
}

class ApiHandler {
  static late Auth _auth;
  static late final Dio _dio;

  static Future<bool> login() async {
    TokenModel? details = await _auth.login();
    if (details == null) return false;
    AppController.setTokens(details.token, details.refreshToken);
    return true;
  }

  static Future<bool> logout() async {
    // AppController.loader.show('Logging out...');
    try {
      AppController.clearTokens();
    } catch (e) {
      log.severe(e);
    } finally {}
    return Db.isLoggedIn();
  }

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
    _auth = auth;
    _dio = create(uri);
    _dio.interceptors.add(logger);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: onRequestInterceptor(auth),
      onError: onErrorInterceptor(auth, _dio),
    ));
    // TODO: Do a downstream reachabiliy check here.
    return true;
  }

  static Future<Response<T>?> get<T>(String path,
      {RequestCallbacks? callbacks}) async {
    // AppController.loader.show(callbacks?.message ?? 'Loading...');
    try {
      Response<T> response =
          await _dio.request(path, options: Options(method: 'GET'));
      if (callbacks?.onSuccess != null) await callbacks!.onSuccess!();
      return response;
    } catch (e) {
      if (callbacks?.onError != null) {
        await callbacks!.onError!();
      } else {
        log.severe(e);
      }
    } finally {
      if (callbacks?.onDone != null) await callbacks!.onDone!();
      // AppController.loader.hide();
    }
    return null;
  }

  static Future<Response<T>?> _update<T>(String path, String method, T data,
      {RequestCallbacks? callbacks,
      Map<String, String> headers = const {
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
      if (callbacks?.onSuccess != null) await callbacks!.onSuccess!();
      return response;
    } catch (e) {
      print(e);
      if (callbacks?.onError != null)
        await callbacks!.onError!();
      else
        log.severe(e);
    } finally {
      if (callbacks?.onDone != null) await callbacks!.onDone!();
    }
    return null;
  }

  static Future<Response<T>?> post<T>(String path, dynamic data,
      {RequestCallbacks? callbacks,
      Map<String, String> headers = const {
        'Content-Type': 'application/json'
      }}) async {
    return await _update(path, "POST", data,
        headers: headers, callbacks: callbacks);
  }

  static Future<Response<T>?> patch<T>(String path, dynamic data,
      {RequestCallbacks? callbacks,
      Map<String, String> headers = const {
        'Content-Type': 'application/json'
      }}) async {
    return await _update(path, "PATCH", data,
        headers: headers, callbacks: callbacks);
  }

  static Future<Response<T>?> put<T>(String path, dynamic data,
      {RequestCallbacks? callbacks,
      Map<String, String> headers = const {
        'Content-Type': 'application/json'
      }}) async {
    return await _update(path, "PUT", data,
        headers: headers, callbacks: callbacks);
  }
}
