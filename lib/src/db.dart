import 'dart:typed_data';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:word_generator/word_generator.dart';
import "package:pointycastle/export.dart";

class UserNotSetException implements Exception {
  UserNotSetException();
}

class Encrypter {
  static final IV = '137d1fbc211e4bf9';
  static final PAD = '=';

  static String padStringTo32Chars(String input, {int length = 32}) {
    while (input.length < length) {
      input += PAD;
    }
    return input;
  }

  static String unpadString(String input) {
    return input.split(PAD).first;
  }

  static stringToUint8list(String value) {
    List<int> list = value.codeUnits;
    Uint8List bytes = Uint8List.fromList(list);
    return bytes;
  }

  static String encrypt(String data, String key) {
    try {
      key = padStringTo32Chars(key.replaceAll(" ", ""));
      data = padStringTo32Chars(data);
      Uint8List _data = stringToUint8list(data);

      Uint8List _key = stringToUint8list(key);
      Uint8List iv = stringToUint8list(IV);
      final cbc = CBCBlockCipher(AESEngine())
        ..init(true, ParametersWithIV(KeyParameter(_key), iv)); // true=encrypt
      Uint8List cipherText = Uint8List(_data.length); // allocate space
      var offset = 0;
      while (offset < data.length) {
        offset += cbc.processBlock(_data, offset, cipherText, offset);
      }
      String string = new String.fromCharCodes(cipherText);
      return string;
    } catch (e) {
      throw e;
    }
  }

  static String decrypt(String data, String key) {
    try {
      key = padStringTo32Chars(key.replaceAll(" ", ""));
      Uint8List _key = stringToUint8list(key);
      Uint8List iv = stringToUint8list(IV);
      final cbc = CBCBlockCipher(AESEngine())
        ..init(
            false, ParametersWithIV(KeyParameter(_key), iv)); // false=decrypt
      Uint8List _data = stringToUint8list(data);
      Uint8List paddedPlainText = Uint8List(_data.length); // allocate space
      var offset = 0;
      while (offset < _data.length) {
        offset += cbc.processBlock(_data, offset, paddedPlainText, offset);
      }
      String string = unpadString(String.fromCharCodes(paddedPlainText));
      return string;
    } catch (e) {
      throw e;
    }
  }

  static String generateRandomKey() {
    final wordGenerator = WordGenerator();
    String key = "";
    while (key.length == 0 || key.length >= 30) {
      key = "${wordGenerator.randomVerb()} "
          "${wordGenerator.randomNoun()} "
          "${wordGenerator.randomVerb()} "
          "${wordGenerator.randomNoun()} ";
    }
    return key;
  }
}

class AppDb extends Db {
  static String getEncryptionIdentifier(String user) => "__cashcase_key_$user";
  static final String CURRENT_USER_IDENTIFIER = "__cashcase_user__";

  static String CURRENT_USER_EKEY = "";
  static String CONNECTED_USER_EKEY = "";

  static Map<String, String> ekeys = {};

  static Future<void> loadEncyptionKeys() async {}
  static Future<bool> setCurrentPair(User? user) async {
    var me = AppDb.getCurrentUser();
    if (me == null) throw UserNotSetException();
    if (user != null) {
      return await Db.store.setStringList(getEncryptionIdentifier(me), [
        user.username,
        user.firstName,
        user.lastName,
      ]);
    } else
      return Db.store.remove(getEncryptionIdentifier(me));
  }

  static User? getCurrentPair() {
    var user = AppDb.getCurrentUser();
    if (user == null) throw UserNotSetException();
    var details = Db.store.getStringList(getEncryptionIdentifier(user));
    if (details == null) return null;
    return User.fromJson({
      "username": details[0],
      "firstName": details[1],
      "lastName": details[2],
    });
  }

  static Future<bool> setCurrentUser(String userId) async {
    var status1 = await Db.store.setString(CURRENT_USER_IDENTIFIER, userId);
    return status1;
  }

  static Future<bool> clearCurrentUser() async {
    var status = await Db.store.remove(CURRENT_USER_IDENTIFIER);
    return status;
  }

  static Future<void> clearEncryptionKey() async {
    var user = AppDb.getCurrentUser();
    if (user == null) throw UserNotSetException();
    await Db.locker.delete(key: getEncryptionIdentifier(user));
  }

  static String? getCurrentUser() {
    var user = Db.store.getString(CURRENT_USER_IDENTIFIER) ?? null;
    if (user == null) throw UserNotSetException();
    return user;
  }

  static Future<List<String?>> getEncryptionKeyOfPair() async {
    var myKey = await getEncryptionKey();
    var pair = getCurrentPair();
    if (pair != null) {
      var pairKey = await getEncryptionKey(username: pair.username);
      return [myKey, pairKey];
    } else
      return [myKey];
  }

  static Future<String?> getEncryptionKey({String? username}) async {
    // await clearEncryptionKey();
    if (username == null) {
      var user = AppDb.getCurrentUser();
      if (user == null) throw UserNotSetException();
      return await Db.locker.read(key: getEncryptionIdentifier(user));
    } else {
      return await Db.locker.read(key: getEncryptionIdentifier(username));
    }
  }

  static Future<void> setEncryptionKey(String value, {String? user}) async {
    if (user == null) user = AppDb.getCurrentUser();
    return await Db.locker
        .write(key: getEncryptionIdentifier(user!), value: value);
  }
}
