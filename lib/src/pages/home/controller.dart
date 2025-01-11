import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';

class HomePageController extends BaseController {
  HomePageController({HomePageController? data});

  @override
  void initListeners() {}

  static Future<DbResponse<List<Expense>>> getExpenses(
      DateTime from, DateTime to, List<String> categories) async {
    try {
      late final List<Map<String, Object?>> transaction;
      late final query;
      if (categories.isEmpty) {
        query = '''
      SELECT * from expense WHERE createdOn BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch} AND type = 'SPENT';
      ''';
      } else {
        query = '''
      SELECT * from expense WHERE createdOn BETWEEN ${from.millisecondsSinceEpoch} AND ${to.millisecondsSinceEpoch} AND type = 'SPENT' AND category IN (${categories.map((e) => "'$e'").join(",")});
      ''';
      }
      transaction = await Db.db.rawQuery(query);
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
}
