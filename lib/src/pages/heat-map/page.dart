import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/heat-map/controller.dart';
import 'package:cashcase/src/pages/heat-map/model.dart';
import 'package:cashcase/src/pages/heat-map/view.dart';
import 'package:flutter/material.dart';

class HeatMapPage extends BasePage {
  HeatMapPageData? data;
  HeatMapPage({super.key, this.data});

  @override
  BaseView<HeatMapPage, HeatMapController> createState() => _HeatMapPage();
}

class _HeatMapPage extends BaseView<HeatMapPage, HeatMapController> {
  _HeatMapPage() : super(HeatMapController());

  @override
  Widget get desktopView => HeatMapView(data: widget.data);

  @override
  Widget get mobileView => HeatMapView(data: widget.data);

  @override
  Widget get tabletView => HeatMapView(data: widget.data);

  @override
  Widget get watchView => HeatMapView(data: widget.data);
}
