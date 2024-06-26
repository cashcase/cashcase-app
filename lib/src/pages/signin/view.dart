import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/pages/signin/controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image(
                              width: 120, image: AssetImage('assets/logo.png')),
                        ),
                      ),
                    ),
                    Text(
                      "CashCase",
                      style: GoogleFonts.homemadeApple().copyWith(
                        fontSize: 42,
                        color: Colors.orangeAccent,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Wrap(
              children: [
                Container(
                  padding: EdgeInsets.all(24).copyWith(bottom: 80),
                  color: Colors.black12,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "New Here? Sign up!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade400,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 24),
                      TextField(
                        controller: usernameController,
                        style: TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Colors.grey),
                          errorText: usernameError,
                          errorMaxLines: 2,
                          errorStyle: TextStyle(color: Colors.red),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade800, width: 1.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        style: TextStyle(color: Colors.grey),
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: () =>
                                setState(() => showPassword = !showPassword),
                            child: Icon(
                              !showPassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          errorText: passwordError,
                          errorMaxLines: 2,
                          errorStyle: TextStyle(color: Colors.red),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 1.0),
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade800, width: 1.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              onPressed: () {
                                usernameError = null;
                                passwordError = null;

                                if (!RegExp(
                                        "^(?=.{5,20}\$)(?![_.])(?!.*[_.]{2})[a-z0-9._]+(?<![_.])\$")
                                    .hasMatch(usernameController.text)) {
                                  usernameError =
                                      "Username must be 5-20 alphanumeric chars and only . or _ special chars allowed.";
                                }
                                if (!RegExp(
                                        "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@\$]).{8,20}\$")
                                    .hasMatch(passwordController.text)) {
                                  passwordError =
                                      "Password must contain atleast 1 uppercase, 1 lowercase, 1 digit and 1 special char (!@\$) and between 8-20 chars.";
                                }
                                setState(() => {});
                                if (usernameError == null &&
                                    passwordError == null) {
                                  context.once<AppController>().loader.show();
                                  context
                                      .once<SigninController>()
                                      .login(
                                        usernameController.text,
                                        passwordController.text,
                                      )
                                      .then((e) {
                                    context.once<AppController>().loader.hide();
                                    if (e.status) {
                                      AppController.setTokens(
                                        e.data!.token,
                                        e.data!.refreshToken,
                                      );
                                      context.clearAndReplace("/");
                                    }
                                  }).catchError((e) {
                                    context.once<AppController>().loader.hide();
                                    context
                                        .once<AppController>()
                                        .addNotification(NotificationType.error,
                                            "Invalid Username or Password.");
                                  });
                                }
                              },
                              child: Text("Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  )),
                              color: Colors.orangeAccent,
                              disabledColor: Colors.white12,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
