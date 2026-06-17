import '../models/job.dart';
import '../mocks/mock_shop_data.dart';
import 'api_config.dart';

/// 공고 인기도 지표 (서버 집계 연동 전 mock·클라이언트 공통 형태).
class JobPopularityMetrics {
  const JobPopularityMetrics({
    this.applicationCount = 0,
    this.viewCount = 0,
  });

  final int applicationCount;
  final int viewCount;
}

/// 인기 공고 선정·배지 표시 규칙.
///
/// **점수 구성 (높을수록 인기)**
/// 1. 지원 수 × 10 — 가장 큰 비중
/// 2. 조회 수 × 1
/// 3. 일급 ÷ 10,000 (만원 단위)
/// 4. 프리미엄 매장 +5
/// 5. 등록 3일 이내 신규 보너스 (최대 +6)
/// 6. 에너지 3개 이하 +2 (지원 장벽 낮음)
///
/// **인기 배지**
/// - 급구 공고는 `급구` 배지 우선 → 인기 배지 없음
/// - 노출 중인 공고 풀에서 점수 상위 [topLimit]개 (기본 10)
abstract final class JobPopularity {
  JobPopularity._();

  static const int defaultTopLimit = 10;

  static Map<String, JobPopularityMetrics> resolveMetrics(Iterable<Job> jobs) {
    if (ApiConfig.useMockData) {
      return MockShopData.popularityMetricsForJobs(jobs.map((j) => j.id));
    }
    return {};
  }

  static int score(
    Job job, {
    JobPopularityMetrics metrics = const JobPopularityMetrics(),
  }) {
    var total = metrics.applicationCount * 10 + metrics.viewCount;
    total += (job.amount / 10000).round();
    if (job.isPremium) total += 5;

    final ageHours = DateTime.now().difference(job.createdAt).inHours;
    if (ageHours <= 72) {
      total += (72 - ageHours) ~/ 12;
    }
    if (job.energy <= 3) total += 2;

    return total;
  }

  static List<Job> topPopular(
    List<Job> jobs, {
    int limit = defaultTopLimit,
    Map<String, JobPopularityMetrics>? metricsByJobId,
  }) {
    final metrics = metricsByJobId ?? resolveMetrics(jobs);
    final published = jobs.where((j) => j.status == 'published' && !j.isHidden);
    final ranked = published.toList()
      ..sort(
        (a, b) => score(
          b,
          metrics: metrics[b.id] ?? const JobPopularityMetrics(),
        ).compareTo(
          score(
            a,
            metrics: metrics[a.id] ?? const JobPopularityMetrics(),
          ),
        ),
      );
    return ranked.take(limit).toList();
  }

  static Set<String> popularJobIds(
    List<Job> jobs, {
    int limit = defaultTopLimit,
    Map<String, JobPopularityMetrics>? metricsByJobId,
  }) {
    return topPopular(
      jobs,
      limit: limit,
      metricsByJobId: metricsByJobId,
    ).map((j) => j.id).toSet();
  }

  static bool showsPopularBadge(
    Job job,
    Set<String> popularJobIds,
  ) {
    if (job.isUrgent) return false;
    return popularJobIds.contains(job.id);
  }
}
