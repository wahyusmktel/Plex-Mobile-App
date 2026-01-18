class ELearningModel {
  final String id;
  final String subjectId;
  final String teacherId;
  final String title;
  final String? description;
  final String? thumbnail;
  final String? subjectName;
  final String? teacherName;
  final int progressPercentage;
  final int completedCount;
  final int totalModules;
  final List<ELearningChapterModel>? chapters;

  ELearningModel({
    required this.id,
    required this.subjectId,
    required this.teacherId,
    required this.title,
    this.description,
    this.thumbnail,
    this.subjectName,
    this.teacherName,
    this.progressPercentage = 0,
    this.completedCount = 0,
    this.totalModules = 0,
    this.chapters,
  });

  factory ELearningModel.fromJson(Map<String, dynamic> json) {
    return ELearningModel(
      id: json['id'] ?? '',
      subjectId: json['subject_id'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnail: json['thumbnail'],
      subjectName: json['subject']?['nama_pelajaran'],
      teacherName: json['teacher']?['nama'],
      progressPercentage: json['progress_percentage'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
      totalModules: json['total_modules'] ?? 0,
      chapters: json['chapters'] != null
          ? (json['chapters'] as List)
                .map((i) => ELearningChapterModel.fromJson(i))
                .toList()
          : null,
    );
  }
}

class ELearningChapterModel {
  final String id;
  final String title;
  final int order;
  final List<ELearningModuleModel> modules;

  ELearningChapterModel({
    required this.id,
    required this.title,
    required this.order,
    required this.modules,
  });

  factory ELearningChapterModel.fromJson(Map<String, dynamic> json) {
    return ELearningChapterModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 0,
      modules: (json['modules'] as List? ?? [])
          .map((i) => ELearningModuleModel.fromJson(i))
          .toList(),
    );
  }
}

class ELearningModuleModel {
  final String id;
  final String type; // material, assignment, exercise, exam
  final String title;
  final String? content;
  final String? filePath;
  final String? cbtId;
  final String? dueDate;
  final int order;
  final bool isCompleted;

  ELearningModuleModel({
    required this.id,
    required this.type,
    required this.title,
    this.content,
    this.filePath,
    this.cbtId,
    this.dueDate,
    required this.order,
    this.isCompleted = false,
  });

  factory ELearningModuleModel.fromJson(Map<String, dynamic> json) {
    return ELearningModuleModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'material',
      title: json['title'] ?? '',
      content: json['content'],
      filePath: json['file_path'],
      cbtId: json['cbt_id'],
      dueDate: json['due_date'],
      order: json['order'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
