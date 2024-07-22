import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Db {
  static late final SharedPreferences _prefs;
  static late final Database _db;

  static SharedPreferences get store => _prefs;
  static Database get db => _db;

  static final DB_NAME = '__cashcase__';
  static final DB_EXTENSION = 'ccdb';

  static dbPath() async => join(await getDatabasesPath(), '$DB_NAME.db');

  static Future<bool> init() async {
    _prefs = await SharedPreferences.getInstance();
    String path = await dbPath();
    // deleteDatabase(path);
    _db = await openDatabase(
      path,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE IF NOT EXISTS "expense" (
            "id" text UNIQUE,
            "amount" text NOT NULL,
            "type" NOT NULL,
            "category" text NOT NULL,
            "notes" text,
            "createdOn" int,
            "updatedOn" int,
            "user" text
          );
          ''');
        db.execute('''
          CREATE TABLE IF NOT EXISTS "checklist" (
            "id" text UNIQUE,
            "label" text
          );
          ''');
        db.execute('''
          CREATE TABLE IF NOT EXISTS "checklistitem" (
            "id" text UNIQUE,
            "parent" text NOT NULL,
            "label" text,
            "checked" int
          );
          ''');
      },
      version: 1,
    );
    return true;
  }
}
