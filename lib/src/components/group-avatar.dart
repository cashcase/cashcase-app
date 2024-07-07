import 'dart:math';

import 'package:flutter/material.dart';

class GroupAvatar extends StatefulWidget {
  List<String> users;
  GroupAvatar({required this.users});
  @override
  State<GroupAvatar> createState() => _GroupAvatarState();
}

class _GroupAvatarState extends State<GroupAvatar> {
  final MAX_AVATARS = 3;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < min(widget.users.length, MAX_AVATARS); i++)
          Align(
            widthFactor: 0.5,
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                radius: 18.0,
                child: Text(
                  widget.users[i],
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.black,
                      ),
                ),
              ),
            ),
          ),
        if (widget.users.length > MAX_AVATARS)
          Align(
            widthFactor: 0.5,
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                radius: 18.0,
                child: Text(
                  "+${widget.users.length - 3}",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.black,
                      ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
