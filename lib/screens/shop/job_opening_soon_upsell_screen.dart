import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/services/global_messenger_service.dart';
import 'package:hairspare/services/job_service.dart';
import 'package:hairspare/services/payment_service.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/api_config.dart';
import 'package:hairspare/utils/error_handler.dart';
import 'package:hairspare/widgets/shop_job_new/shop_job_new_ui_kit.dart';

/// 오픈예정 노출 수수료 (원).
const int kShopOpeningSoonFee = 5000;

/// 공고 등록 직후 — 첫 공고인 샵에게만 노출되는 오픈예정 업셀 화면.
class ShopJobOpeningSoonUpsellScreen extends StatefulWidget {
  const ShopJobOpeningSoonUpsellScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  final String jobId;
  final String jobTitle;

  @override
  State<ShopJobOpeningSoonUpsellScreen> createState() =>
      _ShopJobOpeningSoonUpsellScreenState();
}

class _ShopJobOpeningSoonUpsellScreenState
    extends State<ShopJobOpeningSoonUpsellScreen> {
  final JobService _jobService = sl<JobService>();
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);
    try {
      if (!ApiConfig.useMockData) {
        await _paymentService.createPayment(
          type: 'opening_soon',
          amount: kShopOpeningSoonFee,
          paymentMethod: 'card',
          metadata: {'jobId': widget.jobId, 'jobTitle': widget.jobTitle},
        );
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      await _jobService.setOpeningSoon(widget.jobId);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      sl<GlobalMessengerService>()
          .showError(ErrorHandler.getUserFriendlyMessage(ex));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feeLabel = NumberFormat('#,###').format(kShopOpeningSoonFee);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const ShopJobNewAppBar(title: '오픈예정 매장 등록'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OpeningSoonHeroBanner(),
                  const SizedBox(height: AppTheme.spacing4),
                  _OpeningSoonJobSummaryCard(jobTitle: widget.jobTitle),
                  const SizedBox(height: AppTheme.spacing3),
                  _OpeningSoonBreakdownCard(feeLabel: feeLabel),
                  const SizedBox(height: AppTheme.spacing3),
                  const ShopJobNewSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '노출 안내',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing3),
                        ShopJobNewGuideBullet(
                          text: '결제 완료 후 홈 화면 오픈예정 매장 섹션에 바로 노출됩니다.',
                        ),
                        ShopJobNewGuideBullet(
                          text: '스페어들이 미리 찜하고 지원 준비를 할 수 있습니다.',
                        ),
                        ShopJobNewGuideBullet(
                          text: '실제 PG 연동 전까지는 mock 결제로 처리됩니다.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              AppTheme.spacing4,
              AppTheme.spacing3,
              AppTheme.spacing4,
              AppTheme.spacing4 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundWhite,
              border: Border(top: BorderSide(color: AppTheme.borderGray)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '총 $feeLabel원이 결제됩니다',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _isProcessing
                          ? null
                          : AppTheme.stitchHeroGradient,
                      color: _isProcessing ? AppTheme.borderGray : null,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: _isProcessing
                          ? null
                          : [
                              BoxShadow(
                                color: AppTheme.stitchPrimary
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isProcessing ? null : _confirmPayment,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        child: Center(
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.store_outlined,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: AppTheme.spacing2),
                                    Text(
                                      '$feeLabel원 결제하고 오픈예정 등록',
                                      style: const TextStyle(
                                        fontSize: 16,
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
                const SizedBox(height: AppTheme.spacing2),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed:
                        _isProcessing ? null : () => Navigator.pop(context),
                    child: const Text(
                      '건너뛰기',
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
        ],
      ),
    );
  }
}

class _OpeningSoonHeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        gradient: AppTheme.stitchHeroGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: const Row(
        children: [
          Icon(Icons.store_outlined, color: Colors.white, size: 28),
          SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오픈예정 매장 노출',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '스페어들이 오픈 전부터 주목하게 만드세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xE6FFFFFF),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningSoonJobSummaryCard extends StatelessWidget {
  const _OpeningSoonJobSummaryCard({required this.jobTitle});

  final String jobTitle;

  @override
  Widget build(BuildContext context) {
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '등록된 공고',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Text(
            jobTitle.isEmpty ? '(제목 없음)' : jobTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          const Text(
            '첫 번째 공고 등록을 축하드립니다!\n오픈예정 섹션에 노출하면 더 많은 스페어에게 알릴 수 있어요.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningSoonBreakdownCard extends StatelessWidget {
  const _OpeningSoonBreakdownCard({required this.feeLabel});

  final String feeLabel;

  @override
  Widget build(BuildContext context) {
    return ShopJobNewSectionCard(
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                '오픈예정 노출 수수료',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              Spacer(),
              Icon(
                Icons.store_outlined,
                size: 16,
                color: AppTheme.stitchPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                feeLabel,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.stitchPrimary,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  '원',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing3),
          const Divider(height: 1, color: AppTheme.borderGray),
          const SizedBox(height: AppTheme.spacing3),
          const Row(
            children: [
              Text(
                '결제 수단',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              Spacer(),
              Text(
                '카드 결제 (mock)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
