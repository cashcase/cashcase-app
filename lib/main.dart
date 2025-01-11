import 'dart:io';

import 'package:cashcase/core/start.dart';
import 'package:cashcase/theme.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Logger log = Logger("main");

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  start(themeData: themeData);
}
