import 'package:cashcase/core/start.dart';
import 'package:cashcase/theme.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Logger log = Logger("main");

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  start(themeData: themeData);
}
