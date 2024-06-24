import 'package:dio/dio.dart';
import 'package:cashcase/core/api/index.dart';
import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/signin/model.dart';

class SigninController extends Controller {
  @override
  void initListeners() {}

  SigninController({SigninPageData? data});

  Future<bool> login(String username, String password) async {
    try {
      Future<Response<dynamic>?> response = ApiHandler.post(
          "/auth/login", {"username": username, "password": password});
      print(response);
      return true;
    } catch (e) {
      return false;
    }
  }
}
