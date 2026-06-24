import '../models/job.dart';
import 'job_popularity.dart';

/// 공고별 목록 정렬 모드.
enum JobsListSortMode {
  /// 급구 상단 + 나머지 최신순
  all,
  /// [JobPopularity] 점수 내림차순 (지원·조회 등)
  popular,
  latest,
  amount,
  deadline,
}

/// go_router query `sort` → [JobsListSortMode].
JobsListSortMode? jobsListSortModeFromRouteQuery(String? value) {
  if (value == null || value.isEmpty) return null;
  for (final mode in JobsListSortMode.values) {
    if (mode.name == value) return mode;
  }
  return null;
}

JobsListSortMode jobsListSortModeFromDropdown(String? value) {
  if (value == null) return JobsListSortMode.all;
  return switch (value) {
    '인기순' => JobsListSortMode.popular,
    '최신순' => JobsListSortMode.latest,
    '가격순' => JobsListSortMode.amount,
    '마감순' => JobsListSortMode.deadline,
    _ => JobsListSortMode.all,
  };
}

String? jobsListSortDropdownLabel(JobsListSortMode mode) {
  return switch (mode) {
    JobsListSortMode.all => null,
    JobsListSortMode.popular => '인기순',
    JobsListSortMode.latest => '최신순',
    JobsListSortMode.amount => '가격순',
    JobsListSortMode.deadline => '마감순',
  };
}

/// [list]를 제자리에서 정렬합니다.
void sortJobsForList(
  List<Job> list, {
  required JobsListSortMode sortMode,
  required bool recommendedFilterActive,
  required int Function(Job job) deadlineSortKey,
}) {
  if (recommendedFilterActive) {
    list.sort((a, b) {
      if (a.isPremium != b.isPremium) return a.isPremium ? -1 : 1;
      if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return;
  }

  switch (sortMode) {
    case JobsListSortMode.all:
      list.sort((a, b) {
        if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    case JobsListSortMode.popular:
      final metrics = JobPopularity.resolveMetrics(list);
      list.sort((a, b) {
        final scoreA = JobPopularity.score(
          a,
          metrics: metrics[a.id] ?? const JobPopularityMetrics(),
        );
        final scoreB = JobPopularity.score(
          b,
          metrics: metrics[b.id] ?? const JobPopularityMetrics(),
        );
        final byPopularity = scoreB.compareTo(scoreA);
        if (byPopularity != 0) return byPopularity;
        return b.createdAt.compareTo(a.createdAt);
      });
    case JobsListSortMode.amount:
      list.sort((a, b) => b.amount.compareTo(a.amount));
    case JobsListSortMode.deadline:
      list.sort(
        (a, b) => deadlineSortKey(a).compareTo(deadlineSortKey(b)),
      );
    case JobsListSortMode.latest:
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
