import 'package:auto_size_text/auto_size_text.dart';
import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/errors.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/components/confirm.dart';
import 'package:cashcase/src/components/text-field.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/account/controller.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:cashcase/src/pages/home/controller.dart';
import 'package:cashcase/src/utils.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountView extends StatefulWidget {
  AccountPageData? data;
  AccountView({this.data});
  @override
  State<AccountView> createState() => _ViewState();
}

class _ViewState extends State<AccountView> {
  late Future<String?> getEncryptionKey;
  late Future<Either<AppError, ProfileModel>> getProfile;

  TextEditingController findUserController = TextEditingController();
  String? findUserError = null;

  bool copiedUsername = false;

  void refresh() {
    setState(() {
      getProfile = context.once<AccountController>().getDetails();
    });
  }

  @override
  void initState() {
    getEncryptionKey = AppDb.getEncryptionKey();
    getProfile = context.once<AccountController>().getDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      animationDuration: Duration.zero,
      child: FutureBuilder(
        future: getProfile,
        builder: (context, snapshot) {
          var isDone = snapshot.connectionState == ConnectionState.done;
          if (!isDone)
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  color: Colors.orangeAccent,
                ),
              ),
            );
          if (!snapshot.hasData) renderError();
          return snapshot.data!.fold(
            (_) => renderError(),
            (profile) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: renderTabView(),
                body: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...renderUserSearch(profile),
                              if (profile.connections.isNotEmpty)
                                ...renderConnections(profile),
                              if (profile.received.isNotEmpty)
                                ...renderReceivedRequests(profile),
                              if (profile.sent.isNotEmpty)
                                ...renderSentRequests(profile)
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              renderProfileCard(profile.details),
                              SizedBox(height: 24),
                              renderKeySection(),
                              SizedBox(height: 24),
                              renderAccountDeletionSection(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  TabBar renderTabView() {
    return TabBar(
      overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
      indicatorColor: Colors.orangeAccent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorWeight: 4,
      labelColor: Colors.orangeAccent,
      dividerColor: Colors.transparent,
      tabs: [
        Tab(text: "Connections", icon: Icon(Icons.people_rounded)),
        Tab(text: "Settings", icon: Icon(Icons.settings_rounded)),
      ],
    );
  }

  GestureDetector renderAccountDeletionSection() {
    return GestureDetector(
      onTap: confirmAccountDeletion,
      child: Container(
        height: 36,
        child: Card(
          color: Colors.transparent,
          margin: EdgeInsets.zero,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delete Account",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.red,
                    ),
              ),
              Icon(
                Icons.delete_forever,
                color: Colors.red,
              )
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController accountDeletePasswordConfirm = TextEditingController();
  String? accountDeletePasswordError = null;

  void confirmAccountDeletion() {
    accountDeletePasswordError = null;
    accountDeletePasswordConfirm.text = "";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (childContext) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(childContext).viewInsets.bottom),
          child: StatefulBuilder(builder: (_, setState) {
            return ConfirmationDialog(
              message: "",
              child: Column(
                children: [
                  Text(
                    "Are you sure you want to delete your account?",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    label: "Enter your password to confirm",
                    controller: accountDeletePasswordConfirm,
                    error: accountDeletePasswordError,
                  )
                ],
              ),
              icon: Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 100,
              ),
              okLabel: "No",
              cancelLabel: "Yes",
              cancelColor: Colors.red,
              onOk: () => Navigator.pop(context),
              onCancel: () {
                accountDeletePasswordError =
                    isValidPassword(accountDeletePasswordConfirm.text);
                if (accountDeletePasswordError != null) {
                  return setState(() => {});
                }
                context
                    .once<AccountController>()
                    .deleteAccount(accountDeletePasswordConfirm.text)
                    .then((r) {
                  r.fold(
                      (err) => context.once<AppController>().addNotification(
                          NotificationType.error,
                          err.message ??
                              "Could not delete account. Please try again later"),
                      (details) {
                    if (details) {
                      context.once<AppController>().addNotification(
                            NotificationType.success,
                            "Account was deleted!",
                          );
                      AppDb.clearEncryptionKey();
                      context.once<AppController>().logout();
                      Navigator.pop(context);
                    }
                  });
                });
              },
            );
          }),
        );
      },
    );
  }

  GestureDetector renderKeySection() {
    return GestureDetector(
      onTap: showEncryptionKey,
      child: Container(
        height: 36,
        child: Card(
          color: Colors.transparent,
          margin: EdgeInsets.zero,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Encryption Key",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                    ),
              ),
              Icon(
                Icons.password_rounded,
                color: Colors.orangeAccent,
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> renderUserSearch(ProfileModel profile) {
    return [
      Text(
        "Search",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
            ),
      ),
      SizedBox(height: 8),
      TextField(
        controller: findUserController,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Colors.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.white10,
              ),
          hintText: 'Find People',
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24, width: 1.0),
          ),
          errorText: findUserError,
          errorMaxLines: 2,
          errorStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.red,
              ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white10, width: 1.0),
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              if (findUserController.text.isEmpty) return;
              findUserError = isValidUsername(findUserController.text);
              setState(() => {});
              if (findUserController.text == AppDb.getCurrentUser()) {
                return context.once<AppController>().addNotification(
                    NotificationType.info,
                    "You cannot send a request to yourself.");
              }

              if (profile.connections.indexWhere(
                      (e) => e.username == findUserController.text) >=
                  0) {
                return context.once<AppController>().addNotification(
                    NotificationType.info, "Already connected.");
              }

              if (profile.sent.indexWhere(
                      (e) => e.username == findUserController.text) >=
                  0) {
                return context.once<AppController>().addNotification(
                    NotificationType.info,
                    "Already sent a connection request to user.");
              }

              if (profile.received.indexWhere(
                      (e) => e.username == findUserController.text) >=
                  0) {
                return context.once<AppController>().addNotification(
                    NotificationType.info,
                    "Already received a connection request from user.");
              }

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
            child: Icon(
              Icons.search,
              color: findUserError != null ? Colors.red : Colors.white,
            ),
          ),
        ),
      )
    ];
  }

  List<Widget> renderConnections(ProfileModel profile) {
    var currentConn = AppDb.getCurrentPair();
    return [
      SizedBox(height: 16),
      Text(
        "Connections (${profile.connections.length})",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
            ),
      ),
      SizedBox(height: 16),
      renderConnectionList(
        profile.connections,
        canSeeDetails: true,
        rightOptionIcon: (_) => Icon(
          Icons.remove_circle_rounded,
          color: Colors.red,
        ),
        leftOptionIcon: (user) {
          return Icon(
            Icons.people_rounded,
            color: user.username == currentConn?.username
                ? Colors.blue
                : Colors.grey.withOpacity(0.25),
            size: 28,
          );
        },
        onLeftOption: (user) {
          context.once<HomePageController>().setCurrentUser(
              user.username == currentConn?.username ? null : user);
          setState(() {});
        },
        onRightOption: (user) {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return ConfirmationDialog(
                message:
                    "Do you want to \nremove ${user.firstName} from your connections?",
                okLabel: "No",
                cancelColor: Colors.red,
                cancelLabel: "Yes",
                onOk: () => Navigator.pop(context),
                onCancel: () {
                  context
                      .once<AccountController>()
                      .deleteConnection(user.username)
                      .then((r) {
                    r.fold((err) {
                      context.once<AppController>().addNotification(
                          NotificationType.success,
                          err.message ??
                              "Could not remove connection. Please try again later");
                    }, (_) {
                      context.once<HomePageController>().setCurrentUser(null);
                      Navigator.pop(context);
                      refresh();
                      context.once<AppController>().addNotification(
                          NotificationType.success, "Removed connection.");
                    });
                  });
                },
              );
            },
          );
        },
      )
    ];
  }

  List<Widget> renderReceivedRequests(ProfileModel profile) {
    return [
      SizedBox(height: 8),
      Divider(color: Colors.white10),
      SizedBox(height: 8),
      Text(
        "Received (${profile.received.length})",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
            ),
      ),
      SizedBox(height: 16),
      renderConnectionList(
        profile.received,
        rightOptionIcon: (_) => Icon(
          Icons.cancel_rounded,
          color: Colors.red,
        ),
        leftOptionIcon: (_) => Icon(
          Icons.check_rounded,
          color: Colors.green,
        ),
        onLeftOption: (user) {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return ConfirmationDialog(
                message: "Do you want to \naccept ${user.firstName}'s request?",
                okLabel: "No",
                cancelLabel: "Yes",
                onOk: () => Navigator.pop(context),
                onCancel: () {
                  context
                      .once<AccountController>()
                      .acceptRequest(user.username)
                      .then(
                    (r) {
                      r.fold(
                        (err) {
                          context.once<AppController>().addNotification(
                              NotificationType.success,
                              err.message ??
                                  "Could not accept connection request. Please try again later");
                        },
                        (_) {
                          Navigator.pop(context);
                          refresh();
                          context.once<AppController>().addNotification(
                              NotificationType.success,
                              "Connection Request was accepted.");
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
        onRightOption: (user) {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return ConfirmationDialog(
                message: "Do you want to \nreject ${user.firstName}'s request?",
                okLabel: "No",
                cancelColor: Colors.red,
                cancelLabel: "Yes",
                onOk: () => Navigator.pop(context),
                onCancel: () {
                  context
                      .once<AccountController>()
                      .rejectRequest(user.username)
                      .then((r) {
                    r.fold((err) {
                      context.once<AppController>().addNotification(
                          NotificationType.success,
                          err.message ??
                              "Could not reject connection request. Please try again later");
                    }, (_) {
                      Navigator.pop(context);
                      refresh();
                      context.once<AppController>().addNotification(
                          NotificationType.success,
                          "Connection Request was rejected.");
                    });
                  });
                },
              );
            },
          );
        },
      )
    ];
  }

  List<Widget> renderSentRequests(ProfileModel profile) {
    return [
      SizedBox(height: 8),
      Divider(color: Colors.white10),
      SizedBox(height: 8),
      Text(
        "Sent (${profile.sent.length})",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
            ),
      ),
      SizedBox(height: 16),
      renderConnectionList(profile.sent,
          rightOptionIcon: (_) => Icon(
                Icons.cancel_rounded,
                color: Colors.red,
              ),
          onRightOption: (user) {
            showModalBottomSheet(
              context: context,
              builder: (_) {
                return ConfirmationDialog(
                  message:
                      "Do you want to \nrevoke connection request to ${user.firstName}?",
                  okLabel: "No",
                  cancelColor: Colors.red,
                  cancelLabel: "Yes",
                  onOk: () => Navigator.pop(context),
                  onCancel: () {
                    context
                        .once<AccountController>()
                        .revokeRequest(user.username)
                        .then((r) {
                      r.fold((err) {
                        context.once<AppController>().addNotification(
                            NotificationType.success,
                            err.message ??
                                "Could not revoke connection request. Please try again later");
                      }, (_) {
                        Navigator.pop(context);
                        refresh();
                        context.once<AppController>().addNotification(
                            NotificationType.info,
                            "Connection Request was Revoked.");
                      });
                    });
                  },
                );
              },
            );
          })
    ];
  }

  Widget renderProfileCard(User user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              height: 80.0,
              width: 80.0,
              color: Colors.orangeAccent,
              child: Center(
                child: Text(
                  user.getInitials(),
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold),
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
                  "${user.firstName} ${user.lastName}",
                  maxLines: 2,
                  minFontSize: 24.0,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.white),
                ),
                Row(
                  children: [
                    AutoSizeText(
                      copiedUsername ? "Copied!" : "@${user.username}",
                      maxLines: 1,
                      minFontSize: 16.0,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: copiedUsername ? Colors.green : Colors.white),
                    ),
                    SizedBox(width: 8),
                    if (!copiedUsername)
                      GestureDetector(
                        onTap: () async {
                          copiedUsername = true;
                          setState(() => {});
                          await Clipboard.setData(
                            ClipboardData(
                              text: user.username,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.copy_rounded,
                          color: Colors.grey.shade700,
                          size: 16,
                        ),
                      )
                  ],
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
                          color: Colors.red,
                          size: 100,
                        ),
                        okLabel: "Yes",
                        cancelLabel: "No",
                        onOk: () {
                          context.once<AppController>().logout();
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
      ),
    );
  }

  ListView renderConnectionList(
    List<User> list, {
    Icon? Function(User user)? leftOptionIcon,
    Icon? Function(User user)? rightOptionIcon,
    void Function(User user)? onLeftOption,
    void Function(User user)? onRightOption,
    bool canSeeDetails = false,
  }) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, i) {
        User user = list[i];
        return ListTile(
          onTap: canSeeDetails ? () => showConnectionKey(user) : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          // tileColor: Colors.black,
          leading: CircleAvatar(
            backgroundColor: Colors.orangeAccent,
            radius: 24.0,
            child: Text(
              user.getInitials(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          title: Text(
            "${user.firstName} ${user.lastName}",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                ),
          ),
          trailing: Container(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => {if (onLeftOption != null) onLeftOption(user)},
                  child: leftOptionIcon == null
                      ? Container()
                      : leftOptionIcon(user),
                ),
                SizedBox(width: 24),
                GestureDetector(
                  onTap: () => {if (onRightOption != null) onRightOption(user)},
                  child: rightOptionIcon == null
                      ? Container()
                      : rightOptionIcon(user),
                ),
              ],
            ),
          ),
          subtitle: Text(
            "@${list[i].username}",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.white,
                ),
          ),
        );
      },
    );
  }

  void confirmResetKey() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          message: "Are you sure you want to reset your key?",
          icon: Icon(
            Icons.warning_rounded,
            color: Colors.red,
            size: 100,
          ),
          okLabel: "No",
          cancelLabel: "Yes",
          cancelColor: Colors.red,
          onOk: () => Navigator.pop(context),
          onCancel: () {
            AppDb.clearEncryptionKey();
            context.clearAndReplace("/");
          },
        );
      },
    );
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
                  var isDone = snapshot.connectionState == ConnectionState.done;
                  if (!isDone) {
                    return Container(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    );
                  }
                  return StatefulBuilder(builder: (context, setState) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 32, horizontal: 16)
                              .copyWith(
                        top: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                                    "Your Encryption Key",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                  )
                                ],
                              ),
                              GestureDetector(
                                onTap: confirmResetKey,
                                child: Icon(
                                  Icons.lock_reset_outlined,
                                  color: Colors.red,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Divider(color: Colors.white10),
                          SizedBox(height: 8),
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(4)),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: showingKey
                                    ? AutoSizeText(
                                        snapshot.data!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        "● ● ● ● ● ● ● ● ● ● ● ●",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  child: MaterialButton(
                                    onPressed: () {
                                      setState(() => showingKey = !showingKey);
                                    },
                                    color:
                                        showingKey ? Colors.red : Colors.black,
                                    child: Center(
                                      child: Text(
                                        "${showingKey ? "Hide" : "Show"} Key",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: Colors.white),
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
                                  color:
                                      copiedKey ? Colors.green : Colors.black,
                                  child: Center(
                                    child: Text(
                                      copiedKey ? "Copied!" : "Copy Key",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  });
                })
          ],
        );
      },
    );
  }

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

  Future<void> saveKey(User user) async {
    var check = isValidKey(keyController.text);
    if (check != null) {
      context
          .once<AppController>()
          .addNotification(NotificationType.error, check);
      return;
    }
    AppDb.setEncryptionKey(keyController.text, user: user.username)
        .then((_) => context.once<AppController>().addNotification(
            NotificationType.success,
            "Key was configured successfully for ${user.firstName}."))
        .catchError((err) {})
        .whenComplete(() => Navigator.pop(context));
  }

  void showConnectionKey(User user) {
    bool hideKey = true;
    var keyGetterFuture = AppDb.getEncryptionKey(username: user.username);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Wrap(children: [
            FutureBuilder(
                future: keyGetterFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container(
                      height: 80,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    );
                  }
                  keyController.text = snapshot.data ?? "";
                  return StatefulBuilder(builder: (context, setState) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 32, horizontal: 16)
                              .copyWith(top: 18),
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
                              Text(
                                "Configure Key",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Divider(color: Colors.white10),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Full Name",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: Colors.white60),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "${user.firstName} ${user.lastName}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "User ID",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: Colors.white60),
                              ),
                              SizedBox(width: 8),
                              Text(
                                user.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: keyController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white24, width: 1.0),
                              ),
                              hintText: "●●●●●●●●●",
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: Colors.grey,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white12, width: 1.0),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  color: Colors.white,
                                ),
                            obscureText: hideKey,
                            keyboardType: TextInputType.multiline,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            maxLines: 1,
                            minLines: 1,
                          ),
                          SizedBox(height: 8),
                          Row(
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
                                  onPressed: () =>
                                      keyController.text == snapshot.data
                                          ? Navigator.pop(context)
                                          : saveKey(user),
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
                          )
                        ],
                      ),
                    );
                  });
                })
          ]),
        );
      },
    );
  }

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
                  Navigator.pop(context);
                  refresh();
                  context.once<AppController>().addNotification(
                      NotificationType.success, "Sent connection request!");
                });
              });
            },
          );
        },
      );
    }
  }

  Scaffold renderError() {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Unable to get profile details. \nPlease try again after sometime.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white38,
                    ),
              ),
              MaterialButton(
                onPressed: () {
                  context.once<AppController>().logout();
                  Navigator.pop(context);
                },
                child: Text(
                  "Or click here to try relogin",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.orangeAccent,
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
