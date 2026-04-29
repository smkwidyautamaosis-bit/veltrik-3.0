class MaterialModel {
  final String id;
  final String title;
  final String description;
  final num price;
  final String filePath;

  MaterialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.filePath,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? '',
      price: json['price'] ?? 0,
      filePath: json['file_path']?.toString() ?? '',
    );
  }
}
