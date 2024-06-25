import 'package:cashcase/core/utils/models.dart';
import 'package:dio/dio.dart';
import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/signin/model.dart';

class SigninController extends Controller {
  @override
  void initListeners() {}

  SigninController({SigninPageData? data});

  Future<ResponseModel<TokenModel>> login(
      String username, String password) async {
    Response? response = await ApiHandler.post(
        "/auth/login", {"username": username, "password": password});
    return ResponseModel.build<TokenModel>(
      response,
      (data) => TokenModel.fromJson(data),
    );
  }
}
