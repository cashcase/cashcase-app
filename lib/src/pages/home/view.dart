import 'package:cashcase/src/components/group-avatar.dart';
import 'package:cashcase/src/pages/account/page.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:cashcase/src/pages/expenses/page.dart';
import 'package:cashcase/src/pages/home/model.dart';
import 'package:flutter/material.dart';
import 'package:cashcase/core/controller.dart';
import 'package:provider/provider.dart';

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
    // HomePageViewModel(
    //   label: 'Reports',
    //   icon: Icons.timeline_rounded,
    //   builder: (c) => ReportsView(),
    // ),
    HomePageViewModel(
      label: 'Expenses',
      icon: Icons.book,
      builder: (c) => ChangeNotifierProvider<ExpensesController>(
        create: (context) => ExpensesController(),
        builder: (_, __) {
          return BaseConsumer<ExpensesController>(
            builder: (controller, app) {
              return ExpensesPage();
            },
          );
        },
      ),
    ),
    HomePageViewModel(
      label: 'Account',
      icon: Icons.account_circle_rounded,
      builder: (c) => AccountPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        .headlineLarge!
                        .copyWith(color: Colors.orangeAccent),
                  )
                ],
              ),
              GroupAvatar(
                users: ExpensesController()
                    .dummyUsers.sublist(0, 1)
                    .map((e) => ExpensesController().getUserInitials(e))
                    .toList(),
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
                  icon: Container(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(e.icon),
                  ),
                  label: e.label,
                );
              }).toList()),
        ),
      ),
    );
  }
}
