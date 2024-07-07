import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/components/button.dart';
import 'package:cashcase/src/components/text-field.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/signin/controller.dart';
import 'package:cashcase/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class SigninView extends StatefulWidget {
  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? usernameError = null;
  String? passwordError = null;

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Scaffold(
        backgroundColor:
            Colors.blueAccent.withOpacity(isKeyboardVisible ? 0.15 : 0.25),
        body: Center(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: Durations.short1,
                        child: CircleAvatar(
                          radius: isKeyboardVisible ? 0 : 64,
                          backgroundColor: Colors.orangeAccent,
                          child: ClipOval(
                            child: Image(
                              width: 120,
                              image: AssetImage('assets/logo.png'),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isKeyboardVisible ? 12 : 24),
                      Text(
                        "CASHCASE",
                        style: GoogleFonts.abel().copyWith(
                            fontSize: 42,
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              Wrap(
                children: [
                  Container(
                    padding: EdgeInsets.all(16).copyWith(
                      top: 24,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.orangeAccent),
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          label: "Username",
                          controller: usernameController,
                          error: usernameError,
                        ),
                        SizedBox(height: 16),
                        CustomTextField(
                          label: "Password",
                          controller: passwordController,
                          isPassword: true,
                          error: passwordError,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Button(
                                onPressed: () => context.push("/signup"),
                                label: "Sign up",
                                type: ButtonType.secondary,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Button(
                                onPressed: () {
                                  usernameError =
                                      isValidUsername(usernameController.text);
                                  passwordError =
                                      isValidPassword(passwordController.text);
                                  setState(() => {});
                                  if (usernameError == null &&
                                      passwordError == null) {
                                    context
                                        .once<AppController>()
                                        .startLoading();
                                    context
                                        .once<SigninController>()
                                        .login(
                                          usernameController.text,
                                          passwordController.text,
                                        )
                                        .then((r) {
                                      context
                                          .once<AppController>()
                                          .stopLoading();
                                      r.fold(
                                          (err) => context
                                              .once<AppController>()
                                              .addNotification(
                                                  NotificationType.error,
                                                  err.message ??
                                                      "Unable to login. Please try again later."),
                                          (auth) {
                                        AppDb.setCurrentUser(
                                                usernameController.text)
                                            .then((currentUser) {
                                          context
                                              .once<AppController>()
                                              .clearNotifications();
                                          AppController.setTokens(
                                            auth.token,
                                            auth.refreshToken,
                                          );
                                          context.clearAndReplace("/");
                                        });
                                      });
                                    });
                                  }
                                },
                                label: "Login",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
