import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:uuid/uuid.dart';

class ExpensesController extends BaseController {
  @override
  void initListeners() {}

  ExpensesController({ExpensesPageData? data});

  static Future<DbResponse<ExpensesByDate>> getExpenses(
      DateTime from, DateTime to) async {
    try {
      final transaction = await Db.db.rawQuery(
          "SELECT * from expense WHERE createdOn BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch}");
      return DbResponse(
        status: true,
        data: ExpensesByDate(
          expenses:
              transaction.map<Expense>((e) => Expense.fromJson(e)).toList(),
          firstExpenseDate: DateTime.now(),
          lastExpenseDate: DateTime.now(),
        ),
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not get expenses!",
    );
  }

  Future<DbResponse<Expense>> createExpense(
      {required double amount,
      String notes = "",
      required ExpenseType type,
      required String category}) async {
    Expense expense = Expense(
      amount: amount,
      user: "__self__",
      id: Uuid().v1(),
      type: type,
      category: category,
      notes: notes,
      createdOn: DateTime.now().millisecondsSinceEpoch,
      updatedOn: DateTime.now().millisecondsSinceEpoch,
    );
    try {
      final transaction = await Db.db.insert(
        "expense",
        expense.toJson(),
      );
      return DbResponse(
        status: transaction > 0,
        data: expense,
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not add expense!",
    );
  }

  Future<DbResponse<String>> deleteExpense(String id) async {
    try {
      final transaction =
          await Db.db.delete("expense", where: 'id = ?', whereArgs: [id]);
      return DbResponse(
        status: transaction > 0,
        data: id,
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not delete expense!",
    );
  }

  Future<DbResponse<Expense>> editExpenseNotes(
      Expense expense, String notes) async {
    try {
      expense.notes = notes;
      final transaction = await Db.db.update(
        "expense",
        expense.toJson(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      return DbResponse(
        status: transaction > 0,
        data: expense,
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not update expense!",
    );
  }
}
