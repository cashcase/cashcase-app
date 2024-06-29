import 'package:cashcase/core/utils/errors.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:logging/logging.dart';

enum NotificationType { success, error, info, warn }

class NotificationModel {
  String message;
  int milliseconds;
  NotificationType type;
  NotificationModel(this.message, this.type, {this.milliseconds = 5000});
}

class TokenModel {
  late String token;
  late String refreshToken;
  TokenModel({required this.token, required this.refreshToken});

  toJson() {
    return {
      "token": token,
      "refreshToken": refreshToken,
    };
  }

  static TokenModel fromJson(dynamic data) {
    return TokenModel(
      token: data['token'],
      refreshToken: data['refreshToken'],
    );
  }
}

class RequestCallbacks {
  late String? message;
  late Function? onSuccess;
  late Function? onError;
  late Function? onDone;
  RequestCallbacks({this.message, this.onSuccess, this.onError, this.onDone});
}

Logger log = Logger('ResponseModel');

class ResponseModel<T> {
  bool status;
  dynamic error;
  T? data;
  ResponseModel({
    required this.status,
    this.error,
    this.data,
  });

  static ok<T>(T data) {
    return ResponseModel<T>(status: true, data: data);
  }

  static notOk(dynamic error) {
    return ResponseModel(status: false, error: error);
  }

  static Either<AppError, T> respond<T>(
    Response? response,
    T Function(dynamic data) builder,
  ) {
    try {
      if (response?.data['status'])
        return Right(builder(response!.data['data']));
      throw response?.data['error'] ?? response?.data['data'];
    } catch (e) {
      log.shout(e);
      return Left(AppError(
        key: AppErrorType.ApiError,
        message: e.toString(),
      ));
    }
  }
}
