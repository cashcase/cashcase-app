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
    String path = join(await getDatabasesPath(), '$DB_NAME.db');
    // deleteDatabase(path);
    _db = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE IF NOT EXISTS "expense" (
            "id" text,
            "amount" text NOT NULL,
            "type" "type" NOT NULL,
            "category" text NOT NULL,
            "notes" text,
            "createdOn" int,
            "updatedOn" int,
            "user" text
          );
          // CREATE TABLE IF NOT EXISTS "category" (
          //   "name" text,
          //   "enabled" int,
          //   "isDefault" int
          // );
          // INSERT INTO category(name, enabled, isDefault) VALUES("housing", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("food", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("transport", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("healthcare", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("education", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("insurance", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("debt", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("travel", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("utilities", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("entertainment", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("donation", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("subscriptions", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("maintenance", 1, 1); 
          // INSERT INTO category(name, enabled, isDefault) VALUES("misc", 1, 1); 
          ''',
        );
      },
      version: 1,
    );
    return true;
  }
}
