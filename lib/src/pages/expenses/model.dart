import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/account/model.dart';
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

class ExpensesByDate {
  DateTime firstExpenseDate;
  DateTime lastExpenseDate;
  List<Expense> expenses;
  ExpensesByDate({
    required this.expenses,
    required this.firstExpenseDate,
    required this.lastExpenseDate,
  });

  static empty(data) {
    return ExpensesByDate(
      expenses: [],
      firstExpenseDate:
          Expense._parseDateTime(data['firstExpenseDate']) ?? DateTime.now(),
      lastExpenseDate:
          Expense._parseDateTime(data['lastExpenseDate']) ?? DateTime.now(),
    );
  }

  static fromJson(dynamic data) {
    return ExpensesByDate(
      expenses: ((data['expenses'] ?? []) as List)
          .map<Expense>((e) => Expense.fromJson(e))
          .toList(),
      firstExpenseDate:
          Expense._parseDateTime(data['firstExpenseDate']) ?? DateTime.now(),
      lastExpenseDate:
          Expense._parseDateTime(data['lastExpenseDate']) ?? DateTime.now(),
    );
  }
}

class ExpenseDatePickerController {
  DateTime? firstExpenseDate;
  DateTime? lastExpenseDate;
  ExpenseDatePickerController({
    this.firstExpenseDate,
    this.lastExpenseDate,
  });
}

class Expense {
  ExpenseType type;
  String amount;
  String category;
  DateTime createdOn;
  DateTime updatedOn;
  User user;
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

  static _parseDateTime(String? value) {
    if (value == null) return null;
    if (value.endsWith("Z")) return DateTime.parse(value).toLocal();
    return DateTime.parse("${value}Z").toLocal();
  }

  static fromJson(dynamic data) {
    return Expense(
      id: data['id'],
      user: User.fromJson({
        "username": data['username'],
        "firstName": data['firstName'],
        "lastName": data['lastName'],
      }),
      notes: data['notes'],
      type: ExpenseType.values
          .firstWhere((e) => e.toString() == 'ExpenseType.' + data['type']),
      amount: data['amount'],
      category: data['category'],
      createdOn: _parseDateTime(data['createdOn']),
      updatedOn: _parseDateTime(data['updatedOn']),
    );
  }

  String toJson() {
    return {
      "id": this.id,
      "user": this.user,
      "type": this.type.name,
      "amount": this.amount,
      "notes": this.notes,
      "category": this.category,
      "createdOn": this.createdOn.toUtc(),
      "updatedOn": this.updatedOn.toUtc()
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
  SortedMap<String, CategoryExpense> categoryExpenses;
  GroupedExpense({
    required this.totalSaved,
    required this.totalSpent,
    required this.categoryExpenses,
  });

  static GroupedExpense fromExpenses(
    List<Expense> expenses,
    List<String?> keys,
  ) {
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
          .containsKey(each.user.username)) {
        expense.categoryExpenses[each.category]!
            .userExpenses[each.user.username] = UserExpense(
          amount: 0,
          user: each.user,
          isSaving: isSaving,
          notes: each.notes ?? "",
          expenses: [],
        );
      }

      if (double.tryParse(each.amount) == null) {
        try {
          if (each.user.username == AppDb.getCurrentUser()) {
            if (keys.first != null) {
              each.amount = Encrypter.decryptData(each.amount, keys.first!);
              if (each.notes != null && each.notes!.isNotEmpty) {
                each.notes =
                    Encrypter.decryptData(each.notes ?? "", keys.first!);
              }
            }
          } else {
            if (keys.last != null) {
              each.amount = Encrypter.decryptData(each.amount, keys.last!);
              if (each.notes != null && each.notes!.isNotEmpty) {
                each.notes =
                    Encrypter.decryptData(each.notes ?? "", keys.last!);
              }
            }
          }
          // If its still not a double, the decrypt failed.
          if (double.tryParse(each.amount) == null) {
            throw 'Invalid amount ${each.amount}';
          }
        } catch (e) {
          each.amount = "0.0";
        }
      }

      if (each.amount.startsWith("\."))
        each.amount = "0${each.amount}";
      else if (each.amount.endsWith("\.")) each.amount = "${each.amount}0";

      var amount = double.parse(each.amount);

      if (isSaving)
        expense.totalSaved += amount;
      else
        expense.totalSpent += amount;

      expense.categoryExpenses[each.category]!.amount += amount;
      expense.categoryExpenses[each.category]!.userExpenses[each.user.username]!
          .amount += amount;
      expense.categoryExpenses[each.category]!.userExpenses[each.user.username]!
          .expenses
          .add(each);

      expense.categoryExpenses[each.category]!.userExpenses[each.user.username]!
          .expenses
          .sort((a, b) {
        return double.parse(a.amount) > double.parse(b.amount) ? -1 : 1;
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
  User user;
  List<Expense> expenses;
  String? notes;
  UserExpense(
      {required this.user,
      required this.isSaving,
      required this.amount,
      required this.expenses,
      required this.notes});

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
  // For simplicity, 0 is current user key and 1 is paired user key.
  // TODO: Change this to object.
  List<String?> keys;
  void Function(void Function())? refresh;
  ExpenseListController({
    required this.expenses,
    required this.keys,
    this.refresh,
  });

  setRefresher(void Function(void Function()) fn) {
    refresh = fn;
  }

  GroupedExpense getGroupedExpenses() {
    return GroupedExpense.fromExpenses(this.expenses, this.keys);
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
