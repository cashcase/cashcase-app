import 'package:cashcase/core/app/controller.dart';
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

  static showBanner(AppNotification notification, {bool autoDismiss = true}) {
  //   BuildContext context = AppController().context;
  //   Color color = getNotificationColor(notification.type);
  //   ScaffoldMessenger.of(context).clearMaterialBanners();
  //   ScaffoldMessenger.of(context).showMaterialBanner(
  //     MaterialBanner(
  //       padding: const EdgeInsets.all(10),
  //       content: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             notification.title,
  //             style: Theme.of(context)
  //                 .textTheme
  //                 .bodyMedium!
  //                 .copyWith(color: Colors.white),
  //           ),
  //           if (notification.message != null)
  //             Text(
  //               notification.message!,
  //               style: Theme.of(context)
  //                   .textTheme
  //                   .bodySmall!
  //                   .copyWith(color: Colors.white),
  //             )
  //         ],
  //       ),
  //       leading:
  //           Icon(getNotificationIcon(notification.type), color: Colors.white),
  //       backgroundColor: color,
  //       actions: <Widget>[
  //         GestureDetector(
  //           onTap: ScaffoldMessenger.of(context).hideCurrentMaterialBanner,
  //           child: const Text(
  //             'Dismiss',
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (!autoDismiss) return;
  //   debouncer = Debouncer(milliseconds: notification.milliseconds).run(() {
  //     try {
  //       if (debouncer != null) debouncer!.cancel();
  //       ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  //     } finally {}
  //   });
  }
}
