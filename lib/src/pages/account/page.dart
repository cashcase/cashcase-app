import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/account/controller.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:cashcase/src/pages/account/view.dart';
import 'package:flutter/material.dart';

class AccountPage extends BasePage {
  AccountPageData? data;
  AccountPage({super.key, this.data});
  @override
  State<StatefulWidget> createState() => _AccountPage();
}

class _AccountPage extends BaseView<AccountPage, AccountController> {
  _AccountPage() : super(AccountController());

  @override
  BaseWidget get desktopView => AccountView(data: widget.data);

  @override
  BaseWidget get mobileView => AccountView(data: widget.data);

  @override
  BaseWidget get tabletView => AccountView(data: widget.data);

  @override
  BaseWidget get watchView => AccountView(data: widget.data);
}
