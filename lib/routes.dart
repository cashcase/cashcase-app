import 'package:go_router/go_router.dart';
import 'package:cashcase/src/pages/home/page.dart';

GoRouter router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (_, state) {
      dynamic data = state.extra;
      return HomePage(data: data);
    },
  ),
]);
