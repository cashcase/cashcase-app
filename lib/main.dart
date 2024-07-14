import 'dart:io';

import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/core/start.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/theme.dart';
import 'package:dio/src/response.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Logger log = Logger("main");

class AuthHandlers implements Auth {
  @override
  bool? checkTokenExpired(Response? response, {bool test = false}) {
    return response != null &&
        response.statusCode == 401 &&
        (response.headers.value("www-authenticate") ?? '')
            .contains('jwt expired');
  }

  @override
  bool? isAuthPath(String path) {
    return path == "/auth/refreshtoken" ||
        path == "/auth/login" ||
        path == "/auth/forgotpassword" ||
        path == "/auth/resetpassword";
  }

  @override
  Future<Either<AppError, TokenModel>?> refreshToken() async {
    Response? response = await ApiHandler.post("/auth/refresh", {},
        headers: {'refresh-token': Db.refreshToken});
    return ResponseModel.respond<TokenModel>(
      response,
      (data) => TokenModel.fromJson({
        "token": data,
        "refreshToken": Db.refreshToken,
      }),
    );
  }
}

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  const PROD = false;
  start(
    downstreamUri: PROD
        ? Uri(
            scheme: "https",
            host: "cashcase.kappasquare.rest",
            path: "v0",
          )
        : Uri(
            scheme: "http",
            host: Platform.isAndroid ? "10.0.2.2" : "localhost",
            port: 8888,
            path: "v0",
          ),
    auth: AuthHandlers(),
    themeData: themeData,
  );
}
