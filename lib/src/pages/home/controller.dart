import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';

class HomePageController extends BaseController {
  HomePageController({HomePageController? data});

  @override
  void initListeners() {}

  static Future<DbResponse<List<Expense>>> getExpenses(
      DateTime from, DateTime to, List<String> categories) async {
    return DbResponse(status: true, data: []);
  }
}
