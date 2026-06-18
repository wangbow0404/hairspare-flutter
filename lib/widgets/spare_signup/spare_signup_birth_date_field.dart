import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/birth_date_utils.dart';

/// 생년월일 선택 (년·월·일).
class SpareSignupBirthDateField extends StatefulWidget {
  const SpareSignupBirthDateField({
    super.key,
    this.value,
    required this.onChanged,
    this.validator,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? Function(DateTime?)? validator;

  @override
  State<SpareSignupBirthDateField> createState() =>
      _SpareSignupBirthDateFieldState();
}

class _SpareSignupBirthDateFieldState extends State<SpareSignupBirthDateField> {
  int? _year;
  int? _month;
  int? _day;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _syncFromValue(widget.value);
  }

  @override
  void didUpdateWidget(covariant SpareSignupBirthDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _syncFromValue(widget.value);
    }
  }

  void _syncFromValue(DateTime? value) {
    _year = value?.year;
    _month = value?.month;
    _day = value?.day;
  }

  List<int> get _years {
    final maxYear = DateTime.now().year - 14;
    final minYear = DateTime.now().year - 80;
    return List.generate(maxYear - minYear + 1, (i) => maxYear - i);
  }

  List<int> get _months => List.generate(12, (i) => i + 1);

  List<int> get _days {
    if (_year == null || _month == null) {
      return List.generate(31, (i) => i + 1);
    }
    final count = BirthDateUtils.daysInMonth(_year!, _month!);
    return List.generate(count, (i) => i + 1);
  }

  void _emit() {
    if (_year != null &&
        _month != null &&
        _day != null &&
        _day! > BirthDateUtils.daysInMonth(_year!, _month!)) {
      _day = null;
    }
    final composed = BirthDateUtils.composeDate(
      year: _year,
      month: _month,
      day: _day,
    );
    widget.onChanged(composed);
    setState(() {
      _errorText = widget.validator?.call(composed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '생년월일 *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.stitchTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing2),
        Row(
          children: [
            Expanded(
              child: _DateDropdown<int>(
                hint: '년',
                value: _year,
                items: _years,
                labelBuilder: (v) => '$v년',
                onChanged: (v) {
                  setState(() => _year = v);
                  _emit();
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacing2),
            Expanded(
              child: _DateDropdown<int>(
                hint: '월',
                value: _month,
                items: _months,
                labelBuilder: (v) => '$v월',
                onChanged: (v) {
                  setState(() {
                    _month = v;
                    if (v != null &&
                        _day != null &&
                        _year != null &&
                        _day! > BirthDateUtils.daysInMonth(_year!, v)) {
                      _day = null;
                    }
                  });
                  _emit();
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacing2),
            Expanded(
              child: _DateDropdown<int>(
                hint: '일',
                value: _day,
                items: _days,
                labelBuilder: (v) => '$v일',
                onChanged: (v) {
                  setState(() => _day = v);
                  _emit();
                },
              ),
            ),
          ],
        ),
        if (_errorText != null) ...[
          const SizedBox(height: AppTheme.spacing1),
          Text(
            _errorText!,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.urgentRed,
            ),
          ),
        ],
      ],
    );
  }
}

class _DateDropdown<T> extends StatelessWidget {
  const _DateDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing3),
            child: Text(
              hint,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing2),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.stitchTextPrimary,
                  ),
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
