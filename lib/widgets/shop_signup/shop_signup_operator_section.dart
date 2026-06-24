import 'package:flutter/material.dart';

import '../../models/shop_signup_data.dart';
import '../../theme/app_theme.dart';
import '../spare_signup/spare_signup_ui_kit.dart';
import '../stitch/stitch_filter_chip.dart';

/// 운영 유형 선택 + 대리인 정보 (조건부).
class ShopSignupOperatorSection extends StatelessWidget {
  const ShopSignupOperatorSection({
    super.key,
    required this.operatorType,
    required this.onOperatorTypeChanged,
    required this.proxyNameController,
    required this.proxyRelationController,
    required this.proxyPhoneController,
  });

  final ShopOperatorType operatorType;
  final ValueChanged<ShopOperatorType> onOperatorTypeChanged;
  final TextEditingController proxyNameController;
  final TextEditingController proxyRelationController;
  final TextEditingController proxyPhoneController;

  @override
  Widget build(BuildContext context) {
    return SpareSignupSectionCard(
      title: '운영 유형',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: AppTheme.spacing1),
            child: Text(
              '어떻게 운영하시나요?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: [
              for (final type in ShopOperatorType.values)
                StitchFilterChip(
                  label: type.label,
                  isSelected: operatorType == type,
                  onTap: () => onOperatorTypeChanged(type),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            operatorType.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.stitchTextSecondary,
              height: 1.4,
            ),
          ),
          if (operatorType == ShopOperatorType.proxy) ...[
            const SizedBox(height: AppTheme.spacing6),
            const Padding(
              padding: EdgeInsets.only(left: AppTheme.spacing1),
              child: Text(
                '대리인 정보',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.stitchTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            SpareSignupLabeledField(
              controller: proxyNameController,
              label: '대리인 이름',
              hint: '실명을 입력하세요',
              validator: (v) => v == null || v.trim().isEmpty
                  ? '대리인 이름을 입력해 주세요'
                  : null,
            ),
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupLabeledField(
              controller: proxyRelationController,
              label: '관계',
              hint: '예: 점장, 매니저',
              validator: (v) => v == null || v.trim().isEmpty
                  ? '관계를 입력해 주세요'
                  : null,
            ),
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupLabeledField(
              controller: proxyPhoneController,
              label: '대리인 연락처',
              hint: '010-0000-0000',
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.trim().isEmpty
                  ? '연락처를 입력해 주세요'
                  : null,
            ),
            const SizedBox(height: AppTheme.spacing3),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing3),
              decoration: BoxDecoration(
                color: AppTheme.orange50,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.orange100),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppTheme.orange600,
                  ),
                  SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: Text(
                      '가입 후 사업자·본인 인증을 완료하면 대리인 승인 신청을 진행할 수 있습니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.stitchTextSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
