import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/reports/controller.dart';
import 'package:cashcase/src/pages/reports/model.dart';
import 'package:cashcase/src/pages/reports/view.dart';
import 'package:flutter/material.dart';

class ReportsPage extends BasePage {
  ReportsPageData? data;
  ReportsPage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _ReportsPage();
}

class _ReportsPage extends BaseView<ReportsPage, ReportsController> {
  _ReportsPage() : super(ReportsController());

  @override
  Widget get desktopView => ReportsView();

  @override
  Widget get mobileView => ReportsView();

  @override
  Widget get tabletView => ReportsView();

  @override
  Widget get watchView => ReportsView();
}
