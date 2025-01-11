import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:cashcase/src/pages/expenses/view.dart';
import 'package:flutter/material.dart';

class ExpensesPage extends BasePage {
  ExpensesPageData? data;
  ExpensesPage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _ExpensesPage();
}

class _ExpensesPage extends BaseView<ExpensesPage, ExpensesController> {
  _ExpensesPage() : super(ExpensesController());

  @override
  Widget get desktopView => ExpensesView(data: widget.data);

  @override
  Widget get mobileView => ExpensesView(data: widget.data);

  @override
  Widget get tabletView => ExpensesView(data: widget.data);

  @override
  Widget get watchView => ExpensesView(data: widget.data);
}
