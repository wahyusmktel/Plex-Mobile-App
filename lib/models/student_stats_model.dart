class StudentStatsModel {
  final int totalStudents;
  final List<StatItem> genderStats;
  final List<StatItem> levelStats;
  final List<StatItem> statusStats;

  StudentStatsModel({
    required this.totalStudents,
    required this.genderStats,
    required this.levelStats,
    required this.statusStats,
  });

  factory StudentStatsModel.fromJson(Map<String, dynamic> json) {
    return StudentStatsModel(
      totalStudents: json['total_students'] ?? 0,
      genderStats: (json['gender_stats'] as List)
          .map((item) => StatItem.fromJson(item, 'jenis_kelamin'))
          .toList(),
      levelStats: (json['level_stats'] as List)
          .map((item) => StatItem.fromJson(item, 'jenjang'))
          .toList(),
      statusStats: (json['status_stats'] as List)
          .map((item) => StatItem.fromJson(item, 'status_sekolah'))
          .toList(),
    );
  }
}

class StatItem {
  final String label;
  final int total;

  StatItem({required this.label, required this.total});

  factory StatItem.fromJson(Map<String, dynamic> json, String labelKey) {
    return StatItem(
      label: json[labelKey]?.toString() ?? 'N/A',
      total: json['total'] ?? 0,
    );
  }
}
