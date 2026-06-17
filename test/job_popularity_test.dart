import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/job.dart';
import 'package:hairspare/utils/job_popularity.dart';

Job _job({
  required String id,
  int amount = 50000,
  bool isUrgent = false,
  bool isPremium = false,
  int energy = 3,
}) {
  return Job(
    id: id,
    title: 'test',
    shopName: 'shop',
    date: '2026-06-20',
    time: '10:00',
    amount: amount,
    energy: energy,
    requiredCount: 1,
    regionId: 'seoul-gangnam',
    isUrgent: isUrgent,
    isPremium: isPremium,
    createdAt: DateTime.now(),
  );
}

void main() {
  group('JobPopularity', () {
    test('ranks jobs with more applications higher', () {
      final jobs = [
        _job(id: 'low'),
        _job(id: 'high', amount: 45000),
      ];
      final metrics = {
        'low': const JobPopularityMetrics(applicationCount: 1),
        'high': const JobPopularityMetrics(applicationCount: 5),
      };
      final top = JobPopularity.topPopular(jobs, metricsByJobId: metrics);
      expect(top.first.id, 'high');
    });

    test('urgent jobs do not show popular badge', () {
      final job = _job(id: 'urgent', isUrgent: true);
      final ids = {'urgent'};
      expect(JobPopularity.showsPopularBadge(job, ids), isFalse);
    });

    test('non-urgent top job shows popular badge', () {
      final job = _job(id: 'popular');
      final ids = {'popular'};
      expect(JobPopularity.showsPopularBadge(job, ids), isTrue);
    });
  });
}
