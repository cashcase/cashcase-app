import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/pages/Account/model.dart';

class AccountController extends Controller {
  AccountController({AccountPageData? data});
  @override
  void initListeners() {}

  void logout() {
    context.once<AppController>().loader.show();
    AppController.clearTokens();
    context.clearAndReplace("/");
    context.once<AppController>().loader.hide();
  }
}
