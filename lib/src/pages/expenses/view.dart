import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/components/confirm.dart';
import 'package:cashcase/src/components/date-picker.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:either_dart/either.dart';
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
  late Future<Either<AppError, ExpensesByDate>> _future;

  bool isSaving = false;
  late String categoryOfExpenseToAdd;
  DateTime selectedDate = DateTime.now();
  ValueNotifier<ExpenseDatePickerController> expenseDatePickerController =
      ValueNotifier(ExpenseDatePickerController());
  ValueNotifier<bool?> datePickerReady = ValueNotifier(false);
  late Future<List<String?>> _keyGetterFuture;

  Future<Either<AppError, ExpensesByDate>> get expensesFuture {
    var currentUser = AppDb.getCurrentUser();
    var currentConn = AppDb.getCurrentPair();
    var date = selectedDate;
    return context.once<ExpensesController>().getExpense(
          date.startOfDay(),
          date.startOfTmro(),
          currentUser!,
          currentConn?.username,
        );
  }

  Future<Either<AppError, ExpensesByDate>> get expensesEmptyFuture {
    return context.once<ExpensesController>().getEmptyExpense();
  }

  refresh({refreshData = true}) {
    if (refreshData)
      _future = expensesFuture;
    else
      _future = expensesEmptyFuture;
    setState(() => {});
  }

  @override
  void initState() {
    _future = expensesFuture;
    categoryOfExpenseToAdd =
        (isSaving ? SavingsCategories : SpentCategories)[0];
    _keyGetterFuture = AppDb.getEncryptionKeyOfPair();
    super.initState();
  }

  void setDatePickerState(bool? state) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => datePickerReady.value = state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: FutureBuilder(
        future: _keyGetterFuture,
        builder: (context, keySnapshot) {
          if (keySnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text(
                "Fetching expenses...",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white38,
                    ),
              ),
            );
          }
          return Container(
            child: Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: datePickerReady,
                  builder: (context, value, child) {
                    if (value != true) {
                      return Container(
                        width: double.infinity,
                        height: 80,
                        child: Center(
                          child: Text(
                            value == false ? "Loading timeline..." : "",
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Colors.white38,
                                    ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      child: DatePicker(
                        startDate: expenseDatePickerController
                            .value.firstExpenseDate!
                            .startOfDay(),
                        endDate: expenseDatePickerController
                            .value.lastExpenseDate!
                            .startOfDay(),
                        focusedDate: selectedDate,
                        onDateChange: (date, shouldReloadData) {
                          // print("DATE >> ${date.toLocal().startOfDay()}");
                          selectedDate = date.toLocal().startOfDay();
                          refresh(refreshData: shouldReloadData);
                        },
                      ),
                    );
                  },
                ),
                FutureBuilder(
                  future: _future,
                  builder: (context, snapshot) {
                    var isDone =
                        snapshot.connectionState == ConnectionState.done;
                    if (!isDone)
                      return Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeCap: StrokeCap.round,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      );
                    if (isDone && !snapshot.hasData) {
                      setDatePickerState(null);
                      return renderError();
                    }
                    return snapshot.data!.fold(
                      (_) {
                        setDatePickerState(null);
                        return renderError();
                      },
                      (data) {
                        ExpenseListController controller =
                            ExpenseListController(
                          expenses: data.expenses,
                          keys: keySnapshot.data ?? [null, null],
                        );
                        expenseDatePickerController.value.firstExpenseDate =
                            data.firstExpenseDate;
                        expenseDatePickerController.value.lastExpenseDate =
                            data.lastExpenseDate;
                        setDatePickerState(true);
                        return Expanded(
                          child: renderGroupedExpenses(controller),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
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
      String encryptedNotes =
          await Encrypter.encryptData(notes, controller.keys.first ?? "");
      context
          .once<ExpensesController>()
          .editExpenseNotes(expense.id, encryptedNotes)
          .then((r) {
        r.fold((err) {
          context.once<AppController>().stopLoading();
          Navigator.pop(context);
          context.once<AppController>().addNotification(NotificationType.error,
              err.message ?? "Could not edit expense. Please try again later.");
        }, (_) {
          context.once<AppController>().stopLoading();
          Navigator.pop(context);
          controller.update(expense, notes);
        });
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
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${expense.user.firstName.toCamelCase()}",
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
                      enabled: expense.user.username == AppDb.getCurrentUser(),
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
                            onPressed: expense.user.username ==
                                    AppDb.getCurrentUser()
                                ? () => saveExpense(
                                    expense, notesController.text, controller)
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
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderError() {
    return Expanded(
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Unable to get your expenses. \nPlease try again after sometime.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white38,
                ),
          ),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
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
                ),
                if (controller.expenses.isEmpty)
                  Expanded(
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
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.white24,
                                  ),
                        )
                      ],
                    ),
                  ),
                SizedBox(height: 8),
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
                            backgroundColor:
                                (isSaving ? Colors.green : Colors.red)
                                    .withOpacity(0.05),
                            title: Text(
                              categoryExpenses[index].toCamelCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
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
                                    color: isSaving ? Colors.green : Colors.red,
                                  ),
                            ),
                            subtitle: userExpenses.isNotEmpty
                                ? Text(
                                    "${userExpenses.keys.map((e) => "@$e").join(", ")}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  )
                                : null,
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
                              return ExpansionTile(
                                key: ValueKey<String>(userId),
                                title: Text(
                                  "${userExpense.user.firstName} ${userExpense.user.lastName}"
                                      .toCamelCase(),
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
                                  opacity: 1,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.orangeAccent,
                                    radius: 16.0,
                                    child: Text(
                                      userExpense.user.getInitials(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
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
                                        color: isSaving
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                ),
                                tilePadding:
                                    EdgeInsets.symmetric(horizontal: 8),
                                children: expenses.mapIndexed((i, expense) {
                                  return Dismissible(
                                    key: ValueKey<String>("${expense.id}-$i"),
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
                                                  cancelColor: Colors.red,
                                                  onOk: () =>
                                                      Navigator.pop(context),
                                                  onCancel: () {
                                                    context
                                                        .once<AppController>()
                                                        .startLoading();
                                                    context
                                                        .once<
                                                            ExpensesController>()
                                                        .deleteExpense(
                                                            expense.id)
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
                                                    ).whenComplete(() => context
                                                            .once<
                                                                AppController>()
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
                                            .format(expense.createdOn),
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
      decoration: BoxDecoration(
        color: isSaving ? Colors.green.shade900 : Colors.red.shade900,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      height: 60,
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
            minWidth: 8,
            child: Icon(
              isSaving ? Icons.add_rounded : Icons.remove,
              color: Colors.white,
            ),
            elevation: 0.5,
          ),
          Expanded(
            child: TextField(
              autofocus: false,
              onTapOutside: ((event) {
                FocusManager.instance.primaryFocus?.unfocus();
              }),
              controller: amountController,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                  ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*'))
              ],
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
                onChanged:
                    (isSaving ? SavingsCategories : SpentCategories).length == 1
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
              context.once<AppController>().startLoading();
              var parsedAmount = double.tryParse(amountController.text);
              var amount = await Encrypter.encryptData(
                  parsedAmount.toString(), controller.keys.first ?? "");
              if (parsedAmount == null || parsedAmount == 0) {
                return context.once<AppController>().stopLoading();
              }
              context
                  .once<ExpensesController>()
                  .createExpense(
                    amount: amount,
                    type: isSaving ? ExpenseType.SAVED : ExpenseType.SPENT,
                    category: categoryOfExpenseToAdd,
                  )
                  .then((r) {
                r.fold((err) {
                  context.once<AppController>().stopLoading();
                  context.once<AppController>().addNotification(
                      NotificationType.error,
                      err.message ??
                          "Unable to add expense. Please try again later.");
                }, (expense) {
                  context.once<AppController>().stopLoading();
                  context.once<AppController>().addNotification(
                      NotificationType.success, "Added Expense");
                  amountController.text = "";
                  if (selectedDate.sameDay(DateTime.now())) {
                    controller.add(expense);
                    controller.notify();
                  }
                });
              });
            },
            // color: isSaving ? Colors.green.shade800 : Colors.red.shade800,
            minWidth: 0,
            child: const Icon(
              Icons.check_rounded,
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
