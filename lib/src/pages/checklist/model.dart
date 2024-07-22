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
      checked: data['checked'] == 1,
    );
  }
}

class CheckList {
  String id;
  List<CheckListItem> items;
  String label;
  CheckList({
    required this.label,
    required this.id,
    required this.items,
  });
  static CheckList fromJson(dynamic data) {
    return CheckList(
      label: data['label'],
      id: data['id'],
      items: (data['items'] ?? [])
          .map<CheckListItem>((e) => CheckListItem.fromJson(e))
          .toList(),
    );
  }
}
