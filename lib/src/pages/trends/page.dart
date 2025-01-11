import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/trends/controller.dart';
import 'package:cashcase/src/pages/trends/model.dart';
import 'package:cashcase/src/pages/trends/view.dart';
import 'package:flutter/material.dart';

class TrendsPage extends BasePage {
  TrendsPageData? data;
  TrendsPage({super.key, this.data});

  @override
  BaseView<TrendsPage, TrendsController> createState() => _TrendsPage();
}

class _TrendsPage extends BaseView<TrendsPage, TrendsController> {
  _TrendsPage() : super(TrendsController());

  @override
  Widget get desktopView => TrendsView(data: widget.data);

  @override
  Widget get mobileView => TrendsView(data: widget.data);

  @override
  Widget get tabletView => TrendsView(data: widget.data);

  @override
  Widget get watchView => TrendsView(data: widget.data);
}
