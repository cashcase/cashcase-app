import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HomePageController extends BaseController {
  HomePageController({HomePageController? data});

  @override
  void initListeners() {
    currentConn = ValueNotifier(AppDb.getCurrentPair());
  }

  late ValueNotifier<User?> currentConn;

  Future<User?> setCurrentUser(User? user) async {
    var status = await AppDb.setCurrentPair(user);
    if (status) currentConn.value = user;
    return user;
  }

  static Future<Either<AppError, List<OnlyExpense>>> getExpenses(
      DateTime from, DateTime to, List<String> categories) async {
    Response? response = await ApiHandler.get(
      "/expense/by-category-date?"
      "from=${from.startOfDay().toIso8601String()}Z&"
      "to=${to.startOfTmro().toIso8601String()}Z&"
      "categories=${categories.join(",")}",
    );
    return ResponseModel.respond(
      response,
      (data) => ((data['expenses'] ?? []) as List)
          .map<OnlyExpense>((e) => OnlyExpense.fromJson(e))
          .toList(),
    );
  }
}
