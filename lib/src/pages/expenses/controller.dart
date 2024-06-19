import 'dart:math';

import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/expenses/model.dart';

class ExpensesController extends Controller {
  late ExpensesResponse expenses;
  @override
  void initListeners() {}

  ExpensesController({ExpensesPageData? data});

  List<Expense> generateRandomExpenses() {
    List<List<String>> users = [
      ["Abhimanyu", "Pandian"],
      ["Divyaa", "Subramaniam"]
    ];

    return List.generate(25, (i) {
      final _random = new Random();
      var random = [true, false][_random.nextInt(2)];
      var category = (random ? SavingsCategories : SpentCategories)[_random
          .nextInt((random ? SavingsCategories : SpentCategories).length)];
      var type = random ? ExpenseType.saved : ExpenseType.spent;
      var oneOfTwo = _random.nextInt(2);
      var firstName = users[oneOfTwo][0];
      var lastName = users[oneOfTwo][1];
      return Expense.fromJson({
        "type": type,
        "category": category,
        "amount": (100 * i).toDouble(),
        "date": DateTime.now(),
        "user": {
          "id": "${firstName}_${lastName}",
          "firstName": firstName,
          "lastName": lastName,
        }
      });
    });
  }

  Future<List<Expense>> getExpenses(DateTime date) async {
    await Future.delayed(Duration(seconds: 0), () {});
    return generateRandomExpenses();
  }
}
