class PhotoModel {
  final String id;
  final String description;
  final String url;

  PhotoModel({required this.id, required this.description, required this.url});

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] ?? '',
      description: json['description'] ?? 'No description',
      url: json['urls']['small'] ?? '',
    );
  }
}
