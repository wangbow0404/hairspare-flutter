import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/mocks/mock_shop_data.dart';
import 'package:hairspare/mocks/mock_spare_data.dart';
import 'package:hairspare/utils/schedule_cancellation_policy.dart';

void main() {
  group('Mock schedule cancel flow', () {
    setUp(() {
      MockShopData.unilateralCancelCount30d = 0;
      MockShopData.jobPostingSuspendedUntil = null;
    });

    test('shop cancel records penalty and posts chat notice', () async {
      await MockSpareData.cancelSchedule(
        'sched-mock-2',
        actor: CancellationActor.shop,
        cancelReason: '샵 사정 (영업일/인력 등)',
      );

      expect(MockShopData.unilateralCancelCount30d, 1);

      final chat = await MockSpareData.getChatById('chat-mock-2');
      expect(
        chat.messages.any((m) => m.content.contains('[시스템]')),
        isTrue,
      );
      expect(
        chat.messages.last.content,
        contains('매장 사정으로 취소'),
      );

      final schedules = await MockSpareData.getSchedules();
      expect(
        schedules.any((s) => s.id == 'sched-mock-2'),
        isFalse,
      );
    });

    test('third shop cancel triggers job posting suspension', () {
      MockShopData.unilateralCancelCount30d = 2;

      MockShopData.recordShopUnilateralCancel();

      expect(MockShopData.unilateralCancelCount30d, 3);
      expect(MockShopData.jobPostingSuspendedUntil, isNotNull);
      expect(
        () => MockShopData.assertCanPostJob(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
