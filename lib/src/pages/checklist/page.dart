import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/Checklist/controller.dart';
import 'package:cashcase/src/pages/Checklist/model.dart';
import 'package:cashcase/src/pages/Checklist/view.dart';
import 'package:flutter/material.dart';

class ChecklistPage extends BasePage {
  ChecklistPageData? data;
  ChecklistPage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _ChecklistPage();
}

class _ChecklistPage extends BaseView<ChecklistPage, ChecklistController> {
  _ChecklistPage() : super(ChecklistController());

  @override
  Widget get desktopView => ChecklistView();

  @override
  Widget get mobileView => ChecklistView();

  @override
  Widget get tabletView => ChecklistView();

  @override
  Widget get watchView => ChecklistView();
}
