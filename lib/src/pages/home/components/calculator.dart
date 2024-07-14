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
    super.initState();
  }

  Future<void> calculate() async {
    if (tags == previousTags && dateRange == previousDateRange) return;
    if (dateRange.isEmpty) dateRange = [DateTime.now(), DateTime.now()];
    try {
      setState(() => isLoading = true);
      List<String?> keys = await AppDb.getEncryptionKeyOfPair();
      HomePageController.getExpenses(
        dateRange.first!,
        dateRange.last!,
        tags,
      ).then((r) {
        r.fold((err) {
          setState(() => isLoading = false);
          throw err;
        }, (data) {
          double total = 0.0;
          for (var each in data) {
            total += double.parse(Encrypter.decryptData(
              each.amount,
              keys.first!,
            ));
          }
          amount = total.toString();
          setState(() => isLoading = false);
          previousTags = tags;
          previousDateRange = dateRange;
        });
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.orangeAccent,
              ),
              child: Center(
                  child: AnimatedDigitWidget(
                value: double.parse(amount),
                fractionDigits: 2,
                textStyle: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              )),
            ),
            SizedBox(height: 8),
            Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
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
            SizedBox(height: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black,
                            ),
                            child: Theme(
                              data: ThemeData(
                                splashFactory: NoSplash.splashFactory,
                                unselectedWidgetColor: Colors.grey,
                                colorScheme: ColorScheme.dark(
                                  primary: Colors.orangeAccent,
                                  inversePrimary: Colors.orange,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: ChipsChoice<String>.multiple(
                                    wrapped: true,
                                    value: tags,
                                    alignment: WrapAlignment.start,
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
                  Expanded(
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
            )
          ],
        ),
      ),
    );
  }
}
