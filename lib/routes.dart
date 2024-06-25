import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/src/pages/signin/page.dart';
import 'package:go_router/go_router.dart';
import 'package:cashcase/src/pages/home/page.dart';

GoRouter router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (_, state) {
      if (AppController.hasTokens()) {
        return HomePage();
      } else {
        return SigninPage();
      }
    },
  ),
]);
