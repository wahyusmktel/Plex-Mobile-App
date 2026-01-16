class ScheduleModel {
  final String id;
  final String? kelasId;
  final String subjectId;
  final String jamId;
  final String hari;
  final String subjectName;
  final String jamMulai;
  final String jamSelesai;
  final String? attendanceStatus;
  final bool isCurrentSession;
  final bool canAttend;

  ScheduleModel({
    required this.id,
    this.kelasId,
    required this.subjectId,
    required this.jamId,
    required this.hari,
    required this.subjectName,
    required this.jamMulai,
    required this.jamSelesai,
    this.attendanceStatus,
    required this.isCurrentSession,
    required this.canAttend,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;
    final jam = json['jam'] as Map<String, dynamic>?;

    return ScheduleModel(
      id: json['id'] ?? '',
      kelasId: json['kelas_id'],
      subjectId: json['subject_id'] ?? '',
      jamId: json['jam_id'] ?? '',
      hari: json['hari'] ?? '',
      subjectName:
          (subject != null ? subject['nama_pelajaran'] : null) ??
          'Mata Pelajaran',
      jamMulai: (jam != null ? jam['jam_mulai'] : null) ?? '00:00',
      jamSelesai: (jam != null ? jam['jam_selesai'] : null) ?? '00:00',
      attendanceStatus: json['attendance_status'],
      isCurrentSession: json['is_current_session'] ?? false,
      canAttend: json['can_attend'] ?? false,
    );
  }
}
