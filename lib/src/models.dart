import 'package:cashcase/core/utils/errors.dart';
import 'package:either_dart/either.dart';

class DbException implements Exception {
  String message;
  DbException({required this.message});
  String toString() => this.message;
}

class DbResponse<T> {
  bool status;
  T? data;
  String? error;
  DbResponse({
    required this.status,
    required this.data,
    this.error,
  });

  // static Either<AppError, T> respond<T>(
  //   Response? response,
  //   T Function(dynamic data) builder,
  // ) {
  //   try {
  //     if (response?.data['status']) {
  //       return Right(builder(response!.data['data'] ?? {}));
  //     }
  //     throw DbException(message: response?.data['error']);
  //   } on DbException catch (e) {
  //     return Left(AppError(
  //       key: AppErrorType.ApiError,
  //       message: e.toString(),
  //     ));
  //   } catch (e) {
  //     print(e);
  //     return Left(AppError(
  //       key: AppErrorType.ApiError,
  //       message: "Unknown error occurred. Please try again later.",
  //     ));
  //   }
  // }
}
