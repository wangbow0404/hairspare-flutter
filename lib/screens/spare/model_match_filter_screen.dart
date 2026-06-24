import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../models/model_match_preference.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/stitch/stitch_sticky_bottom_bar.dart';

/// 모델 매칭 1단계 — 만나고 싶은 모델 조건 설정.
class ModelMatchFilterScreen extends StatefulWidget {
  const ModelMatchFilterScreen({super.key});

  @override
  State<ModelMatchFilterScreen> createState() => _ModelMatchFilterScreenState();
}

class _ModelMatchFilterScreenState extends State<ModelMatchFilterScreen> {
  String _gender = ModelMatchOptions.anyLabel;
  String _career = ModelMatchOptions.anyLabel;
  final Set<String> _hairLengths = {};
  final Set<String> _treatments = {};
  final Set<String> _imageStyles = {};
  double _distanceKm = ModelMatchOptions.defaultDistanceKm;

  void _toggle(Set<String> set, String value) {
    setState(() {
      if (!set.add(value)) set.remove(value);
    });
  }

  void _startMatching() {
    final preference = ModelMatchPreference(
      gender: _gender,
      hairLengths: Set.of(_hairLengths),
      treatments: Set.of(_treatments),
      imageStyles: Set.of(_imageStyles),
      career: _career,
      distanceKm: _distanceKm,
    );
    final swipeRoute = GoRouterState.of(context).uri.path.startsWith('/shop')
        ? AppRoutes.shopHomeModelMatchSwipe
        : AppRoutes.spareHomeModelMatchSwipe;
    context.push(swipeRoute, extra: preference);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(title: '모델 매칭 설정'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing6,
        ),
        children: [
          _FilterSection(
            title: '원하는 성별',
            child: Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: [
                for (final g in ModelMatchOptions.genders)
                  StitchFilterChip(
                    label: g,
                    isSelected: _gender == g,
                    onTap: () => setState(() => _gender = g),
                  ),
              ],
            ),
          ),
          _FilterSection(
            title: '원하는 기장',
            child: _MultiChips(
              options: ModelMatchOptions.hairLengths,
              selected: _hairLengths,
              onToggle: (v) => _toggle(_hairLengths, v),
            ),
          ),
          _FilterSection(
            title: '선호하는 시술',
            child: _MultiChips(
              options: ModelMatchOptions.treatments,
              selected: _treatments,
              onToggle: (v) => _toggle(_treatments, v),
            ),
          ),
          _FilterSection(
            title: '모델 이미지',
            child: _MultiChips(
              options: ModelMatchOptions.imageStyles,
              selected: _imageStyles,
              onToggle: (v) => _toggle(_imageStyles, v),
            ),
          ),
          _FilterSection(
            title: '모델 경력',
            child: Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: [
                for (final c in ModelMatchOptions.careers)
                  StitchFilterChip(
                    label: c,
                    isSelected: _career == c,
                    onTap: () => setState(() => _career = c),
                  ),
              ],
            ),
          ),
          _DistanceSection(
            distanceKm: _distanceKm,
            onChanged: (v) => setState(() => _distanceKm = v),
          ),
          const SizedBox(height: AppTheme.spacing4),
          const Text(
            '설정된 조건에 맞는 모델이 우선 추천됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
        ],
      ),
      bottomNavigationBar: StitchStickyBottomBar(
        primaryLabel: '매칭 시작하기',
        onPrimary: _startMatching,
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          child,
        ],
      ),
    );
  }
}

class _MultiChips extends StatelessWidget {
  const _MultiChips({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacing2,
      runSpacing: AppTheme.spacing2,
      children: [
        for (final o in options)
          StitchFilterChip(
            label: o,
            isSelected: selected.contains(o),
            onTap: () => onToggle(o),
          ),
      ],
    );
  }
}

class _DistanceSection extends StatelessWidget {
  const _DistanceSection({required this.distanceKm, required this.onChanged});

  final double distanceKm;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '매칭 거리',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing3,
                vertical: AppTheme.spacing1,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurpleLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '${distanceKm.round()} km 이내',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.stitchPrimary,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.stitchPrimary,
            inactiveTrackColor: AppTheme.borderGray,
            thumbColor: AppTheme.stitchPrimary,
            overlayColor: AppTheme.stitchPrimary.withValues(alpha: 0.12),
            trackHeight: 4,
          ),
          child: Slider(
            value: distanceKm,
            min: ModelMatchOptions.minDistanceKm,
            max: ModelMatchOptions.maxDistanceKm,
            onChanged: onChanged,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1km',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.stitchTextSecondary,
                ),
              ),
              Text(
                '50km',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.stitchTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
