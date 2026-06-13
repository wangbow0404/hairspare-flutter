import '../models/space_rental.dart';

/// 1시간 칸 UI 상태.
enum SlotCellState {
  available,
  unavailable,
  booked,
  past,
}

/// 예약 그리드의 단일 1시간 칸.
class HourlySlotCell {
  const HourlySlotCell({
    required this.startTime,
    required this.endTime,
    required this.state,
    this.sourceSlot,
  });

  final DateTime startTime;
  final DateTime endTime;
  final SlotCellState state;

  /// [SpaceRental.availableSlots]와 매칭된 원본(예약 API용).
  final TimeSlot? sourceSlot;

  bool get isTappable => state == SlotCellState.available;

  TimeSlot toBookingSlot() => sourceSlot ??
      TimeSlot(
        startTime: startTime,
        endTime: endTime,
        isAvailable: true,
      );
}

/// 공간 예약 — 날짜별 1시간(09~21) 그리드 생성·범위 검증.
abstract final class SpaceHourlySlotGrid {
  SpaceHourlySlotGrid._();

  static const int defaultOpenHour = 9;
  static const int defaultCloseHour = 21;

  /// [date] 하루의 09:00~21:00(마지막 칸 20:00–21:00) 1시간 칸 목록.
  static List<HourlySlotCell> buildCells({
    required SpaceRental space,
    required DateTime date,
    DateTime? now,
    int openHour = defaultOpenHour,
    int closeHour = defaultCloseHour,
  }) {
    final clock = now ?? DateTime.now();
    final day = DateTime(date.year, date.month, date.day);
    final slotsByStart = <DateTime, TimeSlot>{};
    for (final slot in space.availableSlots) {
      final slotDay = DateTime(
        slot.startTime.year,
        slot.startTime.month,
        slot.startTime.day,
      );
      if (slotDay == day) {
        slotsByStart[_slotKey(slot.startTime)] = slot;
      }
    }

    final cells = <HourlySlotCell>[];
    for (var hour = openHour; hour < closeHour; hour++) {
      final start = DateTime(day.year, day.month, day.day, hour);
      final end = start.add(const Duration(hours: 1));
      final matched = slotsByStart[_slotKey(start)];

      final isToday = day.year == clock.year &&
          day.month == clock.month &&
          day.day == clock.day;

      SlotCellState state;
      if (isToday && !start.isAfter(clock)) {
        state = SlotCellState.past;
      } else if (matched == null) {
        state = SlotCellState.unavailable;
      } else if (!matched.isAvailable) {
        state = SlotCellState.booked;
      } else {
        state = SlotCellState.available;
      }

      cells.add(
        HourlySlotCell(
          startTime: start,
          endTime: end,
          state: state,
          sourceSlot: matched,
        ),
      );
    }
    return cells;
  }

  /// [start]~[end] 구간(양 끝 포함)이 모두 [SlotCellState.available]인지.
  static bool isContiguousAvailableRange(
    List<HourlySlotCell> cells,
    HourlySlotCell start,
    HourlySlotCell end,
  ) {
    final ordered = _orderedRange(cells, start, end);
    if (ordered.isEmpty) return false;
    return ordered.every((c) => c.state == SlotCellState.available);
  }

  /// 범위에 포함된 칸 목록 (시작·끝 포함, 시간순).
  static List<HourlySlotCell> cellsInRange(
    List<HourlySlotCell> cells,
    HourlySlotCell start,
    HourlySlotCell end,
  ) {
    return _orderedRange(cells, start, end);
  }

  static int durationHours(
    HourlySlotCell start,
    HourlySlotCell end,
  ) {
    return end.endTime.difference(start.startTime).inHours;
  }

  static DateTime _slotKey(DateTime t) =>
      DateTime(t.year, t.month, t.day, t.hour);

  static List<HourlySlotCell> _orderedRange(
    List<HourlySlotCell> cells,
    HourlySlotCell start,
    HourlySlotCell end,
  ) {
    final a = start.startTime.isBefore(end.startTime) ? start : end;
    final b = start.startTime.isBefore(end.startTime) ? end : start;
    final startMs = a.startTime.millisecondsSinceEpoch;
    final endMs = b.startTime.millisecondsSinceEpoch;

    return cells
        .where(
          (c) =>
              c.startTime.millisecondsSinceEpoch >= startMs &&
              c.startTime.millisecondsSinceEpoch <= endMs,
        )
        .toList();
  }
}
