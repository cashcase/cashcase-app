import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/home/controller.dart';
import 'package:cashcase/src/pages/home/model.dart';
import 'package:cashcase/src/pages/home/view.dart';
import 'package:flutter/material.dart';

class HomePage extends BasePage {
  HomePageData? data;
  HomePage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends BaseView<HomePage, HomePageController> {
  _HomePage() : super(HomePageController());

  @override
  Widget get desktopView => HomePageView();

  @override
  Widget get mobileView => HomePageView();

  @override
  Widget get tabletView => HomePageView();

  @override
  Widget get watchView => HomePageView();
}
