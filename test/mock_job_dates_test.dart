import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/mocks/mock_spare_data.dart';
import 'package:hairspare/utils/job_work_date_utils.dart';

void main() {
  test('mock public jobs exclude past work dates', () async {
    final jobs = await MockSpareData.getJobs();
    expect(jobs, isNotEmpty);
    for (final job in jobs) {
      expect(
        JobWorkDateUtils.isWorkDatePast(job.date),
        isFalse,
        reason: '${job.id} date ${job.date} is in the past',
      );
    }
  });

  test('overlap demo job is tomorrow or later', () async {
    final job = await MockSpareData.getJobById(MockSpareData.overlapDemoJobId);
    expect(JobWorkDateUtils.isWorkDatePast(job.date), isFalse);
  });
}
