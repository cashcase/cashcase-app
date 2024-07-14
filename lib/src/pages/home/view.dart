import 'dart:io';

import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/account/page.dart';
import 'package:cashcase/src/pages/expenses/page.dart';
import 'package:cashcase/src/pages/home/components/calculator.dart';
import 'package:cashcase/src/pages/home/controller.dart';
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
  late Future<String?> future;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.data?.initialPage ??
        Pages.indexWhere((e) => e.label == 'Expenses');
    pageController = PageController(initialPage: _selectedIndex);
    titleController.text = Pages[_selectedIndex].label;
    future = AppDb.getEncryptionKey();
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
      builder: (c) {
        return ExpensesPage();
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
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          var isDone = snapshot.connectionState == ConnectionState.done;
          var noKey = isDone && snapshot.data == null;
          return SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                if (!isDone)
                  Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        strokeCap: StrokeCap.round,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                if (isDone)
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
                                titleController.text =
                                    Pages[_selectedIndex].label;
                              });
                            },
                            items: Pages.map((e) {
                              return BottomNavigationBarItem(
                                icon: Column(
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: 8, bottom: 4),
                                      child: Icon(e.icon),
                                    ),
                                    if (!Platform.isIOS)
                                      Text(
                                        e.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color:
                                                  Pages[_selectedIndex].label ==
                                                          e.label
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
                if (noKey)
                  Container(
                    padding: EdgeInsets.all(16),
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black87,
                    child: Center(
                      child: Container(
                        height: 400,
                        child: Card(
                          elevation: 1,
                          color: Colors.black,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    borderRadius:
                                        BorderRadius.circular(8).copyWith(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.lock_open_rounded,
                                      size: 60,
                                      color: Colors.red.shade100,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius:
                                        BorderRadius.circular(8).copyWith(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            child: Center(
                                              child: Text(
                                                "You haven't set your\n encryption key!",
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium!
                                                    .copyWith(
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: Theme(
                                              data: ThemeData(
                                                  splashFactory:
                                                      NoSplash.splashFactory),
                                              child: MaterialButton(
                                                color: Colors.red.shade700,
                                                onPressed: () =>
                                                    context.push("/setkey"),
                                                height: 80,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(),
                                                    Text(
                                                      "SET ENCRYPTION KEY",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .keyboard_double_arrow_right,
                                                      size: 30,
                                                      color: Colors.white,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
  }
}
