import '../models/space_operating_schedule.dart';
import '../models/space_rental.dart';

/// [SpaceOperatingSchedule]로 예약 가능 [TimeSlot] 목록 생성.
class SpaceSlotBuilder {
  SpaceSlotBuilder._();

  static const int defaultHorizonDays = 30;

  static List<TimeSlot> build({
    required SpaceOperatingSchedule schedule,
    DateTime? fromDate,
    int horizonDays = defaultHorizonDays,
  }) {
    final base = fromDate ?? DateTime.now();
    final startDay = DateTime(base.year, base.month, base.day);
    final slots = <TimeSlot>[];

    for (var day = 0; day < horizonDays; day++) {
      final date = startDay.add(Duration(days: day));
      if (schedule.isClosedDate(date)) continue;

      final window = schedule.windowForWeekday(date.weekday);
      if (window.closed) continue;

      final startHour = _parseHour(window.start);
      final endHour = _parseHour(window.end);
      if (startHour == null || endHour == null || endHour <= startHour) continue;

      for (var hour = startHour; hour < endHour; hour++) {
        final slotStart = DateTime(date.year, date.month, date.day, hour);
        final slotEnd = slotStart.add(const Duration(hours: 1));
        slots.add(
          TimeSlot(
            startTime: slotStart,
            endTime: slotEnd,
            isAvailable: true,
          ),
        );
      }
    }
    return slots;
  }

  static int? _parseHour(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.isEmpty) return null;
    return int.tryParse(parts[0]);
  }
}
