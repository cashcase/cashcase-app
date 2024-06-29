import 'package:cashcase/core/db.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:word_generator/word_generator.dart';

class UserNotSetException implements Exception {
  UserNotSetException();
}

class AppDb extends Db {
  static String getEncryptionKeyString(String user) => "__cashcase_key_$user";
  static final String USER = "__cashcase_user__";
  static String getCurrentConnectionKey(String user) =>
      "__cashcase_current_connection_$user";

  static Future<bool> setCurrentConnection(User? user) async {
    var me = AppDb.getCurrentUser();
    if (me == null) throw UserNotSetException();
    if (user != null) {
      return await Db.store.setStringList(getCurrentConnectionKey(me), [
        user.username,
        user.firstName,
        user.lastName,
      ]);
    } else return Db.store.remove(getCurrentConnectionKey(me));
  }

  static User? getCurrentConnection() {
    var user = AppDb.getCurrentUser();
    if (user == null) throw UserNotSetException();
    var details = Db.store.getStringList(getCurrentConnectionKey(user));
    if (details == null) return null;
    return User.fromJson({
      "username": details[0],
      "firstName": details[1],
      "lastName": details[2],
    });
  }

  static Future<bool> setCurrentUser(String userId) async {
    var status = await Db.store.setString(USER, userId);
    return status;
  }

  static Future<bool> clearUser() async {
    var status = await Db.store.remove(USER);
    return status;
  }

  static String? getCurrentUser() {
    return Db.store.getString(USER) ?? null;
  }

  static Future<String?> getEncryptionKey() async {
    // await clearEncryptionKey();
    var user = AppDb.getCurrentUser();
    if (user == null) throw UserNotSetException();
    return await Db.locker.read(key: getEncryptionKeyString(user));
  }

  static Future<void> setEncryptionKey(String value) async {
    var user = AppDb.getCurrentUser();
    if (user == null) throw UserNotSetException();
    return await Db.locker
        .write(key: getEncryptionKeyString(user), value: value);
  }

  static Future<void> clearEncryptionKey() async {
    var user = AppDb.getCurrentUser();
    if (user == null) throw UserNotSetException();
    return await Db.locker.delete(key: getEncryptionKeyString(user));
  }

  static String getRandomKey() {
    final wordGenerator = WordGenerator();
    String key = "${wordGenerator.randomVerb()} "
        "${wordGenerator.randomNoun()} "
        "${wordGenerator.randomVerb()} "
        "${wordGenerator.randomNoun()} "
        "${wordGenerator.randomVerb()}";
    return key;
  }
}
