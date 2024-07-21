import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
  }

  int selectedIndex = -1;
  int count = 0;

  checklistCircle(int index, bool selected) {
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
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.orangeAccent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          count,
                          (index) => checklistCircle(index, selectedIndex == index),
                        ),
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
                  
            ),
          )
        ],
      ),
    );
  }
}
