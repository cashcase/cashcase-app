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
      onTap: () => setState(() => selectedList = list.id),
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

  CheckList get selected => checklists.where((e) => e.id == selectedList).first;

  Future<void> delete(CheckListItem item) async {
    selected.items.remove(item);
    completionUpdater.value = !completionUpdater.value;
  }

  Future<void> deleteList(String id) async {
    checklists.removeWhere((e) => e.id == id);
    if (checklists.isNotEmpty) selectedList = checklists[0].id;
    setState(() => {});
  }

  Future<void> addList() async {
    String id = Uuid().v1();
    checklists.add(CheckList(
      title: "",
      id: id,
      items: [],
    ));
    selectedList = id;
    setState(() => {});
  }

  Future<void> reset() async {
    selected.items.forEach((e) => e.checked = false);
    setState(() => {});
  }

  Future<void> add() async {
    selected.items.add(
      CheckListItem(
        id: Uuid().v1(),
        label: "",
        checked: false,
      ),
    );
    setState(() => {});
  }

  Future<void> update(String id, String value) async {
    int i = selected.items.indexWhere((e) => e.id == id);
    selected.items[i].label = value;
  }

  final List<CheckList> checklists = [];

  ValueNotifier completionUpdater = ValueNotifier(false);

  generateNewCheckList(int index) {
    return CheckList(
      id: Uuid().v1(),
      title: generateRandomString(10),
      items: List.generate(
        Random().nextInt(15) + 1,
        (int index) => CheckListItem(
          id: Uuid().v1(),
          label: generateRandomString(
            Random().nextInt(100) + 20,
          ),
          checked: Random().nextInt(50).isEven,
        ),
      ),
    );
  }

  @override
  void initState() {
    // List<int>.generate(4, (int index) => index).forEach((each) {
    //   checklists.add(generateNewCheckList(each));
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Material(
            elevation: 20,
            child: Container(
              padding: EdgeInsets.all(8).copyWith(top: 0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      addList();
                    },
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (checklists.isNotEmpty)
                                ValueListenableBuilder(
                                  valueListenable: completionUpdater,
                                  builder: (_, __, ___) {
                                    int completedCount = selected.items
                                        .where((e) => e.checked)
                                        .length;
                                    int totalCount = selected.items.length;
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
                                            color:
                                                completedCount != totalCount ||
                                                        totalCount == 0
                                                    ? Colors.white
                                                    : Colors.green,
                                          ),
                                    );
                                  },
                                ),
                              SizedBox(width: 8),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      deleteList(selectedList);
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      child: Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      reset();
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      child: Icon(
                                        Icons.restore_rounded,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      add();
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
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
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                            Icons.hourglass_empty_rounded,
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
                                    children: selected.items.map((each) {
                                      return StatefulBuilder(
                                          key: Key(each.id),
                                          builder: (context, innerSetState) {
                                            if (selected.items
                                                .where((e) => e.id == each.id)
                                                .isEmpty) return Container();
                                            return Dismissible(
                                              direction:
                                                  DismissDirection.startToEnd,
                                              key: Key(each.id),
                                              background: Container(
                                                  color: Colors.red.shade800),
                                              onDismissed: (_) {
                                                delete(each);
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Transform.translate(
                                                    offset: const Offset(-8, 0),
                                                    child: Checkbox(
                                                      shape: CircleBorder(),
                                                      side: BorderSide(
                                                        width: 0.001,
                                                      ),
                                                      checkColor: Colors.black,
                                                      fillColor:
                                                          WidgetStateProperty
                                                              .all<Color>(
                                                        each.checked
                                                            ? Colors
                                                                .orangeAccent
                                                            : Colors.grey
                                                                .withOpacity(
                                                                    0.25),
                                                      ),
                                                      value: each.checked,
                                                      onChanged: (value) {
                                                        each.checked =
                                                            !each.checked;
                                                        completionUpdater
                                                                .value =
                                                            !completionUpdater
                                                                .value;
                                                        innerSetState(() => {});
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          Flexible(
                                                            child: TextField(
                                                              maxLines: null,
                                                              controller:
                                                                  TextEditingController(
                                                                text:
                                                                    each.label,
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                update(each.id,
                                                                    value);
                                                              },
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleMedium!
                                                                  .copyWith(
                                                                    color: each
                                                                            .checked
                                                                        ? Colors
                                                                            .grey
                                                                            .shade700
                                                                        : Colors
                                                                            .white,
                                                                    decorationThickness:
                                                                        1,
                                                                    decorationColor:
                                                                        Colors
                                                                            .grey
                                                                            .shade500,
                                                                    decoration: each
                                                                            .checked
                                                                        ? TextDecoration
                                                                            .lineThrough
                                                                        : null,
                                                                  ),
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                                focusedBorder:
                                                                    InputBorder
                                                                        .none,
                                                                disabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                enabledBorder:
                                                                    InputBorder
                                                                        .none,
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
                                    onReorder: (int oldIndex, int newIndex) {
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
      ),
    );
  }
}
