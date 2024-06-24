import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/core/start.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/theme.dart';
import 'package:dio/src/response.dart';
import 'package:logging/logging.dart';

Logger log = Logger("main");

class AuthHandlers implements Auth {
  @override
  bool? checkTokenExpiry(Response? response, {bool test = false}) {
    return response != null &&
        response.statusCode == 401 &&
        (response.headers.value("www-authenticate${test ? '-test' : ''}") ?? '')
            .contains('The token expired at');
  }

  @override
  bool? isAuth(String path) {
    return path == "/auth/refreshtoken" ||
        path == "/auth/login" ||
        path == "/auth/forgotpassword" ||
        path == "/auth/resetpassword";
  }

  @override
  Future<TokenModel?> login() {
    throw UnimplementedError();
  }

  @override
  Future<TokenModel?> refreshToken() async {
    try {
      Response<dynamic>? response =
          await ApiHandler.post("/auth/refreshtoken", {
        "token": Db.token,
        "refreshToken": Db.refreshToken,
      });
      if (response == null || response.data == null) return null;
      return TokenModel.fromJson(response.data);
    } catch (e) {
      log.severe(e);
    }
    return null;
  }
}

void main(List<String> args) {
  start(
    appName: "cashcase",
    downstreamUri: Uri(
      scheme: "http",
      host: "localhost",
      port: 8888,
      path: "v0"
    ),
    auth: AuthHandlers(),
    themeData: themeData,
  );
}
