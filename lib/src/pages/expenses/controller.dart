import 'dart:math';

import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/expenses/model.dart';

int btwn(Random source, int start, int end) =>
    source.nextInt(start) * (end - start) + start;

class ExpensesController extends Controller {
  @override
  void initListeners() {}

  ExpensesController({ExpensesPageData? data});

  List<Expense> _generateRandomExpenses(
      List<String> users, ExpenseType type, List<String> category, int count) {
    List<Expense> spent = List.generate(count, (i) {
      final _random = Random();
      var isSaving = type == ExpenseType.saved;
      var category = (isSaving ? SavingsCategories : SpentCategories)[_random
          .nextInt((isSaving ? SavingsCategories : SpentCategories).length)];
      var oneOfTwo = _random.nextInt(2);
      var firstName = users[oneOfTwo].split(" ")[0];
      var lastName = users[oneOfTwo].split(" ")[1];
      return Expense.fromJson({
        "type": type,
        "category": category,
        "amount": double.parse(
            "${btwn(_random, 9, 99)}.${([00, 25, 50, 75]..shuffle()).first}"),
        "date": DateTime.now(),
        "user": {
          "id": "${firstName}_${lastName}",
          "firstName": firstName,
          "lastName": lastName,
        }
      });
    });
    return spent;
  }

  List<Expense> generateRandomExpenses() {
    List<String> users = ["Abhimanyu Pandian", "Divyaa Subramaniam"];
    var saved =
        _generateRandomExpenses(users, ExpenseType.saved, SavingsCategories, 2);
    var spent = _generateRandomExpenses(
        users, ExpenseType.spent, SpentCategories, btwn(Random(), 2, 15));
    spent.sort((Expense a, Expense b) => a.category.compareTo(b.category));
    return [...saved, ...spent];
  }

  Future<List<Expense>> getExpenses(DateTime date) async {
    await Future.delayed(Duration(seconds: 0), () {});
    return generateRandomExpenses();
  }
}
