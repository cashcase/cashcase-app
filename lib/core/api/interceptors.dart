import 'package:cashcase/core/api/index.dart';
import 'package:flutter/material.dart';
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

dynamic onRequestInterceptor = (Auth auth) =>
    (RequestOptions options, RequestInterceptorHandler handler) async {
      if (auth.isAuth(options.path) == false) {
        options.headers.addAll({'Authorization': 'Bearer ${Db.token}'});
      }
      return handler.next(options);
    };

dynamic onErrorInterceptor = (Auth auth, Dio dio) =>
    (DioException e, ErrorInterceptorHandler handler) async {
      if (auth.checkTokenExpiry(e.response) == true && Db.isLoggedIn()) {
        auth.refreshToken().then((TokenModel? details) async {
          if (details != null && AppController().context.mounted) {
            ScaffoldMessenger.of(AppController().context).showSnackBar(
              const SnackBar(
                content: Text("Your session was refreshed."),
              ),
            );
            AppController.setTokens(details.token, details.refreshToken);
            // Rebuilding the request and resolving it after setting tokens.
            Response refreshedResponse = await dio.request(
              e.requestOptions.path,
              cancelToken: e.requestOptions.cancelToken,
              data: e.requestOptions.data,
              options: Options(
                method: e.requestOptions.method,
                headers: e.requestOptions.headers,
                responseType: e.requestOptions.responseType,
                contentType: e.requestOptions.contentType,
                sendTimeout: e.requestOptions.sendTimeout,
                receiveTimeout: e.requestOptions.receiveTimeout,
                extra: e.requestOptions.extra,
                receiveDataWhenStatusError:
                    e.requestOptions.receiveDataWhenStatusError,
                followRedirects: e.requestOptions.followRedirects,
                listFormat: e.requestOptions.listFormat,
                maxRedirects: e.requestOptions.maxRedirects,
                requestEncoder: e.requestOptions.requestEncoder,
                responseDecoder: e.requestOptions.responseDecoder,
              ),
              onReceiveProgress: e.requestOptions.onReceiveProgress,
              onSendProgress: e.requestOptions.onSendProgress,
              queryParameters: e.requestOptions.queryParameters,
            );
            return handler.resolve(refreshedResponse);
          }
        });
      } else {
        return handler.next(e);
      }
    };
