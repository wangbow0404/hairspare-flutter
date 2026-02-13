import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/payment_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 결제 정보 화면
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _currentNavIndex = 0;
  List<Payment> _payments = [];
  bool _isLoading = true;
  final PaymentService _paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final payments = await _paymentService.getPayments();
      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final appException = ErrorHandler.handleException(error);
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(appException);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
  }

  String _formatCurrency(int amount) {
    return NumberFormat('#,###').format(amount);
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'success':
        return {
          'label': '완료',
          'color': AppTheme.primaryGreen,
          'bgColor': AppTheme.green100,
          'icon': Icons.check_circle,
        };
      case 'failed':
        return {
          'label': '실패',
          'color': AppTheme.urgentRed,
          'bgColor': AppTheme.urgentRedLight,
          'icon': Icons.cancel,
        };
      case 'pending':
        return {
          'label': '대기중',
          'color': AppTheme.yellow400,
          'bgColor': AppTheme.yellow400.withOpacity(0.1),
          'icon': Icons.access_time,
        };
      default:
        return {
          'label': '알 수 없음',
          'color': AppTheme.textSecondary,
          'bgColor': AppTheme.backgroundGray,
          'icon': Icons.help_outline,
        };
    }
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
          '결제 정보',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '결제 내역',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacing4),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: _payments.isEmpty
                  ? Padding(
                      padding: AppTheme.spacing(AppTheme.spacing8),
                      child: Column(
                        children: [
                          IconMapper.icon('creditcard', size: 48, color: AppTheme.textTertiary) ??
                              const Icon(Icons.credit_card, size: 48, color: AppTheme.textTertiary),
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
                  : Column(
                      children: _payments.map((payment) {
                        final statusInfo = _getStatusInfo(payment.status);
                        return Container(
                          padding: AppTheme.spacing(AppTheme.spacing4),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppTheme.borderGray),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: statusInfo['bgColor'] as Color,
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                ),
                                child: Icon(
                                  statusInfo['icon'] as IconData,
                                  size: 20,
                                  color: statusInfo['color'] as Color,
                                ),
                              ),
                              SizedBox(width: AppTheme.spacing3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.description ?? payment.type,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.spacing1 / 2),
                                    Text(
                                      _formatDate(payment.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${_formatCurrency(payment.amount)}원',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: AppTheme.spacing1 / 2),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        statusInfo['icon'] as IconData,
                                        size: 12,
                                        color: statusInfo['color'] as Color,
                                      ),
                                      SizedBox(width: AppTheme.spacing1 / 2),
                                      Text(
                                        statusInfo['label'] as String,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          fontSize: 12,
                                          color: statusInfo['color'] as Color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
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

