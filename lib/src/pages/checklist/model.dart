class ChecklistPageData {}

class CheckListItem {
  String label;
  bool checked;
  CheckListItem({
    required this.label,
    required this.checked,
  });
  static CheckListItem fromJson(dynamic data) {
    return CheckListItem(
      label: data['label'],
      checked: data['checked'],
    );
  }
}

class CheckList {
  int index;
  String id;
  List<CheckListItem> items;
  String title;
  CheckList({
    required this.title,
    required this.id,
    required this.index,
    required this.items,
  });
  static CheckList fromJson(dynamic data) {
    return CheckList(
      title: data['title'],
      id: data['id'],
      index: data['index'],
      items: data['items'].map((e) => CheckListItem.fromJson(e)),
    );
  }
}
