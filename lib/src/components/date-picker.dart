import 'dart:ffi';
import 'dart:math';

import 'package:cashcase/core/utils/extensions.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        borderRadius: BorderRadius.circular(10),
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        hint: Text(
          "",
          textAlign: TextAlign.left,
        ),
        value: widget.initial,
        isDense: true,
        alignment: Alignment.centerLeft,
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
            value: category,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                category.toCamelCase(),
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }).toList(),
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
  late DateTime lastDate;
  final startYear = 2024;
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
    years = _focusDate.year == startYear
        ? [startYear.toString()]
        : List.generate(
            (_focusDate.year - startYear),
            (i) => (startYear + i).toString(),
          );
    lastDate = DateTime(
      _focusDate.year,
      _focusDate.month,
      _focusDate.year == DateTime.now().year &&
              _focusDate.month == DateTime.now().month
          ? DateTime.now().day
          : DateTime(_focusDate.year, _focusDate.month, 0).day,
    );
    super.initState();
  }

  GlobalKey key = GlobalKey();

  void setNewDate(DateTime date) {
    key = GlobalKey();

    if (date.startOfDay().isAfter(DateTime.now().startOfDay()))
      _focusDate = DateTime.now().startOfDay();
    else
      _focusDate = date;
    var shouldReloadData =
        date.startOfDay().isAfter(widget.startDate.startOfDay()) ||
            date.sameDay(widget.startDate);
    widget.onDateChange(_focusDate, shouldReloadData);
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return EasyInfiniteDateTimeLine(
      key: key,
      selectionMode: const SelectionMode.autoCenter(),
      lastDate: lastDate,
      focusDate: _focusDate,
      firstDate: DateTime(_focusDate.year, _focusDate.month, 1),
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
              Dropdown(
                onChange: (month) {
                  // Check if same month
                  var _month = months.indexWhere((e) => e == month) + 1;
                  if (_focusDate.month == month) return;
                  setNewDate(DateTime(_focusDate.year, _month, _focusDate.day));
                },
                initial: months[_focusDate.month - 1],
                options: months
                    .take(_focusDate.year == DateTime.now().year
                        ? DateTime.now().month
                        : 12)
                    .toList(),
              ),
              Dropdown(
                onChange: (year) {
                  // Check if same year
                  if (_focusDate.year == int.parse(year)) return;
                  setNewDate(DateTime(
                      int.parse(year), _focusDate.month, _focusDate.day));
                },
                initial: _focusDate.year.toString(),
                options: years,
              )
            ],
          ),
        );
      },
      dayProps: const EasyDayProps(
        // You must specify the width in this case.
        width: 64.0,
        // The height is not required in this case.
        height: 64.0,
      ),
      itemBuilder: (
        BuildContext context,
        DateTime date,
        bool isSelected,
        VoidCallback onTap,
      ) {
        return InkResponse(
          splashFactory: NoSplash.splashFactory,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              color: isSelected
                  ? Colors.orangeAccent
                  : Colors.orangeAccent.withOpacity(0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      date.day.toString(),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: isSelected ? Colors.black : null,
                          ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      EasyDateFormatter.shortDayName(date, "en_US"),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: isSelected ? Colors.black : null,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
