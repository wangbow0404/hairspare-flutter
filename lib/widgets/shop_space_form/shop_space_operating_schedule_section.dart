import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/space_operating_schedule.dart';
import '../../theme/app_theme.dart';
import '../../view_models/shop_space_form_view_model.dart';
import '../shop_job_new/shop_job_new_form_content.dart';
import '../shop_job_new/shop_job_new_ui_kit.dart';

/// 예약 가능 운영 시간 (매일/평일·주말/요일별).
class ShopSpaceOperatingScheduleSection extends StatelessWidget {
  const ShopSpaceOperatingScheduleSection({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  static const _modeLabels = {
    SpaceOperatingMode.everyDay: '매일 동일',
    SpaceOperatingMode.weekdayWeekend: '평일·주말',
    SpaceOperatingMode.perWeekday: '요일별',
  };

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopSpaceFormViewModel>();
    final scheduleErr =
        vm.showValidationErrors ? vm.validateSchedule() : null;

    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShopJobNewFieldLabel(
            label: '예약 가능 시간',
            isRequired: true,
            hasError: scheduleErr != null,
          ),
          const SizedBox(height: AppTheme.spacing3),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: SpaceOperatingMode.values.map((mode) {
              final selected = vm.operatingMode == mode;
              return ChoiceChip(
                label: Text(_modeLabels[mode]!),
                selected: selected,
                onSelected: (_) => vm.setOperatingMode(mode),
                selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      selected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                ),
                side: BorderSide(
                  color: selected ? AppTheme.primaryBlue : AppTheme.borderGray,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacing4),
          switch (vm.operatingMode) {
            SpaceOperatingMode.everyDay => _DayWindowEditor(
                label: '매일',
                window: vm.everyDayWindow,
                scrollController: scrollController,
                onChanged: vm.setEveryDayWindow,
              ),
            SpaceOperatingMode.weekdayWeekend => Column(
                children: [
                  _DayWindowEditor(
                    label: '평일 (월–금)',
                    window: vm.weekdayWindow,
                    scrollController: scrollController,
                    onChanged: vm.setWeekdayWindow,
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  _DayWindowEditor(
                    label: '주말 (토·일)',
                    window: vm.weekendWindow,
                    scrollController: scrollController,
                    onChanged: vm.setWeekendWindow,
                  ),
                ],
              ),
            SpaceOperatingMode.perWeekday => Column(
                children: [
                  for (var i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(height: AppTheme.spacing2),
                    _DayWindowEditor(
                      label: '${_weekdayLabels[i]}요일',
                      window: vm.perWeekdayWindows[i],
                      scrollController: scrollController,
                      onChanged: (w) => vm.setPerWeekdayWindow(i, w),
                    ),
                  ],
                ],
              ),
          },
          if (scheduleErr != null) ...[
            const SizedBox(height: AppTheme.spacing2),
            Text(
              scheduleErr,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.urgentRed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayWindowEditor extends StatelessWidget {
  const _DayWindowEditor({
    required this.label,
    required this.window,
    required this.onChanged,
    this.scrollController,
  });

  final String label;
  final DayWindow window;
  final ValueChanged<DayWindow> onChanged;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ShopJobNewSubFieldLabel(label: label),
              ),
              Switch(
                value: !window.closed,
                onChanged: (open) {
                  onChanged(
                    open ? window.copyWith(closed: false) : DayWindow.closed(),
                  );
                },
                activeThumbColor: AppTheme.primaryBlue,
              ),
              Text(
                window.closed ? '휴무' : '운영',
                style: TextStyle(
                  fontSize: 12,
                  color: window.closed
                      ? AppTheme.textSecondary
                      : AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (!window.closed) ...[
            const SizedBox(height: AppTheme.spacing2),
            Row(
              children: [
                Expanded(
                  child: _TimePickerTile(
                    label: '시작',
                    time: window.start,
                    scrollController: scrollController,
                    onPick: (t) => onChanged(window.copyWith(start: t)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing2),
                  child: Text('~', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _TimePickerTile(
                    label: '종료',
                    time: window.end,
                    scrollController: scrollController,
                    onPick: (t) => onChanged(window.copyWith(end: t)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({
    required this.label,
    required this.time,
    required this.onPick,
    this.scrollController,
  });

  final String label;
  final String time;
  final ValueChanged<String> onPick;
  final ScrollController? scrollController;

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts.first) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final initial = _parseTime(time);
        final picked = await shopJobNewRunPicker<TimeOfDay?>(
          scrollController,
          () => showTimePicker(
            context: context,
            initialTime: initial,
          ),
        );
        if (picked == null) return;
        onPick(_format(picked));
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing3,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
