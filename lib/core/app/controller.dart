import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/core/app/loader.dart';
import 'package:cashcase/core/app/notifications.dart';
import 'package:cashcase/core/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppController extends Controller {
  static bool ready = false;
  static late final String title;
  static late final GoRouter router;
  static late final AssetImage? appLogo;

  static final AppController _singleton = AppController._internal();
  factory AppController() => _singleton;
  AppController._internal();

  static Future<bool> init({
    AssetImage? appLogo,
    required Uri downstreamUri,
    required String appName,
    required GoRouter router,
    required Auth auth,
  }) async {
    if (ready == true) return ready;

    bool apiStatus = ApiHandler.init(downstreamUri, auth);
    bool dbStatus = await Db.init();

    AppController.title = appName;
    AppController.appLogo = appLogo;
    AppController.router = router;

    ready = apiStatus && dbStatus;
    return ready;
  }

  final LoaderController loader = LoaderController();

  static hasTokens() {
    return Db.token.isNotEmpty && Db.refreshToken.isNotEmpty;
  }

  static setTokens(String token, String refreshToken) {
    Db.token = token;
    Db.refreshToken = refreshToken;
  }

  static clearTokens() {
    Db.token = '';
    Db.refreshToken = '';
    return Db.token.isEmpty && Db.refreshToken.isEmpty;
  }

  static refresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppController().refreshUI();
    });
  }

  @override
  void initListeners() {}
}
