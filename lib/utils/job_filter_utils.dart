import '../models/job.dart';

/// 홈·목록 공고 필터 (client-side).
abstract final class JobFilterUtils {
  static bool matches(String filter, Job job) {
    switch (filter) {
      case 'urgent':
        return job.isUrgent;
      case 'same_day':
        return _matchesSameDay(job);
      case 'beginner':
        return _matchesBeginner(job);
      case 'all':
      default:
        return true;
    }
  }

  static List<Job> apply(String filter, Iterable<Job> jobs) {
    if (filter == 'all') return jobs.toList();
    return jobs.where((j) => matches(filter, j)).toList();
  }

  static bool _matchesSameDay(Job job) {
    final haystack = _textHaystack(job);
    return haystack.contains('당일정산') ||
        haystack.contains('당일 정산') ||
        haystack.contains('same day') ||
        haystack.contains('same-day');
  }

  static bool _matchesBeginner(Job job) {
    final haystack = _textHaystack(job);
    return haystack.contains('초보') ||
        haystack.contains('beginner') ||
        haystack.contains('입문');
  }

  static String _textHaystack(Job job) {
    return [
      job.title,
      job.description ?? '',
      job.requirements ?? '',
    ].join(' ').toLowerCase();
  }
}
