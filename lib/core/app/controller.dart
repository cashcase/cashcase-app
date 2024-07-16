import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/core/utils/debouncer.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/db.dart';
import 'package:go_router/go_router.dart';

class AppController extends BaseController {
  static bool ready = false;
  static late final GoRouter router;
  static Debouncer? _debouncer;
  NotificationModel? currentNotification;

  static final AppController _singleton = AppController._internal();
  factory AppController() => _singleton;
  AppController._internal();

  @override
  void initListeners() {
    AppDb.init();
  }

  static Future<bool> init({required GoRouter router}) async {
    if (ready == true) return ready;

    bool dbStatus = await Db.init();
    AppController.router = router;

    ready = dbStatus;
    return ready;
  }

  addNotification(NotificationType type, String message) {
    currentNotification = NotificationModel(message, type);
    if (_debouncer != null) _debouncer!.cancel();
    _debouncer = Debouncer(milliseconds: 1000 * 5);
    _debouncer?.run(clearNotifications);
    notifyListeners();
  }

  clearNotifications() {
    currentNotification = null;
    notifyListeners();
  }

  static String? _loading;

  get active => _loading != null;

  startLoading([String message = 'Loading...']) {
    _loading = message;
    notify();
  }

  stopLoading() {
    _loading = null;
    notify();
  }
}
