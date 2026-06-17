import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hairspare/theme/app_theme.dart';

/// 급구 유도 본문 하단 여백 — CTA는 [Scaffold.bottomNavigationBar]라 스크롤 뷰 밖.
const double kUrgentUpsellScrollBottomInset = AppTheme.spacing4;

/// 급구 유도 — 히어로 (그라데이션 + 글래스 스탯).
class ShopJobUrgentUpsellHero extends StatelessWidget {
  const ShopJobUrgentUpsellHero({
    super.key,
    this.onBack,
    this.backEnabled = true,
  });

  final VoidCallback? onBack;
  final bool backEnabled;

  static const _heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFDC2626),
      Color(0xFFEA580C),
      Color(0xFFF97316),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppTheme.radius2xl),
        bottomRight: Radius.circular(AppTheme.radius2xl),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: _heroGradient),
        child: Stack(
          children: [
            const _HeroLightOverlay(),
            const _HeroDecorativeCircles(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: kToolbarHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _HeroBackButton(
                        onPressed: backEnabled ? onBack : null,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.spacing5,
                    AppTheme.spacing2,
                    AppTheme.spacing5,
                    AppTheme.spacing10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroEventBadge(),
                      SizedBox(height: AppTheme.spacing4),
                      _HeroHeadline(),
                      SizedBox(height: AppTheme.spacing3),
                      _HeroSubCopy(),
                      SizedBox(height: AppTheme.spacing6),
                      _HeroStatRow(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroLightOverlay extends StatelessWidget {
  const _HeroLightOverlay();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.4, -0.6),
            radius: 1.1,
            colors: [
              Color(0x2EFFFFFF),
              Colors.transparent,
            ],
            stops: [0.0, 0.6],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.6, 0.8),
              radius: 0.9,
              colors: [
                Color(0x1FFFC832),
                Colors.transparent,
              ],
              stops: [0.0, 0.5],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroDecorativeCircles extends StatelessWidget {
  const _HeroDecorativeCircles();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _DecorativeCircle(size: 200, opacity: 0.06),
          ),
          Positioned(
            bottom: 10,
            left: -50,
            child: _DecorativeCircle(size: 140, opacity: 0.05),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _HeroBackButton extends StatelessWidget {
  const _HeroBackButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _HeroEventBadge extends StatelessWidget {
  const _HeroEventBadge();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: Colors.white, size: 13),
                SizedBox(width: 6),
                Text(
                  '급구 채용 이벤트',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
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

class _HeroHeadline extends StatelessWidget {
  const _HeroHeadline();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘 필요한 인력,',
          style: TextStyle(
            color: Color(0xE6FFFFFF),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '오늘 채우세요',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _HeroSubCopy extends StatelessWidget {
  const _HeroSubCopy();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.88),
          fontSize: 14,
          height: 1.6,
        ),
        children: const [
          TextSpan(text: '스페어 앱 홈·공고 목록 최상단에\n'),
          TextSpan(
            text: '급구 배지',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: '와 함께 노출됩니다.'),
        ],
      ),
    );
  }
}

class _HeroStatRow extends StatelessWidget {
  const _HeroStatRow();

  static const _stats = [
    (value: '3×', label: '더 많은 지원'),
    (value: '최상단', label: '우선 노출'),
    (value: '당일', label: '채용 가능'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _HeroStatTile(
            value: _stats[i].value,
            label: _stats[i].label,
          )),
        ],
      ],
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  const _HeroStatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Column(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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

/// 급구 공고 혜택 3칸 그리드.
class ShopJobUrgentBenefitGrid extends StatelessWidget {
  const ShopJobUrgentBenefitGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing6,
        AppTheme.spacing4,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '급구 공고 혜택',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BenefitTile(
                  icon: Icons.visibility_outlined,
                  label: '우선 노출',
                  sub: '홈·목록 상단',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _BenefitTile(
                  icon: Icons.bolt,
                  label: '급구 배지',
                  sub: '눈에 띄는 강조',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _BenefitTile(
                  icon: Icons.people_alt_outlined,
                  label: '빠른 지원',
                  sub: '시급한 채용에',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.label,
    required this.sub,
  });

  final IconData icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.urgentRedLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Icon(icon, size: 20, color: AppTheme.urgentRed),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              height: 1.3,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 급구 vs 일반 — 3열 비교 테이블.
class ShopJobUrgentCompareCard extends StatelessWidget {
  const ShopJobUrgentCompareCard({super.key});

  static const _rows = [
    (label: '공고 위치', normal: '기본 순서', urgent: '최상단 고정'),
    (label: '배지 표시', normal: '없음', urgent: '급구 배지'),
    (label: '지원 유입', normal: '보통', urgent: '최대 3× ↑'),
    (label: '노출 기간', normal: '일반', urgent: '강조 노출'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing6,
        AppTheme.spacing4,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '급구 vs 일반 공고',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.borderGray),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const _CompareTableHeader(),
                for (var i = 0; i < _rows.length; i++)
                  _CompareTableRow(
                    label: _rows[i].label,
                    normal: _rows[i].normal,
                    urgent: _rows[i].urgent,
                    showDivider: i < _rows.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareTableHeader extends StatelessWidget {
  const _CompareTableHeader();

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 1, child: SizedBox()),
          Expanded(
            flex: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderGray),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: Text(
                  '일반 공고',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.urgentRedLight,
                border: Border(
                  bottom: BorderSide(color: AppTheme.urgentRed, width: 2),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt, size: 12, color: AppTheme.urgentRed),
                    SizedBox(width: 4),
                    Text(
                      '급구 공고',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.red600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareTableRow extends StatelessWidget {
  const _CompareTableRow({
    required this.label,
    required this.normal,
    required this.urgent,
    required this.showDivider,
  });

  final String label;
  final String normal;
  final String urgent;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final divider = showDivider
        ? const BorderSide(color: Color(0xFFF3F4F6))
        : BorderSide.none;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border(bottom: divider)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 10,
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                border: Border(bottom: divider),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.close,
                      size: 12,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        normal,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.urgentRedLight.withValues(alpha: 0.45),
                border: Border(bottom: divider),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check,
                      size: 12,
                      color: AppTheme.red600,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        urgent,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.red600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 이럴 때 급구를 쓰세요.
class ShopJobUrgentUseCaseList extends StatelessWidget {
  const ShopJobUrgentUseCaseList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing6,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: AppTheme.orange50,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.orange100),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UseCaseHeader(),
            SizedBox(height: 14),
            _UseCaseRow(
              icon: Icons.schedule,
              text: '오늘·내일 바로 필요한 스텝/디자이너',
            ),
            SizedBox(height: 12),
            _UseCaseRow(
              icon: Icons.person_off_outlined,
              text: '노쇼·결원으로 급히 메워야 할 때',
            ),
            SizedBox(height: 12),
            _UseCaseRow(
              icon: Icons.bolt,
              text: '일반 공고보다 빠른 지원이 필요할 때',
            ),
          ],
        ),
      ),
    );
  }
}

class _UseCaseHeader extends StatelessWidget {
  const _UseCaseHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.orange100,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: const Icon(
            Icons.trending_up,
            size: 16,
            color: AppTheme.orange600,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '이럴 때 급구를 쓰세요',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _UseCaseRow extends StatelessWidget {
  const _UseCaseRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: AppTheme.orange100,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Icon(icon, size: 15, color: AppTheme.orange600),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: AppTheme.textGray700,
            ),
          ),
        ),
      ],
    );
  }
}
