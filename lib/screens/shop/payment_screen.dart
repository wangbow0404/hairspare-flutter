import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/payment_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Shop 결제 정보 화면
class ShopPaymentScreen extends StatefulWidget {
  const ShopPaymentScreen({super.key});

  @override
  State<ShopPaymentScreen> createState() => _ShopPaymentScreenState();
}

class _ShopPaymentScreenState extends State<ShopPaymentScreen> {
  int _currentNavIndex = 1; // 결제 탭
  bool _isLoading = true;
  final PaymentService _paymentService = PaymentService();
  
  // 구독 정보
  Map<String, dynamic>? _subscription;
  List<Map<String, dynamic>> _paymentHistory = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 구독 정보 및 결제 내역 API 호출
      // final subscription = await PaymentService.getShopSubscription();
      // final history = await PaymentService.getShopPaymentHistory();
      
      // Mock 데이터
      setState(() {
        _subscription = {
          'name': '무료',
          'id': 'free',
          'isActive': false,
          'dailyFreeChats': 0,
        };
        _paymentHistory = [
          {
            'id': 'pay-1',
            'type': 'subscription',
            'amount': 99000,
            'status': 'completed',
            'description': '프리미엄 구독 (1개월)',
            'createdAt': DateTime.now().subtract(const Duration(days: 5)),
          },
          {
            'id': 'pay-2',
            'type': 'premium_job',
            'amount': 5000,
            'status': 'completed',
            'description': '프리미엄 고정 공고',
            'createdAt': DateTime.now().subtract(const Duration(days: 2)),
          },
          {
            'id': 'pay-3',
            'type': 'chat',
            'amount': 2000,
            'status': 'completed',
            'description': '추가 채팅 1회',
            'createdAt': DateTime.now().subtract(const Duration(days: 1)),
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 정보 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'completed':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing2, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 12, color: AppTheme.primaryGreen),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '완료',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        );
      case 'pending':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing2, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.orange.shade700),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '대기중',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      case 'failed':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing2, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: AppTheme.urgentRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, size: 12, color: AppTheme.urgentRed),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '실패',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.urgentRed,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatAmount(int amount) {
    return '₩${NumberFormat('#,###').format(amount)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 M월 d일', 'ko_KR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            '결제 정보',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
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
          '결제 정보',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: IconMapper.icon('refresh', size: 24, color: AppTheme.textSecondary) ??
                const Icon(Icons.refresh, color: AppTheme.textSecondary),
            onPressed: _loadPaymentData,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 구독 정보
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing4),
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacing6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          child: Icon(
                            Icons.star,
                            size: 24,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '현재 구독 플랜',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing1),
                              Text(
                                '${_subscription?['name'] ?? '무료'} 플랜',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '일일 무료 채팅',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${_subscription?['dailyFreeChats'] ?? 0}회',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '구독 상태',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          _subscription?['isActive'] == true ? '활성' : '비활성',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _subscription?['isActive'] == true
                                ? AppTheme.primaryGreen
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (_subscription?['id'] == 'free') ...[
                      SizedBox(height: AppTheme.spacing6),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: 구독 플랜 화면으로 이동
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                          ),
                          child: const Text('구독 플랜 보기'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // 결제 내역
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppTheme.spacing6),
                      child: Text(
                        '결제 내역',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (_paymentHistory.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(AppTheme.spacing12),
                        child: Column(
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 48,
                              color: AppTheme.textTertiary,
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            Text(
                              '결제 내역이 없습니다',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _paymentHistory.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: AppTheme.borderGray,
                        ),
                        itemBuilder: (context, index) {
                          final payment = _paymentHistory[index];
                          return InkWell(
                            onTap: () {
                              // TODO: 결제 상세 화면으로 이동
                            },
                            child: Padding(
                              padding: EdgeInsets.all(AppTheme.spacing6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                payment['description'] as String,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: AppTheme.spacing2),
                                            _buildStatusBadge(payment['status'] as String),
                                          ],
                                        ),
                                        SizedBox(height: AppTheme.spacing2),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: AppTheme.textSecondary,
                                            ),
                                            SizedBox(width: AppTheme.spacing1),
                                            Text(
                                              _formatDate(payment['createdAt'] as DateTime),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatAmount(payment['amount'] as int),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // 결제 수단 관리
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing4),
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacing6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '결제 수단 관리',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacing3),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundGray,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                          SizedBox(width: AppTheme.spacing3),
                          Text(
                            '등록된 결제 수단이 없습니다',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textGray700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing3),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: 결제 수단 추가 화면으로 이동
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primaryPurple, width: 2),
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacing2),
                        ),
                        child: Text(
                          '결제 수단 추가',
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 하단 여백
          SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopHomeScreen()),
              );
              break;
            case 1:
              // 현재 화면
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopFavoritesScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
