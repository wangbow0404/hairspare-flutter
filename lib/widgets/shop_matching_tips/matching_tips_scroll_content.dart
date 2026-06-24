import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'package:hairspare/widgets/common/app_network_image.dart';

/// 매칭 꿀팁 본문 — 교육 섹션 + 급구 업셀.
class MatchingTipsScrollContent extends StatelessWidget {
  const MatchingTipsScrollContent({super.key});

  static const _salonPhotoUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAVgELDe0rUr3aVZS6kqHLKNKDPfc11rIbz0k6OQzbOJkMis4UR71d85HRhren6wasSZt29KisXaVdKB6bfeIhhz6s3f6zkU6ApA4xUx-Dw5QPqZKLV-Bu_r_X67UoZLWHyIYTq10dX6gonyMy4zqh68Dk2Cziq7AJnX2VmnSqyXo6bPSCPKryh0Pa8FLOLAxmvXmGdcHI6yVc5WvC9pibJ8nnuKV0e1itCHscIQb-3LE2FQCn4FcUb4mH9wR61ONNY6zd_wpZkR281';

  static const _urgentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: _MatchingTipsEducationHero()),
        const SliverToBoxAdapter(child: _MatchingTipsContentSection()),
        const SliverToBoxAdapter(child: _MatchingTipsPhotoSection()),
        const SliverToBoxAdapter(child: _MatchingTipsTransitionSection()),
        SliverFillRemaining(
          hasScrollBody: false,
          child: _MatchingTipsUrgentSection(gradient: _urgentGradient),
        ),
      ],
    );
  }
}

class _MatchingTipsEducationHero extends StatelessWidget {
  const _MatchingTipsEducationHero();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryPurpleLight.withValues(alpha: 0.55),
            AppTheme.backgroundGray,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing5,
          AppTheme.spacing8,
          AppTheme.spacing5,
          AppTheme.spacing12,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.stitchPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: AppTheme.stitchPrimary,
                size: 28,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            const Text(
              '더 많은 지원자를\n모집하는 방법',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            const Text(
              '공고만 잘 써도 지원률이 달라져요.\n아래 3가지만 챙겨보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchingTipsContentSection extends StatelessWidget {
  const _MatchingTipsContentSection();

  static const _checklist = [
    '정확한 담당 업무 (예: 샴푸, 커트 보조)',
    '근무 시간 및 휴게 시간',
    '상세 급여 조건',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing5,
        0,
        AppTheme.spacing5,
        AppTheme.spacing12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MatchingTipsSectionHeader(
            number: 1,
            title: '공고 내용을 자세히 써주세요',
          ),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.borderGray),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                for (var i = 0; i < _checklist.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppTheme.spacing3),
                  _MatchingTipsCheckRow(text: _checklist[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          const Row(
            children: [
              Expanded(
                child: _MatchingTipsCopyCard(
                  label: 'BAD',
                  isGood: false,
                  text: '"주말 알바 구해요. 연락주세요."',
                ),
              ),
              SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: _MatchingTipsCopyCard(
                  label: 'GOOD',
                  isGood: true,
                  text: '"토/일 10시-6시 스페어 구합니다. 커트 보조 및 샴푸 위주입니다."',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchingTipsPhotoSection extends StatelessWidget {
  const _MatchingTipsPhotoSection();

  static const _photoTips = [
    (icon: Icons.wb_sunny_outlined, label: '창가 자연광'),
    (icon: Icons.crop_portrait_outlined, label: '세로 사진'),
    (icon: Icons.store_outlined, label: '매장 전경'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing5,
        0,
        AppTheme.spacing5,
        AppTheme.spacing12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _MatchingTipsSectionHeader(
            number: 2,
            title: '사진 한 장이 지원을 바꿉니다',
          ),
          const SizedBox(height: AppTheme.spacing4),
          Row(
            children: [
              Expanded(
                child: _MatchingTipsPhotoCompareCard(
                  isGood: false,
                  child: ColoredBox(
                    color: AppTheme.surfaceContainerLow,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: AppTheme.outline.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: _MatchingTipsPhotoCompareCard(
                  isGood: true,
                  child: AppNetworkImage(
                    imageUrl: MatchingTipsScrollContent._salonPhotoUrl,
                    memCacheWidth: 400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: [
              for (final tip in _photoTips)
                _MatchingTipsChip(icon: tip.icon, label: tip.label),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchingTipsTransitionSection extends StatelessWidget {
  const _MatchingTipsTransitionSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing12,
        horizontal: AppTheme.spacing5,
      ),
      child: Column(
        children: [
          const Text(
            '그래도 오늘 당장\n채워야 한다면?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing6),
          _BouncingArrow(),
        ],
      ),
    );
  }
}

class _BouncingArrow extends StatefulWidget {
  @override
  State<_BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<_BouncingArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _offset = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        );
      },
      child: const Icon(
        Icons.keyboard_double_arrow_down_rounded,
        size: 40,
        color: AppTheme.stitchTextSecondary,
      ),
    );
  }
}

class _MatchingTipsUrgentSection extends StatelessWidget {
  const _MatchingTipsUrgentSection({required this.gradient});

  final LinearGradient gradient;

  static const _useCases = [
    '당일/익일 근무',
    '주말 대타',
    '이벤트/촬영',
    '성수기',
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _UrgentDecorativeCircles(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing5,
              AppTheme.spacing12,
              AppTheme.spacing5,
              AppTheme.spacing12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _UrgentBadge(),
                const SizedBox(height: AppTheme.spacing4),
                const Text(
                  '오늘 필요한 인력,\n오늘 채우세요',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                Text(
                  '최상단 노출과 급구 배지로 먼저 보여요.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                const _UrgentStatRow(),
                const SizedBox(height: AppTheme.spacing10),
                const Text(
                  '스페어 화면에서는 이렇게 보여요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                const _UrgentListMockup(),
                const SizedBox(height: AppTheme.spacing10),
                const Text(
                  '이런 때 급구를 쓰세요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Wrap(
                  spacing: AppTheme.spacing2,
                  runSpacing: AppTheme.spacing2,
                  children: [
                    for (final label in _useCases)
                      _UrgentUseCaseChip(label: label),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchingTipsSectionHeader extends StatelessWidget {
  const _MatchingTipsSectionHeader({
    required this.number,
    required this.title,
  });

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppTheme.stitchPrimary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacing2),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchingTipsCheckRow extends StatelessWidget {
  const _MatchingTipsCheckRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 20,
          color: AppTheme.stitchPrimary,
        ),
        const SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchingTipsCopyCard extends StatelessWidget {
  const _MatchingTipsCopyCard({
    required this.label,
    required this.isGood,
    required this.text,
  });

  final String label;
  final bool isGood;
  final String text;

  @override
  Widget build(BuildContext context) {
    final accent = isGood ? AppTheme.stitchPrimary : AppTheme.urgentRed;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: isGood
            ? AppTheme.surfaceContainerLow
            : AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: isGood
              ? AppTheme.stitchPrimary.withValues(alpha: 0.3)
              : AppTheme.borderGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            margin: const EdgeInsets.only(bottom: AppTheme.spacing2),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: isGood
                  ? AppTheme.stitchTextPrimary
                  : AppTheme.stitchTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchingTipsPhotoCompareCard extends StatelessWidget {
  const _MatchingTipsPhotoCompareCard({
    required this.isGood,
    required this.child,
  });

  final bool isGood;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = isGood ? AppTheme.stitchPrimary : AppTheme.urgentRed;
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: accent, width: 2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  isGood ? 'GOOD' : 'BAD',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchingTipsChip extends StatelessWidget {
  const _MatchingTipsChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.stitchTextSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgentDecorativeCircles extends StatelessWidget {
  const _UrgentDecorativeCircles();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: _DecorativeBlurCircle(size: 256),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _DecorativeBlurCircle(size: 192),
          ),
        ],
      ),
    );
  }
}

class _DecorativeBlurCircle extends StatelessWidget {
  const _DecorativeBlurCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _UrgentBadge extends StatelessWidget {
  const _UrgentBadge();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              '🚀 급구',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UrgentStatRow extends StatelessWidget {
  const _UrgentStatRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _UrgentStatTile(value: '3x', label: '더 많은 지원')),
        SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: _UrgentStatTile(
            icon: Icons.vertical_align_top_rounded,
            label: '최상단 노출',
          ),
        ),
        SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: _UrgentStatTile(
            icon: Icons.timer_outlined,
            label: '당일 매칭',
          ),
        ),
      ],
    );
  }
}

class _UrgentStatTile extends StatelessWidget {
  const _UrgentStatTile({
    this.value,
    this.icon,
    required this.label,
  });

  final String? value;
  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                if (value != null)
                  Text(
                    value!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else
                  Icon(icon, color: Colors.white, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UrgentListMockup extends StatelessWidget {
  const _UrgentListMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _UrgentMockJobCard(
            isUrgent: true,
            region: '강남구 · 내일 10:00',
            title: '내일 오전 스페어 급구합니다!',
            pay: '일급 120,000원',
          ),
          const SizedBox(height: AppTheme.spacing3),
          Opacity(
            opacity: 0.6,
            child: _UrgentMockJobCard(
              isUrgent: false,
              region: '서초구 · 토 10:00',
              title: '주말 메인 스페어 모십니다',
              pay: '일급 110,000원',
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgentMockJobCard extends StatelessWidget {
  const _UrgentMockJobCard({
    required this.isUrgent,
    required this.region,
    required this.title,
    required this.pay,
  });

  final bool isUrgent;
  final String region;
  final String title;
  final String pay;

  @override
  Widget build(BuildContext context) {
    final urgentColor = const Color(0xFFFF6B6B);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isUrgent ? urgentColor : AppTheme.borderGray,
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (isUrgent)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: urgentColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppTheme.radiusLg),
                  ),
                ),
                child: const Text(
                  '🚀 급구',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      region,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.stitchTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isUrgent ? urgentColor : AppTheme.stitchTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UrgentUseCaseChip extends StatelessWidget {
  const _UrgentUseCaseChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
