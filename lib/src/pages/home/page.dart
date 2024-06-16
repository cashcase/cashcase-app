import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/home/controller.dart';
import 'package:cashcase/src/pages/home/model.dart';
import 'package:cashcase/src/pages/home/view.dart';
import 'package:flutter/material.dart';

class HomePage extends ResponsiveView {
  HomePageData? data;
  HomePage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => PageState();
}

class PageState extends ResponsivePageState<HomePage, HomePageController> {
  PageState() : super(HomePageController());

  @override
  AppView get desktopView => HomePageView(data: widget.data);

  @override
  AppView get mobileView => HomePageView(data: widget.data);

  @override
  AppView get tabletView => HomePageView(data: widget.data);

  @override
  AppView get watchView => HomePageView(data: widget.data);
}
