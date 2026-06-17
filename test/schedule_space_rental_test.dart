import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/schedule.dart';
import 'package:hairspare/utils/schedule_space_rental.dart';

Schedule _schedule({
  required String id,
  String jobId = ScheduleSpaceRental.jobIdMarker,
  String spareId = 'spare-1',
  SpareInfo? spare,
}) {
  return Schedule(
    id: id,
    jobId: jobId,
    spareId: spareId,
    shopId: 'shop-1',
    date: '2030-06-15',
    startTime: '10:00',
    endTime: '12:00',
    status: 'scheduled',
    createdAt: DateTime(2030, 1, 1),
    updatedAt: DateTime(2030, 1, 1),
    spare: spare,
  );
}

void main() {
  group('ScheduleSpaceRental', () {
    test('detects space rental schedules by job marker or id prefix', () {
      expect(
        ScheduleSpaceRental.isSpaceRental(_schedule(id: 'regular-1')),
        isTrue,
      );
      expect(
        ScheduleSpaceRental.isSpaceRental(
          _schedule(id: 'sched-space-booking-1', jobId: 'other-job'),
        ),
        isTrue,
      );
      expect(
        ScheduleSpaceRental.isSpaceRental(
          _schedule(id: 'regular-1', jobId: 'job-1'),
        ),
        isFalse,
      );
    });

    test('derives booking id and chat id from space schedule id', () {
      final schedule = _schedule(id: 'sched-space-booking-1');

      expect(ScheduleSpaceRental.bookingIdFromSchedule(schedule), 'booking-1');
      expect(
        ScheduleSpaceRental.chatIdFromSchedule(schedule),
        'chat-space-booking-1',
      );
    });

    test('does not derive booking or chat id for regular schedules', () {
      final schedule = _schedule(id: 'sched-regular-1');

      expect(ScheduleSpaceRental.bookingIdFromSchedule(schedule), isNull);
      expect(ScheduleSpaceRental.chatIdFromSchedule(schedule), isNull);
    });

    test('uses spare name for booker line with fallback to spare id', () {
      expect(
        ScheduleSpaceRental.bookerLine(
          _schedule(
            id: 'sched-space-booking-1',
            spare: const SpareInfo(id: 'spare-1', name: '김스페어'),
          ),
        ),
        '예약자 · 김스페어',
      );
      expect(
        ScheduleSpaceRental.bookerLine(
          _schedule(id: 'sched-space-booking-1', spareId: 'spare-fallback'),
        ),
        '예약자 · spare-fallback',
      );
    });
  });
}
