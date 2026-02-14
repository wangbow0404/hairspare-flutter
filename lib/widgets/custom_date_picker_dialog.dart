import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_theme.dart';

/// 일요일 빨간색, 토요일 파란색, 공휴일 빨간색이 적용된 커스텀 날짜 선택 다이얼로그
class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;

  const CustomDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => CustomDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        onDateSelected: (date) => Navigator.pop(context, date),
      ),
    );
  }

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  /// 한국 공휴일 (2025-2027) - 행정안전부 고시 기준
  static final Set<String> _holidays = {
    // 2025
    '2025-01-01', // 신정
    '2025-01-28', '2025-01-29', '2025-01-30', // 설날 연휴 (1/29 당일)
    '2025-03-01', '2025-03-03', // 삼일절(토), 대체공휴일
    '2025-05-05', // 어린이날
    '2025-06-06', '2025-08-15', '2025-10-03', // 현충일, 광복절, 개천절
    '2025-10-05', '2025-10-06', '2025-10-07', '2025-10-08', // 추석 연휴(10/6 당일) + 대체
    '2025-10-09', '2025-12-25', // 한글날, 크리스마스
    // 2026
    '2026-01-01', // 신정
    '2026-02-16', '2026-02-17', '2026-02-18', // 설날 연휴 (2/17 당일) - 2/19 아님
    '2026-03-01', '2026-03-02', // 삼일절(일), 대체공휴일
    '2026-05-05', '2026-06-06', '2026-08-15', '2026-10-03', // 어린이날, 현충일, 광복절, 개천절
    '2026-09-24', '2026-09-25', '2026-09-26', // 추석 연휴 (9/25 당일)
    '2026-10-09', '2026-12-25', // 한글날, 크리스마스
    // 2027
    '2027-01-01', '2027-02-10', '2027-02-11', '2027-02-12', // 신정, 설날 연휴
    '2027-03-01', '2027-05-05', '2027-06-06', '2027-08-15',
    '2027-10-03', '2027-10-11', '2027-10-12', '2027-10-13', // 개천절, 추석 연휴
    '2027-10-09', '2027-12-25', // 한글날, 크리스마스
  };

  static String _toKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static bool _isHoliday(DateTime day) {
    return _holidays.contains(_toKey(day));
  }

  Color _getDayColor(DateTime day, {bool isSelected = false, bool isToday = false}) {
    if (isSelected) return Colors.white;
    if (isToday && !isSelected) return AppTheme.primaryBlue;
    if (_isHoliday(day)) return AppTheme.urgentRed;
    if (day.weekday == DateTime.sunday) return AppTheme.urgentRed;
    if (day.weekday == DateTime.saturday) return AppTheme.primaryBlue;
    return AppTheme.textPrimary;
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '날짜 선택',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('M월 d일 (E)', 'ko_KR').format(_selectedDay),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: widget.firstDate,
              lastDay: widget.lastDate,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay) &&
                    !selectedDay.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day)) &&
                    !selectedDay.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day))) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              locale: 'ko_KR',
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: const Icon(Icons.chevron_left),
                rightChevronIcon: const Icon(Icons.chevron_right),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  final dowLabels = ['일', '월', '화', '수', '목', '금', '토'];
                  final color = day.weekday == DateTime.sunday
                      ? AppTheme.urgentRed
                      : day.weekday == DateTime.saturday
                          ? AppTheme.primaryBlue
                          : AppTheme.textSecondary;
                  return Center(
                    child: Text(
                      dowLabels[day.weekday - 1],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  );
                },
                defaultBuilder: (context, day, focusedDay) {
                  final isSelected = isSameDay(_selectedDay, day);
                  final isToday = isSameDay(DateTime.now(), day);
                  final color = _getDayColor(day, isSelected: isSelected, isToday: isToday);
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
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
                },
                todayBuilder: (context, day, focusedDay) {
                  final isSelected = isSameDay(_selectedDay, day);
                  final color = isSelected ? Colors.white : _getDayColor(day, isToday: true);
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.primaryBlue.withOpacity(0.2),
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
                },
                outsideBuilder: (context, day, focusedDay) {
                  final color = _getDayColor(day).withOpacity(0.4);
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(fontSize: 16, color: color),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => widget.onDateSelected(_selectedDay),
                  child: const Text('선택'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
