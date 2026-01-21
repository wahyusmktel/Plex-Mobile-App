class SambutanModel {
  final String id;
  final String judul;
  final String? thumbnail;
  final String konten;
  final String createdAt;

  SambutanModel({
    required this.id,
    required this.judul,
    this.thumbnail,
    required this.konten,
    required this.createdAt,
  });

  factory SambutanModel.fromJson(Map<String, dynamic> json) {
    return SambutanModel(
      id: json['id']?.toString() ?? '',
      judul: json['judul']?.toString() ?? '',
      thumbnail: json['thumbnail_url']?.toString(),
      konten: json['konten']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
