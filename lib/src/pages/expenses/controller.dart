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

  Future<Either<AppError, ExpensesByDate>> getExpense(
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
      (data) => ExpensesByDate.fromJson(data),
    );
  }

  Future<Either<AppError, ExpensesByDate>> getEmptyExpense() async {
    return ResponseModel.respond(
      Response(
          data: {"status": true, "data": {}}, requestOptions: RequestOptions()),
      (data) => ExpensesByDate.empty(data),
    );
  }

  Future<Either<AppError, Expense>> createExpense(
      {required String amount,
      String notes = "",
      required ExpenseType type,
      required String category}) async {
    Response? response = await ApiHandler.post("/expense", {
      "amount": amount,
      "notes": notes,
      "type": type.name,
      "category": category.toLowerCase()
    });
    return ResponseModel.respond(
      response,
      (data) => Expense.fromJson(data),
    );
  }

  Future<Either<AppError, void>> deleteExpense(String id) async {
    Response? response = await ApiHandler.delete("/expense/$id", {});
    return ResponseModel.respond(
      response,
      (data) => null,
    );
  }

  Future<Either<AppError, bool>> editExpenseNotes(
      String id, String notes) async {
    Response? response =
        await ApiHandler.patch("/expense/$id", {"notes": notes});
    return ResponseModel.respond(
      response,
      (data) => true,
    );
  }
}
