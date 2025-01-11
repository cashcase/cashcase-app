import 'package:cashcase/core/base/controller.dart';
import 'package:cashcase/core/db.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/checklist/model.dart';
import 'package:sqflite/sqlite_api.dart';

class ChecklistController extends BaseController {
  @override
  void initListeners() {}

  ChecklistController({ChecklistPageData? data});

  static Future<DbResponse<List<CheckList>>> getChecklists() async {
    try {
      var transaction = await Db.db.query("checklist");
      List<CheckList> checklists = [];
      for (var each in transaction) {
        transaction = await Db.db
            .query("checklistitem", where: "parent = '${each['id']}';");
        CheckList checklist =
            CheckList.fromJson({...each, 'items': transaction});
        checklists.add(checklist);
      }
      return DbResponse(
        status: true,
        data: checklists,
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not create checklist!",
    );
  }

  static Future<DbResponse<bool>> createChecklist(
      String id, String label) async {
    try {
      final transaction = await Db.db.insert(
        "checklist",
        {
          "id": id,
          "label": label,
        },
      );
      return DbResponse(
        status: transaction > 0,
        data: true,
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not create checklist!",
    );
  }

  static Future<DbResponse<bool>> createChecklistItem(
    String parent,
    String id,
  ) async {
    try {
      final transaction = await Db.db.insert(
        "checklistitem",
        {
          "id": id,
          "parent": parent,
          "label": "",
          "checked": 0,
        },
      );
      return DbResponse(
        status: transaction > 0,
        data: true,
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not create checklist item!",
    );
  }

  static Future<DbResponse<bool>> updateChecklistItem(
      String parent, String id, String label, bool checked) async {
    try {
      final transaction = await Db.db.update(
        "checklistitem",
        {
          "id": id,
          "parent": parent,
          "label": label,
          "checked": checked ? 1 : 0,
        },
        where: "id = '${id}'",
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return DbResponse(
        status: transaction > 0,
        data: true,
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not update checklist item!",
    );
  }

  static Future<DbResponse<bool>> deleteChecklistItem(String id) async {
    try {
      final transaction =
          await Db.db.delete("checklistitem", where: "id = '${id}'");
      return DbResponse(
        status: transaction > 0,
        data: true,
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not delete checklist item!",
    );
  }

  static Future<DbResponse<bool>> deleteChecklist(String id) async {
    try {
      final transaction =
          await Db.db.delete("checklist", where: "id = '${id}'");
      return DbResponse(
        status: transaction > 0,
        data: true,
      );
    } catch (e) {}
    return DbResponse(
      status: false,
      data: null,
      error: "Could not create checklist!",
    );
  }
}
