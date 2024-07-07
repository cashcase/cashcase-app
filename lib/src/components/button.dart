import 'package:flutter/material.dart';

enum ButtonType { primary, secondary }

class Button extends StatefulWidget {
  String label;
  ButtonType type;
  void Function()? onPressed;
  Color? color;
  Button({
    super.key,
    this.color,
    this.type = ButtonType.primary,
    required this.label,
    required this.onPressed,
  });

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 40,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onPressed: widget.onPressed,
      child: Text(
        widget.label,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.black,
            ),
      ),
      disabledColor: Colors.white12,
      color: widget.color != null
          ? widget.color
          : widget.type == ButtonType.primary
              ? Colors.orangeAccent
              : Colors.white,
    );
  }
}
