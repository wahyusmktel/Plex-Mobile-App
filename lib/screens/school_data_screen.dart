import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_model.dart';
import '../services/dinas_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'school_detail_screen.dart';

class SchoolDataScreen extends StatefulWidget {
  const SchoolDataScreen({super.key});

  @override
  State<SchoolDataScreen> createState() => _SchoolDataScreenState();
}

class _SchoolDataScreenState extends State<SchoolDataScreen> {
  late DinasService _dinasService;
  final ScrollController _scrollController = ScrollController();
  List<SchoolModel> _schools = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  String? _searchQuery;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _dinasService = DinasService(auth.authService.dio, auth.token!);
    _scrollController.addListener(_onScroll);
    _fetchSchools(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isMoreLoading &&
        !_isLoading &&
        _currentPage < _lastPage) {
      _loadMore();
    }
  }

  Future<void> _fetchSchools({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _schools = [];
        _isLoading = true;
      });
    }

    final result = await _dinasService.getSchools(
      search: _searchQuery,
      status: 'approved', // Fokus pada data sekolah terdaftar
      page: _currentPage,
    );

    if (mounted) {
      setState(() {
        if (result['success']) {
          if (refresh) {
            _schools = result['schools'];
          } else {
            _schools.addAll(result['schools']);
          }
          _lastPage = result['last_page'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isMoreLoading || _currentPage >= _lastPage) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isMoreLoading = true);
    });
    _currentPage++;

    final result = await _dinasService.getSchools(
      search: _searchQuery,
      status: 'approved',
      page: _currentPage,
    );

    if (mounted) {
      setState(() {
        if (result['success']) {
          _schools.addAll(result['schools']);
          _lastPage = result['last_page'];
        }
        _isMoreLoading = false;
      });
    }
  }

  Future<void> _resetPassword(SchoolModel school) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password Admin"),
        content: Text(
          "Apakah Anda yakin ingin meriset password admin untuk ${school.namaSekolah}? Password akan diubah menjadi NPSN (${school.npsn}).",
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _dinasService.resetAdminPassword(school.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Sekolah Terdaftar"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: _isLoading && _schools.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _schools.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () => _fetchSchools(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _schools.length + (_isMoreLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _schools.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _buildSchoolCard(_schools[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: "Cari nama sekolah atau NPSN...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          _searchQuery = value.isEmpty ? null : value;
          _fetchSchools(refresh: true);
        },
      ),
    );
  }

  Widget _buildSchoolCard(SchoolModel school) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          school.namaSekolah,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "NPSN: ${school.npsn} | ${school.jenjang.toUpperCase()}",
        ),
        leading: const CircleAvatar(
          backgroundColor: AppTheme.primary,
          child: Icon(Icons.school, color: Colors.white, size: 20),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Alamat: ${school.alamat ?? '-'}"),
                Text(
                  "Lokasi: ${school.kecamatan ?? '-'}, ${school.kabupatenKota ?? '-'}",
                ),
                const Divider(),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SchoolDetailScreen(schoolId: school.id),
                        ),
                      ),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text("Detail"),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _resetPassword(school),
                      icon: const Icon(Icons.lock_reset, size: 18),
                      label: const Text("Reset Admin Password"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        foregroundColor: Colors.orange,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Tidak ada data sekolah terdaftar",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
