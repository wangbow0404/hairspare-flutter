import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/utils/space_booking_rules.dart';

void main() {
  group('SpaceBookingRules.meetsMinHours', () {
    test('minHours 1 — 1시간 예약 가능', () {
      expect(
        SpaceBookingRules.meetsMinHours(selectedHours: 1, minHours: 1),
        isTrue,
      );
    });

    test('minHours 2 — 1시간 불가, 2시간 가능', () {
      expect(
        SpaceBookingRules.meetsMinHours(selectedHours: 1, minHours: 2),
        isFalse,
      );
      expect(
        SpaceBookingRules.meetsMinHours(selectedHours: 2, minHours: 2),
        isTrue,
      );
    });

    test('minHours 0 이하 — 1시간으로 취급', () {
      expect(
        SpaceBookingRules.meetsMinHours(selectedHours: 1, minHours: 0),
        isTrue,
      );
    });
  });

  group('SpaceBookingRules.belowMinHoursMessage', () {
    test('minHours 2 안내 문구', () {
      expect(
        SpaceBookingRules.belowMinHoursMessage(2),
        '이 공간은 최소 2시간부터 예약할 수 있어요.',
      );
    });
  });
}
