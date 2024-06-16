import 'package:cashcase/core/app/controller.dart';

class LoaderController {
  static final LoaderController _singleton = LoaderController._internal();
  factory LoaderController() => _singleton;
  LoaderController._internal();

  static String? _loading;

  get active => _loading != null;

  show([String message = 'Loading...']) {
    _loading = message;
    AppController.refresh();
  }

  hide() {
    _loading = null;
    AppController.refresh();
  }
}
