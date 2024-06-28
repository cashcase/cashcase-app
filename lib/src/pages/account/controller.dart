import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/db.dart';
import 'package:dio/dio.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:either_dart/either.dart';

class AccountController extends BaseController {
  AccountController();
  @override
  void initListeners() {}

  void logout() {
    context.once<AppController>().loader.show();
    AppController.clearTokens();
    AppDb.clearUser();
    context.clearAndReplace("/");
    context.once<AppController>().loader.hide();
  }

  Future<Either<AppError, ProfileModel>> getDetails() async {
    Response? response = await ApiHandler.get("/profile");
    return ResponseModel.respond<ProfileModel>(
      response,
      (data) => ProfileModel.fromJson(data),
    );
  }

  Future<Either<AppError, User>> findUser(String username) async {
    Response? response = await ApiHandler.get("/profile/find/$username");
    return ResponseModel.respond<User>(
      response,
      (data) => User.fromJson(data),
    );
  }

  Future<Either<AppError, void>> sendRequest(String username) async {
    Response? response = await ApiHandler.post("/request/$username", {});
    return ResponseModel.respond(
      response,
      (data) => null,
    );
  }
}
