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

/// 하이패스 노출 수수료 (원).
const int kShopOpeningSoonFee = 5000;

const Color _kHiPassGold = Color(0xFFD4AF37);
const Color _kHiPassGoldLight = Color(0xFFFDF8E7);

/// 공고 등록 직후 — 첫 공고인 샵에게만 노출되는 하이패스 업셀 화면.
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HiPassHeroBanner(),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HiPassJobSummaryCard(jobTitle: widget.jobTitle),
                        const SizedBox(height: AppTheme.spacing3),
                        const _HiPassBenefitsCard(),
                        const SizedBox(height: AppTheme.spacing3),
                        _HiPassPaymentSummaryCard(feeLabel: feeLabel),
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
                                    Text(
                                      '$feeLabel원 결제하고 하이패스 등록',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacing2),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 18,
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
                      '다음에 하기 (일반 등록)',
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

class _HiPassHeroBanner extends StatelessWidget {
  const _HiPassHeroBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.stitchHeroGradient),
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.12)),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing4,
                AppTheme.spacing2,
                AppTheme.spacing4,
                AppTheme.spacing6,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Colors.white),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  Image.asset(
                    'assets/images/brand/hipass_mark.png',
                    width: 88,
                    height: 88,
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  const Text(
                    '축하합니다!\n하이패스 대상자로\n선정되셨어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing2,
                    ),
                    decoration: BoxDecoration(
                      color: _kHiPassGoldLight.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                        color: _kHiPassGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, size: 16, color: AppTheme.stitchPrimary),
                        const SizedBox(width: AppTheme.spacing1),
                        Text(
                          '첫 공고 사장님께만 드리는 1회 한정 특별 혜택',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.stitchPrimary,
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

class _HiPassJobSummaryCard extends StatelessWidget {
  const _HiPassJobSummaryCard({required this.jobTitle});

  final String jobTitle;

  @override
  Widget build(BuildContext context) {
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '등록된 공고',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 12, color: AppTheme.stitchPrimary),
                    const SizedBox(width: 2),
                    const Text(
                      'HIPASS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.stitchPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.stitchPrimaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.content_cut,
                    color: AppTheme.stitchPrimary, size: 20),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Text(
                  jobTitle.isEmpty ? '(제목 없음)' : jobTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          const Text(
            '첫 번째 공고 등록을 축하드립니다!\n하이패스로 노출하면 더 많은 스페어에게 빠르게 알릴 수 있어요.',
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

class _HiPassBenefitsCard extends StatelessWidget {
  const _HiPassBenefitsCard();

  @override
  Widget build(BuildContext context) {
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium, size: 18, color: _kHiPassGold),
              SizedBox(width: AppTheme.spacing2),
              Text(
                '하이패스 프리미엄 혜택',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing3),
          const _HiPassBenefitRow(
            title: '리스트 최상단 노출',
            description: '결제 완료 후 홈 화면 하이패스 구역에 바로 노출됩니다.',
          ),
          const _HiPassBenefitRow(
            title: '찜 우선순위',
            description: '스페어들이 미리 찜하고 지원 준비를 할 수 있습니다.',
          ),
          const _HiPassBenefitRow(
            title: '첫 공고 특별 혜택',
            description: '하이패스는 첫 공고를 등록하는 샵에게만 제공되는 혜택입니다.',
            isLast: true,
          ),
          const SizedBox(height: AppTheme.spacing2),
          const Divider(height: 1, color: AppTheme.borderGray),
          const SizedBox(height: AppTheme.spacing2),
          const Text(
            '실제 PG 연동 전까지는 mock 결제로 처리됩니다.',
            style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _HiPassBenefitRow extends StatelessWidget {
  const _HiPassBenefitRow({
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppTheme.spacing3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: _kHiPassGoldLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 14, color: _kHiPassGold),
          ),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
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

class _HiPassPaymentSummaryCard extends StatelessWidget {
  const _HiPassPaymentSummaryCard({required this.feeLabel});

  final String feeLabel;

  @override
  Widget build(BuildContext context) {
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '결제 정보',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          const Row(
            children: [
              Text(
                '기본 노출',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              Spacer(),
              Text(
                '무료',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing2),
            child: Row(
              children: [
                const Text(
                  '하이패스 노출 수수료',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.stitchPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$feeLabel원',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.stitchPrimary,
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
