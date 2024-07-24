import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:uuid/uuid.dart';

class Trend {
  DateTime highestSpendDate;
  double highestSpend;
  DateTime lowestSpendDate;
  double lowestSpend;
  double total;
  Trend({
    required this.highestSpend,
    required this.highestSpendDate,
    required this.lowestSpendDate,
    required this.lowestSpend,
    required this.total,
  });
}

class TrendsController extends BaseController {
  TrendsController();
  @override
  void initListeners() {}

  var getSpendQuery = (List<String> categories, bool min) =>
      '''
        WITH secondary AS 
            (SELECT 
              date, SUM(amount) as amount
              FROM expense
              WHERE
                type = 'SPENT'
            ''' +
      (categories.isNotEmpty
          ? "AND category IN "
              "(${categories.map((e) => "'$e'").join(",")})"
          : "") +
      '''
              GROUP BY date
            )
    SELECT ''' +
      (min ? "MIN(amount)" : "MAX(amount)") +
      ''' as amount, date as createdOn
    from secondary;
  ''';

  Future<DbResponse<Trend?>> getKeyMetrics(
      DateTime selectedDate, List<String> categories) async {
    try {
      var batch = Db.db.batch();
      batch.rawQuery("SELECT SUM(amount) as total FROM"
              " expense WHERE type = 'SPENT' AND "
              " createdOn BETWEEN "
              "${selectedDate.startOfDay().millisecondsSinceEpoch} AND "
              "${selectedDate.endOfDay().millisecondsSinceEpoch}" +
          (categories.isNotEmpty
              ? " AND category IN "
                  "(${categories.map((e) => "'$e'").join(",")});"
              : ";"));
      batch.rawQuery(getSpendQuery(categories, true));
      batch.rawQuery(getSpendQuery(categories, false));
      var transaction = await batch.commit() as dynamic;
      return DbResponse(
        status: true,
        data: Trend(
          total: transaction[0][0]['total'] ?? 0.0,
          lowestSpend: transaction[1][0]['amount'] as double,
          lowestSpendDate: DateTime.fromMillisecondsSinceEpoch(
              transaction[1][0]['createdOn']),
          highestSpend: transaction[2][0]['amount'] as double,
          highestSpendDate: DateTime.fromMillisecondsSinceEpoch(
            transaction[2][0]['createdOn'],
          ),
        ),
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not get trends!",
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

  static Future<DbResponse<Expense>> createExpense({
    required double amount,
    String notes = "",
    required ExpenseType type,
    required String category,
    required DateTime createdOn,
  }) async {
    Expense expense = Expense(
      amount: amount,
      user: "__self__",
      id: Uuid().v1(),
      type: type,
      category: category,
      notes: notes,
      date: createdOn.startOfDay().millisecondsSinceEpoch,
      createdOn: createdOn.millisecondsSinceEpoch,
      updatedOn: createdOn.millisecondsSinceEpoch,
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
    } catch (e) {
    }
    return DbResponse(
      status: false,
      data: null,
      error: "Could not add expense!",
    );
  }
}
