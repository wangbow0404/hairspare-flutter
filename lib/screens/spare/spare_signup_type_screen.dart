import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../models/spare_subtype.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/hairspare_brand_assets.dart';
import '../../widgets/common/shared_app_bar.dart';

/// 회원가입 1단계 — 스페어·디자이너 / 모델 / 샵 / 스토어 유형 선택.
class SpareSignupTypeScreen extends StatefulWidget {
  const SpareSignupTypeScreen({super.key});

  @override
  State<SpareSignupTypeScreen> createState() => _SpareSignupTypeScreenState();
}

class _SpareSignupTypeScreenState extends State<SpareSignupTypeScreen> {
  bool _showStoreModal = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.backgroundGray,
          appBar: const SharedAppBar(title: '회원가입'),
          body: SafeArea(
            child: SingleChildScrollView(
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
                      context.push(AppRoutes.spareSignupProfessional);
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  _TypeCard(
                    title: SpareSubtype.model.label,
                    subtitle: '헤어 시술 모델로 활동해요',
                    description: '디자이너 매칭에 노출 · 채팅으로 일정 조율',
                    icon: Icons.face_retouching_natural_outlined,
                    onTap: () {
                      context.push(AppRoutes.spareSignupModel);
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  _TypeCard(
                    title: '샵(미용실)',
                    subtitle: '미용실을 운영하고 있어요',
                    description: '스페어 채용 · 공고 등록 · 정산 관리',
                    icon: Icons.storefront_outlined,
                    onTap: () {
                      context.push(AppRoutes.shopSignup);
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  _TypeCard(
                    title: '스토어',
                    subtitle: '미용 제품을 판매해요',
                    description: '상품 등록 · 주문 관리 (준비중)',
                    icon: Icons.shopping_bag_outlined,
                    onTap: () {
                      setState(() => _showStoreModal = true);
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing8),
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
        ),
        if (_showStoreModal)
          _StoreComingSoonModal(
            onClose: () => setState(() => _showStoreModal = false),
          ),
      ],
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

/// 스토어 회원가입 "준비중" 안내 — 실제 가입 폼은 별도 작업으로 진행 예정.
class _StoreComingSoonModal extends StatelessWidget {
  final VoidCallback onClose;

  const _StoreComingSoonModal({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: GestureDetector(
        onTap: onClose,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: AppTheme.spacing(AppTheme.spacing4),
              constraints: const BoxConstraints(maxWidth: 384),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                boxShadow: AppTheme.shadowXl,
              ),
              padding: AppTheme.spacing(AppTheme.spacing6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: AppTheme.textTertiary,
                      onPressed: onClose,
                    ),
                  ),
                  Padding(
                    padding: AppTheme.spacingVertical(AppTheme.spacing4),
                    child: Column(
                      children: [
                        Text(
                          '스토어 회원가입은 현재 준비중입니다!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          '빠른 시일 내에 만나뵐 수 있도록 준비하겠습니다.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onClose,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: AppTheme.spacingSymmetric(
                                horizontal: AppTheme.spacing3,
                                vertical: AppTheme.spacing3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    AppTheme.borderRadius(AppTheme.radiusLg),
                              ),
                            ),
                            child: Text(
                              '확인',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 라우터 호환 alias.
typedef SpareSignupScreen = SpareSignupTypeScreen;
