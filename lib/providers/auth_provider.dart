import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/slider_model.dart';
import '../models/schedule_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  Map<String, dynamic> _dashboardStats = {};
  List<SliderModel> _sliders = [];
  List<ScheduleModel> _todaySchedule = [];
  String? _serverTime;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<SliderModel> get sliders => _sliders;
  List<ScheduleModel> get todaySchedule => _todaySchedule;
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

  Future<Map<String, dynamic>> submitAttendance(
    String subjectId,
    String status,
  ) async {
    if (_token == null)
      return {'success': false, 'message': 'Not authenticated'};

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
}
