import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  String message;
  Icon? icon;
  String okLabel;
  Color? okColor;
  String cancelLabel;
  Color? cancelColor;
  void Function()? onOk;
  void Function()? onCancel;
  Widget? child;
  ConfirmationDialog({
    required this.message,
    required this.okLabel,
    required this.cancelLabel,
    this.child,
    this.icon,
    this.okColor,
    this.cancelColor,
    this.onOk,
    this.onCancel,
  });
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(24).copyWith(top: 20),
          child: Column(
            children: [
              icon ??
                  Icon(
                    Icons.warning_rounded,
                    color: Colors.orangeAccent,
                    size: 100,
                  ),
              SizedBox(height: 24),
              child ??
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                        ),
                  ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: MaterialButton(
                      color: okColor ?? Colors.black,
                      onPressed: onOk,
                      child: Center(
                        child: Text(
                          okLabel,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Colors.red.shade50,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: MaterialButton(
                      color: cancelColor ?? Colors.orangeAccent,
                      onPressed: onCancel,
                      child: Center(
                        child: Text(
                          cancelLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
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
        ),
      ],
    );
  }
}
