import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/components/button.dart';
import 'package:cashcase/src/components/text-field.dart';
import 'package:cashcase/src/pages/signup/controller.dart';
import 'package:cashcase/src/utils.dart';
import 'package:flutter/material.dart';

class SignupView extends StatefulWidget {
  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  String? usernameError = null;
  String? passwordError = null;
  String? confirmError = null;
  String? firstNameError = null;
  String? lastNameError = null;

  bool obscureText = true;

  CustomTextField renderTextField(
      TextEditingController controller, String hint, String? error,
      {isPassword = false}) {
    return CustomTextField(
      controller: controller,
      isPassword: isPassword,
      error: error,
      label: hint,
    );
  }

  void handleSignup() {
    usernameError = isValidUsername(usernameController.text);
    passwordError = isValidPassword(passwordController.text);
    confirmError = passwordController.text != confirmController.text
        ? "Passwords do not match!"
        : null;
    firstNameError = isValidName(firstNameController.text);
    lastNameError = isValidName(lastNameController.text, optional: true);
    if (confirmError == null &&
        passwordError == null &&
        usernameError == null &&
        firstNameError == null &&
        lastNameError == null) {
      var appController = context.once<AppController>();
      if (usernameError == null && passwordError == null) {
        appController.startLoading();
        context
            .once<SignupController>()
            .signup(
              usernameController.text,
              passwordController.text,
              firstNameController.text,
              lastNameController.text,
            )
            .then((r) {
          appController.stopLoading();
          r.fold(
              (err) => appController.addNotification(
                    NotificationType.error,
                    err.message ??
                        'Unable to sign you up. Please try again later.',
                  ), (_) {
            appController.addNotification(
              NotificationType.success,
              "Successfully signed up!",
            );
            Navigator.of(context).pop();
          });
        }).catchError((e) {
          appController.stopLoading();
          appController.addNotification(
            NotificationType.error,
            'Unable to sign you up!',
          );
        });
      }
    } else
      setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(16).copyWith(top: 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(color: Colors.orangeAccent),
              ),
              SizedBox(height: 16),
              Text(
                "First Name*",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
              SizedBox(height: 8),
              renderTextField(
                firstNameController,
                "First Name",
                firstNameError,
              ),
              SizedBox(height: 8),
              Text(
                "Last Name",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
              SizedBox(height: 8),
              renderTextField(
                lastNameController,
                "Last Name",
                lastNameError,
              ),
              SizedBox(height: 8),
              Text(
                "Choose a username*",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
              SizedBox(height: 8),
              renderTextField(
                usernameController,
                "Username",
                usernameError,
              ),
              SizedBox(height: 8),
              Text(
                "Enter a strong password*",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
              SizedBox(height: 8),
              renderTextField(passwordController, "Password", passwordError,
                  isPassword: true),
              SizedBox(height: 8),
              Text(
                "Re-enter your password*",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
              SizedBox(height: 8),
              renderTextField(
                  confirmController, "Confirm Password", confirmError,
                  isPassword: true),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button(
                    onPressed: handleSignup,
                    label: "Sign up!",
                  )
                ],
              ),
              Container()
            ],
          ),
        ),
      ),
    );
  }
}
