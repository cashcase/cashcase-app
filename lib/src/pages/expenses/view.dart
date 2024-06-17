import 'dart:math';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/components/date-picker.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:flutter/material.dart';
import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:flutter/services.dart';

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
  late Future<ExpensesResponse?> _future;

  @override
  void initState() {
    super.initState();
    _future = ExpensesController().getExpenses();

    const users = [
      ["Abhimanyu", "Pandian"],
      ["Divyaa", "Subramaniam"]
    ];

    expenses = List.generate(25, (i) {
      final _random = new Random();
      var category = (isSaving ? SavingsCategories : SpentCategories)[_random
          .nextInt((isSaving ? SavingsCategories : SpentCategories).length)];
      var type = ExpenseType.values[_random.nextInt(ExpenseType.values.length)];
      var oneOfTwo = _random.nextInt(2);
      var firstName = users[oneOfTwo][0];
      var lastName = users[oneOfTwo][1];
      return Expense.fromJson({
        "type": type,
        "category": category,
        "amount": (100 * i).toDouble(),
        "date": DateTime.now(),
        "user": {
          "id": "$firstName$lastName",
          "firstName": firstName,
          "lastName": lastName,
        }
      });
    });
    selectedValue = (isSaving ? SavingsCategories : SpentCategories)[0];
  }

  bool isSaving = false;
  late String? selectedValue;

  late List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ExpensesResponse?>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          return Container(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  child: renderHeader(snapshot),
                ),
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: DatePicker(),
                      ),
                      Expanded(
                        child: renderExpensesList(
                          restructureExpense(expenses),
                        ),
                      )
                    ],
                  ),
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

  Map<String, CollectedExpense> restructureExpense(List<Expense> expenses) {
    Map<String, CollectedExpense> restructured = {};
    expenses.forEach((each) {
      if (!restructured.containsKey(each.category))
        restructured[each.category] =
            CollectedExpense(expenses: [], type: each.type, total: 0);
      restructured[each.category]!.expenses.add(each);
      restructured[each.category]!.total += each.amount;
    });
    return restructured;
  }

  ListView renderExpensesList(Map<String, CollectedExpense> expenses) {
    return ListView.builder(
        padding:
            const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        shrinkWrap: true,
        itemCount: expenses.keys.length,
        itemBuilder: (context, index) {
          var category = expenses.keys.toList()[index];
          var isSaving = SavingsCategories.contains(category);
          return ExpansionTile(
            title: Text(
              expenses.keys.toList()[index].toCamelCase(),
              style: Theme.of(context).textTheme.titleLarge!.copyWith(),
            ),
            trailing: Text(
              "${isSaving ? "+" : "-"} "
              "${expenses[category]!.total}",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: isSaving ? Colors.green : Colors.red,
                  ),
            ),
            tilePadding: EdgeInsets.all(8),
            controlAffinity: ListTileControlAffinity.leading,
            children: expenses[category]!.expenses.map((each) {
              return ListTile(
                contentPadding: EdgeInsets.only(left: 16, right: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  radius: 18.0,
                  child: Text(
                    "${each.user.firstName[0].toUpperCase()}${each.user.lastName[0].toUpperCase()}",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                subtitle: Text(
                  each.date.toString().split(" ")[0],
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      each.category.toCamelCase(),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(),
                    ),
                    Text(
                      "${isSaving ? "+" : "-"} "
                      "${each.amount}",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: isSaving ? Colors.green : Colors.red,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        });
  }

  Container renderHeader(AsyncSnapshot<ExpensesResponse?> snapshot) {
    return Container(
      height: 40,
      color: Colors.black87,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Today",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "+ ${snapshot.data!.saved}",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(width: 10),
              Text(
                "- ${snapshot.data!.spent}",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
              )
            ],
          )
        ],
      ),
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
              selectedValue =
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
                value: selectedValue,
                alignment: Alignment.centerLeft,
                onChanged:
                    (isSaving ? SavingsCategories : SpentCategories).length == 1
                        ? null
                        : (newValue) {
                            setState(() {
                              selectedValue = newValue;
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
