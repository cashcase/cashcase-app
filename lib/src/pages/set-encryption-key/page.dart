import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/set-encryption-key/controller.dart';
import 'package:cashcase/src/pages/set-encryption-key/model.dart';
import 'package:cashcase/src/pages/set-encryption-key/view.dart';
import 'package:flutter/material.dart';

class SetKeyPage extends BasePage {
  SetKeyPageData? data;
  SetKeyPage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _SetKeyPage();
}

class _SetKeyPage extends BaseView<SetKeyPage, SetKeyController> {
  _SetKeyPage() : super(SetKeyController());

  @override
  Widget get desktopView => SetKeyView();

  @override
  Widget get mobileView => SetKeyView();

  @override
  Widget get tabletView => SetKeyView();

  @override
  Widget get watchView => SetKeyView();
}
