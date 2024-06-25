import 'package:cashcase/core/utils/debouncer.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:flutter/material.dart';

class NotificationsController {
  static Debouncer? debouncer;

  static Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.lightGreen;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.warn:
        return Colors.orange;
    }
  }

  static IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_box_rounded;
      case NotificationType.error:
        return Icons.error_outline_rounded;
      case NotificationType.info:
        return Icons.info_rounded;
      case NotificationType.warn:
        return Icons.warning_rounded;
    }
  }
}
