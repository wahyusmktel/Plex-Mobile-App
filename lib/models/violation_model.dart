class ViolationModel {
  final String id;
  final String? studentName;
  final String? nisn;
  final String? schoolName;
  final String? violationName;
  final int points;
  final DateTime createdAt;
  final String? description;

  ViolationModel({
    required this.id,
    this.studentName,
    this.nisn,
    this.schoolName,
    this.violationName,
    required this.points,
    required this.createdAt,
    this.description,
  });

  factory ViolationModel.fromJson(Map<String, dynamic> json) {
    // Poin might be in the masterPelanggaran or directly in violation if duplicated
    int p = 0;
    if (json['poin'] != null) {
      p = int.tryParse(json['poin'].toString()) ?? 0;
    } else if (json['master_pelanggaran']?['poin'] != null) {
      p = int.tryParse(json['master_pelanggaran']['poin'].toString()) ?? 0;
    }

    return ViolationModel(
      id: json['id']?.toString() ?? '',
      studentName: json['siswa']?['nama_lengkap'],
      nisn: json['siswa']?['nisn'],
      schoolName: json['school']?['nama_sekolah'],
      violationName: json['master_pelanggaran']?['nama'],
      points: p,
      createdAt: DateTime.parse(json['created_at']),
      description: json['deskripsi'],
    );
  }
}
