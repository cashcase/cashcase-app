import 'package:cashcase/src/pages/account/model.dart';

class ExpensesPageData {}

enum ExpenseType { saved, spent }

const SavingsCategories = [
  "income",
  // "stocks",
  // "crypto",
  // "rental",
  // "deposits",
  // "misc"
];

const SpentCategories = [
  "housing",
  "food",
  "transport",
  "healthcare",
  "education",
  "insurance",
  "debt",
  "travel",
  "utilities",
  "entertainment",
  "donation",
  "subscriptions",
  "maintenance",
  "misc"
];

String idGenerator() {
  final now = DateTime.now();
  return now.microsecondsSinceEpoch.toString();
}

class Expense {
  ExpenseType type;
  double amount;
  String category;
  DateTime date;
  User user;
  String id;
  String? notes;
  Expense({
    required this.id,
    required this.user,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = "",
  });

  static fromJson(dynamic data) {
    return Expense(
      id: idGenerator(),
      user: User.fromJson(data['user']),
      type: data['type'],
      amount: data['amount'],
      category: data['category'],
      date: data['date'],
    );
  }

  String toJson() {
    return {
      "id": this.id,
      "user": this.user,
      "type": this.type.name,
      "amount": this.amount,
      "category": this.category,
      "date": this.date.toUtc()
    }.toString();
  }
}

class CollectedExpense {
  double totalSaved;
  double totalSpent;
  List<Expense> expenses;
  // ExpenseType type;
  CollectedExpense({
    required this.expenses,
    // required this.type,
    required this.totalSaved,
    required this.totalSpent,
  });
}

class GroupedExpense {
  double totalSaved;
  double totalSpent;
  Map<String, CategoryExpense> categoryExpenses;
  GroupedExpense({
    required this.totalSaved,
    required this.totalSpent,
    required this.categoryExpenses,
  });
  static GroupedExpense fromExpenses(List<Expense> expenses) {
    GroupedExpense expense = GroupedExpense(
      totalSaved: 0,
      totalSpent: 0,
      categoryExpenses: {},
    );
    expenses.toList().forEach((each) {
      var isSaving = each.type == ExpenseType.saved;
      if (!expense.categoryExpenses.containsKey(each.category)) {
        expense.categoryExpenses[each.category] = CategoryExpense(
          amount: 0,
          isSaving: isSaving,
          userExpenses: {},
        );
      }
      if (!expense.categoryExpenses[each.category]!.userExpenses
          .containsKey(each.user.id)) {
        expense.categoryExpenses[each.category]!.userExpenses[each.user.id] =
            UserExpense(
          amount: 0,
          user: each.user,
          isSaving: isSaving,
          expenses: {
            each.id: each,
          },
        );
      }
      if (isSaving)
        expense.totalSaved += each.amount;
      else
        expense.totalSpent += each.amount;

      expense.categoryExpenses[each.category]!.amount += each.amount;
      expense.categoryExpenses[each.category]!.userExpenses[each.user.id]!
          .amount += each.amount;
      expense.categoryExpenses[each.category]!.userExpenses[each.user.id]!
          .expenses[each.id] = each;
    });
    return expense;
  }
}

class CategoryExpense {
  double amount;
  bool isSaving;
  Map<String, UserExpense> userExpenses;
  CategoryExpense({
    required this.isSaving,
    required this.amount,
    required this.userExpenses,
  });

  @override
  String toString() {
    return {
      "amount": this.amount,
      "isSaving": this.isSaving,
      "userExpenses": this.userExpenses
    }.toString();
  }
}

class UserExpense {
  double amount;
  bool isSaving;
  User user;
  Map<String, Expense> expenses;
  UserExpense({
    required this.user,
    required this.isSaving,
    required this.amount,
    required this.expenses,
  });

  @override
  String toString() {
    return {
      "amount": this.amount,
      "isSaving": this.isSaving,
      "expenses": this.expenses.toString()
    }.toString();
  }
}
