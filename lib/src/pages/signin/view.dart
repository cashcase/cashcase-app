import 'package:cashcase/core/controller.dart';
import 'package:cashcase/src/pages/signin/controller.dart';
import 'package:cashcase/src/pages/signin/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SigninView extends BaseWidget {
  SigninPageData? data;
  SigninView({
    super.key,
    this.data,
  });

  @override
  BaseConsumer build(BuildContext context) {
    return BaseConsumer<SigninController>(builder: (controller, app) {
      return SigninWidget();
    });
  }
}

class SigninWidget extends StatefulWidget {
  @override
  State<SigninWidget> createState() => _SigninWidgetState();
}

class _SigninWidgetState extends State<SigninWidget> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
            Expanded(
              child: Container(
                padding: EdgeInsets.all(24),
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
                              // context
                              //     .once<SigninController>()
                              //     .login("messi", "test@123");
                            },
                            child: Text("Login",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                )),
                            color: Colors.orangeAccent,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
