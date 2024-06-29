import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:flutter/material.dart';

class HomePageController extends BaseController {
  HomePageController({HomePageController? data});

  @override
  void initListeners() {
    currentConn = ValueNotifier(AppDb.getCurrentConnection());
  }

  late ValueNotifier<User?> currentConn;

  Future<User?> setCurrentUser(User? user) async {
    var status = await AppDb.setCurrentConnection(user);
    if (status) currentConn.value = user;
    return user;
  }
}
