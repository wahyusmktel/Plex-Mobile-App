import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/teacher_certificate_model.dart';
import '../services/dinas_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class TeacherCertificatesScreen extends StatefulWidget {
  const TeacherCertificatesScreen({super.key});

  @override
  State<TeacherCertificatesScreen> createState() =>
      _TeacherCertificatesScreenState();
}

class _TeacherCertificatesScreenState extends State<TeacherCertificatesScreen> {
  late DinasService _dinasService;
  final ScrollController _scrollController = ScrollController();
  List<TeacherModel> _teachers = [];
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
    _fetchTeachers(refresh: true);
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

  Future<void> _fetchTeachers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _teachers = [];
        _isLoading = true;
      });
    }

    final result = await _dinasService.getTeachersWithCertificates(
      search: _searchQuery,
      page: _currentPage,
    );

    if (mounted) {
      setState(() {
        if (result['success']) {
          if (refresh) {
            _teachers = result['teachers'];
          } else {
            _teachers.addAll(result['teachers']);
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

    final result = await _dinasService.getTeachersWithCertificates(
      search: _searchQuery,
      page: _currentPage,
    );

    if (mounted) {
      setState(() {
        if (result['success']) {
          _teachers.addAll(result['teachers']);
          _lastPage = result['last_page'];
        }
        _isMoreLoading = false;
      });
    }
  }

  void _showCertificateDetails(TeacherModel teacher) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => CertificateDetailsWidget(
        teacherId: teacher.id,
        dinasService: _dinasService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoring Sertifikat Guru"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: _isLoading && _teachers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _teachers.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () => _fetchTeachers(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _teachers.length + (_isMoreLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _teachers.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _buildTeacherCard(_teachers[index]);
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
          hintText: "Cari nama guru atau sekolah...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          _searchQuery = value.isEmpty ? null : value;
          _fetchTeachers(refresh: true);
        },
      ),
    );
  }

  Widget _buildTeacherCard(TeacherModel teacher) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black12,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppTheme.primary),
        ),
        title: Text(
          teacher.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              teacher.schoolName ?? "N/A",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              teacher.jabatan ?? "Guru",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: teacher.certificateCount > 0
                    ? Colors.green
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                "${teacher.certificateCount}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.workspace_premium, size: 16, color: Colors.amber),
          ],
        ),
        onTap: () => _showCertificateDetails(teacher),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Data guru tidak ditemukan",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class CertificateDetailsWidget extends StatefulWidget {
  final String teacherId;
  final DinasService dinasService;

  const CertificateDetailsWidget({
    super.key,
    required this.teacherId,
    required this.dinasService,
  });

  @override
  State<CertificateDetailsWidget> createState() =>
      _CertificateDetailsWidgetState();
}

class _CertificateDetailsWidgetState extends State<CertificateDetailsWidget> {
  bool _isLoading = true;
  TeacherModel? _teacher;
  List<TeacherCertificateModel> _certificates = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final result = await widget.dinasService.getTeacherCertificateDetails(
      widget.teacherId,
    );
    if (mounted) {
      setState(() {
        if (result['success']) {
          _teacher = result['teacher'];
          _certificates = result['certificates'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.75,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.amber,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _teacher?.name ?? "",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Daftar Sertifikat Terdaftar",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _certificates.isEmpty
                      ? const Center(
                          child: Text("Guru ini belum mengunggah sertifikat"),
                        )
                      : ListView.builder(
                          itemCount: _certificates.length,
                          itemBuilder: (context, index) {
                            final cert = _certificates[index];
                            return _buildCertItem(cert);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCertItem(TeacherCertificateModel cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cert.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              Text(
                "${cert.year}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (cert.description != null && cert.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              cert.description!,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                cert.expiryType == 'none'
                    ? "Berlaku Selamanya"
                    : cert.expiryType == 'year'
                    ? "Berlaku hingga ${cert.expiryYear}"
                    : "Berlaku hingga ${cert.expiryDate?.toString().split(' ')[0] ?? '-'}",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
