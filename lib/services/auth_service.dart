import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      validateStatus: (status) => status! < 500,
    ),
  );

  Dio get dio => _dio;

  Options authOptions(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Response> login(
    String login,
    String password,
    String deviceName,
  ) async {
    try {
      return await _dio.post(
        ApiConstants.login,
        data: {'login': login, 'password': password, 'device_name': deviceName},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAppSettings() async {
    try {
      return await _dio.get(ApiConstants.appSettings);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> registerSchool(Map<String, dynamic> data) async {
    try {
      return await _dio.post(ApiConstants.registerSchool, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logout(String token) async {
    try {
      return await _dio.post(
        ApiConstants.logout,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getUser(String token) async {
    try {
      return await _dio.get(
        ApiConstants.user,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getDashboardStats(String token) async {
    try {
      return await _dio.get(
        ApiConstants.dashboardStats,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSliders(String token) async {
    try {
      return await _dio.get(
        ApiConstants.sliders,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getTodaySchedule(String token) async {
    try {
      return await _dio.get(
        ApiConstants.studentScheduleToday,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAllSchedules(String token) async {
    try {
      return await _dio.get(
        ApiConstants.studentScheduleAll,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAllSubjects(String token) async {
    try {
      return await _dio.get(
        ApiConstants.studentSubjectsAll,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getAllGrades(String token) async {
    try {
      return await _dio.get(
        ApiConstants.studentGradesAll,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getELearningCourses(String token) async {
    try {
      return await _dio.get(
        ApiConstants.studentELearning,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getELearningDetail(String token, String id) async {
    try {
      return await _dio.get(
        "${ApiConstants.studentELearning}/$id",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getModuleDetail(String token, String id) async {
    try {
      return await _dio.get(
        "${ApiConstants.studentELearning}/module/$id",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> completeModule(String token, String id) async {
    try {
      return await _dio.post(
        "${ApiConstants.studentELearning}/module/$id/complete",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> submitAssignment({
    required String token,
    required String moduleId,
    String? content,
    String? filePath,
    List<int>? bytes,
    String? fileName,
  }) async {
    try {
      FormData formData = FormData.fromMap({'content': content});

      if (bytes != null && fileName != null) {
        formData.files.add(
          MapEntry('file', MultipartFile.fromBytes(bytes, filename: fileName)),
        );
      } else if (filePath != null) {
        formData.files.add(
          MapEntry('file', await MultipartFile.fromFile(filePath)),
        );
      }

      return await _dio.post(
        "${ApiConstants.studentELearning}/module/$moduleId/submit",
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSubmission(String token, String moduleId) async {
    try {
      return await _dio.get(
        "${ApiConstants.studentELearning}/module/$moduleId/submission",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> startCbtSession(
    String token,
    String cbtId,
    String cbtToken,
  ) async {
    try {
      return await _dio.post(
        "/student/cbt/$cbtId/start",
        data: {'token': cbtToken},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCbtQuestions(String token, String sessionId) async {
    try {
      return await _dio.get(
        "/student/cbt/session/$sessionId/questions",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> submitCbtAnswer({
    required String token,
    required String sessionId,
    required String questionId,
    String? optionId,
    String? essayAnswer,
  }) async {
    try {
      return await _dio.post(
        "/student/cbt/session/$sessionId/answer",
        data: {
          'question_id': questionId,
          'option_id': optionId,
          'essay_answer': essayAnswer,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> finishCbtSession(String token, String sessionId) async {
    try {
      return await _dio.post(
        "/student/cbt/session/$sessionId/finish",
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> submitAttendance(
    String token,
    String subjectId,
    String status,
  ) async {
    try {
      return await _dio.post(
        ApiConstants.studentAttendance,
        data: {'subject_id': subjectId, 'status': status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getBankSoals(String token) async {
    try {
      return await _dio.get(
        '/student/bank-soal',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getBankSoalDetail(String token, String id) async {
    try {
      return await _dio.get(
        '/student/bank-soal/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getForums(String token) async {
    try {
      return await _dio.get(
        '/student/forums',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getForumDetail(String token, String id) async {
    try {
      return await _dio.get(
        '/student/forums/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getForumTopic(String token, String id) async {
    try {
      return await _dio.get(
        '/student/forums/topic/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCbtList(String token) async {
    try {
      return await _dio.get(
        '/student/cbt/list',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> postForumReply(
    String token,
    String topicId,
    String content,
    String? parentId,
  ) async {
    try {
      return await _dio.post(
        '/student/forums/topic/$topicId/post',
        data: {'content': content, 'parent_id': parentId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createForum(
    String token,
    String title,
    String description,
    String visibility,
  ) async {
    try {
      return await _dio.post(
        '/student/forums',
        data: {
          'title': title,
          'description': description,
          'visibility': visibility,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createTopic(
    String token,
    String forumId,
    String title,
    String content,
  ) async {
    try {
      return await _dio.post(
        '/student/forums/$forumId/topic',
        data: {'title': title, 'content': content},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProfile(String token) async {
    try {
      return await _dio.get(
        '/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _dio.post(
        '/profile/update',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateAvatar(String token, String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      return await _dio.post(
        '/profile/avatar',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String token,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await _dio.post(
        '/profile/change-password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      return e.response?.data ??
          {'success': false, 'message': 'Terjadi kesalahan sistem.'};
    }
  }
}
