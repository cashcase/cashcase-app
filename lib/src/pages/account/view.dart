import 'dart:io';

import 'package:cashcase/src/components/confirm.dart';
import 'package:cashcase/src/pages/categories/page.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:cashcase/src/pages/home/controller.dart';
import 'package:path/path.dart' as p;
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/connection.dart';
import 'package:cashcase/src/pages/account/controller.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:sqflite/sqflite.dart';

class AccountView extends StatefulWidget {
  AccountPageData? data;
  AccountView({this.data});
  @override
  State<AccountView> createState() => _ViewState();
}

class _ViewState extends State<AccountView> {
  // late final Peer peer;
  // DataConnection? conn;

  TextEditingController to = TextEditingController();
  TextEditingController msg = TextEditingController();
  @override
  void initState() {
    // peer = Peer(
    //     options: PeerOptions(
    //   debug: LogLevel.All,
    // ));
    // peer.on('open').listen((id) {
    //   setState(() => message = id);
    // });
    // peer.on("data").listen((data) {
    //   setState(() => message = data);
    // });

    // peer.on<DataConnection>("connection").listen((c) {
    //   setState(() => message = "Connected to ${c.peer}");
    // });
    super.initState();
  }

  Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);

    return unit8List;
  }

  List<Widget> divider() {
    return [
      Divider(
        color: Colors.transparent,
      ),
    ];
  }

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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  renderCategoriesSection(),
                  ...divider(),
                  renderExportSection(),
                  ...divider(),
                  renderImportSection(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 24,
                      width: 24,
                      child: Image.asset('assets/logo.png'),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "CASHCASE v${AppController.version} (${AppController.buildNumber})",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white24,
                      ),
                    ),
                  ],
                ),
              )
              // ...divider(),
              // renderSyncSection(),
              // Container(
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: TextField(
              //           controller: to,
              //           style: TextStyle(color: Colors.white),
              //         ),
              //       ),
              //       MaterialButton(
              //         onPressed: () {
              //           conn = peer.connect(to.text);
              //         },
              //         child: Text("Connect"),
              //         color: Colors.green,
              //       )
              //     ],
              //   ),
              // ),
              // Container(
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: TextField(
              //           controller: msg,
              //           style: TextStyle(color: Colors.white),
              //         ),
              //       ),
              //       MaterialButton(
              //         onPressed: () {
              //           if (conn == null) return;
              //           print("Sending data");
              //           conn!.send(msg.text);
              //           // conn!.sendBinary(convertStringToUint8List(msg.text));
              //         },
              //         child: Text("Send"),
              //         color: Colors.green,
              //       )
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget renderSyncSection() {
    return Opacity(
      opacity: 0.25,
      child: GestureDetector(
        onTap: () {},
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
                  "Sync (Pro)",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                      ),
                ),
                Icon(
                  Icons.sync_rounded,
                  color: Colors.orangeAccent,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector renderExportSection() {
    return GestureDetector(
      onTap: () async {
        try {
          if (!await FlutterFileDialog.isPickDirectorySupported()) {
            return;
          }
          final pickedDirectory = await FlutterFileDialog.pickDirectory();
          if (pickedDirectory != null) {
            setState(context.once<AppController>().startLoading);
            context.once<AccountController>().export(pickedDirectory);
            context.once<AppController>().addNotification(
                NotificationType.success, "Exported database!");
          }
        } catch (e) {
        } finally {
          setState(context.once<AppController>().stopLoading);
        }
      },
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
                "Export Data",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                    ),
              ),
              Icon(
                Icons.cloud_download,
                color: Colors.orangeAccent,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> confirmImport(List<Expense> expenses) async {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return ConfirmationDialog(
          message:
              "Do you want to import ${expenses.length} expenses? Existing ones will be overwritten.",
          okLabel: "No",
          cancelLabel: "Yes",
          cancelColor: Colors.green,
          onOk: () => Navigator.pop(context),
          onCancel: () async {
            setState(context.once<AppController>().startLoading);
            Navigator.pop(context);
            await Future.wait(expenses
                    .map((context.once<AccountController>().createExpense)))
                .then((results) {
              var errCount = 0;
              for (var each in results) {
                if (!each.status) errCount += 1;
              }
              setState(context.once<AppController>().stopLoading);
              if (errCount == 0) {
                context.once<AppController>().addNotification(
                    NotificationType.success,
                    "Import was successfully completed!");
              } else if (errCount > 0 && errCount < expenses.length) {
                context.once<AppController>().addNotification(
                    NotificationType.warn,
                    "Some expenses were not imported. Please try again.");
              } else {
                context.once<AppController>().addNotification(
                    NotificationType.warn,
                    "All imports failed. Please try again.");
              }
            }).catchError((err) {
              print(err);
            });
            ;
          },
        );
      },
    );
  }

  GestureDetector renderImportSection() {
    return GestureDetector(
      onTap: () async {
        try {
          setState(context.once<AppController>().startLoading);
          List<Expense>? expenses =
              await context.once<AccountController>().import();
          if (expenses != null) {
            if (expenses.isNotEmpty) {
              confirmImport(expenses);
            } else
              context.once<AppController>().addNotification(
                  NotificationType.info, "The imported DB was empty/invalid.");
          }
        } catch (e) {
        } finally {
          setState(context.once<AppController>().stopLoading);
        }
      },
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
                "Import Data",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                    ),
              ),
              Icon(
                Icons.save,
                color: Colors.orangeAccent,
              )
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector renderCategoriesSection() {
    return GestureDetector(
      onTap: () {
        context.push("/categories");
        // GoRoute(
        //   path: '/categories',
        //   pageBuilder: (_, state) {
        //     return CustomTransitionPage(
        //       key: state.pageKey,
        //       child: CategoriesPage(),
        //       transitionDuration: Duration(seconds: 2),
        //       transitionsBuilder: (_, a, __, c) =>
        //           FadeTransition(opacity: a, child: c),
        //     );
        //   },
        // );
      },
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
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
