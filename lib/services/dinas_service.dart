import 'package:dio/dio.dart';
import '../models/school_model.dart';

class DinasService {
  final Dio _dio;
  final String _token;

  DinasService(this._dio, this._token);

  Options get _options => Options(headers: {'Authorization': 'Bearer $_token'});

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
}
