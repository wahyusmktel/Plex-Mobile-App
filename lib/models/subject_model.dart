class SubjectModel {
  final String id;
  final String namaPelajaran;
  final String kodePelajaran;
  final String guru;
  final List<SubjectSchedule> schedules;

  SubjectModel({
    required this.id,
    required this.namaPelajaran,
    required this.kodePelajaran,
    required this.guru,
    required this.schedules,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      namaPelajaran: json['nama_pelajaran'],
      kodePelajaran: json['kode_pelajaran'],
      guru: json['guru'],
      schedules: (json['schedules'] as List)
          .map((s) => SubjectSchedule.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_pelajaran': namaPelajaran,
      'kode_pelajaran': kodePelajaran,
      'guru': guru,
      'schedules': schedules.map((s) => s.toJson()).toList(),
    };
  }
}

class SubjectSchedule {
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  SubjectSchedule({
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory SubjectSchedule.fromJson(Map<String, dynamic> json) {
    return SubjectSchedule(
      hari: json['hari'],
      jamMulai: json['jam_mulai'],
      jamSelesai: json['jam_selesai'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'hari': hari, 'jam_mulai': jamMulai, 'jam_selesai': jamSelesai};
  }
}
