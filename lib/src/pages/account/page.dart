import 'package:cashcase/core/base/page.dart';
import 'package:cashcase/core/base/view.dart';
import 'package:cashcase/src/pages/account/controller.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:cashcase/src/pages/account/view.dart';
import 'package:flutter/material.dart';

class AccountPage extends BasePage {
  AccountPageData? data;
  AccountPage({super.key, this.data});
  
  @override
  BaseView<AccountPage, AccountController> createState() => _AccountPage();
}

class _AccountPage extends BaseView<AccountPage, AccountController> {
  _AccountPage() : super(AccountController());

  @override
  Widget get desktopView => AccountView(data: widget.data);

  @override
  Widget get mobileView => AccountView(data: widget.data);

  @override
  Widget get tabletView => AccountView(data: widget.data);

  @override
  Widget get watchView => AccountView(data: widget.data);
}
