import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateHelper {
  static final Map<String, int> _dayMap = {
    'Senin': DateTime.monday,
    'Selasa': DateTime.tuesday,
    'Rabu': DateTime.wednesday,
    'Kamis': DateTime.thursday,
    'Jumat': DateTime.friday,
    'Sabtu': DateTime.saturday,
    'Minggu': DateTime.sunday,
  };

  /// Calculates the next date for a given day name (e.g., "Senin")
  static DateTime getNextOccurrence(String dayName) {
    int? targetDay = _dayMap[dayName];
    if (targetDay == null) return DateTime.now();

    DateTime now = DateTime.now();
    int currentDay = now.weekday;

    int daysUntil = targetDay - currentDay;
    if (daysUntil < 0) {
      daysUntil += 7;
    }
    // Note: If today is the target day, we can show today or next week.
    // Usually, showing today is better if it's currently that day.

    return now.add(Duration(days: daysUntil));
  }

  /// Formats the schedule into "(Senin, 20 Juni 2026 Pukul 07.15 WIB)"
  static String formatSchedule(String dayName, String jamMulai) {
    try {
      DateTime date = getNextOccurrence(dayName);

      String timeStr = extractTimeStr(jamMulai);

      // We need Indonesian locale for month names
      // Ensure locale is initialized (usually done in main, but we can check here)
      // Since we can't easily wait for initializeDateFormatting in a static method,
      // we'll use a hardcoded month map for safety if intl locale fails or just use intl properly.

      final monthNames = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      String formattedDate =
          "$dayName, ${date.day} ${monthNames[date.month]} ${date.year}";

      return "($formattedDate Pukul $timeStr WIB)";
    } catch (e) {
      return "($dayName, Pukul $jamMulai WIB)";
    }
  }

  /// Extracts "HH.mm" from either ISO string "2026-01-18T07:00:00" or simple "07:00"
  static String extractTimeStr(String jam) {
    try {
      if (jam.contains('T')) {
        // ISO format
        DateTime dt = DateTime.parse(jam);
        return "${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}";
      } else {
        // HH:mm:ss or HH:mm format
        List<String> parts = jam.split(':');
        if (parts.length >= 2) {
          String hour = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
          // If it's something like "2026-01-18 07", we only want the "07"
          if (hour.length > 2) hour = hour.substring(hour.length - 2);
          return "$hour.${parts[1]}";
        }
        return jam;
      }
    } catch (e) {
      return jam;
    }
  }
}
