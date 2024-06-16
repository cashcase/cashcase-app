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

enum ExpenseBy { me, partner }

enum ExpenseType { saved, spent }

enum ExpenseCategory { food, clothing, housing, travel, shopping, income }

class Expense {
  ExpenseType type;
  double amount;
  ExpenseCategory category;
  DateTime date;
  ExpenseBy by;
  Expense({
    this.by = ExpenseBy.me,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
  });
}
