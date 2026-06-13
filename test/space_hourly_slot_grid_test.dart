import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/space_rental.dart';
import 'package:hairspare/utils/space_hourly_slot_grid.dart';

SpaceRental _spaceWithSlots(List<TimeSlot> slots) {
  return SpaceRental(
    id: 's1',
    shopId: 'sh1',
    shopName: '테스트샵',
    address: '서울',
    regionId: 'r1',
    availableSlots: slots,
    pricePerHour: 30000,
    facilities: const ['의자'],
    status: SpaceStatus.available,
    createdAt: DateTime(2030, 1, 1),
  );
}

TimeSlot _slot(DateTime start, {bool available = true}) {
  return TimeSlot(
    startTime: start,
    endTime: start.add(const Duration(hours: 1)),
    isAvailable: available,
  );
}

void main() {
  group('SpaceHourlySlotGrid.buildCells', () {
    test('generates 12 hourly cells for 9-21', () {
      final date = DateTime(2030, 6, 15);
      final space = _spaceWithSlots([
        _slot(DateTime(2030, 6, 15, 10)),
        _slot(DateTime(2030, 6, 15, 11)),
      ]);
      final cells = SpaceHourlySlotGrid.buildCells(
        space: space,
        date: date,
        now: DateTime(2030, 6, 15, 8),
      );
      expect(cells.length, 12);
      expect(cells.first.startTime.hour, 9);
      expect(cells.last.startTime.hour, 20);
    });

    test('marks booked and unavailable', () {
      final date = DateTime(2030, 6, 15);
      final space = _spaceWithSlots([
        _slot(DateTime(2030, 6, 15, 10)),
        _slot(DateTime(2030, 6, 15, 12), available: false),
      ]);
      final cells = SpaceHourlySlotGrid.buildCells(
        space: space,
        date: date,
        now: DateTime(2030, 6, 15, 8),
      );
      expect(
        cells.firstWhere((c) => c.startTime.hour == 10).state,
        SlotCellState.available,
      );
      expect(
        cells.firstWhere((c) => c.startTime.hour == 11).state,
        SlotCellState.unavailable,
      );
      expect(
        cells.firstWhere((c) => c.startTime.hour == 12).state,
        SlotCellState.booked,
      );
    });

    test('marks past hours on today', () {
      final now = DateTime(2030, 6, 15, 11, 30);
      final space = _spaceWithSlots([
        for (var h = 9; h < 21; h++) _slot(DateTime(2030, 6, 15, h)),
      ]);
      final cells = SpaceHourlySlotGrid.buildCells(
        space: space,
        date: now,
        now: now,
      );
      expect(
        cells.firstWhere((c) => c.startTime.hour == 9).state,
        SlotCellState.past,
      );
      expect(
        cells.firstWhere((c) => c.startTime.hour == 11).state,
        SlotCellState.past,
      );
      expect(
        cells.firstWhere((c) => c.startTime.hour == 12).state,
        SlotCellState.available,
      );
    });
  });

  group('SpaceHourlySlotGrid range', () {
    test('contiguous available range', () {
      final date = DateTime(2030, 6, 15);
      final space = _spaceWithSlots([
        _slot(DateTime(2030, 6, 15, 10)),
        _slot(DateTime(2030, 6, 15, 11)),
        _slot(DateTime(2030, 6, 15, 12)),
      ]);
      final cells = SpaceHourlySlotGrid.buildCells(
        space: space,
        date: date,
        now: DateTime(2030, 6, 15, 8),
      );
      final a = cells.firstWhere((c) => c.startTime.hour == 10);
      final c = cells.firstWhere((c) => c.startTime.hour == 12);
      expect(
        SpaceHourlySlotGrid.isContiguousAvailableRange(cells, a, c),
        isTrue,
      );
      expect(SpaceHourlySlotGrid.durationHours(a, c), 3);
    });

    test('rejects range over booked cell', () {
      final date = DateTime(2030, 6, 15);
      final space = _spaceWithSlots([
        _slot(DateTime(2030, 6, 15, 10)),
        _slot(DateTime(2030, 6, 15, 11), available: false),
        _slot(DateTime(2030, 6, 15, 12)),
      ]);
      final cells = SpaceHourlySlotGrid.buildCells(
        space: space,
        date: date,
        now: DateTime(2030, 6, 15, 8),
      );
      final a = cells.firstWhere((c) => c.startTime.hour == 10);
      final c = cells.firstWhere((c) => c.startTime.hour == 12);
      expect(
        SpaceHourlySlotGrid.isContiguousAvailableRange(cells, a, c),
        isFalse,
      );
    });
  });
}
