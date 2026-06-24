import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/space_rental.dart';
import 'package:hairspare/utils/space_rental_list_sort.dart';

SpaceRental _space({
  required String id,
  DateTime? createdAt,
  int pricePerHour = 30000,
  int? reviewCount,
  double? averageRating,
  List<TimeSlot>? slots,
}) {
  return SpaceRental(
    id: id,
    shopId: 'shop-$id',
    shopName: '샵 $id',
    address: '서울',
    regionId: 'seoul-gangnam',
    availableSlots: slots ?? const [],
    pricePerHour: pricePerHour,
    facilities: const [],
    status: SpaceStatus.available,
    createdAt: createdAt ?? DateTime(2026, 1, 1),
    reviewCount: reviewCount,
    averageRating: averageRating,
  );
}

void main() {
  test('all mode puts urgent (today slot) spaces first', () {
    final today = DateTime.now();
    final todaySlot = TimeSlot(
      startTime: DateTime(today.year, today.month, today.day, 14),
      endTime: DateTime(today.year, today.month, today.day, 16),
      isAvailable: true,
    );
    final list = [
      _space(
        id: 'old',
        createdAt: DateTime(2026, 6, 1),
        slots: [
          TimeSlot(
            startTime: DateTime(2026, 12, 1, 10),
            endTime: DateTime(2026, 12, 1, 12),
            isAvailable: true,
          ),
        ],
      ),
      _space(
        id: 'urgent',
        createdAt: DateTime(2026, 1, 1),
        slots: [todaySlot],
      ),
    ];

    sortSpacesForList(list, sortMode: SpaceRentalListSortMode.all);

    expect(list.first.id, 'urgent');
  });

  test('popular mode sorts by review score', () {
    final list = [
      _space(id: 'low', reviewCount: 1, averageRating: 3),
      _space(id: 'high', reviewCount: 10, averageRating: 4.8),
    ];

    sortSpacesForList(list, sortMode: SpaceRentalListSortMode.popular);

    expect(list.first.id, 'high');
  });

  test('dropdown label round-trip', () {
    expect(
      spaceRentalSortModeFromDropdown('인기순'),
      SpaceRentalListSortMode.popular,
    );
    expect(
      spaceRentalSortDropdownLabel(SpaceRentalListSortMode.latest),
      '최신순',
    );
    expect(spaceRentalSortModeFromDropdown(null), SpaceRentalListSortMode.all);
  });
}
