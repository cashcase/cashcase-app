import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:uuid/uuid.dart';

class TrendsController extends BaseController {
  TrendsController();
  @override
  void initListeners() {}

  Future<DbResponse<double>> getTotalForDate(
      DateTime on, List<String> categories) async {
    try {
      String query = "SELECT SUM(amount) as total FROM"
              " expense WHERE"
              " createdOn BETWEEN "
              "${on.startOfDay().millisecondsSinceEpoch} AND "
              "${on.endOfDay().millisecondsSinceEpoch}" +
          (categories.isNotEmpty
              ? " AND category IN "
                  "(${categories.map((e) => "'$e'").join(",")});"
              : ";");
      final transaction = await Db.db.rawQuery(query);
      return DbResponse(
        status: true,
        data:
            transaction.isEmpty ? 0.0 : (transaction.first['total'] as double),
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not get expenses!",
    );
  }

  Future<DbResponse<List<Expense>>> getExpenses(
      DateTime from, DateTime to, List<String> categories) async {
    try {
      String query = "SELECT * FROM"
              " expense WHERE"
              " createdOn BETWEEN "
              "${from.millisecondsSinceEpoch} AND "
              "${to.millisecondsSinceEpoch}" +
          (categories.isNotEmpty
              ? " AND category IN "
                  "(${categories.map((e) => "'$e'").join(",")});"
              : ";");
      final transaction = await Db.db.rawQuery(query);
      return DbResponse(
        status: true,
        data: transaction.map<Expense>((e) => Expense.fromJson(e)).toList(),
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not get expenses!",
    );
  }

  Future<DbResponse<Expense>> createExpense({
    required double amount,
    String notes = "",
    required ExpenseType type,
    required String category,
    DateTime? createdOn,
  }) async {
    Expense expense = Expense(
      amount: amount,
      user: "__self__",
      id: Uuid().v1(),
      type: type,
      category: category,
      notes: notes,
      createdOn: createdOn?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
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
}
