import 'dart:io';

import 'package:cashcase/src/pages/account/page.dart';
import 'package:cashcase/src/pages/checklist/page.dart';
import 'package:cashcase/src/pages/expenses/page.dart';
import 'package:cashcase/src/pages/heat-map/page.dart';
import 'package:cashcase/src/pages/home/components/calculator.dart';
import 'package:cashcase/src/pages/home/model.dart';
import 'package:flutter/material.dart';

class HomePageView extends StatefulWidget {
  HomePageData? data;
  HomePageView({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  State<HomePageView> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageView> {
  late int _selectedIndex;
  late final PageController pageController;
  final TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.data?.initialPage ??
        Pages.indexWhere((e) => e.label == 'Expenses');
    pageController = PageController(initialPage: _selectedIndex);
    titleController.text = Pages[_selectedIndex].label;
  }

  List<HomePageViewModel> Pages = [
    HomePageViewModel(
      label: 'Trends',
      icon: Icons.pie_chart_rounded,
      builder: (c) => HeatMapPage(),
    ),
    HomePageViewModel(
      label: 'Expenses',
      icon: Icons.book,
      builder: (c) {
        return ExpensesPage();
      },
    ),
    HomePageViewModel(
      label: 'Checklist',
      icon: Icons.checklist_rounded,
      builder: (c) {
        return ChecklistPage();
      },
    ),
    HomePageViewModel(
      label: 'Account',
      icon: Icons.account_circle_rounded,
      builder: (c) {
        return AccountPage();
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Pages[_selectedIndex].icon,
                          color: Colors.orangeAccent,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          titleController.text,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: Colors.orangeAccent),
                        )
                      ],
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.calculate_rounded,
                        color: Colors.orangeAccent,
                        size: 28,
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.8,
                              child: Calculator(
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now(),
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            body: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: pageController,
              children: Pages.map((e) {
                return e.builder(context);
              }).toList(),
            ),
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                shadowColor: Colors.white,
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.black54,
                        blurRadius: 15.0,
                        offset: Offset(0.0, 0.75))
                  ],
                ),
                child: BottomNavigationBar(
                    elevation: 1,
                    selectedItemColor: Colors.orangeAccent,
                    type: BottomNavigationBarType.fixed,
                    iconSize: 28,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    currentIndex: _selectedIndex,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                        pageController.jumpToPage(index);
                        titleController.text = Pages[_selectedIndex].label;
                      });
                    },
                    items: Pages.map((e) {
                      return BottomNavigationBarItem(
                        icon: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 8, bottom: 4),
                              child: Icon(
                                e.icon,
                                size: 24,
                              ),
                            ),
                            if (!Platform.isIOS)
                              Text(
                                e.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color:
                                          Pages[_selectedIndex].label == e.label
                                              ? Colors.orangeAccent
                                              : Colors.white,
                                    ),
                              )
                          ],
                        ),
                        label: Platform.isIOS ? e.label : "",
                      );
                    }).toList()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
