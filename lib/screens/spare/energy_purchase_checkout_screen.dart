import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/services/global_messenger_service.dart';
import 'package:hairspare/services/energy_service.dart';
import 'package:hairspare/services/payment_service.dart';
import 'package:hairspare/services/point_service.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/api_config.dart';
import 'package:hairspare/utils/energy_purchase_pricing.dart';
import 'package:hairspare/utils/error_handler.dart';
import 'package:hairspare/utils/icon_mapper.dart';
import 'package:hairspare/widgets/common/shared_app_bar.dart';
import 'package:hairspare/widgets/energy/energy_purchase_provisional_notice.dart';

enum _EnergyCheckoutMethod { card, points }

/// 에너지 패키지 결제 수단 선택 화면.
class EnergyPurchaseCheckoutScreen extends StatefulWidget {
  const EnergyPurchaseCheckoutScreen({
    super.key,
    required this.energyAmount,
    required this.cashPrice,
    required this.packageId,
  });

  final int energyAmount;
  final int cashPrice;
  final String packageId;

  @override
  State<EnergyPurchaseCheckoutScreen> createState() =>
      _EnergyPurchaseCheckoutScreenState();
}

class _EnergyPurchaseCheckoutScreenState
    extends State<EnergyPurchaseCheckoutScreen> {
  final EnergyService _energyService = EnergyService();
  final PaymentService _paymentService = PaymentService();
  final PointService _pointService = PointService();

  _EnergyCheckoutMethod _method = _EnergyCheckoutMethod.card;
  int _pointBalance = 0;
  bool _isLoading = true;
  bool _isProcessing = false;

  int get _pointCost => energyPointCostForPackage(widget.energyAmount);

  bool get _canPayWithPoints => _pointBalance >= _pointCost;

  @override
  void initState() {
    super.initState();
    _loadBalances();
  }

  Future<void> _loadBalances() async {
    setState(() => _isLoading = true);
    try {
      _pointBalance = await _pointService.getBalance();
    } catch (_) {
      _pointBalance = 0;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmPayment() async {
    if (_method == _EnergyCheckoutMethod.points && !_canPayWithPoints) {
      sl<GlobalMessengerService>().showError(
        '포인트가 부족합니다. (필요: ${_formatPoints(_pointCost)}, 보유: ${_formatPoints(_pointBalance)})',
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      if (_method == _EnergyCheckoutMethod.card) {
        await _paymentService.createPayment(
          type: 'energy_purchase',
          amount: widget.cashPrice,
          paymentMethod: 'CARD',
          metadata: {
            'energyAmount': widget.energyAmount,
            'packageId': widget.packageId,
          },
        );
        await _energyService.purchaseEnergy(
          widget.energyAmount,
          paymentMethod: 'CARD',
          cashPrice: widget.cashPrice,
        );
      } else {
        await _energyService.purchaseEnergy(
          widget.energyAmount,
          paymentMethod: 'POINTS',
          pointCost: _pointCost,
        );
      }

      if (!mounted) return;
      sl<GlobalMessengerService>().showSuccess(
        _method == _EnergyCheckoutMethod.card
            ? '결제가 완료되었습니다.'
            : '포인트로 에너지 ${widget.energyAmount}개를 충전했습니다.',
      );
      Navigator.pop(context, true);
    } catch (error) {
      final appException = ErrorHandler.handleException(error);
      sl<GlobalMessengerService>().showError(
        ErrorHandler.getUserFriendlyMessage(appException),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _formatPrice(int price) => NumberFormat('#,###').format(price);

  String _formatPoints(int points) => '${NumberFormat('#,###').format(points)}P';

  String _checkoutGuideText() {
    final provisional = kEnergyPurchasePricingIsProvisional
        ? '• ${kEnergyPurchaseProvisionalNotice}\n'
        : '';
    if (ApiConfig.useMockData) {
      return '${provisional}'
          '• 현재는 mock 결제로 처리됩니다.\n'
          '• 실제 PG 연동 전까지 카드 결제는 즉시 완료됩니다.\n'
          '• 포인트 결제는 1에너지당 ${NumberFormat('#,###').format(kEnergyPointCostPerUnit)}P가 차감됩니다. (예시 환율)';
    }
    return '${provisional}'
        '• 카드 결제는 PG 창으로 이동합니다.\n'
        '• 포인트 결제는 보유 포인트에서 즉시 차감됩니다.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '결제하기'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _OrderSummaryCard(
                          energyAmount: widget.energyAmount,
                          cashPrice: widget.cashPrice,
                          pointCost: _pointCost,
                          formatPrice: _formatPrice,
                          formatPoints: _formatPoints,
                        ),
                        const SizedBox(height: AppTheme.spacing3),
                        const EnergyPurchaseProvisionalNotice(),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          '결제 수단 선택',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacing3),
                        _PaymentMethodTile(
                          selected: _method == _EnergyCheckoutMethod.card,
                          icon: Icons.credit_card_rounded,
                          iconColor: AppTheme.primaryBlue,
                          iconBg: AppTheme.backgroundGradientStart,
                          title: '현금 · 카드 결제',
                          subtitle: '₩${_formatPrice(widget.cashPrice)}',
                          onTap: () => setState(
                            () => _method = _EnergyCheckoutMethod.card,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing3),
                        _PaymentMethodTile(
                          selected: _method == _EnergyCheckoutMethod.points,
                          icon: Icons.stars_rounded,
                          iconColor: AppTheme.stitchPrimary,
                          iconBg: const Color(0xFFF0DBFF),
                          title: '포인트 결제',
                          subtitle: _canPayWithPoints
                              ? '${_formatPoints(_pointCost)} (보유 ${_formatPoints(_pointBalance)})'
                              : '${_formatPoints(_pointCost)} · 보유 ${_formatPoints(_pointBalance)} (부족)',
                          enabled: _canPayWithPoints,
                          onTap: _canPayWithPoints
                              ? () => setState(
                                    () => _method = _EnergyCheckoutMethod.points,
                                  )
                              : null,
                        ),
                        if (!_canPayWithPoints) ...[
                          const SizedBox(height: AppTheme.spacing2),
                          Text(
                            '포인트가 부족하면 미션에서 포인트를 받은 뒤 다시 시도해 주세요.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacing4),
                        Container(
                          padding: AppTheme.spacing(AppTheme.spacing4),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundWhite,
                            borderRadius:
                                AppTheme.borderRadius(AppTheme.radiusXl),
                            border: Border.all(color: AppTheme.borderGray),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '결제 안내',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textGray700,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacing2),
                              Text(
                                _checkoutGuideText(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.55,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _CheckoutFooter(
                  method: _method,
                  cashPrice: widget.cashPrice,
                  pointCost: _pointCost,
                  isProcessing: _isProcessing,
                  formatPrice: _formatPrice,
                  formatPoints: _formatPoints,
                  onConfirm: _confirmPayment,
                ),
              ],
            ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.energyAmount,
    required this.cashPrice,
    required this.pointCost,
    required this.formatPrice,
    required this.formatPoints,
  });

  final int energyAmount;
  final int cashPrice;
  final int pointCost;
  final String Function(int) formatPrice;
  final String Function(int) formatPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing5),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.orange50,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
                child: IconMapper.icon('zap', size: 22, color: AppTheme.orange500) ??
                    const Icon(Icons.flash_on, size: 22, color: AppTheme.orange500),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '에너지 $energyAmount개',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '카드 ₩${formatPrice(cashPrice)} · 포인트 ${formatPoints(pointCost)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
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

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final bool selected;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppTheme.stitchPrimary
        : AppTheme.borderGray;
    final bgColor = selected
        ? const Color(0xFFF8F4FF)
        : AppTheme.backgroundWhite;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
          child: Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
              border: Border.all(color: borderColor, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppTheme.stitchPrimary
                          : AppTheme.borderGray300,
                      width: 2,
                    ),
                    color: selected
                        ? AppTheme.stitchPrimary
                        : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: AppTheme.spacing3),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: AppTheme.spacing3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
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
    );
  }
}

class _CheckoutFooter extends StatelessWidget {
  const _CheckoutFooter({
    required this.method,
    required this.cashPrice,
    required this.pointCost,
    required this.isProcessing,
    required this.formatPrice,
    required this.formatPoints,
    required this.onConfirm,
  });

  final _EnergyCheckoutMethod method;
  final int cashPrice;
  final int pointCost;
  final bool isProcessing;
  final String Function(int) formatPrice;
  final String Function(int) formatPoints;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isCard = method == _EnergyCheckoutMethod.card;
    final amountLabel = isCard
        ? '₩${formatPrice(cashPrice)}'
        : formatPoints(pointCost);

    return Container(
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
            '총 $amountLabel 결제',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isProcessing ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isProcessing ? AppTheme.borderGray300 : AppTheme.orange500,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                ),
              ),
              child: Text(
                isProcessing ? '결제 처리 중...' : '결제하기',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
