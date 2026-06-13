import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../theme/app_theme.dart';
import '../utils/korean_public_holidays.dart';

/// [TableCalendar] 공통 — 일요일·공휴일 빨강, 토요일 파랑.
class KoreanTableCalendarBuilders {
  KoreanTableCalendarBuilders._();

  static CalendarBuilders forSelection({
    required DateTime selectedDay,
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    return CalendarBuilders(
      dowBuilder: (context, day) {
        return Center(
          child: Text(
            KoreanPublicHolidays.dowLabelsKo[day.weekday - 1],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KoreanPublicHolidays.dowHeaderColor(day),
            ),
          ),
        );
      },
      defaultBuilder: (context, day, focusedDay) =>
          _dayCell(day: day, selectedDay: selectedDay, today: now),
      selectedBuilder: (context, day, focusedDay) =>
          _dayCell(day: day, selectedDay: selectedDay, today: now, forceSelected: true),
      todayBuilder: (context, day, focusedDay) =>
          _dayCell(day: day, selectedDay: selectedDay, today: now, isTodayCell: true),
      outsideBuilder: (context, day, focusedDay) =>
          _dayCell(day: day, selectedDay: selectedDay, today: now, isOutside: true),
    );
  }

  static Widget _dayCell({
    required DateTime day,
    required DateTime selectedDay,
    required DateTime today,
    bool forceSelected = false,
    bool isTodayCell = false,
    bool isOutside = false,
  }) {
    final isSelected = forceSelected || isSameDay(selectedDay, day);
    final isToday = isTodayCell || isSameDay(today, day);
    final outsideAlpha = isOutside ? 0.4 : 1.0;
    final color = KoreanPublicHolidays.dayTextColor(
      day,
      isSelected: isSelected,
      isToday: isToday && !isSelected,
      outsideAlpha: outsideAlpha,
    );

    if (isSelected) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: AppTheme.primaryBlue,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (isToday) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Center(
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 16,
          color: color,
        ),
      ),
    );
  }
}
