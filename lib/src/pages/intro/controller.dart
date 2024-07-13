import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:dio/dio.dart';
import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/src/pages/intro/model.dart';
import 'package:either_dart/either.dart';

class IntroController extends BaseController {
  @override
  void initListeners() {}

  IntroController({IntroPageData? data});

  Future<Either<AppError, bool>> Intro(
    String username,
    String password,
    String firstName,
    String? lastName,
  ) async {
    Response? response = await ApiHandler.post("/auth/Intro", {
      "username": username,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
    });
    return ResponseModel.respond<bool>(
      response,
      (data) => true,
    );
  }
}
