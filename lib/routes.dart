import 'package:cashcase/src/pages/categories/page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cashcase/src/pages/home/page.dart';

slideTransition(ValueKey<String> pageKey, Widget page) {
  return CustomTransitionPage(
    key: pageKey,
    child: page,
    transitionDuration: Duration(milliseconds: 250),
    transitionsBuilder: (_, a, __, c) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: a.drive(tween), child: c);
    },
  );
}

GoRouter router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (_, state) {
      return HomePage();
    },
  ),
  GoRoute(
    path: '/categories',
    pageBuilder: (_, state) {
      return slideTransition(state.pageKey, CategoriesPage());
    },
  ),
]);
