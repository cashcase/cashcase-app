import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/components/confirm.dart';
import 'package:cashcase/src/components/date-picker.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ExpensesView extends StatefulWidget {
  @override
  State<ExpensesView> createState() => _ViewState();
}

class _ViewState extends State<ExpensesView> {
  late Future<Either<AppError, List<Expense>>> _future;

  bool isSaving = false;
  late String categoryOfExpenseToAdd;
  DateTime selectedDate = DateTime.now();

  Future<Either<AppError, List<Expense>>> get expensesFuture {
    var currentUser = AppDb.getCurrentUser();
    var currentConn = AppDb.getCurrentConnection();
    return context.once<ExpensesController>().getExpense(
          selectedDate.startOfToday(),
          selectedDate.startOfTmro(),
          currentUser!,
          currentConn?.username,
        );
  }

  refresh() {
    _future = expensesFuture;
    setState(() => {});
  }

  @override
  void initState() {
    _future = expensesFuture;
    categoryOfExpenseToAdd =
        (isSaving ? SavingsCategories : SpentCategories)[0];
    super.initState();
  }

  Future saveExpense(
    Expense expense,
    String notes,
    ExpenseListController controller,
  ) async {
    if (expense.notes != notes) {
      context
          .once<ExpensesController>()
          .editExpenseNotes(expense.id, notes)
          .then((r) {
        r.fold((err) {
          Navigator.pop(context);
          context.once<AppController>().addNotification(NotificationType.error,
              err.message ?? "Could not edit expense. Please try again later.");
        }, (_) {
          Navigator.pop(context);
          controller.update(expense, notes);
        });
      });
    }
    return true;
  }

  Future showExpenseDetails(Expense expense, ExpenseListController controller) {
    var isSaved = expense.type == ExpenseType.SAVED;
    print(expense.notes);
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
                    child: Stack(
                      children: [
                        Row(
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
                                    expense.user.getInitials(),
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
                            DateFormat().format(expense.createdOn),
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
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        enabled:
                            expense.user.username == AppDb.getCurrentUser(),
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
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 5,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Theme(
                        data: ThemeData(splashFactory: NoSplash.splashFactory),
                        child: Row(
                          children: [
                            Expanded(
                              child: MaterialButton(
                                color: Colors.black,
                                onPressed: () => Navigator.pop(context),
                                child: Center(
                                  child: Text(
                                    "Back",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: MaterialButton(
                                color: Colors.orangeAccent,
                                onPressed: expense.user.username ==
                                        AppDb.getCurrentUser()
                                    ? () => saveExpense(expense,
                                        notesController.text, controller)
                                    : null,
                                disabledColor: Colors.grey,
                                child: Center(
                                  child: Text(
                                    "Save",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget renderError() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          "Unable to get your expenses. \nPlease try again after sometime.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            DatePicker(
              focusedDate: selectedDate,
              onDateChange: (date) {
                selectedDate = date;
                refresh();
              },
            ),
            FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                var isDone = snapshot.connectionState == ConnectionState.done;
                if (!isDone)
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.orangeAccent,
                      ),
                    ),
                  );
                if (isDone && !snapshot.hasData) return renderError();
                return snapshot.data!.fold(
                  (_) => renderError(),
                  (expenses) {
                    ExpenseListController controller =
                        ExpenseListController(expenses: expenses);
                    return Expanded(
                      child: renderGroupedExpenses(controller),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  StatefulBuilder renderGroupedExpenses(ExpenseListController controller) {
    return StatefulBuilder(builder: (context, innerSetState) {
      controller.setRefresher(innerSetState);
      var groupedExpenses = controller.getGroupedExpenses();
      var categoryExpenses = groupedExpenses.categoryExpenses.keys.toList();
      return Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => refresh(),
            color: Colors.orangeAccent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 8),
                Container(
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  color: Colors.green.shade800,
                                ),
                          ),
                          Text(
                            "+ ${groupedExpenses.totalSaved.roundTo2()}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
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
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  color: Colors.red.shade800,
                                ),
                          ),
                          Text(
                            "- ${groupedExpenses.totalSpent.roundTo2()}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Colors.red.shade800,
                                ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                        bottom: kFloatingActionButtonMargin + 48),
                    shrinkWrap: true,
                    itemCount: categoryExpenses.length,
                    itemBuilder: (context, index) {
                      var category = categoryExpenses[index];
                      var isSaving =
                          groupedExpenses.categoryExpenses[category]!.isSaving;
                      var amount =
                          groupedExpenses.categoryExpenses[category]!.amount;
                      if (amount == 0) return Container();
                      var userExpenses = groupedExpenses
                          .categoryExpenses[category]!.userExpenses;
                      return Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          backgroundColor: Colors.black.withOpacity(0.25),
                          collapsedIconColor:
                              isSaving ? Colors.green : Colors.red,
                          iconColor: isSaving ? Colors.green : Colors.red,
                          title: Text(
                            categoryExpenses[index].toCamelCase(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(),
                          ),
                          trailing: Text(
                            "${isSaving ? "+" : "-"} "
                            "${amount.roundTo2()}",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  color: isSaving ? Colors.green : Colors.red,
                                ),
                          ),
                          subtitle: userExpenses.isNotEmpty
                              ? Text(
                                  "${userExpenses.keys.join(", ")}",
                                  style: TextStyle(color: Colors.grey.shade600),
                                )
                              : null,
                          leading: Icon(isSaving
                              ? Icons.add_rounded
                              : Icons.remove_rounded),
                          tilePadding: EdgeInsets.symmetric(horizontal: 8),
                          controlAffinity: ListTileControlAffinity.leading,
                          children: userExpenses.keys.toList().map((userId) {
                            var userExpense = userExpenses[userId]!;
                            var amount = userExpense.amount;
                            if (amount == 0) return Container();
                            var userExpenseIds =
                                userExpense.expenses.keys.toList();
                            return ExpansionTile(
                              title: Text(
                                "${userExpense.user.firstName} ${userExpense.user.lastName}"
                                    .toCamelCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(),
                              ),
                              subtitle: Text(
                                "${userExpenseIds.length} transaction${userExpenseIds.length == 1 ? "" : "s"}",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              controlAffinity: ListTileControlAffinity.trailing,
                              leading: CircleAvatar(
                                backgroundColor: Colors.orangeAccent,
                                radius: 18.0,
                                child: Text(
                                  userExpense.user.getInitials(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              trailing: Text(
                                "${isSaving ? "+" : "-"} "
                                "${amount.roundTo2()}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color:
                                          isSaving ? Colors.green : Colors.red,
                                    ),
                              ),
                              tilePadding: EdgeInsets.symmetric(horizontal: 8)
                                  .copyWith(left: 8),
                              children:
                                  userExpenseIds.mapIndexed((i, expenseId) {
                                var expense = userExpense.expenses[expenseId]!;
                                if (expense.amount <= 0) return Container();
                                return Dismissible(
                                  direction: expense.user.username !=
                                          AppDb.getCurrentUser()
                                      ? DismissDirection.none
                                      : DismissDirection.horizontal,
                                  background: Container(
                                    color: Colors.red.shade800,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.delete_rounded,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Delete",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Icon(
                                          Icons.delete_rounded,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                  ),
                                  key: Key(expense.id),
                                  confirmDismiss: expense.user.username !=
                                          AppDb.getCurrentUser()
                                      ? null
                                      : (direction) {
                                          return showModalBottomSheet(
                                            context: context,
                                            builder: (_) {
                                              return ConfirmationDialog(
                                                message:
                                                    "Do you want to \ndelete this expense?",
                                                okLabel: "No",
                                                cancelLabel: "Yes",
                                                onOk: () =>
                                                    Navigator.pop(context),
                                                onCancel: () {
                                                  context
                                                      .once<
                                                          ExpensesController>()
                                                      .deleteExpense(expense.id)
                                                      .then(
                                                    (r) {
                                                      r.fold(
                                                        (err) {
                                                          context
                                                              .once<
                                                                  AppController>()
                                                              .addNotification(
                                                                  NotificationType
                                                                      .error,
                                                                  err.message ??
                                                                      "Could not delete expense. Please try again later");
                                                        },
                                                        (_) {
                                                          Navigator.pop(
                                                              context);
                                                          controller.remove(
                                                              expense.id);
                                                          context
                                                              .once<
                                                                  AppController>()
                                                              .addNotification(
                                                                  NotificationType
                                                                      .success,
                                                                  "Expense was deleted!");
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                  child: ListTile(
                                    onTap: () =>
                                        showExpenseDetails(expense, controller),
                                    contentPadding:
                                        EdgeInsets.only(left: 60, right: 8),
                                    leading: Text(
                                      "${i + 1}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    subtitle: Text(
                                      DateFormat('dd MMMM yyyy hh:mm a')
                                          .format(expense.createdOn.toLocal()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            (expense.notes ?? "").isNotEmpty
                                                ? expense.notes
                                                : expense.category
                                                    .toCamelCase(),
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Text(
                                          "${isSaving ? "+" : "-"} "
                                          "${expense.amount}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: isSaving
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                        ),
                                      ],
                                    ),
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
            ),
          ),
          Positioned(
            bottom: 0,
            child: renderFooter(controller),
          ),
        ],
      );
    });
  }

  TextEditingController amountController = TextEditingController();

  Container renderFooter(ExpenseListController controller) {
    var sortedItems = [...(isSaving ? SavingsCategories : SpentCategories)];
    sortedItems.sort((a, b) => a.toString().compareTo(b.toString()));
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
              categoryOfExpenseToAdd =
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
              controller: amountController,
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
                value: categoryOfExpenseToAdd,
                alignment: Alignment.centerLeft,
                onChanged:
                    (isSaving ? SavingsCategories : SpentCategories).length == 1
                        ? null
                        : (newValue) {
                            setState(() => categoryOfExpenseToAdd = newValue!);
                          },
                items: sortedItems.map((e) => e).map((category) {
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
            onPressed: () {
              var parsedAmount = double.tryParse(amountController.text);
              if (parsedAmount == null) return;
              context
                  .once<ExpensesController>()
                  .createExpense(
                    amount: parsedAmount.toString(),
                    type: isSaving ? ExpenseType.SAVED : ExpenseType.SPENT,
                    category: categoryOfExpenseToAdd,
                  )
                  .then((r) {
                context.once<AppController>().loader.hide();
                r.fold((err) {
                  context.once<AppController>().addNotification(
                      NotificationType.success,
                      err.message ??
                          "Unable to add expense. Please try again later.");
                }, (expense) {
                  context.once<AppController>().addNotification(
                      NotificationType.success, "Added Expense");
                  amountController.text = "";
                  controller.expenses.add(expense);
                });
              });
            },
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
