import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/categories/controller.dart';
import 'package:cashcase/src/pages/categories/model.dart';
import 'package:cashcase/src/pages/categories/view.dart';
import 'package:flutter/material.dart';

class CategoriesPage extends BasePage {
  CategoriesPageData? data;
  CategoriesPage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _CategoriesPage();
}

class _CategoriesPage extends BaseView<CategoriesPage, CategoriesController> {
  _CategoriesPage() : super(CategoriesController());

  @override
  Widget get desktopView => CategoriesView();

  @override
  Widget get mobileView => CategoriesView();

  @override
  Widget get tabletView => CategoriesView();

  @override
  Widget get watchView => CategoriesView();
}
