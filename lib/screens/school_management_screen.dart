import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_model.dart';
import '../services/dinas_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'school_detail_screen.dart';

class SchoolManagementScreen extends StatefulWidget {
  const SchoolManagementScreen({super.key});

  @override
  State<SchoolManagementScreen> createState() => _SchoolManagementScreenState();
}

class _SchoolManagementScreenState extends State<SchoolManagementScreen> {
  late DinasService _dinasService;
  final ScrollController _scrollController = ScrollController();
  List<SchoolModel> _schools = [];
  bool _isLoading = false;
  bool _isMoreLoading = false;
  String? _searchQuery;
  String? _selectedStatus;
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
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isMoreLoading &&
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
      status: _selectedStatus,
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

    setState(() => _isMoreLoading = true);
    _currentPage++;

    final result = await _dinasService.getSchools(
      search: _searchQuery,
      status: _selectedStatus,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Sekolah"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchSchools(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Cari nama sekolah atau NPSN...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              _searchQuery = value.isEmpty ? null : value;
              _fetchSchools(refresh: true);
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip(null, "Semua"),
                _buildStatusChip("pending", "Menunggu"),
                _buildStatusChip("approved", "Disetujui"),
                _buildStatusChip("rejected", "Ditolak"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status, String label) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() => _selectedStatus = selected ? status : null);
          _fetchSchools(refresh: true);
        },
        selectedColor: AppTheme.primary.withOpacity(0.2),
        checkmarkColor: AppTheme.primary,
      ),
    );
  }

  Widget _buildSchoolCard(SchoolModel school) {
    Color statusColor;
    String statusLabel;

    switch (school.status) {
      case 'approved':
        statusColor = Colors.green;
        statusLabel = "Disetujui";
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusLabel = "Ditolak";
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = "Menunggu";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          school.namaSekolah,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("NPSN: ${school.npsn}"),
            Text("Jenjang: ${school.jenjang.toUpperCase()}"),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (school.status == 'approved')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: school.isActive
                          ? Colors.blue.withOpacity(0.12)
                          : Colors.grey.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      school.isActive ? "Aktif" : "Nonaktif",
                      style: TextStyle(
                        color: school.isActive ? Colors.blue : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchoolDetailScreen(schoolId: school.id),
            ),
          );
          if (result == true) {
            _fetchSchools(refresh: true);
          }
        },
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
            "Tidak ada data sekolah ditemukan",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
