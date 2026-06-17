import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/mocks/mock_spare_data.dart';
import 'package:hairspare/utils/schedule_conflict.dart';

void main() {
  test('overlap demo job conflicts with dedicated blocker schedule', () async {
    final job = await MockSpareData.getJobById(MockSpareData.overlapDemoJobId);
    final schedules = await MockSpareData.getSchedules(ownerId: 'me');
    final window = ScheduleConflict.windowFromJob(job);
    expect(window, isNotNull);

    final conflicts = ScheduleConflict.findBlockingSchedules(
      all: schedules,
      candidate: window!,
    );

    expect(
      conflicts.any((s) => s.id == MockSpareData.overlapDemoBlockerScheduleId),
      isTrue,
    );
  });
}
