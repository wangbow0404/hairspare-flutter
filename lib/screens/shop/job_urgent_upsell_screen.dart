import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/router/route_extras.dart';
import '../../utils/shell_navigation.dart';
import '../../theme/app_theme.dart';
import '../../view_models/shop_job_new_view_model.dart';
import '../../widgets/shop_job_new/shop_job_urgent_upsell_content.dart';

/// 공고 등록 직전 급구 유도(업셀) — Figma 이벤트/프로모션 시안.
class ShopJobUrgentUpsellScreen extends StatelessWidget {
  const ShopJobUrgentUpsellScreen({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  Future<void> _submitNormal(BuildContext context) async {
    final vm = context.read<ShopJobNewViewModel>();
    vm.setUrgentForRegistration(false);
    final ok = await vm.submit(formKey);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _goToUrgentPayment(BuildContext context) async {
    final vm = context.read<ShopJobNewViewModel>();
    vm.setUrgentForRegistration(true);

    final paid = await ShellNavigation.pushShopJobUrgentPayment(
          context,
          ShopJobUrgentPaymentExtra(
            viewModel: vm,
            formKey: formKey,
          ),
        ) ??
        false;

    if (!context.mounted || !paid) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopJobNewViewModel>();
    final isLoading = vm.isLoading;

    final statusBarHeight = MediaQuery.viewPaddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Column(
          children: [
            // 상태바 영역 고정 — 스크롤해도 시계·와이파이·배터리와 겹치지 않음
            SizedBox(
              height: statusBarHeight,
              width: double.infinity,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFDC2626), Color(0xFFEA580C)],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: kUrgentUpsellScrollBottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShopJobUrgentUpsellHero(
                      backEnabled: !isLoading,
                      onBack: () => Navigator.maybePop(context),
                    ),
                    const ShopJobUrgentBenefitGrid(),
                    const ShopJobUrgentCompareCard(),
                    const ShopJobUrgentUseCaseList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: isLoading
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFFDC2626), Color(0xFFF97316)],
                          ),
                    color: isLoading ? AppTheme.borderGray : null,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: AppTheme.urgentRed.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isLoading ? null : () => _goToUrgentPayment(context),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt, color: Colors.white, size: 18),
                                  SizedBox(width: AppTheme.spacing2),
                                  Text(
                                    '급구로 등록하기',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => _submitNormal(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textGray700,
                    side: const BorderSide(
                      color: AppTheme.borderGray,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  child: const Text(
                    '일반 공고로 등록하기',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    '돌아가서 수정하기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textTertiary,
                    ),
                  ),
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
