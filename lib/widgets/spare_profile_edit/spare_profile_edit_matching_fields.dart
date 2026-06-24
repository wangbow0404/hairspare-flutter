import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../view_models/profile_edit_view_model.dart';
import '../spare_signup/spare_signup_region_picker.dart';
import '../spare_signup/spare_signup_text_field.dart';
import '../stitch/stitch_filter_chip.dart';
import 'spare_profile_edit_section_card.dart';

/// 프로필 수정 — 매칭·전문가 프로필 필드.
class SpareProfileEditMatchingFields extends StatelessWidget {
  const SpareProfileEditMatchingFields({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileEditViewModel>();

    return SpareProfileEditSectionCard(
      title: '매칭·전문가 프로필',
      subtitle: '모델 매칭·샵 검색에 노출되는 정보입니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '활동 역할',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'designer', label: Text('디자이너')),
                  ButtonSegment(value: 'step', label: Text('스텝')),
                ],
                selected: {vm.role},
                onSelectionChanged: (value) => vm.setRole(value.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          SpareSignupRegionPicker(
            provinceId: vm.provinceId,
            districtId: vm.districtId,
            onChanged: ({
              required provinceId,
              required districtId,
              required displayLabel,
            }) {
              vm.setRegion(
                province: provinceId,
                district: districtId,
                label: displayLabel,
              );
            },
          ),
          const SizedBox(height: AppTheme.spacing4),
          const Text(
            '경력',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          Slider(
            value: vm.experienceYears.toDouble(),
            min: 0,
            max: 20,
            divisions: 20,
            activeColor: AppTheme.stitchPrimary,
            label: vm.experienceYears == 0 ? '신입' : '${vm.experienceYears}년',
            onChanged: (v) => vm.setExperienceYears(v.round()),
          ),
          Text(
            vm.experienceYears == 0
                ? '신입 (0년)'
                : '경력 ${vm.experienceYears}년',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          const Text(
            '전문 분야 *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: [
              for (final s in vm.specialtyOptions)
                StitchFilterChip(
                  label: s,
                  isSelected: vm.specialties.contains(s),
                  onTap: () => vm.toggleSpecialty(s),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          SpareSignupTextField(
            controller: vm.matchingIntroController,
            label: '매칭 한줄 소개',
            hint: '예: 내추럴 염색·탈색 전문. 모델 촬영 경험 풍부합니다.',
            prefixIcon: Icons.chat_bubble_outline_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: AppTheme.spacing1),
          const Text(
            '모델에게 보이는 자기소개입니다. (80자 이내)',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: vm.matchingVisible,
            onChanged: vm.setMatchingVisible,
            activeTrackColor: AppTheme.stitchPrimaryContainer,
            title: const Text(
              '모델 매칭에 프로필 노출',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
            subtitle: const Text(
              '끄면 새로운 관심을 받지 않습니다.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
