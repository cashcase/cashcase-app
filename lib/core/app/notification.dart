import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:flutter/material.dart';

class NotificationsController {
  static List<Color> getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return [Colors.green, Colors.green.shade100, Colors.green.shade900];
      case NotificationType.error:
        return [Colors.red, Colors.red.shade100, Colors.red.shade900];
      case NotificationType.info:
        return [
          Colors.blueGrey,
          Colors.blueGrey.shade100,
          Colors.blueGrey.shade900
        ];
      case NotificationType.warn:
        return [Colors.brown, Colors.brown.shade100, Colors.brown.shade900];
    }
  }

  static IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_rounded;
      case NotificationType.error:
        return Icons.error_outline_rounded;
      case NotificationType.info:
        return Icons.info_rounded;
      case NotificationType.warn:
        return Icons.warning_rounded;
    }
  }
}

class AppNotification extends StatelessWidget {
  NotificationType type;
  String message;
  AppNotification({required this.type, required this.message});
  @override
  Widget build(BuildContext context) {
    List<Color> color = NotificationsController.getNotificationColor(type);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Dismissible(
        direction: DismissDirection.horizontal,
        key: ValueKey<String>("$message-$type"),
        onDismissed: (_) {
          context.once<AppController>().clearNotifications();
        },
        child: Wrap(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.all(8).copyWith(
                  top: MediaQuery.of(context).padding.top + 8,
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color[2],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Icon(
                            NotificationsController.getNotificationIcon(type),
                            color: color[1],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(
                          child: Text(
                            message,
                            textDirection: TextDirection.ltr,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: color[1],
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
