import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../theme/app_theme.dart';

class TodayScheduleWidget extends StatelessWidget {
  final List<ScheduleModel> schedules;
  final String? serverTime;
  final VoidCallback? onAttendanceTap;

  const TodayScheduleWidget({
    super.key,
    required this.schedules,
    this.serverTime,
    this.onAttendanceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Jadwal Hari Ini",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (serverTime != null)
                  Text(
                    "Waktu Server: $serverTime",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.primary.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            if (schedules.isNotEmpty)
              Text(
                "${schedules.length} Pelajaran",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        if (schedules.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
            ),
            child: const Center(
              child: Text(
                "Tidak ada jadwal untuk hari ini",
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          ...schedules.map((item) => _buildScheduleItem(item)),
      ],
    );
  }

  Widget _buildScheduleItem(ScheduleModel item) {
    Color statusColor = AppTheme.textSecondary;
    String statusText = "${item.jamMulai} - ${item.jamSelesai}";

    if (item.attendanceStatus != null) {
      statusText = item.attendanceStatus!;
      switch (item.attendanceStatus) {
        case 'Hadir':
          statusColor = Colors.green;
          break;
        case 'Alfa':
          statusColor = Colors.red;
          break;
        case 'Sakit':
          statusColor = Colors.orange;
          break;
        case 'Izin':
          statusColor = Colors.blue;
          break;
        default:
          statusColor = Colors.green;
      }
    } else if (item.isCurrentSession) {
      statusColor = AppTheme.primary;
      statusText = "Sedang Berlangsung";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  (item.attendanceStatus != null
                          ? Colors.green
                          : AppTheme.primary)
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.attendanceStatus != null
                  ? Icons.check_circle_rounded
                  : Icons.menu_book_rounded,
              color: statusColor,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: item.isCurrentSession
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          if (item.canAttend)
            ElevatedButton(
              onPressed: onAttendanceTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Absensi",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
