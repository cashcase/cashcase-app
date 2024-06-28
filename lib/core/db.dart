import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Db {
  static const t = 'token';
  static const rt = 'refreshToken';

  static late final SharedPreferences _prefs;
  static late final FlutterSecureStorage _locker;

  static SharedPreferences get store => _prefs;
  static FlutterSecureStorage get locker => _locker;

  static bool isLoggedIn() => Db.token.isNotEmpty && Db.refreshToken.isNotEmpty;

  static Future<bool> init() async {
    _prefs = await SharedPreferences.getInstance();
    _locker = FlutterSecureStorage(
        aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ));
    return true;
  }

  static String get token => store.getString(t) ?? '';
  static set token(String? value) {
    store.setString(t, value ?? '');
  }

  static String get refreshToken => store.getString(rt) ?? '';
  static set refreshToken(String? value) {
    store.setString(rt, value ?? '');
  }
}
