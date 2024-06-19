import 'package:intl/intl.dart';

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
  String daysAgo({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(this);
    print((difference.inDays / 7).floor());
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
