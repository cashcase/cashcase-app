import 'dart:math';

import 'package:cashcase/core/utils/extensions.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  String initial;
  List<String> options;
  Function(String) onChange;
  Dropdown({
    required this.options,
    required this.initial,
    required this.onChange,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          padding: EdgeInsets.symmetric(vertical: 4),
          dropdownColor: Colors.black87,
          value: widget.initial,
          isDense: true,
          icon: Container(),
          alignment: Alignment.topLeft,
          onChanged: (newValue) {
            setState(() {
              if (newValue != null) {
                widget.initial = newValue;
                widget.onChange(newValue);
              }
            });
          },
          items: widget.options.map((category) {
            return DropdownMenuItem<String>(
              alignment: AlignmentDirectional.center,
              value: category,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  category.toCamelCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class DatePicker extends StatefulWidget {
  DateTime focusedDate;
  DateTime startDate;
  DateTime endDate;
  Function(DateTime, bool) onDateChange;
  DatePicker({
    required this.onDateChange,
    required this.focusedDate,
    required this.startDate,
    required this.endDate,
  });
  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime _focusDate;
  // late DateTime lastDate;
  late int startYear;
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  late final List<String> years;

  @override
  void initState() {
    _focusDate = widget.focusedDate;
    startYear = widget.startDate.year;
    years = List.generate(
      (DateTime.now().year - startYear) + 1,
      (i) => (startYear + i).toString(),
    );
    super.initState();
  }

  GlobalKey key = GlobalKey();

  void setNewDate(DateTime date, {bool? dontRefresh}) {
    key = GlobalKey();

    if (date.startOfDay().isAfter(DateTime.now().startOfDay()))
      _focusDate = DateTime.now().startOfDay();
    else
      _focusDate = date;
    var shouldReloadData =
        (date.startOfDay().isAfter(widget.startDate.startOfDay()) ||
            date.sameDay(widget.startDate));
    if (dontRefresh != true) widget.onDateChange(_focusDate, shouldReloadData);
    setState(() => {});
  }

  List<String> getMonths() {
    if (_focusDate.year == widget.endDate.year) {
      return months.sublist(0, widget.endDate.month);
    }
    if (_focusDate.year < widget.endDate.year && _focusDate.year > startYear) {
      return months;
    }
    return months.sublist(
      widget.startDate.month - 1,
      12,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EasyInfiniteDateTimeLine(
      key: key,
      selectionMode: const SelectionMode.autoCenter(),
      lastDate: DateTime.now(),
      focusDate: _focusDate,
      firstDate: widget.startDate,
      onDateChange: (date) {
        // Check if same day
        if (_focusDate.startOfDay() == date.startOfDay()) return;
        setNewDate(date);
      },
      headerBuilder: (context, date) {
        return Container(
          padding: EdgeInsets.only(top: 8, bottom: 12, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setNewDate(
                    DateTime.now().startOfDay(),
                    dontRefresh: _focusDate.sameDay(
                      DateTime.now().startOfDay(),
                    ),
                  );
                },
                child: Icon(
                  Icons.today_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setNewDate(
                    _focusDate,
                    dontRefresh: true, // just scroll to date
                  );
                },
                child: Container(
                  width: 60,
                  height: 34,
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
                    child: Text(
                      "".getNumberSuffix(date.day),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white38,
                          ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Dropdown(
                  onChange: (month) {
                    // Check if same month
                    var _month = months.indexWhere((e) => e == month) + 1;
                    if (_focusDate.month == _month) return;
                    _month = widget.startDate.year == _focusDate.year
                        ? max(widget.startDate.month, _month)
                        : _month;
                    var day = widget.startDate.year == _focusDate.year
                        ? max(widget.startDate.day, _focusDate.day)
                        : _focusDate.day;
                    setNewDate(DateTime(_focusDate.year, _month, day));
                  },
                  initial: months[_focusDate.month - 1],
                  options: getMonths(),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Dropdown(
                  onChange: (year) {
                    // Check if same year
                    if (_focusDate.year == int.parse(year)) return;
                    var date = DateTime(
                      int.parse(year),
                      year == startYear
                          ? max(_focusDate.month, widget.startDate.month)
                          : _focusDate.month,
                      _focusDate.day,
                    );
                    if (date.isBefore(widget.startDate)) {
                      date = widget.startDate;
                    }
                    setNewDate(date);
                  },
                  initial: _focusDate.year.toString(),
                  options: years,
                ),
              )
            ],
          ),
        );
      },
      dayProps: const EasyDayProps(
        width: 54.0,
        height: 80.0,
      ),
      itemBuilder: (
        BuildContext context,
        DateTime date,
        bool isSelected,
        VoidCallback onTap,
      ) {
        var color = isSelected ? Colors.black : Colors.white;
        var isBeforeFirstExpense = date.startOfDay().isBefore(widget.startDate);
        return InkResponse(
          onTap: isBeforeFirstExpense ? null : onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Opacity(
              opacity: isBeforeFirstExpense ? 0.25 : 1,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orangeAccent : Colors.black26,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        EasyDateFormatter.shortMonthName(date, "en_US"),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: color,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        date.day.toString(),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: color,
                            ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        EasyDateFormatter.shortDayName(date, "en_US"),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: color,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
