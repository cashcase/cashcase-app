import 'package:cashcase/core/controller.dart';
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
  BaseWidget get desktopView => ExpensesView(data: widget.data);

  @override
  BaseWidget get mobileView => ExpensesView(data: widget.data);

  @override
  BaseWidget get tabletView => ExpensesView(data: widget.data);

  @override
  BaseWidget get watchView => ExpensesView(data: widget.data);
}
