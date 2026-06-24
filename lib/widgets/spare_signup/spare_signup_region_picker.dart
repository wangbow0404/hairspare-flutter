import 'package:flutter/material.dart';

import '../../models/region.dart';
import '../../theme/app_theme.dart';
import '../../utils/region_helper.dart';

/// 전국 시/도 → 구/군 선택.
class SpareSignupRegionPicker extends StatefulWidget {
  const SpareSignupRegionPicker({
    super.key,
    this.provinceId,
    this.districtId,
    required this.onChanged,
    this.compactRow = false,
    this.label = '활동 지역 *',
  });

  final String? provinceId;
  final String? districtId;
  final void Function({
    required String? provinceId,
    required String? districtId,
    required String displayLabel,
  }) onChanged;
  final bool compactRow;
  final String label;

  @override
  State<SpareSignupRegionPicker> createState() =>
      _SpareSignupRegionPickerState();
}

class _SpareSignupRegionPickerState extends State<SpareSignupRegionPicker> {
  late String? _provinceId;
  late String? _districtId;

  @override
  void initState() {
    super.initState();
    _provinceId = widget.provinceId;
    _districtId = widget.districtId;
  }

  @override
  void didUpdateWidget(covariant SpareSignupRegionPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provinceId != widget.provinceId) {
      _provinceId = widget.provinceId;
    }
    if (oldWidget.districtId != widget.districtId) {
      _districtId = widget.districtId;
    }
  }

  List<Region> get _provinces => RegionHelper.getProvinces();

  List<Region> get _districts {
    if (_provinceId == null) return const [];
    return RegionHelper.getDistrictsByProvince(_provinceId!);
  }

  void _notify() {
    widget.onChanged(
      provinceId: _provinceId,
      districtId: _districtId,
      displayLabel: RegionHelper.formatRegionLabel(
        provinceId: _provinceId,
        districtId: _districtId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDistricts = _districts.isNotEmpty;

    if (widget.compactRow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppTheme.spacing1),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Row(
            children: [
              Expanded(
                child: _RegionDropdown(
                  hint: '시/도 선택',
                  value: _provinceId,
                  regions: _provinces,
                  compact: true,
                  onChanged: (id) {
                    setState(() {
                      _provinceId = id;
                      _districtId = null;
                    });
                    final districts = id == null
                        ? const <Region>[]
                        : RegionHelper.getDistrictsByProvince(id);
                    if (districts.isEmpty) {
                      _notify();
                    } else {
                      widget.onChanged(
                        provinceId: _provinceId,
                        districtId: null,
                        displayLabel: '',
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: _RegionDropdown(
                  hint: '구/군 선택',
                  value: _districtId,
                  regions: _districts,
                  compact: true,
                  enabled: hasDistricts,
                  onChanged: hasDistricts
                      ? (id) {
                          setState(() => _districtId = id);
                          _notify();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.stitchTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing2),
        _RegionDropdown(
          hint: '시/도 선택',
          value: _provinceId,
          regions: _provinces,
          onChanged: (id) {
            setState(() {
              _provinceId = id;
              _districtId = null;
            });
            final districts = id == null
                ? const <Region>[]
                : RegionHelper.getDistrictsByProvince(id);
            if (districts.isEmpty) {
              _notify();
            } else {
              widget.onChanged(
                provinceId: _provinceId,
                districtId: null,
                displayLabel: '',
              );
            }
          },
        ),
        if (hasDistricts) ...[
          const SizedBox(height: AppTheme.spacing2),
          _RegionDropdown(
            hint: '시/군/구 선택',
            value: _districtId,
            regions: _districts,
            onChanged: (id) {
              setState(() => _districtId = id);
              _notify();
            },
          ),
        ],
      ],
    );
  }
}

class _RegionDropdown extends StatelessWidget {
  const _RegionDropdown({
    required this.hint,
    required this.value,
    required this.regions,
    required this.onChanged,
    this.compact = false,
    this.enabled = true,
  });

  final String hint;
  final String? value;
  final List<Region> regions;
  final ValueChanged<String?>? onChanged;
  final bool compact;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: compact ? AppTheme.backgroundGray : AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(
            compact ? AppTheme.radiusLg : AppTheme.radiusXl,
          ),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
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
              for (final region in regions)
                DropdownMenuItem<String>(
                  value: region.id,
                  child: Text(
                    region.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.stitchTextPrimary,
                    ),
                  ),
                ),
            ],
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }
}
