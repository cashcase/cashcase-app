import 'package:auto_size_text/auto_size_text.dart';
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/components/confirm.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/account/controller.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:cashcase/src/pages/expenses/controller.dart';
import 'package:cashcase/src/utils.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountView extends StatefulWidget {
  AccountPageData? data;
  AccountView({
    super.key,
    this.data,
  });
  @override
  State<AccountView> createState() => _ViewState();
}

class _ViewState extends State<AccountView> {
  late Future<String?> getEncryptionKey;
  late Future<Either<AppError, ProfileModel>> getProfile;

  @override
  void initState() {
    getEncryptionKey = AppDb.getEncryptionKey();
    getProfile = context.once<AccountController>().getDetails();
    super.initState();
  }

  void showEncryptionKey() {
    bool showingKey = false;
    bool copiedKey = false;
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              FutureBuilder(
                  future: getEncryptionKey,
                  builder: (context, snapshot) {
                    var isDone =
                        snapshot.connectionState == ConnectionState.done;
                    if (!isDone) {
                      return Container(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.orangeAccent,
                          ),
                        ),
                      );
                    }
                    return StatefulBuilder(builder: (context, setState) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.symmetric(vertical: 32, horizontal: 16)
                                .copyWith(
                          top: 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  showingKey
                                      ? Icons.lock_open_rounded
                                      : Icons.lock_rounded,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 16),
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
                            SizedBox(height: 8),
                            Divider(),
                            SizedBox(height: 8),
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: showingKey
                                      ? Text(
                                          snapshot.data!,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium!
                                              .copyWith(
                                                color: Colors.black,
                                              ),
                                        )
                                      : Text(
                                          "●●● ●●● ●●●\n●●● ●●●",
                                          textAlign: TextAlign.center,
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
                                  splashFactory: NoSplash.splashFactory),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      child: MaterialButton(
                                        onPressed: () {
                                          setState(
                                              () => showingKey = !showingKey);
                                        },
                                        color: showingKey
                                            ? Colors.red
                                            : Colors.black,
                                        child: Center(
                                          child: Text(
                                            "${showingKey ? "Hide" : "Show"} Key",
                                            style: TextStyle(
                                              color: Colors.red.shade50,
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
                                            text: snapshot.data!,
                                          ),
                                        );
                                      },
                                      color: copiedKey
                                          ? Colors.green
                                          : Colors.black,
                                      child: Center(
                                        child: Text(
                                          copiedKey ? "Copied!" : "Copy Key",
                                          style: TextStyle(
                                            color: Colors.green.shade50,
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
                    });
                  })
            ],
          );
        });
  }

  List<User> connections = ExpensesController().dummyUsers.sublist(1, 3);

  void showDeleteConnection(User user) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ConfirmationDialog(
              message:
                  "Are you sure you want \n to remove ${user.firstName} ${user.lastName} from your connections?",
              icon: Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 100,
              ),
              okLabel: "Yes",
              cancelLabel: "No",
              onOk: () => {},
              onCancel: () => Navigator.pop(context));
        });
  }

  TextEditingController keyController = TextEditingController();

  void showConnectionKey(User user) {
    bool hideKey = true;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(children: [
          StatefulBuilder(builder: (context, setState) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding:
                  EdgeInsets.symmetric(vertical: 32, horizontal: 16).copyWith(
                top: 24,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 16),
                      Text("Configure Key",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith()),
                    ],
                  ),
                  SizedBox(height: 4),
                  Divider(),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("User",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: Colors.grey)),
                      SizedBox(width: 4),
                      Text("${user.firstName} ${user.lastName}",
                          style: Theme.of(context).textTheme.headlineSmall!),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Email",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: Colors.grey)),
                      SizedBox(width: 8),
                      Text(user.username,
                          style: Theme.of(context).textTheme.headlineSmall!),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: keyController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white24, width: 1.0),
                      ),
                      hintText: "●●●●●●●●●",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white12, width: 1.0),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => hideKey = !hideKey),
                        child: Icon(
                          hideKey
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                    style: TextStyle(fontSize: 20),
                    obscureText: hideKey,
                    keyboardType: TextInputType.multiline,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: 1,
                    minLines: 1,
                  ),
                  SizedBox(height: 8),
                  Theme(
                    data: ThemeData(splashFactory: NoSplash.splashFactory),
                    child: Row(
                      children: [
                        Expanded(
                          child: MaterialButton(
                            color: Colors.black,
                            onPressed: () => Navigator.pop(context),
                            child: Center(
                              child: Text(
                                "Back",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: MaterialButton(
                            color: Colors.orangeAccent,
                            onPressed: () => Navigator.pop(context),
                            child: Center(
                              child: Text(
                                "Save",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
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
        ]);
      },
    );
  }

  TextEditingController findUserController = TextEditingController();
  String? findUserError = null;

  void confirmConnection(User user) {
    if (user.username == AppDb.getCurrentUser()) {
      return context.once<AppController>().addNotification(
          NotificationType.info, "You cannot send a request to yourself.");
    } else {
      showModalBottomSheet(
          context: context,
          builder: (_) {
            return ConfirmationDialog(
                message:
                    "Do you want to send a connection request to ${user.firstName} "
                    "${user.lastName.isEmpty ? "?" : "${user.lastName}?"}",
                icon: Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 100,
                ),
                okLabel: "No",
                cancelLabel: "Yes",
                cancelColor: Colors.orangeAccent,
                onOk: () => Navigator.pop(context),
                onCancel: () {
                  context
                      .once<AccountController>()
                      .sendRequest(user.username)
                      .then((r) {
                    r.fold(
                        (err) => context.once<AppController>().addNotification(
                              NotificationType.error,
                              err.message ??
                                  'Unable to send request at this time. Please try again later',
                            ), (_) {
                      context.once<AppController>().addNotification(
                          NotificationType.success, "Sent connection request!");
                    });
                  }).whenComplete(() => Navigator.pop(context));
                });
          });
    }
  }

  Scaffold renderError() {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Unable to get profile details. \nPlease try again after sometime.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getProfile,
        builder: (context, snapshot) {
          var isDone = snapshot.connectionState == ConnectionState.done;
          if (!isDone)
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.orangeAccent,
                ),
              ),
            );

          if (!snapshot.hasData) renderError();
          return snapshot.data!.fold(
            (_) => renderError(),
            (profile) => Scaffold(
              body: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      renderProfileCard(profile.details),
                      ...renderKeySection(),
                      ...renderUserSearch(),
                      if (profile.connections.isNotEmpty)
                        ...renderConnections(profile),
                      if (profile.connections.isNotEmpty)
                        ...renderReceivedRequests(profile),
                      if (profile.connections.isNotEmpty)
                        ...renderSentRequests(profile)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  List<Widget> renderKeySection() {
    return [
      SizedBox(height: 8),
      Divider(),
      SizedBox(height: 8),
      GestureDetector(
        onTap: showEncryptionKey,
        child: Card(
          color: Colors.transparent,
          margin: EdgeInsets.zero,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Encryption Key", style: TextStyle(fontSize: 20)),
              Container(
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      splashFactory: NoSplash.splashFactory),
                  onPressed: showEncryptionKey,
                  color: Colors.black,
                  icon: Icon(
                    Icons.password_rounded,
                  ),
                ),
              )
            ],
          ),
        ),
      )
    ];
  }

  List<Widget> renderUserSearch() {
    return [
      SizedBox(height: 8),
      Divider(),
      SizedBox(height: 8),
      Text(
        "Connect",
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.left,
      ),
      SizedBox(height: 8),
      TextField(
        controller: findUserController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Find People',
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24, width: 1.0),
          ),
          errorText: findUserError,
          errorMaxLines: 2,
          errorStyle: TextStyle(color: Colors.red),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white12, width: 1.0),
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              if (findUserController.text.isEmpty) return;
              findUserError = isValidUsername(findUserController.text);
              setState(() => {});
              if (findUserError == null) {
                context
                    .once<AccountController>()
                    .findUser(findUserController.text)
                    .then((r) {
                  r.fold(
                    (error) {
                      context.once<AppController>().addNotification(
                            NotificationType.error,
                            error.message ??
                                "Unable to search for users. "
                                    "Please try again later.",
                          );
                    },
                    confirmConnection,
                  );
                });
              }
              ;
            },
            child: Icon(Icons.search),
          ),
        ),
      )
    ];
  }

  List<Widget> renderConnections(ProfileModel profile) {
    return [
      SizedBox(height: 16),
      Text(
        "Connections (${profile.connections.length})",
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.left,
      ),
      SizedBox(height: 16),
      renderConnectionList(profile.connections)
    ];
  }

  List<Widget> renderReceivedRequests(ProfileModel profile) {
    return [
      SizedBox(height: 8),
      Divider(),
      SizedBox(height: 8),
      Text(
        "Received (${profile.connections.length})",
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.left,
      ),
      SizedBox(height: 16),
      renderConnectionList(profile.connections)
    ];
  }

  List<Widget> renderSentRequests(ProfileModel profile) {
    return [
      SizedBox(height: 8),
      Divider(),
      SizedBox(height: 8),
      Text(
        "Sent (${profile.connections.length})",
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.left,
      ),
      SizedBox(height: 16),
      renderConnectionList(profile.connections)
    ];
  }

  Row renderProfileCard(User user) {
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
                ExpensesController().getUserInitials(user),
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
                user.firstName,
                maxLines: 1,
                minFontSize: 24.0,
                overflow: TextOverflow.ellipsis,
              ),
              AutoSizeText(
                user.lastName,
                maxLines: 1,
                minFontSize: 24.0,
                overflow: TextOverflow.ellipsis,
              ),
              AutoSizeText(
                "ID: ${user.username}",
                maxLines: 1,
                minFontSize: 16.0,
                style: TextStyle(color: Colors.white54),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (_) {
                  return ConfirmationDialog(
                      message: "Are you sure you want to logout?",
                      icon: Icon(
                        Icons.warning_rounded,
                        color: Colors.orange,
                        size: 100,
                      ),
                      okLabel: "Yes",
                      cancelLabel: "No",
                      onOk: () {
                        context.once<AccountController>().logout();
                        Navigator.pop(context);
                      },
                      onCancel: () => Navigator.pop(context));
                });
          },
          child: Icon(
            Icons.logout_rounded,
            color: Colors.red,
          ),
        )
      ],
    );
  }

  ListView renderConnectionList(List<User> connections) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: connections.length,
      itemBuilder: (context, i) {
        return Theme(
          data: ThemeData(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ListTile(
            onTap: () => showConnectionKey(connections[i]),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              radius: 24.0,
              child: Text(
                "${connections[i].firstName[0].toUpperCase()}"
                "${connections[i].lastName[0].toUpperCase()}",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.black,
                    ),
              ),
            ),
            title: Text(
              "${connections[i].firstName} ${connections[i].lastName}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            trailing: Container(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => showDeleteConnection(connections[i]),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Text(
              connections[i].username,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
        );
      },
    );
  }
}
