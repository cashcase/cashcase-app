import 'dart:io';
import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/app/view.dart';
import 'package:cashcase/core/utils/helpers.dart';
import 'package:cashcase/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

start({
  AssetImage? appLogo,
  required String appName,
  required Uri downstreamUri,
  required Auth auth,
  required ThemeData themeData,
}) {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) HttpOverrides.global = DebugCertificate();
  AppController.init(
    downstreamUri: downstreamUri,
    appName: appName,
    auth: auth,
    appLogo: appLogo,
    themeData: themeData,
    router: router,
  ).then(
    (ready) {
      if (ready) {
        runApp(
          BaseView(
            title: appName,
            router: router,
            themeData: themeData,
          ),
        );
      }
      // TODO: Else show error page
    },
  );
}
