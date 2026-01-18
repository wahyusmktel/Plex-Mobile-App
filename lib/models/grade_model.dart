class GradeModel {
  final String id;
  final String cbtName;
  final String subjectName;
  final double skor;
  final double skorMaksimal;
  final String tanggal;
  final String createdAt;

  GradeModel({
    required this.id,
    required this.cbtName,
    required this.subjectName,
    required this.skor,
    required this.skorMaksimal,
    required this.tanggal,
    required this.createdAt,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] ?? '',
      cbtName: json['cbt_name'] ?? '',
      subjectName: json['subject_name'] ?? '',
      skor: (json['skor'] ?? 0).toDouble(),
      skorMaksimal: (json['skor_maksimal'] ?? 100).toDouble(),
      tanggal: json['tanggal'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
