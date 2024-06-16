enum NotificationType { success, error, info, warn }

class AppNotification {
  String title;
  String? message;
  int milliseconds;
  NotificationType type;
  AppNotification(this.title, this.message, this.type,
      {this.milliseconds = 5000});
}

class TokenModel {
  late String token;
  late String refreshToken;
  TokenModel({required this.token, required this.refreshToken});

  toJson() {
    return {"token": token, "refreshToken": refreshToken};
  }

  static fromJson(dynamic data) {
    return TokenModel(token: data['token'], refreshToken: data['refreshToken']);
  }
}

class RequestCallbacks {
  late String? message;
  late Function? onSuccess;
  late Function? onError;
  late Function? onDone;
  RequestCallbacks({this.message, this.onSuccess, this.onError, this.onDone});
}
