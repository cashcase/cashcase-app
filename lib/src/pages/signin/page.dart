import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/signin/controller.dart';
import 'package:cashcase/src/pages/signin/model.dart';
import 'package:cashcase/src/pages/signin/view.dart';
import 'package:flutter/material.dart';

class SigninPage extends BasePage {
  SigninPageData? data;
  SigninPage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _SigninPage();
}

class _SigninPage extends BaseView<SigninPage, SigninController> {
  _SigninPage() : super(SigninController());

  @override
  Widget get desktopView => SigninView();

  @override
  Widget get mobileView => SigninView();

  @override
  Widget get tabletView => SigninView();

  @override
  Widget get watchView => SigninView();
}
