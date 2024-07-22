import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/core/utils/models.dart';
import 'package:cashcase/src/components/confirm.dart';
import 'package:cashcase/src/models.dart';
import 'package:cashcase/src/pages/checklist/controller.dart';
import 'package:cashcase/src/pages/checklist/model.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:uuid/uuid.dart';

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

class ChecklistView extends StatefulWidget {
  @override
  State<ChecklistView> createState() => _ChecklistViewState();
}

class CategoryModel {
  String label;
  bool enabled;
  CategoryModel({required this.label, required this.enabled});
}

class _ChecklistViewState extends State<ChecklistView> {
  TextEditingController newCategory = TextEditingController(text: "");
  String? newCategoryError;
  List<CategoryModel> Checklist = [];

  String selectedList = "";

  Widget checklistCircle(CheckList list) {
    bool isSelected = selectedList == list.id;
    return GestureDetector(
      onTap: () {
        setSelectedList(list.id);
        setState(() => {});
      },
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orangeAccent : Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            (checklists.indexOf(list) + 1).toString(),
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }

  List<CheckList> checklists = [];

  ValueNotifier completionUpdater = ValueNotifier(false);

  Future<DbResponse<List<CheckList>>> get getCheckListsFuture {
    return ChecklistController.getChecklists();
  }

  @override
  void initState() {
    super.initState();
  }

  CheckList get selected => checklists.where((e) => e.id == selectedList).first;

  Future<bool?> delete(CheckListItem item) async {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return ConfirmationDialog(
          message: "Are you sure you want to delete this item?",
          okLabel: "No",
          cancelLabel: "Yes",
          cancelColor: Colors.red,
          onOk: () => Navigator.pop(context),
          onCancel: () async {
            final response =
                await ChecklistController.deleteChecklistItem(item.id);
            if (!response.status) {
              return context.once<AppController>().addNotification(
                  NotificationType.error, "Could not delete check list item");
            }
            selected.items.remove(item);
            setState(() => {});
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> deleteList(String id) async {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return ConfirmationDialog(
          message: "Are you sure you want to delete this list?",
          okLabel: "No",
          cancelLabel: "Yes",
          cancelColor: Colors.red,
          onOk: () => Navigator.pop(context),
          onCancel: () async {
            final response = await ChecklistController.deleteChecklist(id);
            if (!response.status) {
              return context.once<AppController>().addNotification(
                  NotificationType.error, "Could not delete check list");
            }
            checklists.removeWhere((e) => e.id == id);
            setSelectedList(checklists.isNotEmpty ? checklists[0].id : "");
            setState(() => {});
          },
        );
      },
    );
  }

  Future<void> addList() async {
    String id = Uuid().v1();
    final response = await ChecklistController.createChecklist(id, "");
    if (!response.status) {
      return context.once<AppController>().addNotification(
          NotificationType.error, "Could not add new check list");
    }
    checklists.add(CheckList(
      label: "",
      id: id,
      items: [],
    ));
    selectedList = id;
    setState(() => {});
  }

  Future<void> reset() async {
    selected.items.forEach((e) async {
      final response = await ChecklistController.updateChecklistItem(
          selectedList, e.id, e.label, false);
      if (!response.status) {
        return context.once<AppController>().addNotification(
            NotificationType.error, "Could not updated check list item");
      }
      e.checked = false;
    });
    setState(() => {});
  }

  Future<void> add() async {
    String id = Uuid().v1();
    final response =
        await ChecklistController.createChecklistItem(selectedList, id);
    if (!response.status) {
      return context.once<AppController>().addNotification(
          NotificationType.error, "Could not add new check list item");
    }
    selected.items.add(
      CheckListItem(
        id: id,
        label: "",
        checked: false,
      ),
    );
    setState(() => {});
  }

  Future<void> update(String id, String value, bool checked) async {
    final response = await ChecklistController.updateChecklistItem(
        selectedList, id, value, checked);
    if (!response.status) {
      return context.once<AppController>().addNotification(
          NotificationType.error, "Could not updated check list item");
    }
    setState(() => {});
  }

  Map<String, TextEditingController> controllers = {};

  setSelectedList(String id) {
    controllers = {};
    if (checklists.isEmpty)
      selectedList = "";
    else {
      selectedList = id;
      for (var each in selected.items) {
        controllers[each.id] = TextEditingController(text: each.label);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: FutureBuilder(
            future: getCheckListsFuture,
            builder: (context, snapshot) {
              var isDone = snapshot.connectionState == ConnectionState.done;
              if (isDone && !snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.orangeAccent,
                  ),
                );
              }
              if (snapshot.data?.status == false ||
                  snapshot.data?.data == null) {
                return Center(
                  child: Text(
                    "Unable to get checklists. \nTry again later.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Colors.white30,
                        ),
                  ),
                );
              }
              checklists = snapshot.data?.data as List<CheckList>;
              if (selectedList == "" && checklists.isNotEmpty) {
                setSelectedList(checklists.first.id);
              }
              return Row(
                children: [
                  Material(
                    elevation: 20,
                    child: Container(
                      padding: EdgeInsets.all(8).copyWith(top: 0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: addList,
                            child: Container(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.orangeAccent,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: checklists.map<Widget>((e) {
                                  return checklistCircle(e);
                                }).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8)),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 32,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (checklists.isNotEmpty)
                                        Builder(
                                          builder: (_) {
                                            int completedCount = selected.items
                                                .where((e) => e.checked)
                                                .length;
                                            int totalCount =
                                                selected.items.length;
                                            return Text(
                                              totalCount == 0
                                                  ? "Checklist #${checklists.indexWhere((e) => e.id == selected.id) + 1}"
                                                  : completedCount == totalCount
                                                      ? "Done!"
                                                      : "${completedCount}/${totalCount} Complete",
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .copyWith(
                                                    color: completedCount !=
                                                                totalCount ||
                                                            totalCount == 0
                                                        ? Colors.white
                                                        : Colors.green,
                                                  ),
                                            );
                                          },
                                        ),
                                      SizedBox(width: 8),
                                      if (selectedList.isNotEmpty)
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                deleteList(selectedList);
                                              },
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                color: Colors.transparent,
                                                child: Icon(
                                                  Icons.delete_rounded,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: reset,
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                color: Colors.transparent,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.restore_rounded,
                                                    color: Colors.orangeAccent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: add,
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                color: Colors.transparent,
                                                child: Icon(
                                                  Icons.add_rounded,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                if (checklists.isEmpty)
                                  Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.hourglass_empty_rounded,
                                            color: Colors.white12,
                                            size: 48,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "No Checklists",
                                            style: TextStyle(
                                              color: Colors.white24,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if (checklists.isNotEmpty)
                                  Expanded(
                                    child: selected.items.isEmpty
                                        ? Container(
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .hourglass_empty_rounded,
                                                    color: Colors.white12,
                                                    size: 48,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "No items",
                                                    style: TextStyle(
                                                      color: Colors.white24,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : ReorderableListView(
                                            children:
                                                selected.items.map((each) {
                                              return StatefulBuilder(
                                                  key: Key(each.id),
                                                  builder:
                                                      (context, innerSetState) {
                                                    if (selected.items
                                                        .where((e) =>
                                                            e.id == each.id)
                                                        .isEmpty)
                                                      return Container();
                                                    return Dismissible(
                                                      direction:
                                                          DismissDirection
                                                              .startToEnd,
                                                      key: Key(each.id),
                                                      background: Container(
                                                          color: Colors
                                                              .red.shade800),
                                                      confirmDismiss: (_) {
                                                        return delete(each);
                                                      },
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Transform.translate(
                                                            offset:
                                                                const Offset(
                                                                    -8, 0),
                                                            child: Checkbox(
                                                              shape:
                                                                  CircleBorder(),
                                                              side: BorderSide(
                                                                width: 0.001,
                                                              ),
                                                              checkColor:
                                                                  Colors.black,
                                                              fillColor:
                                                                  WidgetStateProperty
                                                                      .all<
                                                                          Color>(
                                                                each.checked
                                                                    ? Colors
                                                                        .orangeAccent
                                                                    : Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.25),
                                                              ),
                                                              value:
                                                                  each.checked,
                                                              onChanged:
                                                                  (value) {
                                                                if (each.label
                                                                    .isEmpty)
                                                                  return;
                                                                update(
                                                                    each.id,
                                                                    each.label,
                                                                    !each
                                                                        .checked);
                                                                innerSetState(
                                                                    () => {});
                                                              },
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              child: Row(
                                                                children: <Widget>[
                                                                  Flexible(
                                                                    child:
                                                                        TextField(
                                                                      maxLines:
                                                                          null,
                                                                      controller:
                                                                          controllers[
                                                                              each.id],
                                                                      onChanged:
                                                                          (value) {
                                                                        update(
                                                                          each.id,
                                                                          value,
                                                                          each.checked,
                                                                        );
                                                                      },
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .titleMedium!
                                                                          .copyWith(
                                                                            color: each.checked
                                                                                ? Colors.grey.shade700
                                                                                : Colors.white,
                                                                            decorationThickness:
                                                                                1,
                                                                            decorationColor:
                                                                                Colors.grey.shade500,
                                                                            decoration: each.checked
                                                                                ? TextDecoration.lineThrough
                                                                                : null,
                                                                          ),
                                                                      decoration:
                                                                          InputDecoration(
                                                                        hintStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white24,
                                                                        ),
                                                                        hintText:
                                                                            "Item #${(selected.items.indexWhere((e) => e.id == each.id) + 1).toString()}",
                                                                        border:
                                                                            OutlineInputBorder(),
                                                                        focusedBorder:
                                                                            InputBorder.none,
                                                                        disabledBorder:
                                                                            InputBorder.none,
                                                                        enabledBorder:
                                                                            InputBorder.none,
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            }).toList(),
                                            onReorder:
                                                (int oldIndex, int newIndex) {
                                              // setState(() {
                                              //   if (oldIndex < newIndex) {
                                              //     newIndex -= 1;
                                              //   }
                                              //   final int item = _items.removeAt(oldIndex);
                                              //   _items.insert(newIndex, item);
                                              // });
                                            },
                                          ),
                                  )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}
