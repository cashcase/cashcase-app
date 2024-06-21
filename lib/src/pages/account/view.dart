import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/account/controller.dart';
import 'package:flutter/services.dart';

class AccountView extends ResponsiveViewState {
  AccountView() : super(create: () => AccountController());
  @override
  Widget get desktopView => View();

  @override
  Widget get mobileView => View();

  @override
  Widget get tabletView => View();

  @override
  Widget get watchView => View();
}

class View extends StatefulWidget {
  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  String encryptionKey = "quick brown fox walked in the rain";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        child: Column(
          children: [
            renderProfileCard(),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Encryption Key", style: TextStyle(fontSize: 20)),
                Container(
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        splashFactory: NoSplash.splashFactory),
                    onPressed: () {
                      bool showingKey = false;
                      bool copiedKey = false;
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Wrap(
                              children: [
                                StatefulBuilder(builder: (context, setState) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 32, horizontal: 32),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              showingKey
                                                  ? Icons.lock_open_rounded
                                                  : Icons.lock_rounded,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              "Your Encrpytion Key",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium!
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                              color: Colors.orangeAccent,
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Center(
                                              child: showingKey
                                                  ? Text(
                                                      encryptionKey,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium!
                                                          .copyWith(
                                                            color: Colors.black,
                                                          ),
                                                    )
                                                  : Text(
                                                      "●●● ●●● ●●●\n●●● ●●●",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.black),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        Theme(
                                          data: ThemeData(
                                              splashFactory:
                                                  NoSplash.splashFactory),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  child: MaterialButton(
                                                    onPressed: () {
                                                      setState(() =>
                                                          showingKey =
                                                              !showingKey);
                                                    },
                                                    color: showingKey
                                                        ? Colors.red
                                                        : Colors.black,
                                                    child: Center(
                                                      child: Text(
                                                        "${showingKey ? "Hide" : "Show"} Key",
                                                        style: TextStyle(
                                                          color: Colors
                                                              .red.shade50,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: MaterialButton(
                                                  onPressed: () async {
                                                    copiedKey = true;
                                                    setState(() => {});
                                                    await Clipboard.setData(
                                                      ClipboardData(
                                                          text: encryptionKey),
                                                    );
                                                  },
                                                  color: copiedKey
                                                      ? Colors.green
                                                      : Colors.black,
                                                  child: Center(
                                                    child: Text(
                                                      copiedKey
                                                          ? "Copied!"
                                                          : "Copy Key",
                                                      style: TextStyle(
                                                        color: Colors
                                                            .green.shade50,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                })
                              ],
                            );
                          });
                    },
                    color: Colors.black,
                    icon: Icon(
                      Icons.password_rounded,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Connections (39)",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.left,
                )
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Find People',
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white24, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white12, width: 1.0),
                        ),
                        suffixIcon: Icon(Icons.search)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row renderProfileCard() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            height: 80.0,
            width: 80.0,
            color: Colors.orangeAccent,
            child: Center(
              child: Text(
                "AP",
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Colors.black,
                    ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                "Abhimanyu",
                maxLines: 1,
                minFontSize: 24.0,
                overflow: TextOverflow.ellipsis,
              ),
              AutoSizeText(
                "Pandian",
                maxLines: 1,
                minFontSize: 24.0,
                overflow: TextOverflow.ellipsis,
              ),
              AutoSizeText(
                "abhimanyu.pandian@walmart.com",
                maxLines: 1,
                minFontSize: 16.0,
                style: TextStyle(color: Colors.white54),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        GestureDetector(
          child: Icon(
            Icons.logout_rounded,
            color: Colors.redAccent,
          ),
        )
      ],
    );
  }
}
