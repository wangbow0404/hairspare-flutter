import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/mocks/mock_spare_data.dart';

void main() {
  test('model schedules parse without error', () async {
    final list = await MockSpareData.getSchedules(ownerId: 'model');
    expect(list, isNotEmpty);
    expect(list.every((s) => s.status != 'proposed'), isTrue);
  });
}
