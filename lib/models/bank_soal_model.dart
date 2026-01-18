class BankSoalModel {
  final String id;
  final String title;
  final String level;
  final String subject;
  final String teacher;
  final int questionsCount;
  final String createdAt;
  final List<BankSoalQuestionModel>? questions;

  BankSoalModel({
    required this.id,
    required this.title,
    required this.level,
    required this.subject,
    required this.teacher,
    required this.questionsCount,
    required this.createdAt,
    this.questions,
  });

  factory BankSoalModel.fromJson(Map<String, dynamic> json) {
    return BankSoalModel(
      id: json['id'],
      title: json['title'],
      level: json['level'],
      subject: json['subject'],
      teacher: json['teacher'],
      questionsCount: json['questions_count'] ?? 0,
      createdAt: json['created_at'],
      questions: json['questions'] != null
          ? (json['questions'] as List)
                .map((i) => BankSoalQuestionModel.fromJson(i))
                .toList()
          : null,
    );
  }
}

class BankSoalQuestionModel {
  final String id;
  final String type;
  final String question;
  final String? image;
  final int points;
  final List<BankSoalOptionModel> options;

  BankSoalQuestionModel({
    required this.id,
    required this.type,
    required this.question,
    this.image,
    required this.points,
    required this.options,
  });

  factory BankSoalQuestionModel.fromJson(Map<String, dynamic> json) {
    return BankSoalQuestionModel(
      id: json['id'],
      type: json['type'],
      question: json['question'],
      image: json['image'],
      points: json['points'] ?? 0,
      options: (json['options'] as List)
          .map((i) => BankSoalOptionModel.fromJson(i))
          .toList(),
    );
  }
}

class BankSoalOptionModel {
  final String id;
  final String text;
  final bool isCorrect;

  BankSoalOptionModel({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory BankSoalOptionModel.fromJson(Map<String, dynamic> json) {
    return BankSoalOptionModel(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'] ?? false,
    );
  }
}
