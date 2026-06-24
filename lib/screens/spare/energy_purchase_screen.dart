import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/energy_service.dart';
import '../../utils/energy_purchase_pricing.dart';
import '../../core/router/route_extras.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/energy/energy_purchase_provisional_notice.dart';

/// Next.js와 동일한 에너지 구매 화면
class EnergyPurchaseScreen extends StatefulWidget {
  const EnergyPurchaseScreen({super.key});

  @override
  State<EnergyPurchaseScreen> createState() => _EnergyPurchaseScreenState();
}

class _EnergyPurchaseScreenState extends State<EnergyPurchaseScreen> {
  EnergyPurchasePackage? _selectedPackage;
  int _currentEnergy = 0;
  bool _isLoading = true;
  final EnergyService _energyService = EnergyService();

  @override
  void initState() {
    super.initState();
    _loadEnergyBalance();
  }

  Future<void> _loadEnergyBalance() async {
    try {
      final balance = await _energyService.getBalance();
      setState(() {
        _currentEnergy = balance;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('에너지 잔액 조회 중 오류가 발생했습니다: $error'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _goToCheckout() async {
    if (_selectedPackage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구매할 에너지 패키지를 선택해주세요.'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      return;
    }

    final purchased = await ShellNavigation.pushEnergyCheckout(
      context,
      EnergyPurchaseCheckoutArgs(
        energyAmount: _selectedPackage!.energyAmount,
        cashPrice: _selectedPackage!.cashPriceKrw,
        packageId: _selectedPackage!.id,
      ),
    );

    if (!mounted) return;
    if (purchased == true) {
      await _loadEnergyBalance();
      setState(() => _selectedPackage = null);
    }
  }

  String _formatPrice(int price) {
    return NumberFormat('#,###').format(price);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '에너지 구매'),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 에너지 표시 카드
            Container(
              padding: AppTheme.spacing(AppTheme.spacing6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.yellow400,
                    AppTheme.orange400,
                    AppTheme.orange500,
                  ],
                ),
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
                boxShadow: AppTheme.shadowLg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child: IconMapper.icon('zap', size: 24, color: AppTheme.orange500) ??
                        const Icon(Icons.flash_on, size: 24, color: AppTheme.orange500),
                  ),
                  const SizedBox(width: AppTheme.spacing3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '현재 에너지',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing1),
                      Text(
                        '$_currentEnergy개',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing6),

            const EnergyPurchaseProvisionalNotice(),
            const SizedBox(height: AppTheme.spacing3),

            // 패키지 선택
            Text(
              '에너지 패키지 선택',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            ...kEnergyPurchasePackagesExample.map((pkg) {
              final isSelected = _selectedPackage?.id == pkg.id;
              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPackage = pkg;
                      });
                    },
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                    child: Container(
                      padding: AppTheme.spacing(AppTheme.spacing5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.orange50
                            : AppTheme.backgroundWhite,
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.orange500
                              : AppTheme.borderGray,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 라디오 버튼
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.orange500
                                    : AppTheme.borderGray300,
                                width: 2,
                              ),
                              color: isSelected
                                  ? AppTheme.orange500
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppTheme.spacing3),
                          // 패키지 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${pkg.energyAmount}개',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    if (pkg.popular) ...[
                                      const SizedBox(width: AppTheme.spacing2),
                                      Container(
                                        padding: AppTheme.spacingSymmetric(
                                          horizontal: AppTheme.spacing2,
                                          vertical: AppTheme.spacing1 / 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.orange100,
                                          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                        ),
                                        child: Text(
                                          '인기',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.orange600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: AppTheme.spacing1),
                                Text(
                                  '₩${_formatPrice(pkg.cashPriceKrw)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 개당 가격
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '개당',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing1),
                              Text(
                                '₩${_formatPrice((pkg.cashPriceKrw / pkg.energyAmount).round())}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textGray700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppTheme.spacing6),

            // 선택된 패키지 요약
            if (_selectedPackage != null)
              Container(
                padding: AppTheme.spacing(AppTheme.spacing5),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '구매 내역',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textGray700,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '에너지 ${_selectedPackage!.energyAmount}개',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '₩${_formatPrice(_selectedPackage!.cashPriceKrw)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: AppTheme.spacing4, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 결제금액',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '₩${_formatPrice(_selectedPackage!.cashPriceKrw)}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.orange500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppTheme.spacing6),

            // 구매하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedPackage != null ? _goToCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPackage != null
                      ? null
                      : AppTheme.borderGray300,
                  foregroundColor: Colors.white,
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                  ),
                  elevation: _selectedPackage != null ? 4 : 0,
                ).copyWith(
                  backgroundColor: _selectedPackage != null
                      ? WidgetStateProperty.all<Color>(
                          AppTheme.orange500,
                        )
                      : null,
                ),
                child: Container(
                  decoration: _selectedPackage != null
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.orange400,
                              AppTheme.orange500,
                            ],
                          ),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                        )
                      : null,
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  child: Text(
                    '결제하기',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing6),

            // 안내 문구
            Container(
              padding: AppTheme.spacing(AppTheme.spacing4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGradientStart, // blue-50
                borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                border: Border.all(
                  color: AppTheme.blue100, // blue-100
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 에너지 안내',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlueDark, // blue-800
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    '• 에너지는 공고 지원 시 예약금으로 사용됩니다.\n'
                    '• 근무 완료 시 에너지가 반환됩니다.\n'
                    '• 노쇼 시 에너지는 반환되지 않습니다.\n'
                    '• 충전 패키지는 1·3·5개만 제공되며, 1회 최대 $kMaxEnergyPurchaseAmount개까지 구매할 수 있습니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: AppTheme.primaryBlueDark, // blue-800
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // 하단 네비게이션 바 여백
          ],
        ),
      ),
    );
  }
}
