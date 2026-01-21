class ApiConstants {
  // static const String baseUrl = 'https://literasia.org/api';
  // static const String baseStorageUrl = 'https://literasia.org/storage';
  static const String baseUrl =
      'http://127.0.0.1:8000/api'; // Use 10.0.2.2 for Android Emulator
  static const String baseStorageUrl = 'http://127.0.0.1:8000/storage';

  // Auth Endpoints
  static const String login = '/login';
  static const String appSettings = '/app-settings';
  static const String registerSchool = '/register-school';

  static const String logout = '/logout';
  static const String user = '/user';
  static const String dashboardStats = '/dashboard-stats';
  static const String sliders = '/sliders';

  // Student Endpoints
  static const String studentScheduleToday = '/student/schedule-today';
  static const String studentScheduleAll = '/student/schedule-all';
  static const String studentSubjectsAll = '/student/subjects-all';
  static const String studentGradesAll = '/student/grades-all';
  static const String studentELearning = '/student/elearning';
  static const String studentAttendance = '/student/attendance';
}
