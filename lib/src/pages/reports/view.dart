import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/Reports/controller.dart';
import 'package:cashcase/src/pages/reports/model.dart';
import 'package:flutter/material.dart';

class ReportsView extends BaseWidget {
  ReportsPageData? data;
  ReportsView({
    super.key,
    this.data,
  });

  @override
  BaseConsumer build(BuildContext context) {
    return BaseConsumer<ReportsController>(builder: (controller, app) {
      return View();
    });
  }
}

class View extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
