import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/app/view.dart';
import 'package:cashcase/routes.dart';
import 'package:flutter/material.dart';

start({
  AssetImage? appLogo,
  required ThemeData themeData,
}) {
  AppController.init(router: router).then(
    (ready) {
      if (ready) {
        runApp(
          BaseApp(
            router: router,
            themeData: themeData,
          ),
        );
      }
    },
  );
}
