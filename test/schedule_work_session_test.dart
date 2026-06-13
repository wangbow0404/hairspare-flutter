import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/schedule.dart';
import 'package:hairspare/utils/schedule_work_session.dart';

Schedule _schedule({
  required String date,
  required String startTime,
  String? endTime,
}) {
  return Schedule(
    id: 's1',
    jobId: 'j1',
    spareId: 'sp1',
    shopId: 'sh1',
    date: date,
    startTime: startTime,
    endTime: endTime,
    status: 'confirmed',
    createdAt: DateTime(2030, 1, 1),
    updatedAt: DateTime(2030, 1, 1),
  );
}

void main() {
  group('ScheduleWorkSession.phase', () {
    test('before start', () {
      final s = _schedule(
        date: '2030-06-15',
        startTime: '14:00',
        endTime: '18:00',
      );
      final now = DateTime(2030, 6, 15, 13, 30);
      expect(ScheduleWorkSession.phase(s, now), ScheduleWorkPhase.beforeStart);
    });

    test('in progress', () {
      final s = _schedule(
        date: '2030-06-15',
        startTime: '14:00',
        endTime: '18:00',
      );
      final now = DateTime(2030, 6, 15, 16, 0);
      expect(ScheduleWorkSession.phase(s, now), ScheduleWorkPhase.inProgress);
    });

    test('after end', () {
      final s = _schedule(
        date: '2030-06-15',
        startTime: '14:00',
        endTime: '18:00',
      );
      final now = DateTime(2030, 6, 15, 18, 30);
      expect(ScheduleWorkSession.phase(s, now), ScheduleWorkPhase.afterEnd);
    });
  });

  group('ScheduleWorkSession.workCheckBlockedMessage', () {
    test('before start returns snack message', () {
      final s = _schedule(
        date: '2030-06-15',
        startTime: '09:30',
        endTime: '13:00',
      );
      final msg = ScheduleWorkSession.workCheckBlockedMessage(
        s,
        DateTime(2030, 6, 15, 8, 0),
      );
      expect(msg, '아직 근무 전입니다.');
    });

    test('in progress returns snack message', () {
      final s = _schedule(
        date: '2030-06-15',
        startTime: '09:30',
        endTime: '13:00',
      );
      final msg = ScheduleWorkSession.workCheckBlockedMessage(
        s,
        DateTime(2030, 6, 15, 10, 0),
      );
      expect(msg, '아직 근무 중입니다.');
    });

    test('after end returns null', () {
      final s = _schedule(
        date: '2030-06-15',
        startTime: '09:30',
        endTime: '13:00',
      );
      final msg = ScheduleWorkSession.workCheckBlockedMessage(
        s,
        DateTime(2030, 6, 15, 14, 0),
      );
      expect(msg, isNull);
    });
  });
}
