import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/job.dart';
import 'package:hairspare/utils/jobs_list_sort.dart';

Job _job({
  required String id,
  bool isUrgent = false,
  DateTime? createdAt,
  int amount = 50000,
}) {
  return Job(
    id: id,
    title: 'test',
    shopName: 'shop',
    date: '2026-06-20',
    time: '10:00',
    amount: amount,
    energy: 3,
    requiredCount: 1,
    regionId: 'seoul-gangnam',
    isUrgent: isUrgent,
    isPremium: false,
    createdAt: createdAt ?? DateTime.now(),
  );
}

void main() {
  group('sortJobsForList', () {
    test('all mode puts urgent jobs first then newest', () {
      final jobs = [
        _job(id: 'normal', createdAt: DateTime(2026, 6, 20)),
        _job(id: 'urgent-old', isUrgent: true, createdAt: DateTime(2026, 6, 1)),
        _job(id: 'urgent-new', isUrgent: true, createdAt: DateTime(2026, 6, 19)),
      ];

      sortJobsForList(
        jobs,
        sortMode: JobsListSortMode.all,
        recommendedFilterActive: false,
        deadlineSortKey: (_) => 0,
      );

      expect(jobs.map((j) => j.id).toList(), [
        'urgent-new',
        'urgent-old',
        'normal',
      ]);
    });

    test('dropdown 인기순 maps to popular mode', () {
      expect(
        jobsListSortModeFromDropdown('인기순'),
        JobsListSortMode.popular,
      );
      expect(
        jobsListSortDropdownLabel(JobsListSortMode.popular),
        '인기순',
      );
    });

    test('dropdown 전체 maps to all mode', () {
      expect(jobsListSortModeFromDropdown(null), JobsListSortMode.all);
      expect(jobsListSortDropdownLabel(JobsListSortMode.all), isNull);
    });
  });
}
