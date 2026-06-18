import 'package:flutter/material.dart';

import '../../models/spare_subtype.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/hairspare_brand_assets.dart';
import '../../widgets/common/shared_app_bar.dart';
import 'spare_signup_model_screen.dart';
import 'spare_signup_professional_screen.dart';

/// 회원가입 1단계 — 스페어·디자이너 vs 모델 유형 선택.
class SpareSignupTypeScreen extends StatelessWidget {
  const SpareSignupTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '회원가입'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.spacing4),
              const Center(child: HairSpareBrandSymbol(size: 72)),
              const SizedBox(height: AppTheme.spacing6),
              const Text(
                '어떤 활동을 하시나요?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing2),
              const Text(
                '가입 유형에 맞는 프로필을 설정해 드려요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.stitchTextSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              _TypeCard(
                title: SpareSubtype.professional.label,
                subtitle: '미용 일자리를 찾고 있어요',
                description: '공고 지원 · 스케줄 · 에너지 결제',
                icon: Icons.content_cut_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          const SpareSignupProfessionalScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spacing4),
              _TypeCard(
                title: SpareSubtype.model.label,
                subtitle: '헤어 시술 모델로 활동해요',
                description: '디자이너 매칭에 노출 · 채팅으로 일정 조율',
                icon: Icons.face_retouching_natural_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const SpareSignupModelScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '이미 계정이 있으신가요? ',
                    style: TextStyle(color: AppTheme.stitchTextSecondary),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('로그인'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundWhite,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.borderGray),
            boxShadow: AppTheme.stitchSoftShadow,
          ),
          padding: const EdgeInsets.all(AppTheme.spacing5),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurpleLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Icon(icon, color: AppTheme.stitchPrimary, size: 28),
              ),
              const SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.stitchPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.stitchTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 라우터 호환 alias.
typedef SpareSignupScreen = SpareSignupTypeScreen;
