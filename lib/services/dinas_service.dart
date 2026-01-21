import 'package:dio/dio.dart';
import '../models/school_model.dart';
import '../models/student_stats_model.dart';
import '../models/teacher_certificate_model.dart';
import '../models/violation_model.dart';
import '../models/sambutan_model.dart';

class DinasService {
  final Dio _dio;
  final String _token;

  DinasService(this._dio, this._token);

  Options get _options => Options(headers: {'Authorization': 'Bearer $_token'});

  Future<Map<String, dynamic>> getSambutans() async {
    try {
      final response = await _dio.get('/dinas/sambutan', options: _options);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        final List<SambutanModel> sambutans = list
            .map((json) => SambutanModel.fromJson(json))
            .toList();

        return {'success': true, 'sambutans': sambutans};
      }
    } catch (e) {
      print("Error fetching sambutans: $e");
    }
    return {'success': false, 'message': 'Gagal mengambil data sambutan'};
  }

  Future<Map<String, dynamic>> createSambutan({
    required String judul,
    required String konten,
    required String thumbnailPath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'judul': judul,
        'konten': konten,
        'thumbnail': await MultipartFile.fromFile(
          thumbnailPath,
          filename: thumbnailPath.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/dinas/sambutan',
        data: formData,
        options: _options,
      );

      return {
        'success':
            response.statusCode == 200 && response.data['success'] == true,
        'message': response.data['message'] ?? 'Berhasil menambah sambutan',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteSambutan(String id) async {
    try {
      final response = await _dio.delete(
        '/dinas/sambutan/$id',
        options: _options,
      );

      return {
        'success':
            response.statusCode == 200 && response.data['success'] == true,
        'message': response.data['message'] ?? 'Berhasil menghapus sambutan',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getSchools({
    String? search,
    String? status,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/dinas/schools',
        queryParameters: {
          if (search != null) 'search': search,
          if (status != null) 'status': status,
          'page': page,
        },
        options: _options,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> list = response.data['data']['data'];
        final List<SchoolModel> schools = list
            .map((json) => SchoolModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'schools': schools,
          'current_page': response.data['data']['current_page'],
          'last_page': response.data['data']['last_page'],
          'total': response.data['data']['total'],
        };
      }
      return {'success': false, 'message': 'Gagal mengambil data sekolah'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<SchoolModel?> getSchoolDetail(String id) async {
    try {
      final response = await _dio.get('/dinas/schools/$id', options: _options);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return SchoolModel.fromJson(response.data['data']);
      }
    } catch (e) {
      print("Error fetching school detail: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> approveSchool(String id) async {
    try {
      final response = await _dio.post(
        '/dinas/schools/$id/approve',
        options: _options,
      );
      return {
        'success':
            response.statusCode == 200 && response.data['status'] == 'success',
        'message': response.data['message'] ?? 'Berhasil menyetujui sekolah',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> rejectSchool(String id) async {
    try {
      final response = await _dio.post(
        '/dinas/schools/$id/reject',
        options: _options,
      );
      return {
        'success':
            response.statusCode == 200 && response.data['status'] == 'success',
        'message': response.data['message'] ?? 'Berhasil menolak sekolah',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> toggleSchoolActive(String id) async {
    try {
      final response = await _dio.post(
        '/dinas/schools/$id/toggle-active',
        options: _options,
      );
      return {
        'success':
            response.statusCode == 200 && response.data['status'] == 'success',
        'message':
            response.data['message'] ??
            'Berhasil mengubah status aktif sekolah',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resetAdminPassword(String schoolId) async {
    try {
      final response = await _dio.post(
        '/dinas/schools/$schoolId/reset-password',
        options: _options,
      );
      return {
        'success':
            response.statusCode == 200 && response.data['status'] == 'success',
        'message':
            response.data['message'] ?? 'Berhasil meriset password admin',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<StudentStatsModel?> getStudentStats() async {
    try {
      final response = await _dio.get(
        '/dinas/student-stats',
        options: _options,
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return StudentStatsModel.fromJson(response.data['data']);
      }
    } catch (e) {
      print("Error fetching student stats: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>> getTeachersWithCertificates({
    String? search,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/dinas/teacher-certificates',
        queryParameters: {if (search != null) 'search': search, 'page': page},
        options: _options,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> list = response.data['data']['data'];
        final List<TeacherModel> teachers = list
            .map((json) => TeacherModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'teachers': teachers,
          'current_page': response.data['data']['current_page'],
          'last_page': response.data['data']['last_page'],
        };
      }
    } catch (e) {
      print("Error fetching teachers: $e");
    }
    return {'success': false, 'message': 'Gagal mengambil data guru'};
  }

  Future<Map<String, dynamic>> getTeacherCertificateDetails(
    String teacherId,
  ) async {
    try {
      final response = await _dio.get(
        '/dinas/teacher-certificates/$teacherId',
        options: _options,
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> certList = response.data['data']['certificates'];
        final List<TeacherCertificateModel> certificates = certList
            .map((json) => TeacherCertificateModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'teacher': TeacherModel.fromJson(response.data['data']['teacher']),
          'certificates': certificates,
        };
      }
    } catch (e) {
      print("Error fetching certificate details: $e");
    }
    return {'success': false, 'message': 'Gagal mengambil detail sertifikat'};
  }

  Future<Map<String, dynamic>> getViolations({
    String? search,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/dinas/violations',
        queryParameters: {if (search != null) 'search': search, 'page': page},
        options: _options,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List<dynamic> list = response.data['data']['data'];
        final List<ViolationModel> violations = list
            .map((json) => ViolationModel.fromJson(json))
            .toList();

        return {
          'success': true,
          'violations': violations,
          'current_page': response.data['data']['current_page'],
          'last_page': response.data['data']['last_page'],
        };
      }
    } catch (e) {
      print("Error fetching violations: $e");
    }
    return {'success': false, 'message': 'Gagal mengambil data pelanggaran'};
  }

  Future<Map<String, dynamic>> getGlobalCbts() async {
    try {
      final response = await _dio.get('/dinas/cbt-global', options: _options);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
    } catch (e) {
      print("Error fetching global cbts: $e");
    }
    return {'success': false, 'message': 'Gagal mengambil data CBT Global'};
  }

  Future<Map<String, dynamic>> getGlobalSubjects() async {
    try {
      final response = await _dio.get(
        '/dinas/subjects-global',
        options: _options,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
    } catch (e) {
      print("Error fetching global subjects: $e");
    }
    return {'success': false, 'message': 'Gagal mengambil data mata pelajaran'};
  }

  Future<Map<String, dynamic>> createCbtGlobal(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '/dinas/cbt-global',
        data: data,
        options: _options,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'message': response.data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
    return {'success': false, 'message': 'Gagal menambah CBT Global'};
  }

  Future<Map<String, dynamic>> updateCbtGlobal(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(
        '/dinas/cbt-global/$id',
        data: data,
        options: _options,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'message': response.data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
    return {'success': false, 'message': 'Gagal memperbarui CBT Global'};
  }

  Future<Map<String, dynamic>> deleteCbtGlobal(String id) async {
    try {
      final response = await _dio.delete(
        '/dinas/cbt-global/$id',
        options: _options,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'message': response.data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
    return {'success': false, 'message': 'Gagal menghapus CBT Global'};
  }
}
