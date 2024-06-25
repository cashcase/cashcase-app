import 'package:cashcase/core/base/controller.dart';

class LoaderController extends BaseController {
  static final LoaderController _singleton = LoaderController._internal();
  factory LoaderController() => _singleton;
  LoaderController._internal();

  static String? _loading;

  get active => _loading != null;

  show([String message = 'Loading...']) {
    _loading = message;
    notify();
  }

  hide() {
    _loading = null;
    notify();
  }

  @override
  void initListeners() {}
}
