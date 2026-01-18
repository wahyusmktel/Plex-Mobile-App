import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/slider_model.dart';
import '../models/schedule_model.dart';
import '../models/subject_model.dart';
import '../models/grade_model.dart';
import '../models/e_learning_model.dart';
import '../models/cbt_model.dart';
import '../models/bank_soal_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  Map<String, dynamic> _dashboardStats = {};
  List<SliderModel> _sliders = [];
  List<ScheduleModel> _todaySchedule = [];
  List<SubjectModel> _subjects = [];
  Map<String, dynamic> _fullSchedule = {};
  List<GradeModel> _grades = [];
  List<ELearningModel> _elearningCourses = [];
  ELearningModel? _selectedCourse;
  List<BankSoalModel> _bankSoals = [];
  BankSoalModel? _selectedBankSoal;
  String? _serverTime;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<SliderModel> get sliders => _sliders;
  List<ScheduleModel> get todaySchedule => _todaySchedule;
  List<SubjectModel> get subjects => _subjects;
  Map<String, dynamic> get fullSchedule => _fullSchedule;
  List<GradeModel> get grades => _grades;
  List<ELearningModel> get elearningCourses => _elearningCourses;
  ELearningModel? get selectedCourse => _selectedCourse;
  List<BankSoalModel> get bankSoals => _bankSoals;
  BankSoalModel? get selectedBankSoal => _selectedBankSoal;
  String? get serverTime => _serverTime;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      _user = UserModel.fromJson(jsonDecode(userJson));
    }
    notifyListeners();
  }

  Future<bool> login(String login, String password, String deviceName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(login, password, deviceName);

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        _token = response.data['data']['token'];
        _user = UserModel.fromJson(response.data['data']['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', jsonEncode(_user!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> registerSchool(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.registerSchool(data);
      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': response.data['message']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Terjadi kesalahan',
          'errors': response.data['errors'],
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Gagal menghubungi server'};
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      await _authService.logout(_token!);
    }
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<void> getDashboardStats() async {
    if (_token == null) return;

    try {
      // Parallelize fetches
      await Future.wait([
        _fetchStats(),
        _fetchSliders(),
        if (_user?.role == 'siswa') _fetchTodaySchedule(),
      ]);
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    }
  }

  Future<void> _fetchStats() async {
    final response = await _authService.getDashboardStats(_token!);
    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final data = response.data['data'];
      if (data != null && data['stats'] != null) {
        _dashboardStats = data['stats'];
      }
    }
  }

  Future<void> _fetchSliders() async {
    final response = await _authService.getSliders(_token!);
    if (response.statusCode == 200 && response.data['status'] == 'success') {
      final List<dynamic>? data = response.data['data'];
      if (data != null) {
        _sliders = data.map((json) => SliderModel.fromJson(json)).toList();
      }
    }
  }

  Future<void> _fetchTodaySchedule() async {
    final response = await _authService.getTodaySchedule(_token!);
    if (response.statusCode == 200 && response.data['status'] == 'success') {
      _serverTime = response.data['server_time'];
      final List<dynamic>? data = response.data['data'];
      if (data != null) {
        _todaySchedule = data
            .map((json) => ScheduleModel.fromJson(json))
            .toList();
      }
    }
  }

  Future<void> fetchAllSubjects() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.getAllSubjects(_token!);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic>? data = response.data['data'];
        if (data != null) {
          _subjects = data.map((json) => SubjectModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching subjects: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllSchedules() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.getAllSchedules(_token!);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        _fullSchedule = response.data['data'] ?? {};
      }
    } catch (e) {
      debugPrint("Error fetching full schedule: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllGrades() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.getAllGrades(_token!);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic>? data = response.data['data'];
        if (data != null) {
          _grades = data.map((json) => GradeModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching grades: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchELearningCourses() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.getELearningCourses(_token!);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic>? data = response.data['data'];
        if (data != null) {
          _elearningCourses = data
              .map((json) => ELearningModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching elearning courses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchELearningDetail(String id) async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.getELearningDetail(_token!, id);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        _selectedCourse = ELearningModel.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching elearning detail: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ELearningModuleModel?> getModuleDetail(String id) async {
    if (_token == null) return null;

    try {
      final response = await _authService.getModuleDetail(_token!, id);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return ELearningModuleModel.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching module detail: $e");
    }
    return null;
  }

  Future<bool> markModuleAsCompleted(String id) async {
    if (_token == null) return false;

    try {
      final response = await _authService.completeModule(_token!, id);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return true;
      }
    } catch (e) {
      debugPrint("Error completing module: $e");
    }
    return false;
  }

  Future<bool> submitAssignment({
    required String moduleId,
    String? content,
    String? filePath,
    List<int>? bytes,
    String? fileName,
  }) async {
    if (_token == null) return false;

    try {
      final response = await _authService.submitAssignment(
        token: _token!,
        moduleId: moduleId,
        content: content,
        filePath: filePath,
        bytes: bytes,
        fileName: fileName,
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return true;
      }
    } catch (e) {
      debugPrint("Error submitting assignment: $e");
    }
    return false;
  }

  Future<Map<String, dynamic>?> getSubmission(String moduleId) async {
    if (_token == null) return null;

    try {
      final response = await _authService.getSubmission(_token!, moduleId);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint("Error fetching submission: $e");
    }
    return null;
  }

  Future<CbtSessionModel?> startCbtSession(
    String cbtId,
    String cbtToken,
  ) async {
    if (_token == null) return null;

    try {
      final response = await _authService.startCbtSession(
        _token!,
        cbtId,
        cbtToken,
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return CbtSessionModel.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint("Error starting CBT session: $e");
    }
    return null;
  }

  Future<List<CbtQuestionModel>> getCbtQuestions(String sessionId) async {
    if (_token == null) return [];

    try {
      final response = await _authService.getCbtQuestions(_token!, sessionId);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> data = response.data['data'];
        return data.map((q) => CbtQuestionModel.fromJson(q)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching CBT questions: $e");
    }
    return [];
  }

  Future<bool> submitCbtAnswer({
    required String sessionId,
    required String questionId,
    String? optionId,
    String? essayAnswer,
  }) async {
    if (_token == null) return false;

    try {
      final response = await _authService.submitCbtAnswer(
        token: _token!,
        sessionId: sessionId,
        questionId: questionId,
        optionId: optionId,
        essayAnswer: essayAnswer,
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return true;
      }
    } catch (e) {
      debugPrint("Error submitting CBT answer: $e");
    }
    return false;
  }

  Future<Map<String, dynamic>?> finishCbtSession(String sessionId) async {
    if (_token == null) return null;

    try {
      final response = await _authService.finishCbtSession(_token!, sessionId);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint("Error finishing CBT session: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> submitAttendance(
    String subjectId,
    String status,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final response = await _authService.submitAttendance(
        _token!,
        subjectId,
        status,
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        await _fetchTodaySchedule(); // Refresh schedule to show updated status
        notifyListeners();
        return {'success': true, 'message': response.data['message']};
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Gagal mengirim absensi',
        };
      }
    } catch (e) {
      String message = 'Terjadi kesalahan sistem';
      if (e is DioException && e.response != null) {
        message = e.response?.data['message'] ?? message;
      }
      return {'success': false, 'message': message};
    }
  }

  Future<void> fetchBankSoals() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.getBankSoals(_token!);
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic>? data = response.data['data'];
        if (data != null) {
          _bankSoals = data
              .map((json) => BankSoalModel.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching bank soals: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBankSoalDetail(String id) async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.getBankSoalDetail(_token!, id);
      if (response.statusCode == 200 && response.data['success']) {
        _selectedBankSoal = BankSoalModel.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching bank soal detail: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
