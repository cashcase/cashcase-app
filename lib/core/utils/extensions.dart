extension StringConverters on String {
  toCamelCase() {
    if (isEmpty) return '';
    String c = replaceAll('_', " ")
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
    return c
        .split(" ")
        .map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}")
        .toList()
        .join(" ");
  }
}
