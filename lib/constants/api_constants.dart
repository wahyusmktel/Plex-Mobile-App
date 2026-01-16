class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth Endpoints
  static const String login = '/login';
  static const String registerSchool = '/register-school';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String dashboardStats = '/dashboard-stats';
  static const String sliders = '/sliders';

  // Student Endpoints
  static const String studentScheduleToday = '/student/schedule-today';
  static const String studentAttendance = '/student/attendance';
}
