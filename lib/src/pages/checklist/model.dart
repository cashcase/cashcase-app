class ChecklistPageData {}

class CheckListItem {
  String id;
  String label;
  bool checked;
  CheckListItem({
    required this.id,
    required this.label,
    required this.checked,
  });
  static CheckListItem fromJson(dynamic data) {
    return CheckListItem(
      id: data['id'],
      label: data['label'],
      checked: data['checked'],
    );
  }
}

class CheckList {
  String id;
  List<CheckListItem> items;
  String title;
  CheckList({
    required this.title,
    required this.id,
    required this.items,
  });
  static CheckList fromJson(dynamic data) {
    return CheckList(
      title: data['title'],
      id: data['id'],
      items: data['items'].map((e) => CheckListItem.fromJson(e)),
    );
  }
}
