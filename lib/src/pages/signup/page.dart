import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/signin/model.dart';
import 'package:cashcase/src/pages/signup/controller.dart';
import 'package:cashcase/src/pages/signup/view.dart';
import 'package:flutter/material.dart';

class SignupPage extends BasePage {
  SigninPageData? data;
  SignupPage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _SignupPage();
}

class _SignupPage extends BaseView<SignupPage, SignupController> {
  _SignupPage() : super(SignupController());

  @override
  Widget get desktopView => SignupView();

  @override
  Widget get mobileView => SignupView();

  @override
  Widget get tabletView => SignupView();

  @override
  Widget get watchView => SignupView();
}
