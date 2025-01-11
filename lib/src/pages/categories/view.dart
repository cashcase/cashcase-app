import 'package:cashcase/core/app/controller.dart';
import 'package:cashcase/core/utils/extensions.dart';
import 'package:cashcase/src/components/text-field.dart';
import 'package:cashcase/src/db.dart';
import 'package:cashcase/src/pages/expenses/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoriesView extends StatefulWidget {
  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class CategoryModel {
  String label;
  bool enabled;
  CategoryModel({required this.label, required this.enabled});
}

class _CategoriesViewState extends State<CategoriesView> {
  TextEditingController newCategory = TextEditingController(text: "");
  String? newCategoryError;
  List<CategoryModel> categories = [];
  @override
  void initState() {
    var _categories = AppDb.getCategories();
    categories = _categories.keys
        .toList()
        .map((e) => CategoryModel(label: e, enabled: _categories[e]))
        .toList();
    categories.sort((a, b) => a.label.compareTo(b.label));
    super.initState();
  }

  Future<void> saveCategories() async {
    try {
      context.once<AppController>().startLoading();
      Map<String, bool> _categories = {};
      for (var each in categories) {
        _categories[each.label] = each.enabled;
      }
      await AppDb.setCategories(_categories);
    } catch (e) {
    } finally {
      categories.sort((a, b) => a.label.compareTo(b.label));
      setState(() => {});
      context.once<AppController>().stopLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        title: Text(
          "Manage Categories",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add/Remove or Enable/Disable categories from here. Disabled categories will not be displayed in the Expense screen. Categories can only be alphabets with length between 3 to 20. Default categories can only be disabled.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 16),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: "Add new category",
                      controller: newCategory,
                      error: newCategoryError,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]")),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      newCategoryError = null;
                      if (newCategory.text.isEmpty) {
                        newCategoryError = 'Category label cannot be empty';
                      }
                      if (categories.any(
                          (e) => e.label == newCategory.text.toLowerCase())) {
                        newCategoryError = 'Category already exists';
                      }

                      if (newCategoryError != null) {
                        return setState(() => {});
                      }

                      categories.add(
                        CategoryModel(
                          label: newCategory.text.toLowerCase(),
                          enabled: true,
                        ),
                      );
                      saveCategories();
                      newCategory.text = "";
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.orangeAccent),
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  var category = categories[index];
                  return ListTile(
                    onTap: () {
                      category.enabled = !category.enabled;
                      saveCategories();
                    },
                    contentPadding: EdgeInsets.all(0),
                    title: Text(
                      category.label.toCamelCase(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    trailing: SpentCategories.contains(category.label)
                        ? null
                        : GestureDetector(
                            onTap: () {
                              categories.removeAt(index);
                              saveCategories();
                            },
                            child: Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Colors.red,
                            ),
                          ),
                    leading: Checkbox(
                      activeColor: Colors.orangeAccent,
                      value: categories[index].enabled,
                      onChanged: (value) {
                        if (value == null) return;
                        category.enabled = value;
                        saveCategories();
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
