import 'package:cashcase/core/controller.dart';
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
  BaseWidget get desktopView => SigninView(data: widget.data);

  @override
  BaseWidget get mobileView => SigninView(data: widget.data);

  @override
  BaseWidget get tabletView => SigninView(data: widget.data);

  @override
  BaseWidget get watchView => SigninView(data: widget.data);
}
