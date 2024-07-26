import 'package:animated_digit/animated_digit.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:cashcase/src/pages/trends/controller.dart';
import 'package:cashcase/src/pages/trends/model.dart';
import 'package:cashcase/src/utils.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math';

Random random = new Random();

class TrendsView extends StatefulWidget {
  TrendsPageData? data;
  TrendsView({this.data});
  @override
  State<TrendsView> createState() => _ViewState();
}

class _ViewState extends State<TrendsView> {
  List<String> tags = [];
  List<String> options = [];

  TextEditingController thresholdController = TextEditingController();
  String threshold = "";

  DateTime selectedDate = DateTime.now().startOfDay();

  DateTime? highestSpendDate;
  DateTime? lowestSpendDate;

  double highestSpend = 0.0;
  double lowestSpend = 0.0;

  bool loadingTotal = false;
  double totalForDate = 0.0;

  @override
  void initState() {
    options = AppDb.getCategories().keys.toList();
    options.sort((a, b) => a.compareTo(b));
    refresh();
    super.initState();
  }

  refresh() {
    refreshTrends();
    refreshMetrics();
  }

  refreshMetrics() {
    setState(() => loadingTotal = true);
    totalForDate = 0.0;
    context
        .once<TrendsController>()
        .getKeyMetrics(selectedDate, tags)
        .then((metrics) {
      setState(() => loadingTotal = false);
      if (metrics.data == null) return;
      totalForDate = metrics.data!.total;
      highestSpend = metrics.data!.highestSpend;
      highestSpendDate = metrics.data!.highestSpendDate;
      lowestSpend = metrics.data!.lowestSpend;
      lowestSpendDate = metrics.data!.lowestSpendDate;
    });
  }

  thresholdIsNotEmptyOrZero() {
    return threshold.isNotEmpty && double.parse(threshold) > 0;
  }

  refreshTrends() async {
    data = {};
    setState(() => {});
    DbResponse<List<Expense>> response =
        await context.once<TrendsController>().getExpenses(
              DateTime.now()
                  .subtract(
                    Duration(days: 90),
                  )
                  .startOfDay(),
              DateTime.now().endOfDay(),
              tags,
            );
    if (response.data == null ||
        (response.data != null && response.data!.isEmpty)) {
      data = {};
    } else {
      for (Expense each in (response.data ?? [])) {
        var date = DateTime.fromMillisecondsSinceEpoch(
          each.createdOn,
        ).startOfDay();
        data[date] = (data[date] ?? 0) + each.amount.toInt();
      }
    }

    // Setting Trends data
    if (thresholdIsNotEmptyOrZero()) {
      double _threshold = double.parse(thresholdController.text);
      for (var date in data.keys) {
        int _amount = data[date] as int;

        bool green = _amount <= _threshold / 4;
        bool yellow = _amount > _threshold / 4 && _amount <= _threshold * 3 / 4;

        if (_amount >= _threshold) {
          data[date] = 500;
        } else {
          data[date] = green
              ? 0
              : yellow
                  ? 50
                  : 75;
        }
      }
    }

    // Setting Trends colors
    if (thresholdIsNotEmptyOrZero()) {
      colorsets[0] = Colors.green.shade900;
      colorsets[50] = Colors.green.shade900;
      colorsets[75] = Colors.orange.shade800.withOpacity(0.75);
      colorsets[500] = Colors.red.shade900;
    } else {
      colorsets = {0: Colors.red};
    }
  }

  Map<DateTime, int> data = {};
  Map<int, Color> colorsets = {0: Colors.transparent};

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      animationDuration: Duration.zero,
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd MMMM yyyy').format(
                                    selectedDate.toLocal(),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 12,
                                      width: 12,
                                      child: loadingTotal
                                          ? CircularProgressIndicator(
                                              color: Colors.red,
                                              strokeCap: StrokeCap.round,
                                              strokeWidth: 2,
                                            )
                                          : Container(),
                                    ),
                                    SizedBox(width: 16),
                                    Opacity(
                                      opacity: loadingTotal ? 0.2 : 1,
                                      child: AnimatedDigitWidget(
                                        value: totalForDate,
                                        fractionDigits: 2,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward_rounded,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lowestSpendDate == null
                                              ? "---"
                                              : DateFormat('dd MMMM yyyy')
                                                  .format(
                                                  lowestSpendDate!.toLocal(),
                                                ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                color: Colors.grey,
                                              ),
                                        ),
                                        AnimatedDigitWidget(
                                          value: lowestSpend,
                                          fractionDigits: 2,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                color: Colors.green,
                                              ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          highestSpendDate == null
                                              ? "---"
                                              : DateFormat('dd MMMM yyyy')
                                                  .format(
                                                  highestSpendDate!.toLocal(),
                                                ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                color: Colors.grey,
                                              ),
                                        ),
                                        AnimatedDigitWidget(
                                          value: highestSpend,
                                          fractionDigits: 2,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                color: Colors.red,
                                              ),
                                        )
                                      ],
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      HeatMap(
                        startDate: DateTime.now().subtract(Duration(days: 90)),
                        endDate: DateTime.now().endOfDay(),
                        datasets: data,
                        colorMode: thresholdIsNotEmptyOrZero()
                            ? ColorMode.color
                            : ColorMode.opacity,
                        showText: true,
                        scrollable: true,
                        showColorTip: false,
                        colorTipCount: 10,
                        textColor: Colors.white,
                        colorsets: colorsets,
                        defaultColor: Colors.black,
                        size: 30,
                        onClick: (value) {
                          selectedDate = value;
                          refreshMetrics();
                        },
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          child: Center(
                            child: Theme(
                              data: ThemeData(
                                splashFactory: NoSplash.splashFactory,
                                unselectedWidgetColor: Colors.black,
                                colorScheme: ColorScheme.dark(
                                  primary: Colors.orangeAccent,
                                  inversePrimary: Colors.orangeAccent,
                                  outline: Colors.grey,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: ChipsChoice<String>.multiple(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 16,
                                    ),
                                    wrapped: true,
                                    value: tags,
                                    alignment: WrapAlignment.start,
                                    choiceStyle: C2ChipStyle(
                                      backgroundOpacity: 1,
                                    ),
                                    leading: GestureDetector(
                                      onTap: () {
                                        tags.clear();
                                        refresh();
                                      },
                                      child: Container(
                                        width: 40,
                                        child: Icon(
                                          Icons.clear_all_rounded,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    onChanged: (val) {
                                      tags = val;
                                      refresh();
                                    },
                                    choiceItems:
                                        C2Choice.listFrom<String, String>(
                                      source: options,
                                      value: (i, v) => v,
                                      label: (i, v) => v.toCamelCase(),
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 72)
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    height: 72,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: EdgeInsets.all(16),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Spending Limit",
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(color: Colors.white),
                                  ),
                                  Container(
                                    width: 120,
                                    height: 80,
                                    child: TextField(
                                      autofocus: false,
                                      onTapOutside: ((event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      }),
                                      controller: thresholdController,
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: Colors.orangeAccent,
                                          ),
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [amountFormatter],
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0.0',
                                        contentPadding: EdgeInsets.all(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 72,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (double.tryParse(
                                              thresholdController.text) !=
                                          null) {
                                        threshold = thresholdController.text;
                                      } else {
                                        threshold = "";
                                      }
                                      refresh();
                                    },
                                    onDoubleTap: () async {
                                      if (tags.isEmpty) return;
                                      DateTime current = DateTime.now()
                                          .subtract(Duration(days: 90));
                                      int n = 0;
                                      while (n < 91) {
                                        await TrendsController.createExpense(
                                          amount: random.nextInt(50).toDouble(),
                                          type: ExpenseType.SPENT,
                                          category: tags.first,
                                          createdOn: current,
                                        );
                                        current =
                                            current.add(Duration(days: 1));
                                        n = n + 1;
                                      }
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Icon(
                                        Icons.currency_exchange_rounded,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
