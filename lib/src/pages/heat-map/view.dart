import 'package:animated_digit/animated_digit.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:cashcase/src/pages/heat-map/controller.dart';
import 'package:cashcase/src/pages/heat-map/model.dart';
import 'package:cashcase/src/utils.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math';

Random random = new Random();

class HeatMapView extends StatefulWidget {
  HeatMapPageData? data;
  HeatMapView({this.data});
  @override
  State<HeatMapView> createState() => _ViewState();
}

class _ViewState extends State<HeatMapView> {
  List<String> tags = [];
  List<String> options = [];

  TextEditingController threshold = TextEditingController();

  DateTime selectedDate = DateTime.now().startOfDay();

  bool loadingMap = false;
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
    refreshHeatmap();
    refreshTotalForDate();
  }

  thresholdIsNotEmptyOrZero() {
    return threshold.text.isNotEmpty && double.parse(threshold.text) > 0;
  }

  refreshTotalForDate() {
    setState(() => loadingTotal = true);
    context
        .once<HeatMapController>()
        .getTotalForDate(selectedDate, tags)
        .then((response) {
      totalForDate = response.data ?? 0.0;
      setState(() => loadingTotal = false);
    });
  }

  refreshHeatmap() async {
    data = {};
    setState(() => loadingMap = true);
    DbResponse<List<Expense>> response =
        await context.once<HeatMapController>().getExpenses(
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

    // Setting heatmap data
    if (thresholdIsNotEmptyOrZero()) {
      double _threshold = double.parse(threshold.text);
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

    // Setting heatmap colors
    if (thresholdIsNotEmptyOrZero()) {
      colorsets[0] = Colors.green.shade900;
      colorsets[50] = Colors.green.shade900;
      colorsets[75] = Colors.orange.shade800.withOpacity(0.75);
      colorsets[500] = Colors.red.shade900;
    } else {
      colorsets = {0: Colors.red};
    }
    setState(() => loadingMap = false);
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
            vertical: 8,
          ),
          child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
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
                        color: Colors.transparent.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
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
                  ),
                  SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        child: Opacity(
                          opacity: loadingMap ? 0.15 : 1,
                          child: HeatMap(
                            startDate:
                                DateTime.now().subtract(Duration(days: 90)),
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
                            size: MediaQuery.of(context).size.height / 25,
                            onClick: (value) {
                              selectedDate = value;
                              setState(() => {});
                              refreshTotalForDate();
                            },
                          ),
                        ),
                      ),
                      if (loadingMap)
                        Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        )
                    ],
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
                                choiceItems: C2Choice.listFrom<String, String>(
                                  source: options,
                                  value: (i, v) => v,
                                  label: (i, v) => v.toCamelCase(),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 62,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  controller: threshold,
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Colors.orangeAccent,
                                      ),
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  inputFormatters: [amountFormatter],
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0.0',
                                      contentPadding: EdgeInsets.all(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: null,
                        onDoubleTap: () async {
                          if (tags.isEmpty) return;
                          DateTime current =
                              DateTime.now().subtract(Duration(days: 90));
                          int n = 0;
                          while (n < 91) {
                            await context
                                .once<HeatMapController>()
                                .createExpense(
                                  amount: random.nextInt(50).toDouble(),
                                  type: ExpenseType.SPENT,
                                  category: tags.first,
                                  createdOn: current,
                                );
                            current = current.add(Duration(days: 1));
                            n = n + 1;
                          }
                        },
                        child: GestureDetector(
                          onTap: refresh,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(
                              Icons.currency_exchange_rounded,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
