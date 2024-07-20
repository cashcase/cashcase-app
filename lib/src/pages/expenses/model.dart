import 'package:sortedmap/sortedmap.dart';

class ExpensesPageData {}

enum ExpenseType { SAVED, SPENT }

const SavingsCategories = [
  "income",
  // "stocks",
  // "crypto",
  // "rental",
  // "deposits",
  // "misc"
];

var SpentCategories = [
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

class DateLimits {
  DateTime start;
  DateTime end;
  DateLimits({required this.start, required this.end});
}

class ExpensesByDate {
  DateTime start;
  DateTime end;
  List<Expense> expenses;
  ExpensesByDate({
    required this.expenses,
    required this.start,
    required this.end,
  });

  static empty() {
    return ExpensesByDate(
      expenses: [],
      start: DateTime.now(),
      end: DateTime.now(),
    );
  }

  static fromJson(dynamic data) {
    return ExpensesByDate(
      expenses: ((data['expenses'] ?? []) as List)
          .map<Expense>((e) => Expense.fromJson(e))
          .toList(),
      start: Expense._parseDateTime(data['start']),
      end: Expense._parseDateTime(data['end']),
    );
  }
}

class Expense {
  ExpenseType type;
  double amount;
  String category;
  int createdOn;
  int updatedOn;
  String user;
  String id;
  String? notes;
  Expense({
    required this.id,
    required this.user,
    required this.type,
    required this.amount,
    required this.category,
    required this.createdOn,
    required this.updatedOn,
    this.notes = "",
  });

  String getUser() {
    return user == "__self__" ? "you" : user;
  }

  static _parseDateTime(String? value) {
    if (value == null) return null;
    if (value.endsWith("Z")) return DateTime.parse(value).toLocal();
    return DateTime.parse("${value}Z").toLocal();
  }

  static fromJson(dynamic data) {
    return Expense(
      id: data['id'],
      user: data['user'],
      notes: data['notes'],
      type: ExpenseType.values
          .firstWhere((e) => e.toString() == 'ExpenseType.' + data['type']),
      amount: double.parse(data['amount']),
      category: data['category'],
      createdOn: data['createdOn'],
      updatedOn: data['updatedOn'],
    );
  }

  Map<String, Object?> toJson() {
    return {
      "id": this.id,
      "user": this.user,
      "type": this.type.name,
      "amount": this.amount,
      "notes": this.notes,
      "category": this.category,
      "createdOn": this.createdOn,
      "updatedOn": this.updatedOn
    };
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
  SortedMap<String, CategoryExpense> categoryExpenses;
  GroupedExpense({
    required this.totalSaved,
    required this.totalSpent,
    required this.categoryExpenses,
  });

  static GroupedExpense fromExpenses(List<Expense> expenses) {
    var categoryExpenses = SortedMap<String, CategoryExpense>(Ordering.byKey());
    GroupedExpense expense = GroupedExpense(
      totalSaved: 0,
      totalSpent: 0,
      categoryExpenses: SortedMap(),
    );

    for (var each in expenses.toList()) {
      var isSaving = each.type == ExpenseType.SAVED;

      if (!expense.categoryExpenses.containsKey(each.category)) {
        expense.categoryExpenses[each.category] = CategoryExpense(
          amount: 0,
          isSaving: isSaving,
          userExpenses: SortedMap(),
        );
      }

      var userExpenses = SortedMap<String, UserExpense>(Ordering.byKey());
      if (!expense.categoryExpenses[each.category]!.userExpenses
          .containsKey(each.user)) {
        expense.categoryExpenses[each.category]!.userExpenses[each.user] =
            UserExpense(
          amount: 0,
          user: each.user,
          isSaving: isSaving,
          notes: each.notes ?? "",
          expenses: [],
        );
      }

      var amount = each.amount;

      if (isSaving)
        expense.totalSaved += amount;
      else
        expense.totalSpent += amount;

      expense.categoryExpenses[each.category]!.amount += amount;
      expense.categoryExpenses[each.category]!.userExpenses[each.user]!
          .amount += amount;
      expense.categoryExpenses[each.category]!.userExpenses[each.user]!.expenses
          .add(each);

      expense.categoryExpenses[each.category]!.userExpenses[each.user]!.expenses
          .sort((a, b) {
        return a.amount > b.amount ? -1 : 1;
      });

      userExpenses
          .addAll(expense.categoryExpenses[each.category]!.userExpenses);
      expense.categoryExpenses[each.category]!.userExpenses = userExpenses;
    }

    expense.totalSaved = expense.totalSaved;
    expense.totalSpent = expense.totalSpent;

    categoryExpenses.addAll(expense.categoryExpenses);
    expense.categoryExpenses = categoryExpenses;
    return expense;
  }
}

class CategoryExpense {
  double amount;
  bool isSaving;
  SortedMap<String, UserExpense> userExpenses;
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
  String user;
  List<Expense> expenses;
  String? notes;
  UserExpense(
      {required this.user,
      required this.isSaving,
      required this.amount,
      required this.expenses,
      required this.notes});

  String getUser() {
    return user == "__self__" ? "you" : user;
  }

  @override
  String toString() {
    return {
      "amount": this.amount,
      "isSaving": this.isSaving,
      "expenses": this.expenses.toString()
    }.toString();
  }
}

class ExpenseListController {
  List<Expense> expenses;
  void Function(void Function())? refresh;
  ExpenseListController({
    required this.expenses,
    this.refresh,
  });

  setRefresher(void Function(void Function()) fn) {
    refresh = fn;
  }

  GroupedExpense getGroupedExpenses() {
    return GroupedExpense.fromExpenses(this.expenses);
  }

  notify() {
    if (refresh != null) refresh!(() => {});
  }

  remove(String id, {refresh = true}) {
    this.expenses.removeWhere((e) => e.id == id);
    notify();
  }

  Future<void> add(Expense expense) async {
    this.expenses.add(expense);
    notify();
  }

  update(Expense expense, String notes) {
    expense.notes = notes;
    remove(expense.id, refresh: false);
    add(expense);
  }
}
