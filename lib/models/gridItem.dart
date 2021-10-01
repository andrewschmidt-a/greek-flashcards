class GridItem {
  String path;
  String type;
  String title;

  GridItem({
    required this.title,
    required this.path,
    required this.type,
  });

  factory GridItem.fromJson(Map<String, dynamic> json) {
    return GridItem(
      title: json['title'],
      path: json['path'],
      type: json['type'],
    );
  }
}
