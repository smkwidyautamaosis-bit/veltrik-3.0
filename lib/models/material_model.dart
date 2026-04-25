class MaterialModel {
  final String id;
  final String title;
  final String description;
  final num price; // Menggunakan num agar fleksibel (integer/desimal)
  final String filePath;

  MaterialModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.filePath,
  });

  // Fungsi untuk mengubah data mentah JSON dari Supabase menjadi Model Dart
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Tanpa Judul',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      filePath: json['file_path'] ?? '',
    );
  }
}
