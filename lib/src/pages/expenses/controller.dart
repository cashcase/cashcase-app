import 'dart:math';
import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:cashcase/src/pages/expenses/model.dart';

int btwn(Random source, int start, int end) =>
    source.nextInt(start) * (end - start) + start;

class ExpensesController extends BaseController {
  @override
  void initListeners() {}

  ExpensesController({ExpensesPageData? data});

  List<User> get dummyUsers => [
        {
          "firstName": "Lionel",
          "lastName": "Messi",
          "id": "1",
          "email": "lionel@messi.com"
        },
        {
          "firstName": "Cristiano",
          "lastName": "Ronaldo",
          "id": "2",
          "email": "crisitano@ronaldo.com"
        },
        {
          "firstName": "Mesut",
          "lastName": "Ozil",
          "id": "3",
          "email": "mesut@ozil.com"
        }
      ].map<User>((e) => User.fromJson(e)).toList();

  String getUserInitials(User user) {
    return "${user.firstName[0].toUpperCase()}${user.lastName[0].toUpperCase()}";
  }

  List<Expense> _generateRandomExpenses(
      List<User> users, ExpenseType type, List<String> category, int count) {
    List<Expense> spent = List.generate(count, (i) {
      final _random = Random();
      var isSaving = type == ExpenseType.saved;
      var category = (isSaving ? SavingsCategories : SpentCategories)[_random
          .nextInt((isSaving ? SavingsCategories : SpentCategories).length)];
      var oneOfTwo = _random.nextInt(users.length);
      return Expense.fromJson({
        "type": type,
        "category": category,
        "amount": double.parse(
            "${btwn(_random, 9, 99)}.${([00, 25, 50, 75]..shuffle()).first}"),
        "date": DateTime.now(),
        "user": users[oneOfTwo].toJson()
      });
    });
    return spent;
  }

  List<Expense> generateRandomExpenses() {
    var saved = _generateRandomExpenses(
        dummyUsers, ExpenseType.saved, SavingsCategories, 2);
    var spent = _generateRandomExpenses(
        dummyUsers, ExpenseType.spent, SpentCategories, btwn(Random(), 2, 15));
    spent.sort((Expense a, Expense b) => a.category.compareTo(b.category));
    return [...saved, ...spent];
  }

  Future<List<Expense>> getExpenses(DateTime date) async {
    await Future.delayed(Duration(seconds: 0), () {});
    return generateRandomExpenses();
  }
}
