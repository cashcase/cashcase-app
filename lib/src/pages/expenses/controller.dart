import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/expenses/model.dart';

class ExpensesController extends Controller {
  late ExpensesResponse expenses;
  @override
  void initListeners() {}

  ExpensesController({ExpensesPageData? data});

  Future<ExpensesResponse?> getExpenses() async {
    await Future.delayed(Duration(seconds: 0), () {});
    this.expenses = ExpensesResponse.fromJson({});
    return expenses;
  }
}
