import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:dio/dio.dart';
import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/src/pages/signin/model.dart';
import 'package:either_dart/either.dart';

class SigninController extends BaseController {
  @override
  void initListeners() {}

  SigninController({SigninPageData? data});

  Future<Either<AppError, TokenModel>> login(
      String username, String password) async {
    Response? response = await ApiHandler.post(
        "/auth/login", {"username": username, "password": password});
    return ResponseModel.respond<TokenModel>(
      response,
      (data) => TokenModel.fromJson(data),
    );
  }
}
