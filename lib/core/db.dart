import 'package:shared_preferences/shared_preferences.dart';

class Db {
  static const t = 'token';
  static const rt = 'refreshToken';

  static late final SharedPreferences _prefs;

  static SharedPreferences get store => _prefs;

  static bool isLoggedIn() => Db.token.isNotEmpty && Db.refreshToken.isNotEmpty;

  static Future<bool> init() async {
    _prefs = await SharedPreferences.getInstance();
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
