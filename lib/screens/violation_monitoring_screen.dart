import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/violation_model.dart';
import '../services/dinas_service.dart';
import '../providers/auth_provider.dart';

class ViolationMonitoringScreen extends StatefulWidget {
  const ViolationMonitoringScreen({super.key});

  @override
  State<ViolationMonitoringScreen> createState() =>
      _ViolationMonitoringScreenState();
}

class _ViolationMonitoringScreenState extends State<ViolationMonitoringScreen> {
  late DinasService _dinasService;
  final ScrollController _scrollController = ScrollController();
  List<ViolationModel> _violations = [];
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
    _fetchViolations(refresh: true);
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

  Future<void> _fetchViolations({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _violations = [];
        _isLoading = true;
      });
    }

    final result = await _dinasService.getViolations(
      search: _searchQuery,
      page: _currentPage,
    );

    if (mounted) {
      setState(() {
        if (result['success']) {
          if (refresh) {
            _violations = result['violations'];
          } else {
            _violations.addAll(result['violations']);
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

    final result = await _dinasService.getViolations(
      search: _searchQuery,
      page: _currentPage,
    );

    if (mounted) {
      setState(() {
        if (result['success']) {
          _violations.addAll(result['violations']);
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
        title: const Text("Monitoring Pelanggaran Nasional"),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: _isLoading && _violations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _violations.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () => _fetchViolations(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _violations.length + (_isMoreLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _violations.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _buildViolationCard(_violations[index]);
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
          hintText: "Cari nama siswa atau sekolah...",
          prefixIcon: const Icon(Icons.search, color: Colors.red),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          _searchQuery = value.isEmpty ? null : value;
          _fetchViolations(refresh: true);
        },
      ),
    );
  }

  Widget _buildViolationCard(ViolationModel violation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black12,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.red[50],
          child: Icon(Icons.report_problem, color: Colors.red[600]),
        ),
        title: Text(
          violation.studentName ?? "N/A",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              violation.violationName ?? "Pelanggaran Umum",
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              violation.schoolName ?? "Sekolah Tidak Diketahui",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red[600],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "${violation.points} pts",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildDetailRow("NISN", violation.nisn ?? "-"),
                _buildDetailRow(
                  "Tanggal",
                  DateFormat('dd MMMM yyyy').format(violation.createdAt),
                ),
                if (violation.description != null &&
                    violation.description!.isNotEmpty)
                  _buildDetailRow("Keterangan", violation.description!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(": "),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
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
          Icon(Icons.gavel_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Belum ada data pelanggaran tercatat",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
