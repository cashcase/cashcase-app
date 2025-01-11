import 'package:flutter/foundation.dart';
import 'dart:async';

class Debouncer {
  final int milliseconds;
  static Timer? _timer;

  Debouncer({required this.milliseconds});

  cancel() {
    if (_timer != null) _timer!.cancel();
  }

  run(VoidCallback action) {
    cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
