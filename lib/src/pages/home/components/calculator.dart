import 'package:animated_digit/animated_digit.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/home/controller.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

Logger log = Logger('Calculator');

class Calculator extends StatefulWidget {
  DateTime firstDate;
  DateTime lastDate;
  Calculator({required this.firstDate, required this.lastDate});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String amount = "0.0";
  List<String> tags = [];
  List<String> previousTags = [];
  List<String> options = [];

  List<DateTime?> dateRange = [];
  List<DateTime?> previousDateRange = [];

  bool isLoading = false;

  @override
  void initState() {
    options = AppDb.getCategories().keys.toList();
    options.sort((a, b) => a.compareTo(b));
    super.initState();
  }

  Future<void> calculate() async {
    if (tags == previousTags && dateRange == previousDateRange) return;
    if (dateRange.isEmpty) {
      dateRange = [
        DateTime.now().startOfDay(),
        DateTime.now().endOfDay(),
      ];
    }
    try {
      setState(() => isLoading = true);
      HomePageController.getExpenses(
        dateRange.first!.startOfDay(),
        dateRange.last!.startOfTmro(),
        tags,
      ).then((r) {
        if (r.status) {
          double total = 0.0;
          for (var each in r.data!) {
            total += each.amount;
          }
          amount = total.toString();
          setState(() => isLoading = false);
          previousTags = tags;
          previousDateRange = dateRange;
        } else {
          setState(() => isLoading = false);
          throw Error();
        }
      });
    } catch (e) {
      log.severe(e);
      context.once<AppController>().addNotification(
          NotificationType.error, "Unable to get expenses. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => HomePageController(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)
            .copyWith(bottom: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Calculator",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            SizedBox(height: 8),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              child: Opacity(
                opacity: isLoading ? 0.5 : 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 16,
                        width: 16,
                        child: isLoading
                            ? CircularProgressIndicator(
                                strokeCap: StrokeCap.round,
                                color: Colors.orangeAccent,
                                strokeWidth: 2,
                              )
                            : null,
                      ),
                      AnimatedDigitWidget(
                        value: double.parse(amount),
                        fractionDigits: 2,
                        textStyle: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Container(),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 280,
              padding: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                    dayTextStyle:
                        Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                            ),
                    selectedDayTextStyle:
                        Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.black,
                            ),
                    // firstDate: widget.firstDate,
                    lastDate: DateTime.now(),
                    selectedDayHighlightColor: Colors.orangeAccent,
                    calendarType: CalendarDatePicker2Type.range,
                  ),
                  value: dateRange,
                  onValueChanged: (dates) => dateRange = dates,
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                              ),
                            ),
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
                                    wrapped: true,
                                    value: tags,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                    alignment: WrapAlignment.start,
                                    choiceStyle:
                                        C2ChipStyle(backgroundOpacity: 1),
                                    onChanged: (val) =>
                                        setState(() => tags = val),
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
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: calculate,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.orangeAccent,
                        ),
                        height: double.infinity,
                        child: Center(
                            child: Text(
                          "=",
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall!
                              .copyWith(
                                color: Colors.black,
                              ),
                        )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
