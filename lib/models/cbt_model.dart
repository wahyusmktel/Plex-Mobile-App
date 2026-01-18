class CbtQuestionModel {
  final String id;
  final String cbtId;
  final String type; // pilihan_ganda, essay
  final String question;
  final String? image;
  final int points;
  final List<CbtOptionModel> options;

  CbtQuestionModel({
    required this.id,
    required this.cbtId,
    required this.type,
    required this.question,
    this.image,
    required this.points,
    required this.options,
  });

  factory CbtQuestionModel.fromJson(Map<String, dynamic> json) {
    return CbtQuestionModel(
      id: json['id'] ?? '',
      cbtId: json['cbt_id'] ?? '',
      type: json['jenis_soal'] ?? 'pilihan_ganda',
      question: json['pertanyaan'] ?? '',
      image: json['gambar'],
      points: json['poin'] ?? 0,
      options: (json['options'] as List? ?? [])
          .map((o) => CbtOptionModel.fromJson(o))
          .toList(),
    );
  }
}

class CbtOptionModel {
  final String id;
  final String questionId;
  final String optionText;
  final String? image;

  CbtOptionModel({
    required this.id,
    required this.questionId,
    required this.optionText,
    this.image,
  });

  factory CbtOptionModel.fromJson(Map<String, dynamic> json) {
    return CbtOptionModel(
      id: json['id'] ?? '',
      questionId: json['question_id'] ?? '',
      optionText: json['opsi'] ?? '',
      image: json['gambar'],
    );
  }
}

class CbtSessionModel {
  final String id;
  final String cbtId;
  final String studentId;
  final String status; // ongoing, completed
  final int? score;
  final Map<String, dynamic>? cbt;

  CbtSessionModel({
    required this.id,
    required this.cbtId,
    required this.studentId,
    required this.status,
    this.score,
    this.cbt,
  });

  factory CbtSessionModel.fromJson(Map<String, dynamic> json) {
    return CbtSessionModel(
      id: json['id'] ?? '',
      cbtId: json['cbt_id'] ?? '',
      studentId: json['siswa_id'] ?? '',
      status: json['status'] ?? 'ongoing',
      score: json['skor'],
      cbt: json['cbt'],
    );
  }
}
