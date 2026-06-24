import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/services/global_messenger_service.dart';
import 'package:hairspare/screens/spare/education_screen.dart';
import 'package:hairspare/services/education_service.dart';
import 'package:hairspare/services/energy_service.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/error_handler.dart';
import 'package:hairspare/utils/shell_navigation.dart';
import 'package:hairspare/widgets/common/shared_app_bar.dart';
import 'package:hairspare/widgets/education/education_ui_kit.dart';

/// 교육 신청 — 에너지 N개 결제 확인.
class EducationEnergyCheckoutScreen extends StatefulWidget {
  const EducationEnergyCheckoutScreen({
    super.key,
    required this.education,
  });

  final Education education;

  @override
  State<EducationEnergyCheckoutScreen> createState() =>
      _EducationEnergyCheckoutScreenState();
}

class _EducationEnergyCheckoutScreenState
    extends State<EducationEnergyCheckoutScreen> {
  final EnergyService _energyService = EnergyService();
  final EducationService _educationService = EducationService();
  int _balance = 0;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() => _isLoading = true);
    try {
      _balance = await _energyService.getBalance();
    } catch (_) {
      _balance = 0;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmPayment() async {
    final cost = widget.education.energyCost;
    if (_balance < cost) {
      sl<GlobalMessengerService>().showInfo(
        '에너지가 부족합니다. 충전 후 다시 시도해 주세요.',
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final enrollment =
          await _educationService.enrollWithEnergy(widget.education.id);
      if (!mounted) return;
      context.replace(
        '${ShellNavigation.branchBase(context)}/enrollment/${enrollment.id}',
      );
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      sl<GlobalMessengerService>().showError(
        ErrorHandler.getUserFriendlyMessage(appException),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _openEnergyPurchase() async {
    await ShellNavigation.pushEnergyPurchase(context);
    await _loadBalance();
  }

  String? get _scheduleLabel {
    final start = widget.education.startDate;
    if (start == null) return null;
    final end = widget.education.endDate;
    if (end != null && end != start) {
      return '${DateFormat('M/d', 'ko_KR').format(start)}~${DateFormat('M/d', 'ko_KR').format(end)}';
    }
    return DateFormat('M/d', 'ko_KR').format(start);
  }

  @override
  Widget build(BuildContext context) {
    final cost = widget.education.energyCost;
    final canPay = !_isLoading && _balance >= cost;
    final shortfall = (cost - _balance).clamp(0, 999999);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '에너지 결제'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : EducationFlowBackground(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppTheme.spacing(AppTheme.spacing4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const EducationFlowStepLabel(
                            step: '',
                            title: '에너지로 교육 신청',
                            subtitle: '참가비는 에너지로 결제됩니다. 잔액을 확인해 주세요.',
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          EducationProgramPreviewCard(
                            title: widget.education.title,
                            energyCost: cost,
                            isOnline: widget.education.isOnline,
                            scheduleLabel: _scheduleLabel,
                          ),
                          const SizedBox(height: AppTheme.spacing3),
                          EducationPaymentBreakdownCard(
                            energyCost: cost,
                            balance: _balance,
                          ),
                          if (!canPay) ...[
                            const SizedBox(height: AppTheme.spacing4),
                            EducationInsufficientEnergyBanner(
                              shortfall: shortfall,
                              onChargeTap: _openEnergyPurchase,
                            ),
                          ],
                          const SizedBox(height: AppTheme.spacing4),
                          const EducationInfoNoticeCard(
                            title: '교육 신청 안내',
                            body: '• 결제한 에너지는 신청 즉시 차감됩니다.\n'
                                '• 신청 완료 후 스케줄표에서 교육 일정을 확인할 수 있어요.\n'
                                '• 교육 전 자료는 신청 완료 화면에서 확인할 수 있어요.',
                          ),
                          const SizedBox(height: AppTheme.spacing6),
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
                      border: Border(
                        top: BorderSide(color: AppTheme.borderGray),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (canPay)
                          Text(
                            '에너지 $cost개가 차감됩니다',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        if (canPay) const SizedBox(height: AppTheme.spacing2),
                        EducationGradientPrimaryButton(
                          label: canPay
                              ? '에너지 $cost개로 결제하기'
                              : '에너지가 부족합니다',
                          icon: Icons.flash_on_outlined,
                          onPressed: canPay && !_isProcessing ? _confirmPayment : null,
                          isLoading: _isProcessing,
                          gradientColors: canPay
                              ? const [AppTheme.orange500]
                              : const [AppTheme.borderGray300],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
