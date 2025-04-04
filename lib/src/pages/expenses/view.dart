import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/components/confirm.dart';
import 'package:cashcase/src/components/date-picker.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:cashcase/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ExpensesView extends StatefulWidget {
  ExpensesPageData? data;
  ExpensesView({this.data});
  @override
  State<ExpensesView> createState() => _ViewState();
}

class _ViewState extends State<ExpensesView> {
  late Future<DbResponse<ExpensesByDate>> _expensesFuture;
  late Future<DbResponse<DateLimits>> _datesFuture;

  ValueNotifier listRefresher = ValueNotifier<bool>(false);
  ValueNotifier datesRefresher = ValueNotifier<bool>(false);

  bool isSaving = false;
  late String categoryOfExpenseToAdd;
  DateTime selectedDate = DateTime.now();

  Future<DbResponse<DateLimits>> get dateLimitsFuture {
    return ExpensesController.getDateLimits();
  }

  Future<DbResponse<ExpensesByDate>> get expensesFuture {
    return ExpensesController.getExpenses(
      selectedDate.startOfDay(),
      selectedDate.startOfTmro(),
    );
  }

  Future<DbResponse<ExpensesByDate>> get expensesEmptyFuture async {
    return DbResponse(
      status: true,
      data: ExpensesByDate.empty(),
    );
  }

  refresh({refreshData = true}) {
    _datesFuture = dateLimitsFuture;
    if (refreshData) {
      _expensesFuture = expensesFuture;
    } else {
      _expensesFuture = expensesEmptyFuture;
    }
    setState(() => {});
    return _expensesFuture;
  }

  List<String> getSpentCategories() {
    List<String> categories = [];
    for (var each in AppDb.getCategories().entries) {
      if (each.value) categories.add(each.key);
    }
    return categories;
  }

  @override
  void initState() {
    _expensesFuture = expensesFuture;
    _datesFuture = dateLimitsFuture;
    categoryOfExpenseToAdd =
        (isSaving ? SavingsCategories : getSpentCategories())[0];
    super.initState();
  }

  DatePickerController dateTimelineController = DatePickerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        child: Column(
          children: [
            FutureBuilder(
              future: _datesFuture,
              builder: (context, snapshot) {
                var isDone = snapshot.connectionState == ConnectionState.done;
                if ((isDone && !snapshot.hasData) ||
                    snapshot.data?.status == false) {
                  return renderPlaceholder();
                }
                if (snapshot.data?.status == true) {
                  return ValueListenableBuilder(
                    valueListenable: datesRefresher,
                    builder: (_, __, ___) {
                      return DatePicker(
                        controller: dateTimelineController,
                        startDate: DateTime(2024, 1, 1).startOfDay(),
                        endDate: snapshot.data!.data!.end.startOfDay(),
                        focusedDate: selectedDate,
                        onDateChange: (date, shouldReloadData) {
                          selectedDate = date.startOfDay();
                          _expensesFuture = expensesFuture;
                          listRefresher.value = !listRefresher.value;
                        },
                      );
                    },
                  );
                } else {
                  return renderPlaceholder(message: "Loading Timeline...");
                }
              },
            ),
            ValueListenableBuilder(
              valueListenable: listRefresher,
              builder: (_, __, ___) {
                return FutureBuilder(
                  future: _expensesFuture,
                  builder: (context, snapshot) {
                    var isDone =
                        snapshot.connectionState == ConnectionState.done;
                    if ((isDone && !snapshot.hasData) ||
                        snapshot.data?.status == false) {
                      return renderPlaceholder();
                    }
                    if (snapshot.data?.status == true) {
                      var data = snapshot.data!.data!;
                      ExpenseListController controller = ExpenseListController(
                        expenses: data.expenses,
                      );
                      return Expanded(
                        child: GestureDetector(
                          onHorizontalDragEnd: (drag) {
                            DateTime? newDate;
                            int sensitivity = 25;
                            if ((drag.primaryVelocity ?? 0) > sensitivity) {
                              newDate = selectedDate
                                  .subtract(Duration(days: 1))
                                  .startOfDay();
                            } else if ((drag.primaryVelocity ?? 0) <
                                -sensitivity) {
                              newDate = selectedDate
                                  .add(Duration(days: 1))
                                  .startOfDay();
                            }
                            if (newDate == null) return;
                            if (newDate.isBefore(data.end.startOfTmro()) &&
                                (newDate.isAfter(data.start) ||
                                    newDate.isAtSameMomentAs(
                                      data.start,
                                    ))) {
                              selectedDate = newDate;
                              dateTimelineController.setDate!(selectedDate);
                              datesRefresher.value = !datesRefresher.value;
                              listRefresher.value = !listRefresher.value;
                              _expensesFuture = expensesFuture;
                            }
                          },
                          child: renderGroupedExpenses(controller),
                        ),
                      );
                    } else {
                      return renderPlaceholder(message: "Loading Expenses...");
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future saveExpense(
    Expense expense,
    String notes,
    ExpenseListController controller,
  ) async {
    if (expense.notes != notes) {
      context.once<AppController>().startLoading();
      context
          .once<ExpensesController>()
          .editExpenseNotes(expense, notes)
          .then((r) {
        context.once<AppController>().stopLoading();
        if (r.status) {
          Navigator.pop(context);
          controller.update(expense, notes);
        } else {
          context.once<AppController>().addNotification(NotificationType.error,
              r.error ?? "Could not edit expense. Please try again later.");
        }
      });
    }
    return true;
  }

  Future showExpenseDetails(Expense expense, ExpenseListController controller) {
    var isSaved = expense.type == ExpenseType.SAVED;
    TextEditingController notesController =
        TextEditingController(text: expense.notes ?? "");
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black87,
      builder: (context) => SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.only(bottom: 24),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                          Text(
                            expense.getUser().toCamelCase(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Colors.white,
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
                              color: Colors.white,
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
                          DateFormat().format(
                            DateTime.fromMillisecondsSinceEpoch(
                                    expense.createdOn)
                                .toLocal(),
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white),
                        ),
                        Text(
                          expense.category.toCamelCase(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white),
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
                      autofocus: false,
                      controller: notesController,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                          ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp("[0-9a-zA-Z ]")),
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Notes',
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white24, width: 1.0),
                        ),
                        disabledBorder: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white12, width: 1.0),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLength: 50,
                      maxLines: 5,
                      minLines: 5,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
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
                            onPressed: () => saveExpense(
                                expense, notesController.text, controller),
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
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderPlaceholder({String? message}) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                message ??
                    "Unable to get your expenses. \nPlease try again after sometime.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white38,
                    ),
              ),
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
                SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.1),
                      ),
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
                                  .titleLarge!
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
                                  .titleLarge!
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
                ),
                if (controller.expenses.isEmpty)
                  Expanded(
                    child: Container(
                      color: Colors.transparent, // Needed for swipe to work.
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 80,
                            color: Colors.white12,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "No expenses on this day",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.white24,
                                ),
                          )
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 2),
                if (controller.expenses.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                          bottom: kFloatingActionButtonMargin + 48),
                      shrinkWrap: true,
                      itemCount: categoryExpenses.length,
                      itemBuilder: (context, index) {
                        var category = categoryExpenses[index];
                        var isSaving = groupedExpenses
                            .categoryExpenses[category]!.isSaving;
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
                            dense: true,
                            backgroundColor:
                                (isSaving ? Colors.green : Colors.red)
                                    .withOpacity(0.05),
                            title: Text(
                              categoryExpenses[index].toCamelCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                            ),
                            trailing: Text(
                              "${isSaving ? "+" : "-"} "
                              "${amount.roundTo2()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontSize: 20,
                                    color: isSaving ? Colors.green : Colors.red,
                                  ),
                            ),
                            // subtitle: userExpenses.isNotEmpty
                            //     ? Text(
                            //         "${userExpenses.keys.map((e) {
                            //           if (e == "__self__") return "you";
                            //           return "@$e";
                            //         }).join(", ")}",
                            //         style: Theme.of(context)
                            //             .textTheme
                            //             .titleSmall!
                            //             .copyWith(
                            //               color: Colors.grey.shade600,
                            //             ),
                            //       )
                            //     : null,
                            leading: CircleAvatar(
                              radius: 16.0,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                isSaving
                                    ? Icons.add_rounded
                                    : Icons.remove_rounded,
                                color: isSaving ? Colors.green : Colors.red,
                              ),
                            ),
                            tilePadding: EdgeInsets.symmetric(horizontal: 8),
                            controlAffinity: ListTileControlAffinity.leading,
                            children: userExpenses.keys.toList().map((userId) {
                              var userExpense = userExpenses[userId]!;
                              var amount = userExpense.amount;
                              if (amount == 0) return Container();
                              var expenses = userExpense.expenses;
                              expenses.sort((a, b) => a.amount <= b.amount
                                  ? 1
                                  : -1); // Sorting desc by amount
                              return ExpansionTile(
                                dense: true,
                                key: ValueKey<String>(userId),
                                title: Text(
                                  userExpense.getUser().toCamelCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                                subtitle: Text(
                                  "${expenses.length} transaction${expenses.length == 1 ? "" : "s"}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                leading: Opacity(
                                  opacity: 0,
                                  child: CircleAvatar(
                                      backgroundColor: Colors.orangeAccent,
                                      radius: 16.0,
                                      child: Container()),
                                ),
                                trailing: Text(
                                  "${isSaving ? "+" : "-"} "
                                  "${amount.roundTo2()}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: isSaving
                                            ? Colors.green.shade800
                                            : Colors.red.shade900,
                                      ),
                                ),
                                tilePadding:
                                    EdgeInsets.symmetric(horizontal: 8),
                                children: expenses.mapIndexed((i, expense) {
                                  return Dismissible(
                                    key: ValueKey<String>("${expense.id}-$i"),
                                    direction: DismissDirection.horizontal,
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
                                                .titleMedium!
                                                .copyWith(color: Colors.white),
                                          ),
                                          Icon(
                                            Icons.delete_rounded,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                    confirmDismiss: (direction) {
                                      return showModalBottomSheet(
                                        context: context,
                                        builder: (_) {
                                          return ConfirmationDialog(
                                            message:
                                                "Do you want to \ndelete this expense?",
                                            okLabel: "No",
                                            cancelLabel: "Yes",
                                            cancelColor: Colors.red,
                                            onOk: () => Navigator.pop(context),
                                            onCancel: () {
                                              context
                                                  .once<AppController>()
                                                  .startLoading();
                                              context
                                                  .once<ExpensesController>()
                                                  .deleteExpense(expense.id)
                                                  .then(
                                                (r) {
                                                  if (r.status) {
                                                    Navigator.pop(context);
                                                    controller.remove(r.data!);
                                                    context
                                                        .once<AppController>()
                                                        .addNotification(
                                                            NotificationType
                                                                .success,
                                                            "Expense was deleted!");
                                                  } else {
                                                    context
                                                        .once<AppController>()
                                                        .addNotification(
                                                            NotificationType
                                                                .error,
                                                            r.error ??
                                                                "Could not delete expense. Please try again later");
                                                  }
                                                },
                                              ).whenComplete(() => context
                                                      .once<AppController>()
                                                      .stopLoading());
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: ListTile(
                                      onTap: () => showExpenseDetails(
                                          expense, controller),
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
                                            .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                            expense.createdOn,
                                          ).toLocal(),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
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
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
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
                                                      ? Colors.green.shade800
                                                      : Colors.red.shade900,
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
    var sortedItems = [
      ...(isSaving ? SavingsCategories : getSpentCategories())
    ];
    sortedItems.sort((a, b) => a.toString().compareTo(b.toString()));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isSaving ? Colors.green.shade900 : Colors.red.shade900,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      height: 54,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          MaterialButton(
            color: isSaving ? Colors.green.shade800 : Colors.red.shade600,
            onPressed: () {
              isSaving = !isSaving;
              categoryOfExpenseToAdd =
                  (isSaving ? SavingsCategories : getSpentCategories())[0];
              setState(() => {});
            },
            minWidth: 8,
            child: Icon(
              isSaving ? Icons.add_rounded : Icons.remove,
              color: Colors.white,
            ),
            elevation: 2,
          ),
          Expanded(
            child: TextField(
              autofocus: false,
              onTapOutside: ((event) {
                FocusManager.instance.primaryFocus?.unfocus();
              }),
              controller: amountController,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                  ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [amountFormatter],
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.0',
                  contentPadding: EdgeInsets.all(8)),
            ),
          ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: Container(),
                dropdownColor: Colors.black87,
                value: categoryOfExpenseToAdd,
                alignment: Alignment.centerLeft,
                borderRadius: BorderRadius.circular(8),
                onChanged: (isSaving ? SavingsCategories : getSpentCategories())
                            .length ==
                        1
                    ? null
                    : (newValue) {
                        setState(() => categoryOfExpenseToAdd = newValue!);
                      },
                items: sortedItems.map((e) => e).map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category.toCamelCase(),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(width: 8),
          MaterialButton(
            onPressed: () async {
              var amount = double.tryParse(amountController.text);
              if (amount == null) return;
              context.once<AppController>().startLoading();
              context
                  .once<ExpensesController>()
                  .createExpense(
                    date: selectedDate,
                    amount: amount,
                    type: isSaving ? ExpenseType.SAVED : ExpenseType.SPENT,
                    category: categoryOfExpenseToAdd,
                  )
                  .then((r) {
                context.once<AppController>().stopLoading();
                if (!r.status) {
                  context.once<AppController>().addNotification(
                      NotificationType.error,
                      r.error ??
                          "Unable to create expense. Please try again later.");
                } else {
                  context.once<AppController>().addNotification(
                      NotificationType.success, "Added Expense");
                  amountController.text = "";
                  controller.add(r.data!);
                  controller.notify();
                }
              });
            },
            // color: isSaving ? Colors.green.shade800 : Colors.red.shade800,
            minWidth: 0,
            child: const Icon(
              Icons.add_task_rounded,
              color: Colors.white,
            ),
            splashColor: Colors.transparent,
            elevation: 0,
          ),
        ],
      ),
    );
  }
}
