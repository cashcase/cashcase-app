import 'dart:convert';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/src/pages/expenses/model.dart';

class AppDb extends Db {
  static String CATEGORIES_IDENTIFIER = "__cashcase_categories__";

  static init() {
    if (!Db.store.containsKey(CATEGORIES_IDENTIFIER)) {
      Map<String, bool> categories = {};
      for (var e in SpentCategories) {
        categories[e] = true;
      }
      setCategories(categories);
    }
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
