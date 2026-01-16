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
}
