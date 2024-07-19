import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/connection.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountView extends StatefulWidget {
  AccountPageData? data;
  AccountView({this.data});
  @override
  State<AccountView> createState() => _ViewState();
}

class _ViewState extends State<AccountView> {
  // late final Peer peer;
  String message = "";

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
                SizedBox(height: 24),
                renderSyncSection(),
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
                  "Sync",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
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
