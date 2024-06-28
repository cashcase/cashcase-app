enum AppErrorType { NotFound, ApiError }

class AppError {
  final AppErrorType key;
  final String? message;

  const AppError({
    required this.key,
    this.message,
  });
}
