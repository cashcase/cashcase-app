import 'dart:convert';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:uuid/uuid.dart';

class AppDb extends Db {
  static String CATEGORIES_IDENTIFIER = "__cashcase_categories__";
  static String CURRENT_USER = "__cashcase_current_user__";

  static init() {
    if (!Db.store.containsKey(CATEGORIES_IDENTIFIER)) {
      Map<String, bool> categories = {};
      for (var e in SpentCategories) {
        categories[e] = true;
      }
      setCategories(categories);
    }

    if (!Db.store.containsKey(CURRENT_USER)) {
      setCurrentUser(Uuid().v1());
    } else {
      print("Current user is ${getCurrentUser()}");
    }
  }

  static getCurrentUser() {
    return Db.store.getString(CURRENT_USER);
  }

  static setCurrentUser(String id) async {
    Db.store.setString(CURRENT_USER, id);
  }

  static Future<bool> setCategories(Map<String, bool> categories) async {
    return await Db.store
        .setString(CATEGORIES_IDENTIFIER, json.encode(categories));
  }

  static Map<String, dynamic> getCategories() {
    String _categories = Db.store.getString(CATEGORIES_IDENTIFIER) ?? "";
    Map<String, dynamic> categories = json.decode(_categories);
    return categories;
  }
}
