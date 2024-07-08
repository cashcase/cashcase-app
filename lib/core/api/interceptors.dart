import 'package:cashcase/core/api/index.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dio/dio.dart';
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/core/utils/models.dart';

PrettyDioLogger logger = PrettyDioLogger(
  requestHeader: true,
  requestBody: true,
  responseBody: true,
  responseHeader: false,
  error: true,
  compact: true,
  maxWidth: 90,
);

Future<void> Function(RequestOptions, RequestInterceptorHandler) Function(Auth)
    onRequestInterceptor = (Auth auth) =>
        (RequestOptions options, RequestInterceptorHandler handler) async {
          if (auth.isAuthPath(options.path) == false) {
            options.headers.addAll({'Authorization': 'Bearer ${Db.token}'});
          }
          return handler.next(options);
        };

Future<void> Function(Response<dynamic>, ResponseInterceptorHandler) Function(
    Auth, Dio) onResponseInterceptor = (Auth auth, Dio dio) => (Response resp,
        ResponseInterceptorHandler handler) async {
      if (auth.checkTokenExpired(resp) == true && Db.isLoggedIn()) {
        auth.refreshToken().then((r) async {
          if (r == null) return handler.next(resp);
          r.fold((err) {
            return handler.next(resp);
          }, (details) async {
            AppController.setTokens(details.token, details.refreshToken);
            Response refreshedRepsonse = await dio.request(
              resp.requestOptions.path,
              data: resp.requestOptions.data,
              queryParameters: resp.requestOptions.queryParameters,
              options: Options(
                method: resp.requestOptions.method,
                headers: resp.requestOptions.headers,
                extra: resp.requestOptions.extra,
                contentType: resp.requestOptions.contentType,
                responseType: resp.requestOptions.responseType,
                validateStatus: resp.requestOptions.validateStatus,
                preserveHeaderCase: resp.requestOptions.preserveHeaderCase,
                persistentConnection: resp.requestOptions.persistentConnection,
              ),
            );
            handler.resolve(refreshedRepsonse);
          });
        });
        return handler.next(resp);
      } else {
        return handler.next(resp);
      }
    };
