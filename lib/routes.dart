import 'package:cashcase/src/pages/categories/page.dart';
import 'package:go_router/go_router.dart';
import 'package:cashcase/src/pages/home/page.dart';

GoRouter router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (_, state) {
      return HomePage();
    },
  ),
  GoRoute(
    path: '/categories',
    builder: (_, state) {
      return CategoriesPage();
    },
  ),
]);
