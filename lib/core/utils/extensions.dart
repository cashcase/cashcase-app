import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

extension StringConverters on String {
  toCamelCase() {
    if (isEmpty) return '';
    String c = replaceAll('_', " ")
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
    return c
        .split(" ")
        .map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}")
        .toList()
        .join(" ");
  }
}

extension DateTimeExtension on DateTime {
  DateTime startOfToday() => DateTime(this.year, this.month, this.day);
  DateTime startOfTmro() => DateTime(this.year, this.month, this.day + 1);

  String daysAgo({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(this);
    if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inDays == 0) {
      // return 'Today';
    }
    return DateFormat("dd MMMM yyyy").format(this);
  }

  String timeAgo({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(this);
    if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }
}

extension ColorsExt on Color {
  MaterialColor toMaterialColor() {
    final int red = this.red;
    final int green = this.green;
    final int blue = this.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(value, shades);
  }
}

extension ContextExtension on BuildContext {
  T once<T>() {
    return Provider.of<T>(this, listen: false);
  }

  T listen<T>() {
    return Provider.of<T>(this, listen: true);
  }

  void clearAndReplace(String path, {Object? extra}) {
    while (GoRouter.of(this).canPop() == true) {
      GoRouter.of(this).pop();
    }
    GoRouter.of(this).pushReplacement(path, extra: extra);
  }

  void attemptPop() {
    if (canPop()) pop();
  }

  void push(String location) {
    GoRouter.of(this).push(location);
  }
}

extension DoubleExtension on double {
  roundTo2() {
    return double.parse(this.toStringAsFixed(2));
  }
}
