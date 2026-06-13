import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/services/global_messenger_service.dart';
import 'package:hairspare/services/payment_service.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/api_config.dart';
import 'package:hairspare/utils/error_handler.dart';
import 'package:hairspare/view_models/shop_job_new_view_model.dart';
import 'package:hairspare/widgets/shop_job_new/shop_job_new_ui_kit.dart';

/// 급구 공고 노출 수수료 (원). MVP mock 기준.
const int kShopUrgentJobListingFee = 5000;

/// 급구 공고 등록 전 결제 확인.
class ShopJobUrgentPaymentScreen extends StatefulWidget {
  const ShopJobUrgentPaymentScreen({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  State<ShopJobUrgentPaymentScreen> createState() =>
      _ShopJobUrgentPaymentScreenState();
}

class _ShopJobUrgentPaymentScreenState extends State<ShopJobUrgentPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

  Future<void> _confirmPayment() async {
    final vm = context.read<ShopJobNewViewModel>();
    setState(() => _isProcessing = true);

    try {
      if (!ApiConfig.useMockData) {
        await _paymentService.createPayment(
          type: 'urgent_job',
          amount: kShopUrgentJobListingFee,
          paymentMethod: 'card',
          metadata: {
            'jobTitle': vm.titleController.text.trim(),
            'isUrgent': true,
          },
        );
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      vm.setUrgentForRegistration(true);
      final ok = await vm.submit(widget.formKey);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      sl<GlobalMessengerService>().showError(
        ErrorHandler.getUserFriendlyMessage(ex),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopJobNewViewModel>();
    final isBusy = _isProcessing || vm.isLoading;
    final feeLabel = NumberFormat('#,###').format(kShopUrgentJobListingFee);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const ShopJobNewAppBar(title: '급구 결제'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _UrgentPaymentHeroBanner(),
                  const SizedBox(height: AppTheme.spacing4),
                  _UrgentPaymentJobSummaryCard(vm: vm),
                  const SizedBox(height: AppTheme.spacing3),
                  _UrgentPaymentBreakdownCard(feeLabel: feeLabel),
                  const SizedBox(height: AppTheme.spacing3),
                  const ShopJobNewSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '결제 안내',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing3),
                        ShopJobNewGuideBullet(
                          text: '결제 완료 후 급구 공고가 즉시 등록됩니다.',
                        ),
                        ShopJobNewGuideBullet(
                          text: '홈·공고 목록 최상단에 급구 배지와 함께 노출됩니다.',
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
                      gradient: isBusy
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFFDC2626), Color(0xFFF97316)],
                            ),
                      color: isBusy ? AppTheme.borderGray : null,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: isBusy
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
                        onTap: isBusy ? null : _confirmPayment,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        child: Center(
                          child: isBusy
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
                                      Icons.bolt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: AppTheme.spacing2),
                                    Text(
                                      '$feeLabel원 결제하고 급구 등록',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgentPaymentHeroBanner extends StatelessWidget {
  const _UrgentPaymentHeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFF97316)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: const Row(
        children: [
          Icon(Icons.bolt, color: Colors.white, size: 28),
          SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '급구 공고 등록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '결제 후 우선 노출·급구 배지가 적용됩니다',
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

class _UrgentPaymentJobSummaryCard extends StatelessWidget {
  const _UrgentPaymentJobSummaryCard({required this.vm});

  final ShopJobNewViewModel vm;

  @override
  Widget build(BuildContext context) {
    final dateLabel = vm.selectedDate != null
        ? DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(vm.selectedDate!)
        : '-';

    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '등록할 공고',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Text(
            vm.titleController.text.trim().isEmpty
                ? '(제목 없음)'
                : vm.titleController.text.trim(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          _SummaryRow(label: '근무일', value: dateLabel),
          _SummaryRow(label: '역할', value: vm.selectedRole ?? '-'),
          _SummaryRow(
            label: '모집 인원',
            value: '${vm.requiredCountController.text.trim()}명',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing1),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgentPaymentBreakdownCard extends StatelessWidget {
  const _UrgentPaymentBreakdownCard({required this.feeLabel});

  final String feeLabel;

  @override
  Widget build(BuildContext context) {
    return ShopJobNewSectionCard(
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                '급구 노출 수수료',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              Spacer(),
              Icon(Icons.bolt, size: 16, color: AppTheme.urgentRed),
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
                  color: AppTheme.red600,
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
