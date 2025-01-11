import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/core/utils/extensions.dart';
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
      // await Future.delayed(Duration(seconds: 3));
      final transaction = await Db.db.rawQuery(
          "SELECT * from expense WHERE date = ${from.millisecondsSinceEpoch}");
      final dates =
          await Db.db.rawQuery("SELECT MIN(date) as min from expense");
      return DbResponse(
        status: true,
        data: ExpensesByDate(
          expenses:
              transaction.map<Expense>((e) => Expense.fromJson(e)).toList(),
          start: DateTime.fromMillisecondsSinceEpoch(
            dates.first['min'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          ).startOfDay(),
          end: DateTime.now(), // End will always be today
        ),
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not get expenses!",
    );
  }

  static Future<DbResponse<DateLimits>> getDateLimits() async {
    try {
      // await Future.delayed(Duration(seconds: 1));
      final dates = await Db.db.rawQuery(
          "SELECT MIN(createdOn) as min, MAX(createdOn) as max from expense");
      return DbResponse(
        status: true,
        data: DateLimits(
          start: DateTime.fromMillisecondsSinceEpoch(
            dates.first['min'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          ).startOfDay(),
          end: DateTime.fromMillisecondsSinceEpoch(
            dates.first['max'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          ).startOfTmro(),
        ),
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not get date limits of expenses!",
    );
  }

  Future<DbResponse<Expense>> createExpense(
      {required double amount,
      required DateTime date,
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
      date: date.startOfDay().millisecondsSinceEpoch,
      createdOn: date.millisecondsSinceEpoch,
      updatedOn: date.millisecondsSinceEpoch,
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
