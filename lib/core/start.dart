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
  required Uri downstreamUri,
  required Auth auth,
  required ThemeData themeData,
}) {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) HttpOverrides.global = DebugCertificate();
  AppController.init(
    auth: auth,
    router: router,
    downstreamUri: downstreamUri,
  ).then(
    (ready) {
      if (ready) {
        runApp(
          BaseView(
            router: router,
            themeData: themeData,
          ),
        );
      }
    },
  );
}
