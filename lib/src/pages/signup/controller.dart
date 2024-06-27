import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:dio/dio.dart';
import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/src/pages/signup/model.dart';

class SignupController extends BaseController {
  @override
  void initListeners() {}

  SignupController({SignupPageData? data});

  Future<ResponseModel> signup(
    String username,
    String password,
    String firstName,
    String? lastName,
  ) async {
    Response? response = await ApiHandler.post("/auth/signup", {
      "username": username,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
    });
    return ResponseModel.build<dynamic>(
      response,
      (data) => data,
    );
  }
}
