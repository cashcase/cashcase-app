import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/routes.dart';
import 'package:cashcase/src/components/date-picker.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:flutter/material.dart';
import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ExpensesView extends ResponsiveViewState {
  ExpensesView() : super(create: () => ExpensesController());
  @override
  Widget get desktopView => View();

  @override
  Widget get mobileView => View();

  @override
  Widget get tabletView => View();

  @override
  Widget get watchView => View();
}

class View extends StatefulWidget {
  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  late Future<List<Expense>?> _future;

  bool isSaving = false;
  late String? typeOfAddingValue;

  DateTime selectedDate = DateTime.now();

  Future<List<Expense>> get expensesFuture =>
      context.once<ExpensesController>().getExpenses(selectedDate);

  @override
  void initState() {
    _future = expensesFuture;
    typeOfAddingValue = (isSaving ? SavingsCategories : SpentCategories)[0];
    super.initState();
  }

  Future saveExpense(String notes) async {
    Navigator.pop(context);
    return true;
  }

  Future showExpenseDetails(Expense expense) {
    var isSaved = expense.type == ExpenseType.saved;
    TextEditingController notesController =
        TextEditingController(text: expense.notes ?? "");
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black87,
      builder: (_) => Wrap(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 40),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSaved ? Colors.green.shade800 : Colors.red.shade800,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isSaved
                                  ? Colors.green.shade600
                                  : Colors.red.shade500,
                              radius: 24.0,
                              child: Text(
                                "${expense.user.firstName[0].toUpperCase()}${expense.user.lastName[0].toUpperCase()}",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "${expense.user.firstName.toCamelCase()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: isSaved
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                  ),
                            )
                          ],
                        ),
                        Text(
                          "${isSaved ? "+" : "-"} ${expense.amount.toString()}",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: isSaved
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                              ),
                        )
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.black38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat().format(expense.date),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(),
                          ),
                          Text(
                            expense.category.toCamelCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: notesController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Notes',
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white24, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white12, width: 1.0),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              saveExpense(notesController.text);
                            },
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Expense>?>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          List<Expense> expenses = snapshot.data!;
          return Container(
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: 0),
                      child: DatePicker(
                        onDateChange: (date) {
                          selectedDate = date;
                          _future = expensesFuture;
                          setState(() => {});
                        },
                      ),
                    ),
                    Expanded(
                      child: renderGroupedExpenses(
                        GroupedExpense.fromExpenses(
                          expenses,
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  bottom: 0,
                  child: renderFooter(),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Column renderGroupedExpenses(GroupedExpense expenses) {
    var categoryExpenses = expenses.categoryExpenses.keys.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8),
        Container(
          // height: 40,
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Saved",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.green.shade800,
                        ),
                  ),
                  Text(
                    "${expenses.totalSaved.toString()}",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.green.shade800,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Spent",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.red.shade800,
                        ),
                  ),
                  Text(
                    "${expenses.totalSpent.toString()}",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.red.shade800,
                        ),
                  ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding:
                const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
            shrinkWrap: true,
            itemCount: categoryExpenses.length,
            itemBuilder: (context, index) {
              var category = categoryExpenses[index];
              var isSaving = expenses.categoryExpenses[category]!.isSaving;
              var amount = expenses.categoryExpenses[category]!.amount;
              if (amount == 0) return Container();
              var userExpenses =
                  expenses.categoryExpenses[category]!.userExpenses;
              return Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  backgroundColor: Colors.black45,
                  collapsedIconColor: isSaving ? Colors.green : Colors.red,
                  iconColor: isSaving ? Colors.green : Colors.red,
                  title: Text(
                    categoryExpenses[index].toCamelCase(),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(),
                  ),
                  trailing: Text(
                    "${isSaving ? "+" : "-"} "
                    "${amount}",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: isSaving ? Colors.green : Colors.red,
                        ),
                  ),
                  tilePadding: EdgeInsets.symmetric(horizontal: 8),
                  controlAffinity: ListTileControlAffinity.leading,
                  children: userExpenses.keys.toList().map((userId) {
                    var userExpense = expenses
                        .categoryExpenses[category]!.userExpenses[userId]!;
                    var amount = userExpense.amount;
                    if (amount == 0) return Container();
                    var userExpenseIds = userExpense.expenses.keys.toList();
                    return ExpansionTile(
                      title: Text(
                        userId.replaceAll("_", " ").toCamelCase(),
                        style:
                            Theme.of(context).textTheme.titleLarge!.copyWith(),
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      leading: CircleAvatar(
                        backgroundColor: Colors.orangeAccent,
                        radius: 18.0,
                        child: Text(
                          "${userId.split("_")[0][0].toUpperCase()}${userId.split("_")[1][0].toUpperCase()}",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      trailing: Text(
                        "${isSaving ? "+" : "-"} "
                        "${amount}",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: isSaving ? Colors.green : Colors.red,
                            ),
                      ),
                      tilePadding: EdgeInsets.all(8).copyWith(left: 16),
                      children: userExpenseIds.map((expenseId) {
                        var expense = userExpense.expenses[expenseId]!;
                        if (expense.amount <= 0) return Container();
                        return ListTile(
                          onTap: () {
                            showExpenseDetails(expense);
                          },
                          contentPadding: EdgeInsets.only(left: 16, right: 8),
                          leading: Container(width: 36),
                          subtitle: Text(
                            DateFormat().format(expense.date),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (expense.notes ?? "").isNotEmpty
                                    ? expense.notes
                                    : expense.category.toCamelCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(),
                              ),
                              Text(
                                "${isSaving ? "+" : "-"} "
                                "${expense.amount}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color:
                                          isSaving ? Colors.green : Colors.red,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Container renderFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 54,
      color: isSaving ? Colors.green.shade900 : Colors.red.shade900,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          MaterialButton(
            onPressed: () {
              isSaving = !isSaving;
              typeOfAddingValue =
                  (isSaving ? SavingsCategories : SpentCategories)[0];
              setState(() => {});
            },
            color: isSaving ? Colors.green : Colors.red,
            minWidth: 8,
            child: Icon(
              isSaving ? Icons.add_rounded : Icons.remove,
              color: Colors.white,
            ),
            elevation: 0.5,
          ),
          Expanded(
            child: TextField(
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.0',
              ),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                padding: EdgeInsets.zero,
                isDense: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                hint: Text(
                  "For what?",
                  textAlign: TextAlign.left,
                ),
                value: typeOfAddingValue,
                alignment: Alignment.centerLeft,
                onChanged:
                    (isSaving ? SavingsCategories : SpentCategories).length == 1
                        ? null
                        : (newValue) {
                            setState(() {
                              typeOfAddingValue = newValue;
                            });
                          },
                items: (isSaving ? SavingsCategories : SpentCategories)
                    .map((e) => e)
                    .map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        category.toCamelCase(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(width: 8),
          MaterialButton(
            onPressed: () => {},
            color: Colors.black,
            minWidth: 0,
            child: const Icon(
              Icons.check_rounded,
              color: Colors.orangeAccent,
            ),
            splashColor: Colors.transparent,
            elevation: 0.5,
          ),
        ],
      ),
    );
  }
}
