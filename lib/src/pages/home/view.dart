import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/components/group-avatar.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/account/page.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:cashcase/src/pages/expenses/page.dart';
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
      builder: (c) => ExpensesPage(),
    ),
    HomePageViewModel(
      label: 'Account',
      icon: Icons.account_circle_rounded,
      builder: (c) => AccountPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          var isDone = snapshot.connectionState == ConnectionState.done;
          if (isDone)
            context.once<AppController>().loader.hide();
          else
            context.once<AppController>().loader.show();
          var noKey = isDone && snapshot.data == null;
          return SafeArea(
            top: false,
            child: Stack(
              children: [
                if (!isDone)
                  Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
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
                                      .headlineLarge!
                                      .copyWith(color: Colors.orangeAccent),
                                )
                              ],
                            ),
                            GroupAvatar(
                              users: ExpensesController()
                                  .dummyUsers
                                  .sublist(0, 1)
                                  .map((e) =>
                                      ExpensesController().getUserInitials(e))
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
                                titleController.text =
                                    Pages[_selectedIndex].label;
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
                  ),
                if (noKey)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Align(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black87,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            height: 600,
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
                                          size: 100,
                                          color: Colors.red.shade100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade900,
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
                                                    "You haven't set your encryption key!",
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium!
                                                        .copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                      splashFactory: NoSplash
                                                          .splashFactory),
                                                  child: MaterialButton(
                                                    color: Colors.red.shade600,
                                                    onPressed: () =>
                                                        context.push("/setkey"),
                                                    height: 48,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(),
                                                        Text(
                                                          "SET ENCRYPTION KEY",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white,
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
                    ),
                  ),
              ],
            ),
          );
        });
  }
}
