import 'package:intl/intl.dart';

import '../models/schedule.dart';

/// 공간 대여 스케줄(선결제·확인용) — 근무 정산과 분리.
abstract final class ScheduleSpaceRental {
  ScheduleSpaceRental._();

  static const String jobIdMarker = 'space-rental';

  static bool isSpaceRental(Schedule schedule) =>
      schedule.jobId == jobIdMarker || schedule.id.startsWith('sched-space-');

  /// 스케줄 카드 제목 — 공간명(shopName), 주소 아님.
  static String displayTitle(Schedule schedule) {
    final name = schedule.job?.shopName.trim();
    if (name != null && name.isNotEmpty) {
      return '공간 대여 · $name';
    }
    return schedule.job?.title ?? '공간 대여';
  }

  /// 스케줄 현황 배지 문구.
  static String statusLabel(Schedule schedule, DateTime now) {
    final start = _parseDateTime(schedule.date, schedule.startTime);
    final end = _parseDateTime(
      schedule.date,
      schedule.endTime ?? schedule.startTime,
    );
    if (start == null) return '예약 확정';
    if (now.isBefore(start)) return '예약 확정';
    if (end != null && now.isBefore(end)) return '이용 중';
    return '이용 완료';
  }

  static DateTime? _parseDateTime(String date, String time) {
    final parts = date.split('-');
    final tp = time.split(':');
    if (parts.length != 3 || tp.isEmpty) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    final h = int.tryParse(tp[0]);
    final min = tp.length > 1 ? int.tryParse(tp[1]) : 0;
    if (y == null || m == null || d == null || h == null) return null;
    return DateTime(y, m, d, h, min ?? 0);
  }

  static String prepaidSummary(Schedule schedule) {
    final amount = NumberFormat('#,###').format(schedule.job?.amount ?? 0);
    return '${schedule.spare?.name ?? schedule.spareId} | 선결제 $amount원';
  }
}
