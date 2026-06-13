import '../models/job.dart';
import '../models/schedule.dart';
import 'schedule_work_session.dart';

/// 같은 날 근무 시간대가 겹치는지 판별.
abstract final class ScheduleConflict {
  ScheduleConflict._();

  static const String overlapCode = 'SCHEDULE_OVERLAP';

  static bool statusBlocksOverlap(String status) =>
      status == 'scheduled' || status == 'proposed';

  static ScheduleWorkWindow? windowFromSchedule(Schedule schedule) {
    final date = schedule.date.trim();
    if (date.isEmpty) return null;
    final start = ScheduleWorkSession.startDateTime(schedule);
    final end = ScheduleWorkSession.endDateTime(schedule);
    return ScheduleWorkWindow(dateYmd: date, start: start, end: end);
  }

  static ScheduleWorkWindow? windowFromJob(Job job) {
    final date = job.date.trim();
    if (date.isEmpty) return null;
    final stub = Schedule(
      id: '',
      jobId: job.id,
      spareId: '',
      shopId: '',
      date: date,
      startTime: job.time,
      endTime: job.endTime,
      status: 'scheduled',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      job: job,
    );
    return windowFromSchedule(stub);
  }

  static bool windowsOverlap(ScheduleWorkWindow a, ScheduleWorkWindow b) {
    if (a.dateYmd != b.dateYmd) return false;
    return a.start.isBefore(b.end) && b.start.isBefore(a.end);
  }

  static List<Schedule> findBlockingSchedules({
    required List<Schedule> all,
    required ScheduleWorkWindow candidate,
    String? ignoreScheduleId,
  }) {
    final conflicts = <Schedule>[];
    for (final existing in all) {
      if (ignoreScheduleId != null && existing.id == ignoreScheduleId) {
        continue;
      }
      if (!statusBlocksOverlap(existing.status)) continue;
      final window = windowFromSchedule(existing);
      if (window == null) continue;
      if (windowsOverlap(window, candidate)) {
        conflicts.add(existing);
      }
    }
    return conflicts;
  }

  static String formatWindowLabel(Schedule schedule) {
    final window = windowFromSchedule(schedule);
    if (window == null) return schedule.date;
    final startHm = ScheduleWorkSession.formatHm(window.start);
    final endHm = ScheduleWorkSession.formatHm(window.end);
    return '${schedule.date} $startHm~$endHm';
  }

  static String shopLabel(Schedule schedule) =>
      schedule.job?.shopName.trim().isNotEmpty == true
          ? schedule.job!.shopName
          : '근무 일정';

  static String overlapUserMessage({
    required String actionLabel,
    required List<Schedule> conflicts,
  }) {
    final names = conflicts.map(shopLabel).toSet().join(', ');
    return '같은 날 $names 근무($actionLabel)와 시간이 겹칩니다. '
        '기존 근무를 취소한 뒤 다시 시도해 주세요.';
  }
}

/// 하루 근무의 [start, end) 구간 (로컬 시각).
class ScheduleWorkWindow {
  const ScheduleWorkWindow({
    required this.dateYmd,
    required this.start,
    required this.end,
  });

  final String dateYmd;
  final DateTime start;
  final DateTime end;
}
