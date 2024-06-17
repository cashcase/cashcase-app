class ExpensesPageData {}

class ExpensesResponse {
  double spent;
  double saved;
  ExpensesResponse({required this.spent, required this.saved});

  static fromJson(dynamic data) {
    return new ExpensesResponse(
      spent: 100,
      saved: 500.41,
    );
  }
}

class ExpenseBy {
  String firstName;
  String lastName;
  String id;
  ExpenseBy({
    required this.id,
    required this.firstName,
    required this.lastName,
  });
  static fromJson(dynamic data) {
    return ExpenseBy(
      id: data["id"],
      firstName: data["firstName"],
      lastName: data["lastName"],
    );
  }
}

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

class Expense {
  ExpenseType type;
  double amount;
  String category;
  DateTime date;
  ExpenseBy user;
  String? notes;
  Expense({
    required this.user,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = "",
  });

  static fromJson(dynamic data) {
    return Expense(
        user: ExpenseBy.fromJson(data['user']),
        type: data['type'],
        amount: data['amount'],
        category: data['category'],
        date: data['date']);
  }
}

class CollectedExpense {
  List<Expense> expenses;
  double total;
  ExpenseType type;
  CollectedExpense({
    required this.expenses,
    required this.type,
    required this.total,
  });
}
