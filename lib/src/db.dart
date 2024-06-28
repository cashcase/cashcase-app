import 'package:cashcase/core/db.dart';
import 'package:word_generator/word_generator.dart';

class UserNotSetException implements Exception {
  UserNotSetException();
}

class AppDb extends Db {
  static String getEncryptionKeyString(String user__) =>
      "__cashcase_key_$user__";
  static final String USER = "__cashcase_user__";

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
