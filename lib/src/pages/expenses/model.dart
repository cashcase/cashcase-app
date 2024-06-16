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
