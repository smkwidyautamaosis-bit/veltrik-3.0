class MaterialModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final String filePath;

  MaterialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.filePath,
  });

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      filePath: map['file_path'] ?? '',
    );
  }
}
