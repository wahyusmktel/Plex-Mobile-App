class SliderModel {
  final String id;
  final String judul;
  final String? deskripsi;
  final String gambarUrl;
  final String? link;

  SliderModel({
    required this.id,
    required this.judul,
    this.deskripsi,
    required this.gambarUrl,
    this.link,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id']?.toString() ?? '',
      judul: json['judul'] ?? 'Untitled',
      deskripsi: json['deskripsi'],
      gambarUrl: json['gambar_url'] ?? '',
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'gambar_url': gambarUrl,
      'link': link,
    };
  }
}
