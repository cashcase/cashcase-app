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
    context.once<AppController>().startLoading();
    AppController.clearTokens();
    AppDb.clearCurrentUser();
    context.clearAndReplace("/");
    context.once<AppController>().stopLoading();
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

  Future<Either<AppError, void>> acceptRequest(String username) async {
    Response? response = await ApiHandler.put("/request/accept/$username", {});
    return ResponseModel.respond(
      response,
      (data) => null,
    );
  }

  Future<Either<AppError, void>> deleteConnection(String username) async {
    Response? response = await ApiHandler.delete("/connection/$username", {});
    return ResponseModel.respond(
      response,
      (data) => null,
    );
  }

  Future<Either<AppError, void>> rejectRequest(String username) async {
    Response? response = await ApiHandler.put("/request/reject/$username", {});
    return ResponseModel.respond(
      response,
      (data) => null,
    );
  }

  Future<Either<AppError, void>> revokeRequest(String username) async {
    Response? response = await ApiHandler.put("/request/revoke/$username", {});
    return ResponseModel.respond(
      response,
      (data) => null,
    );
  }
}
