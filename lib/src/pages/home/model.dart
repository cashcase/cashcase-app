import 'package:flutter/material.dart';

class HomePageData {
  int initialPage;
  HomePageData({this.initialPage = 0});
}

class HomePageViewModel {
  String label;
  IconData icon;
  Widget Function(BuildContext) builder;
  HomePageViewModel({
    required this.builder,
    required this.label,
    required this.icon,
  });
}
