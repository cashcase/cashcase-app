import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/src/pages/set-encryption-key/page.dart';
import 'package:cashcase/src/pages/signin/page.dart';
import 'package:cashcase/src/pages/signup/page.dart';
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
  GoRoute(
    path: '/signup',
    builder: (_, state) {
      return SignupPage();
    },
  ),
  GoRoute(
    path: '/setkey',
    builder: (_, state) {
      return SetKeyPage();
    },
  ),
]);
