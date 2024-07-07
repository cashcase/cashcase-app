import 'dart:convert';
import 'dart:typed_data';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/src/pages/account/model.dart';
import 'package:word_generator/word_generator.dart';
import "package:pointycastle/export.dart";
import 'package:encrypt/encrypt.dart' as encrypt;

class UserNotSetException implements Exception {
  UserNotSetException();
}

class Encrypter {
  static final IV = 'abcdefghijklmnop';
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

  static Uint8List deriveKey(String privateKey, String salt) {
    final saltBytes = utf8.encode(salt);
    final keyBytes = utf8.encode(privateKey);

    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    final params = Pbkdf2Parameters(saltBytes, 1000, 32);
    pbkdf2.init(params);
    return pbkdf2.process(Uint8List.fromList(keyBytes));
  }

  static String encryptDecimalString(
      String decimalString, String privateKey) {
    final derivedKey = deriveKey(privateKey, IV);

    final key = encrypt.Key(derivedKey);
    final iv =
        encrypt.IV.fromSecureRandom(16); // Use a random IV for each encryption
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final encrypted = encrypter.encrypt(decimalString, iv: iv);
    final ivAndEncrypted = iv.bytes + encrypted.bytes;

    return base64.encode(ivAndEncrypted);
  }

  static String decryptDecimalString(
      String encryptedString, String privateKey) {
    final derivedKey = deriveKey(privateKey, IV);

    final key = encrypt.Key(derivedKey);
    final ivAndEncryptedBytes = base64.decode(encryptedString);
    final iv = encrypt.IV(ivAndEncryptedBytes.sublist(0, 16));
    final encryptedBytes = ivAndEncryptedBytes.sublist(16);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final decrypted = encrypter
        .decrypt(encrypt.Encrypted(Uint8List.fromList(encryptedBytes)), iv: iv);

    return decrypted;
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
