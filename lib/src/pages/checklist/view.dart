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

  int selectedIndex = 0;
  int count = 0;

  Widget checklistCircle(int index, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        width: 40,
        height: 40,
        margin: EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.orangeAccent
              : Colors.orangeAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            (index + 1).toString(),
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontWeight: selected ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }

  delete(int index) {}

  reset(int index) {}

  final List<CheckList> checklists = [];

  @override
  void initState() {
    List<int>.generate(4, (int index) => index).forEach((each) {
      checklists.add(
        CheckList(
          id: Uuid().v1(),
          index: each,
          title: generateRandomString(10),
          items: List.generate(
            Random().nextInt(15) + 1,
            (int index) => CheckListItem(
              label: generateRandomString(
                Random().nextInt(100) + 20,
              ),
              checked: Random().nextInt(50).isEven,
            ),
          ),
        ),
      );
    });
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
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => count += 1),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: checklists.map<Widget>((e) {
                          return checklistCircle(
                              e.index, selectedIndex == e.index);
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
                  // Positioned(
                  //   bottom: 16,
                  //   right: 16,
                  //   child: Column(
                  //     children: [
                  //       GestureDetector(
                  //         onTap: () => delete(selectedIndex),
                  //         child: Container(
                  //           width: 40,
                  //           height: 40,
                  //           decoration: BoxDecoration(
                  //             color: Colors.red.shade900,
                  //             borderRadius: BorderRadius.circular(
                  //               100,
                  //             ),
                  //           ),
                  //           child: Center(
                  //             child: Icon(
                  //               Icons.delete_rounded,
                  //               color: Colors.red.shade200,
                  //               size: 20,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(height: 8),
                  //       GestureDetector(
                  //         onTap: () => reset(selectedIndex),
                  //         child: Container(
                  //           width: 40,
                  //           height: 40,
                  //           decoration: BoxDecoration(
                  //             color: Colors.orangeAccent,
                  //             borderRadius: BorderRadius.circular(
                  //               100,
                  //             ),
                  //           ),
                  //           child: Center(
                  //             child: Icon(
                  //               Icons.restore_rounded,
                  //               color: Colors.black,
                  //               size: 20,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // checklists[selectedIndex].title,
                          "Checklist #${selectedIndex + 1}",
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            child: ReorderableListView(
                              children:
                                  checklists[selectedIndex].items.map((each) {
                                return StatefulBuilder(
                                    key: Key(each.label),
                                    builder: (context, innerSetState) {
                                      return Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Transform.scale(
                                                scale: 1.2,
                                                child: Checkbox(
                                                  shape: CircleBorder(),
                                                  side: BorderSide(
                                                    width: 0.001,
                                                  ),
                                                  checkColor: Colors.black,
                                                  fillColor: WidgetStateProperty
                                                      .all<Color>(
                                                          Colors.orangeAccent),
                                                  value: each.checked,
                                                  onChanged: (value) {
                                                    each.checked = !each.checked;
                                                    innerSetState(() => {});
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: TextField(
                                                        maxLines: null,
                                                        controller:
                                                            TextEditingController(
                                                          text: each.label,
                                                        ),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(
                                                              color: each
                                                                      .checked
                                                                  ? Colors.grey
                                                                  : Colors
                                                                      .white,
                                                              decorationThickness:
                                                                  1,
                                                              decorationColor:
                                                                  Colors.grey.shade300,
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
