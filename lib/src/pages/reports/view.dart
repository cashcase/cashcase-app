import 'dart:math';

import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/Reports/controller.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportsView extends ResponsiveViewState<ReportsController> {
  ReportsView() : super(create: () => ReportsController());
  @override
  Widget get desktopView => View();

  @override
  Widget get mobileView => View();

  @override
  Widget get tabletView => View();

  @override
  Widget get watchView => View();
}

class View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
