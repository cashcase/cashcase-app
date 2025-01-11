import 'package:flutter/material.dart';

/**
 * Step 1: Create Page that extends BasePage
 */
abstract class BasePage extends StatefulWidget {
  @override
  final Key? key;
  final RouteObserver? routeObserver;

  const BasePage({this.routeObserver, this.key}) : super(key: key);
}
