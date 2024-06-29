import 'dart:math';
import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:dio/dio.dart';
import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:either_dart/either.dart';

int btwn(Random source, int start, int end) =>
    source.nextInt(start) * (end - start) + start;

class ExpensesController extends BaseController {
  @override
  void initListeners() {}

  ExpensesController({ExpensesPageData? data});

  Future<Either<AppError, List<Expense>>> getExpense(
    DateTime from,
    DateTime to,
    String username,
    String? currentConn,
  ) async {
    Response? response = await ApiHandler.get(
      "/expense/by-date?"
      "from=${from.toIso8601String()}Z&"
      "to=${to.toIso8601String()}Z"
      "${currentConn != null ? "&include=$currentConn" : ""}",
    );
    return ResponseModel.respond(
      response,
      (data) => ((data ?? []) as List)
          .map<Expense>((e) => Expense.fromJson(e))
          .toList(),
    );
  }

  Future<Either<AppError, void>> createExpense(
      {required String amount,
      String notes = "",
      required ExpenseType type,
      required String category}) async {
    Response? response = await ApiHandler.put("/expense", {
      "amount": amount,
      "notes": notes,
      "type": type.name,
      "category": category.toLowerCase()
    });
    return ResponseModel.respond(
      response,
      (data) => null,
    );
  }
}
