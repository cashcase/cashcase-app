import 'dart:async';
import 'dart:ui';
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Logger logger = Logger('App');

class BaseView extends StatefulWidget {
  late final String title;
  late final GoRouter router;
  late final ThemeData _themeData;

  BaseView(
      {super.key,
      required this.title,
      required this.router,
      required ThemeData themeData})
      : _themeData = themeData {
    app = MaterialApp.router(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      title: title,
      theme: _themeData,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  late final MaterialApp app;

  @override
  State<BaseView> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  late final StreamSubscription<InternetStatus>? listener;

  @override
  void dispose() {
    if (listener != null) listener!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppController>(
      create: (_) => AppController(),
      builder: (context, child) {
        return UpgradeAlert(
          navigatorKey: AppController.router.routerDelegate.navigatorKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ChangeNotifierProvider<ThemeModel>(
                  create: (_) => ThemeModel(),
                  child: Consumer<ThemeModel>(
                    builder: (_, model, __) {
                      return widget.app;
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
