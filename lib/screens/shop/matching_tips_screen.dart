import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/shop_matching_tips/matching_tips_scroll_content.dart';

/// 샵 홈 — 매칭 꿀팁 (공고 작성 가이드 + 급구 업셀).
class ShopMatchingTipsScreen extends StatelessWidget {
  const ShopMatchingTipsScreen({super.key});

  static const _urgentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
  );

  Future<void> _openJobRegistration(BuildContext context) async {
    await ShellNavigation.pushShopJobNew(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF8E53),
      appBar: const SpareSubpageAppBar(
        title: '매칭 꿀팁',
        showToolbarActions: false,
      ),
      body: const MatchingTipsScrollContent(),
      bottomNavigationBar: _MatchingTipsBottomBar(
        urgentGradient: _urgentGradient,
        onUrgentTap: _openJobRegistration,
        onNormalTap: _openJobRegistration,
      ),
    );
  }
}

class _MatchingTipsBottomBar extends StatelessWidget {
  const _MatchingTipsBottomBar({
    required this.urgentGradient,
    required this.onUrgentTap,
    required this.onNormalTap,
  });

  final LinearGradient urgentGradient;
  final Future<void> Function(BuildContext context) onUrgentTap;
  final Future<void> Function(BuildContext context) onNormalTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(top: BorderSide(color: AppTheme.borderGray)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '급구는 공고 등록 시 선택할 수 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: urgentGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onUrgentTap(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    child: const Center(
                      child: Text(
                        '🚀 급구로 공고 올리기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => onNormalTap(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundWhite,
                  foregroundColor: AppTheme.stitchTextSecondary,
                  side: const BorderSide(color: AppTheme.borderGray),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: const Text(
                  '일반 공고로 등록하기',
                  style: TextStyle(
                    fontSize: 16,
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
