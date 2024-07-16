import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';

class ExpensesController extends BaseController {
  @override
  void initListeners() {}

  ExpensesController({ExpensesPageData? data});

  static Future<DbResponse<ExpensesByDate>> getExpenses(
      DateTime from, DateTime to) async {
    return DbResponse(
      status: true,
      data: ExpensesByDate(
        expenses: [],
        firstExpenseDate: DateTime.now(),
        lastExpenseDate: DateTime.now(),
      ),
    );
  }

  Future<DbResponse<Expense>> createExpense(
      {required double amount,
      String notes = "",
      required ExpenseType type,
      required String category}) async {
    return DbResponse(status: false, data: null);
  }

  Future<DbResponse<String>> deleteExpense(String id) async {
    return DbResponse(status: true, data: id);
  }

  Future<DbResponse<String>> editExpenseNotes(String id, String notes) async {
    return DbResponse(status: true, data: id);
  }
}
