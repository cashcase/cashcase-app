import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/signin/model.dart';
import 'package:cashcase/src/pages/Intro/controller.dart';
import 'package:cashcase/src/pages/Intro/view.dart';
import 'package:flutter/material.dart';

class IntroPage extends BasePage {
  SigninPageData? data;
  IntroPage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _IntroPage();
}

class _IntroPage extends BaseView<IntroPage, IntroController> {
  _IntroPage() : super(IntroController());

  @override
  Widget get desktopView => IntroView();

  @override
  Widget get mobileView => IntroView();

  @override
  Widget get tabletView => IntroView();

  @override
  Widget get watchView => IntroView();
}
