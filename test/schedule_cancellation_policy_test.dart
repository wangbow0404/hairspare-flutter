import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/job.dart';
import 'package:hairspare/models/schedule.dart';
import 'package:hairspare/utils/schedule_cancellation_policy.dart';

Schedule _schedule({
  required String date,
  required String startTime,
  String status = 'scheduled',
  int energy = 5,
}) {
  return Schedule(
    id: 'sched-test',
    jobId: 'job-test',
    spareId: 'spare-1',
    shopId: 'shop-1',
    date: date,
    startTime: startTime,
    endTime: '18:00',
    status: status,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    job: Job(
      id: 'job-test',
      title: '테스트 공고',
      shopName: '테스트 샵',
      date: date,
      time: startTime,
      amount: 100000,
      energy: energy,
      requiredCount: 1,
      regionId: 'r1',
      isUrgent: false,
      isPremium: false,
      createdAt: DateTime(2026, 1, 1),
    ),
  );
}

void main() {
  group('ScheduleCancellationPolicy v2_unilateral', () {
    test('spare allowed before start with energy forfeit', () {
      final s = _schedule(date: '2030-06-15', startTime: '14:00', energy: 7);
      final now = DateTime(2030, 6, 15, 10, 0);

      final e = ScheduleCancellationPolicy.evaluate(
        s,
        actor: CancellationActor.spare,
        now: now,
      );

      expect(e.canCancelInApp, isTrue);
      expect(e.penaltyTier, CancellationPenaltyTier.spareEnergyForfeit);
      expect(e.energyForfeit, 7);
      expect(e.penaltySummary, contains('환불되지 않습니다'));
    });

    test('blocks after work start', () {
      final s = _schedule(date: '2030-06-15', startTime: '14:00');
      final now = DateTime(2030, 6, 15, 14, 30);

      final e = ScheduleCancellationPolicy.evaluate(
        s,
        now: now,
      );

      expect(e.canCancelInApp, isFalse);
      expect(e.status, CancellationEligibilityStatus.blockedAfterStart);
    });

    test('blocks proposed schedule', () {
      final s = _schedule(
        date: '2030-06-15',
        startTime: '14:00',
        status: 'proposed',
      );

      final e = ScheduleCancellationPolicy.evaluate(s);

      expect(e.canCancelInApp, isFalse);
      expect(e.status, CancellationEligibilityStatus.blockedNotScheduled);
    });

    test('shop warning level from cancel count', () {
      expect(
        ScheduleCancellationPolicy.shopWarningLevelForCount(0),
        ShopCancellationWarningLevel.none,
      );
      expect(
        ScheduleCancellationPolicy.shopWarningLevelForCount(1),
        ShopCancellationWarningLevel.warning,
      );
      expect(
        ScheduleCancellationPolicy.shopWarningLevelForCount(2),
        ShopCancellationWarningLevel.suspensionImminent,
      );
      expect(
        ScheduleCancellationPolicy.shopWarningLevelForCount(3),
        ShopCancellationWarningLevel.suspended,
      );
    });

    test('shop allowed includes cumulative penalty summary', () {
      final s = _schedule(date: '2030-06-15', startTime: '14:00');
      final now = DateTime(2030, 6, 15, 8, 0);

      final e = ScheduleCancellationPolicy.evaluate(
        s,
        actor: CancellationActor.shop,
        now: now,
        shopUnilateralCancelCount30d: 2,
      );

      expect(e.canCancelInApp, isTrue);
      expect(e.shopWarningLevel, ShopCancellationWarningLevel.suspensionImminent);
      expect(e.penaltySummary, contains('7일'));
    });

    test('cancellableFrom includes schedules before start', () {
      final soon = _schedule(date: '2030-06-15', startTime: '16:00');
      final now = DateTime(2030, 6, 15, 15, 0);

      final list = ScheduleCancellationPolicy.cancellableFrom(
        [soon],
        now: now,
      );

      expect(list, [soon]);
    });
  });
}
