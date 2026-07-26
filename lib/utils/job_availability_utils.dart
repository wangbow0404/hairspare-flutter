import '../models/job.dart';

/// 공고가 스페어 목록·찜에 노출 가능한지 판별.
abstract final class JobAvailabilityUtils {
  static bool isListable(Job job, {DateTime? now}) {
    if (job.isHidden) return false;
    if (job.status != 'published') return false;
    return !isWorkStartPast(job, now: now);
  }

  /// 근무 시작 시각이 지났으면 true.
  static bool isWorkStartPast(Job job, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    try {
      final parts = job.time.split(':');
      if (parts.length < 2) return false;
      final start = DateTime(
        int.parse(job.date.substring(0, 4)),
        int.parse(job.date.substring(5, 7)),
        int.parse(job.date.substring(8, 10)),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      return !start.isAfter(reference);
    } catch (_) {
      return false;
    }
  }
}
