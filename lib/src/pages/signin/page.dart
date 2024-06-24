
import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/signin/controller.dart';
import 'package:cashcase/src/pages/signin/view.dart';
import 'package:flutter/material.dart';

class SigninPage extends ResponsiveViewState {
  SigninPage() : super(create: () => SigninController());
  @override
  Widget get desktopView => SigninView();

  @override
  Widget get mobileView => SigninView();

  @override
  Widget get tabletView => SigninView();

  @override
  Widget get watchView => SigninView();
}
