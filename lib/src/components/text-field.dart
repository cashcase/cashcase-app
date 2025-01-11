import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  TextEditingController controller;
  bool isPassword;
  String? error;
  String label;
  List<TextInputFormatter>? inputFormatters;
  CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
    this.error,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => Custom_TextFieldState();
}

class Custom_TextFieldState extends State<CustomTextField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      inputFormatters: widget.inputFormatters,
      controller: widget.controller,
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(color: Colors.white),
      obscureText: widget.isPassword && !showPassword,
      decoration: InputDecoration(
        suffixIcon: !widget.isPassword
            ? null
            : GestureDetector(
                onTap: () => setState(() => showPassword = !showPassword),
                child: Icon(
                  (!showPassword)
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.grey.shade700,
                ),
              ),
        errorText: widget.error,
        errorMaxLines: 2,
        errorStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.red,
            ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        border: OutlineInputBorder(),
        hintText: widget.label,
        hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.grey,
            ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade800, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.15), width: 1.0),
        ),
      ),
    );
  }
}
