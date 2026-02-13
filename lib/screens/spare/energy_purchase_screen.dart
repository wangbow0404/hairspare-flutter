import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/energy_service.dart';
import '../../services/payment_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 에너지 구매 화면
class EnergyPurchaseScreen extends StatefulWidget {
  const EnergyPurchaseScreen({super.key});

  @override
  State<EnergyPurchaseScreen> createState() => _EnergyPurchaseScreenState();
}

class _EnergyPackage {
  final String id;
  final int amount; // 에너지 개수
  final int price; // 가격 (원)
  final bool popular; // 인기 상품 표시

  _EnergyPackage({
    required this.id,
    required this.amount,
    required this.price,
    this.popular = false,
  });
}

class _EnergyPurchaseScreenState extends State<EnergyPurchaseScreen> {
  int _currentNavIndex = 0;
  _EnergyPackage? _selectedPackage;
  bool _isProcessing = false;
  int _currentEnergy = 0;
  bool _isLoading = true;
  final EnergyService _energyService = EnergyService();
  final PaymentService _paymentService = PaymentService();

  final List<_EnergyPackage> _energyPackages = [
    _EnergyPackage(
      id: '1',
      amount: 1,
      price: 9900,
    ),
    _EnergyPackage(
      id: '3',
      amount: 3,
      price: 27000,
      popular: true, // 3개가 인기 상품
    ),
    _EnergyPackage(
      id: '5',
      amount: 5,
      price: 39000,
    ),
  ];

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

  Future<void> _handlePurchase() async {
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

    setState(() {
      _isProcessing = true;
    });

    try {
      // 결제 요청 생성
      final payment = await _paymentService.createPayment(
        type: 'energy_purchase',
        amount: _selectedPackage!.price,
        paymentMethod: 'CARD',
        metadata: {
          'energyAmount': _selectedPackage!.amount,
        },
      );

      // TODO: 토스페이먼츠 결제 위젯 연동
      // 현재는 Mock 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('결제가 완료되었습니다. (Mock)'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        // 에너지 잔액 업데이트
        await _loadEnergyBalance();
        // 선택 해제
        setState(() {
          _selectedPackage = null;
        });
      }
    } catch (error) {
      if (mounted) {
        final appException = ErrorHandler.handleException(error);
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(appException);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _formatPrice(int price) {
    return NumberFormat('#,###').format(price);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '에너지 구매',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
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
                  SizedBox(width: AppTheme.spacing3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '현재 에너지',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing1),
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
            SizedBox(height: AppTheme.spacing6),

            // 패키지 선택
            Text(
              '에너지 패키지 선택',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacing4),
            ..._energyPackages.map((pkg) {
              final isSelected = _selectedPackage?.id == pkg.id;
              return Container(
                margin: EdgeInsets.only(bottom: AppTheme.spacing3),
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
                          SizedBox(width: AppTheme.spacing3),
                          // 패키지 정보
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${pkg.amount}개',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    if (pkg.popular) ...[
                                      SizedBox(width: AppTheme.spacing2),
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
                                SizedBox(height: AppTheme.spacing1),
                                Text(
                                  '₩${_formatPrice(pkg.price)}',
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
                              SizedBox(height: AppTheme.spacing1),
                              Text(
                                '₩${_formatPrice((pkg.price / pkg.amount).round())}',
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
            SizedBox(height: AppTheme.spacing6),

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
                    SizedBox(height: AppTheme.spacing3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '에너지 ${_selectedPackage!.amount}개',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '₩${_formatPrice(_selectedPackage!.price)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: AppTheme.spacing4, thickness: 1),
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
                          '₩${_formatPrice(_selectedPackage!.price)}',
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
            SizedBox(height: AppTheme.spacing6),

            // 구매하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedPackage != null && !_isProcessing)
                    ? _handlePurchase
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPackage != null && !_isProcessing
                      ? null
                      : AppTheme.borderGray300,
                  foregroundColor: Colors.white,
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                  ),
                  elevation: _selectedPackage != null && !_isProcessing ? 4 : 0,
                ).copyWith(
                  backgroundColor: _selectedPackage != null && !_isProcessing
                      ? MaterialStateProperty.all<Color>(
                          AppTheme.orange500,
                        )
                      : null,
                ),
                child: Container(
                  decoration: _selectedPackage != null && !_isProcessing
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
                    _isProcessing ? '처리 중...' : '구매하기',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacing6),

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
                  SizedBox(height: AppTheme.spacing2),
                  Text(
                    '• 에너지는 공고 지원 시 예약금으로 사용됩니다.\n'
                    '• 근무 완료 시 에너지가 반환됩니다.\n'
                    '• 노쇼 시 에너지는 반환되지 않습니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: AppTheme.primaryBlueDark, // blue-800
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80), // 하단 네비게이션 바 여백
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          
          // 네비게이션 처리
          switch (index) {
            case 0:
              // 홈으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              // 결제로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              // 찜으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              // 마이(프로필)로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
