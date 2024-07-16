enum NotificationType { success, error, info, warn }

class NotificationModel {
  String message;
  int milliseconds;
  NotificationType type;
  NotificationModel(this.message, this.type, {this.milliseconds = 5000});
}
