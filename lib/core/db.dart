import 'dart:math';

import 'package:cashcase/core/app/notification.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:cashcase/src/pages/trends/controller.dart';
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
    final refreshDb = !true;
    _prefs = await SharedPreferences.getInstance();
    String path = await dbPath();
    if (refreshDb) deleteDatabase(path);
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
            "date" int,
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
    if (refreshDb) {
      var tags = {'transport': 30, 'grocery': 150, 'food': 50};
      for (var tag in tags.keys) {
        DateTime current =
            DateTime.now().startOfDay().subtract(Duration(days: 90));
        int n = 0;
        while (n < 91) {
          await TrendsController.createExpense(
            amount: Random().nextInt(tags[tag]!).toDouble(),
            type: ExpenseType.SPENT,
            category: tag,
            createdOn: current,
          );
          current = current.add(Duration(days: 1));
          n = n + 1;
        }
      }
    }

    return true;
  }
}
