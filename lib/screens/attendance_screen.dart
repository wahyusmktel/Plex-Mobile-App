import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../utils/notification_helper.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isSubmitting = false;
  final Map<String, String> _selectedStatus = {};
  final Map<String, bool> _editMode = {};

  final Map<String, String> _statusOptions = {
    'H': 'Hadir',
    'A': 'Alfa',
    'S': 'Sakit',
    'I': 'Izin',
  };

  final Map<String, Color> _statusColors = {
    'Hadir': Colors.green,
    'Alfa': Colors.red,
    'Sakit': Colors.orange,
    'Izin': Colors.blue,
  };

  Future<void> _handleAttendance(String subjectId, String subjectName) async {
    final status = _selectedStatus[subjectId];
    if (status == null) {
      NotificationHelper.showError(context, "Silahkan pilih status kehadiran");
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).submitAttendance(subjectId, status);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success']) {
      NotificationHelper.showSuccess(
        context,
        "Berhasil absensi mata pelajaran $subjectName",
      );
      setState(() {
        _editMode[subjectId] = false;
      });
    } else {
      NotificationHelper.showError(context, result['message']);
    }
  }

  String? _getStatusInitial(String? statusText) {
    if (statusText == null) return null;
    return _statusOptions.entries
        .firstWhere(
          (e) => e.value == statusText,
          orElse: () => const MapEntry('', ''),
        )
        .key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Absensi Siswa"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final currentSchedules = auth.todaySchedule
              .where((s) => s.canAttend)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pelajaran Hari Ini",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Anda dapat melakukan absensi pada jam pelajaran yang sedang berlangsung.",
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                if (currentSchedules.isEmpty)
                  _buildEmptyState()
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: currentSchedules.length,
                      itemBuilder: (context, index) {
                        final item = currentSchedules[index];
                        return _buildAttendanceCard(item);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            "Tidak Ada Pelajaran Aktif",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Anda hanya dapat melakukan absensi pada jam pelajaran yang sedang berlangsung.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(dynamic item) {
    final hasAttended = item.attendanceStatus != null;
    final isEditing = _editMode[item.subjectId] ?? false;
    final canInput = !hasAttended || isEditing;

    // Initialize selected status if already attended
    if (hasAttended && _selectedStatus[item.subjectId] == null && !isEditing) {
      _selectedStatus[item.subjectId] = _getStatusInitial(
        item.attendanceStatus,
      )!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasAttended && !isEditing
              ? _statusColors[item.attendanceStatus]!.withOpacity(0.3)
              : AppTheme.primary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (hasAttended && !isEditing
                              ? _statusColors[item.attendanceStatus]!
                              : AppTheme.primary)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  hasAttended && !isEditing
                      ? Icons.check_circle_rounded
                      : Icons.menu_book_rounded,
                  color: hasAttended && !isEditing
                      ? _statusColors[item.attendanceStatus]
                      : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subjectName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${item.jamMulai} - ${item.jamSelesai}",
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasAttended && !isEditing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColors[item.attendanceStatus]!.withOpacity(
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.attendanceStatus!,
                    style: TextStyle(
                      color: _statusColors[item.attendanceStatus],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _statusOptions.entries.map((entry) {
              final isSelected = _selectedStatus[item.subjectId] == entry.key;
              return GestureDetector(
                onTap: canInput
                    ? () {
                        setState(() {
                          _selectedStatus[item.subjectId] = entry.key;
                        });
                      }
                    : null,
                child: Container(
                  width: 55,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (hasAttended && !isEditing)
            AppButton(
              text: "Edit Absensi",
              isOutline: true,
              onPressed: () {
                setState(() {
                  _editMode[item.subjectId] = true;
                });
              },
            )
          else
            AppButton(
              text: isEditing ? "Perbarui Absensi" : "Kirim Absensi",
              onPressed: () =>
                  _handleAttendance(item.subjectId, item.subjectName),
              isLoading: _isSubmitting,
            ),
        ],
      ),
    );
  }
}
