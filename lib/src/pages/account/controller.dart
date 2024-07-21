import 'dart:io';

import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:sqflite/sqflite.dart';

class AccountController extends BaseController {
  AccountController();
  @override
  void initListeners() {}

  Future<DbResponse<List<Expense>>> getAllExpenses() async {
    try {
      String query = "SELECT * FROM expense;";
      final transaction = await Db.db.rawQuery(query);
      return DbResponse(
        status: true,
        data: transaction.map<Expense>((e) => Expense.fromJson(e)).toList(),
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not get expenses!",
    );
  }

  Future<void> import() async {
    final params = OpenFileDialogParams(
      fileExtensionsFilter: [Db.DB_EXTENSION],
      dialogType: OpenFileDialogType.document,
    );
    final String? filePath = await FlutterFileDialog.pickFile(params: params);
    if (filePath != null) {
      final db = await openDatabase(
        filePath,
        readOnly: true,
        singleInstance: false,
      );
      final transaction =
          await db.rawQuery("SELECT count(*) as count from expense;");
      print(transaction.first['count']);
      // Confirmation for whose data this is
      // Confirmation with total count
      db.close();
    }
  }

  Future<void> export(DirectoryLocation dir) async {
    String name =
        "cashcase_db_${DateTime.now().millisecondsSinceEpoch}.${Db.DB_EXTENSION}";
    File file = File(await Db.dbPath());
    await FlutterFileDialog.saveFileToDirectory(
      directory: dir,
      data: file.readAsBytesSync(),
      fileName: name,
      replace: true,
    );
  }
}
