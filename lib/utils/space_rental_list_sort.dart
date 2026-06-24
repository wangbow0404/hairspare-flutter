import '../models/space_rental.dart';

/// 공간대여 목록 정렬 모드.
enum SpaceRentalListSortMode {
  /// 오늘 예약 가능(급구) 우선 + 최신순
  all,
  popular,
  latest,
  price,
  deadline,
}

SpaceRentalListSortMode spaceRentalSortModeFromDropdown(String? value) {
  if (value == null) return SpaceRentalListSortMode.all;
  return switch (value) {
    '인기순' => SpaceRentalListSortMode.popular,
    '최신순' => SpaceRentalListSortMode.latest,
    '가격순' => SpaceRentalListSortMode.price,
    '마감순' => SpaceRentalListSortMode.deadline,
    _ => SpaceRentalListSortMode.all,
  };
}

String? spaceRentalSortDropdownLabel(SpaceRentalListSortMode mode) {
  return switch (mode) {
    SpaceRentalListSortMode.all => null,
    SpaceRentalListSortMode.popular => '인기순',
    SpaceRentalListSortMode.latest => '최신순',
    SpaceRentalListSortMode.price => '가격순',
    SpaceRentalListSortMode.deadline => '마감순',
  };
}

/// 오늘 예약 가능한 슬롯이 있는 공간.
bool isSpaceUrgent(SpaceRental space) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  return space.availableSlots.any((slot) {
    if (!slot.isAvailable) return false;
    final slotDate = DateTime(
      slot.startTime.year,
      slot.startTime.month,
      slot.startTime.day,
    );
    return slotDate.isAtSameMomentAs(todayDate);
  });
}

/// 24시간 이내 예약 가능한 슬롯이 있는 공간.
bool isSpaceDeadlineImminent(SpaceRental space) {
  final cutoff = DateTime.now().add(const Duration(hours: 24));
  return space.availableSlots.any(
    (slot) => slot.isAvailable && slot.startTime.isBefore(cutoff),
  );
}

DateTime? nextAvailableSlotStart(SpaceRental space) {
  final now = DateTime.now();
  DateTime? nearest;
  for (final slot in space.availableSlots) {
    if (!slot.isAvailable || !slot.startTime.isAfter(now)) continue;
    if (nearest == null || slot.startTime.isBefore(nearest)) {
      nearest = slot.startTime;
    }
  }
  return nearest;
}

double spacePopularityScore(SpaceRental space) {
  final reviews = space.reviewCount ?? 0;
  final rating = space.averageRating ?? 0;
  var score = reviews * 10.0 + rating * 8.0;
  if (space.isPremium) score += 40;
  score += space.availableSlots.where((s) => s.isAvailable).length * 2;
  return score;
}

/// [list]를 제자리에서 정렬합니다.
void sortSpacesForList(
  List<SpaceRental> list, {
  required SpaceRentalListSortMode sortMode,
}) {
  switch (sortMode) {
    case SpaceRentalListSortMode.all:
      list.sort((a, b) {
        final au = isSpaceUrgent(a);
        final bu = isSpaceUrgent(b);
        if (au != bu) return au ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    case SpaceRentalListSortMode.popular:
      list.sort((a, b) {
        final byPopularity =
            spacePopularityScore(b).compareTo(spacePopularityScore(a));
        if (byPopularity != 0) return byPopularity;
        return b.createdAt.compareTo(a.createdAt);
      });
    case SpaceRentalListSortMode.latest:
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case SpaceRentalListSortMode.price:
      list.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
    case SpaceRentalListSortMode.deadline:
      list.sort((a, b) {
        final aNext = nextAvailableSlotStart(a);
        final bNext = nextAvailableSlotStart(b);
        if (aNext == null && bNext == null) return 0;
        if (aNext == null) return 1;
        if (bNext == null) return -1;
        return aNext.compareTo(bNext);
      });
  }
}
