import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_model.dart';
import '../services/dinas_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SchoolDetailScreen extends StatefulWidget {
  final String schoolId;
  const SchoolDetailScreen({super.key, required this.schoolId});

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen> {
  late DinasService _dinasService;
  SchoolModel? _school;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _dinasService = DinasService(auth.authService.dio, auth.token!);
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    final detail = await _dinasService.getSchoolDetail(widget.schoolId);
    if (mounted) {
      setState(() {
        _school = detail;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAction(Future<Map<String, dynamic>> action) async {
    final result = await action;
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      if (result['success']) {
        _fetchDetail();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Sekolah"),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _school == null
          ? const Center(child: Text("Data tidak ditemukan"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildInfoSection("Informasi Dasar", [
                    _buildInfoRow(Icons.pin_outlined, "NPSN", _school!.npsn),
                    _buildInfoRow(
                      Icons.category_outlined,
                      "Jenjang",
                      _school!.jenjang.toUpperCase(),
                    ),
                    _buildInfoRow(
                      Icons.business_outlined,
                      "Status",
                      _school!.statusSekolah,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection("Lokasi", [
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      "Alamat",
                      _school!.alamat ?? "-",
                    ),
                    _buildInfoRow(
                      Icons.map_outlined,
                      "Kecamatan",
                      _school!.kecamatan ?? "-",
                    ),
                    _buildInfoRow(
                      Icons.location_city_outlined,
                      "Kab/Kota",
                      _school!.kabupatenKota ?? "-",
                    ),
                    _buildInfoRow(
                      Icons.public_outlined,
                      "Provinsi",
                      _school!.provinsi ?? "-",
                    ),
                  ]),
                  const SizedBox(height: 20),
                  if (_school!.admins != null && _school!.admins!.isNotEmpty)
                    _buildInfoSection("Admin Sekolah", [
                      for (var admin in _school!.admins!)
                        _buildInfoRow(
                          Icons.person_outline,
                          admin.name,
                          "Username: ${admin.username}",
                        ),
                    ]),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    Color statusColor;
    String statusLabel;

    switch (_school!.status) {
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
        statusLabel = "Menunggu Persetujuan";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _school!.namaSekolah,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            if (_school!.status == 'approved') ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _school!.isActive
                      ? Colors.blue.withOpacity(0.12)
                      : Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _school!.isActive ? "Aktif" : "Nonaktif",
                  style: TextStyle(
                    color: _school!.isActive ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_school!.status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  _handleAction(_dinasService.approveSchool(_school!.id)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Setujui",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  _handleAction(_dinasService.rejectSchool(_school!.id)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Tolak",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    if (_school!.status == 'approved') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () =>
              _handleAction(_dinasService.toggleSchoolActive(_school!.id)),
          icon: Icon(
            _school!.isActive ? Icons.block : Icons.check_circle_outline,
          ),
          label: Text(
            _school!.isActive ? "Nonaktifkan Sekolah" : "Aktifkan Sekolah",
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _school!.isActive ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
