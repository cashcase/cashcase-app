import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Db {
  static late final SharedPreferences _prefs;
  static late final FlutterSecureStorage _locker;
  static late final Database _db;

  static SharedPreferences get store => _prefs;
  static FlutterSecureStorage get locker => _locker;
  static Database get db => _db;

  static final DB_NAME = '__cashcase__';

  static Future<bool> init() async {
    _prefs = await SharedPreferences.getInstance();
    _locker = FlutterSecureStorage(
        aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ));
    _db = await openDatabase(
      join(await getDatabasesPath(), '$DB_NAME.db'),
      onCreate: (db, version) {
        // return db.execute(
        //   'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        // );
      },
      version: 1,
    );
    return true;
  }
}
