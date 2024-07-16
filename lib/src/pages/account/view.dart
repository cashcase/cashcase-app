import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:flutter/material.dart';

class AccountView extends StatefulWidget {
  AccountPageData? data;
  AccountView({this.data});
  @override
  State<AccountView> createState() => _ViewState();
}

class _ViewState extends State<AccountView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      animationDuration: Duration.zero,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 24),
                renderCategoriesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector renderCategoriesSection() {
    return GestureDetector(
      onTap: () => context.push("/categories"),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        height: 36,
        child: Card(
          color: Colors.transparent,
          margin: EdgeInsets.zero,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Manage Categories",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                    ),
              ),
              Icon(
                Icons.category_rounded,
                color: Colors.orangeAccent,
              )
            ],
          ),
        ),
      ),
    );
  }
}
