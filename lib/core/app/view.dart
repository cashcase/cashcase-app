import 'dart:ui';
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/app/notification.dart';
import 'package:cashcase/core/app/theme.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:go_router/go_router.dart';

Logger logger = Logger('App');

class BaseApp extends StatelessWidget {
  late final GoRouter router;
  late final MaterialApp app;

  BaseApp({
    super.key,
    required this.router,
    required ThemeData themeData,
  }) {
    app = MaterialApp.router(
      themeMode: ThemeMode.dark,
      darkTheme: themeData,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppController>(
      create: (_) => AppController(),
      builder: (context, child) {
        return UpgradeAlert(
          navigatorKey: app.navigatorKey,
          child: ChangeNotifierProvider<ThemeModel>(
            create: (_) => ThemeModel(),
            child: Consumer<ThemeModel>(
              builder: (_, model, __) {
                var notification =
                    context.listen<AppController>().currentNotification;
                return Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    app,
                    if (context.listen<AppController>().active)
                      Container(
                        color: Colors.black87.withOpacity(0.7),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeCap: StrokeCap.round,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 100),
                      top: notification != null ? 0 : -240,
                      child: notification != null
                          ? AppNotification(
                              type: notification.type,
                              message: notification.message,
                            )
                          : Container(),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
