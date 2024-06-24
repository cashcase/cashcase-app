import 'package:cashcase/core/controller.dart';
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
  BaseWidget get desktopView => HomePageView(data: widget.data);

  @override
  BaseWidget get mobileView => HomePageView(data: widget.data);

  @override
  BaseWidget get tabletView => HomePageView(data: widget.data);

  @override
  BaseWidget get watchView => HomePageView(data: widget.data);
}
