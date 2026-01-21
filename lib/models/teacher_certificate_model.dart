class TeacherCertificateModel {
  final String id;
  final String name;
  final String schoolId;
  final String? teacherId;
  final String? description;
  final int year;
  final String expiryType;
  final DateTime? expiryDate;
  final int? expiryYear;
  final String filePath;

  TeacherCertificateModel({
    required this.id,
    required this.name,
    required this.schoolId,
    this.teacherId,
    this.description,
    required this.year,
    required this.expiryType,
    this.expiryDate,
    this.expiryYear,
    required this.filePath,
  });

  factory TeacherCertificateModel.fromJson(Map<String, dynamic> json) {
    return TeacherCertificateModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      schoolId: json['school_id']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString(),
      description: json['description'],
      year: json['year'] is int
          ? json['year']
          : int.tryParse(json['year'].toString()) ?? 0,
      expiryType: json['expiry_type'] ?? 'none',
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'])
          : null,
      expiryYear: json['expiry_year'] is int
          ? json['expiry_year']
          : int.tryParse(json['expiry_year'].toString()),
      filePath: json['file_path'] ?? '',
    );
  }
}

class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String? schoolName;
  final String? jabatan;
  final int certificateCount;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    this.schoolName,
    this.jabatan,
    required this.certificateCount,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      schoolName: json['school']?['nama_sekolah'],
      jabatan: json['fungsionaris']?['jabatan'],
      certificateCount: json['teacher_certificates_count'] ?? 0,
    );
  }
}
