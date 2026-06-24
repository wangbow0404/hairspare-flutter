import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/router/app_navigation.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../services/payment_service.dart';
/// Next.js와 동일한 결제 화면


class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
        final errorMessage = error.toString().contains('connection errored') ||
                error.toString().contains('XMLHttpRequest')
            ? '서버에 연결할 수 없습니다. Next.js 서버가 실행 중인지 확인해주세요.'
            : '결제 내역을 불러오는 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
  }

  String _formatCurrency(int amount) {
    return '₩${NumberFormat('#,###').format(amount)}';
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'success':
        return {
          'label': '완료',
          'color': AppTheme.green600,
          'icon': 'checkcircle',
          'bgColor': AppTheme.green50,
        };
      case 'failed':
        return {
          'label': '실패',
          'color': AppTheme.urgentRed,
          'icon': 'xcircle',
          'bgColor': AppTheme.red50,
        };
      case 'pending':
        return {
          'label': '대기중',
          'color': AppTheme.yellow600,
          'icon': 'clock',
          'bgColor': AppTheme.yellow50,
        };
      default:
        return {
          'label': '알 수 없음',
          'color': AppTheme.textSecondary,
          'icon': 'clock',
          'bgColor': AppTheme.backgroundGray,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SpareSubpageAppBar(
          title: '결제 정보',
          onBackPressed: () => AppNavigation.backFromSparePayment(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '결제 정보',
        onBackPressed: () => AppNavigation.backFromSparePayment(context),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.spacing6),
            Text(
              '결제 내역',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: AppTheme.stitchSoftShadow,
              ),
              child: _payments.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(AppTheme.spacing8),
                      child: StitchEmptyState(
                        message: '결제 내역이 없습니다',
                        iconName: 'creditcard',
                      ),
                    )
                  : Column(
                      children: _payments.map((payment) {
                        final statusInfo = _getStatusInfo(payment.status);
                        return Container(
                          padding: AppTheme.spacing(AppTheme.spacing4),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.borderGray,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // 아이콘
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: statusInfo['bgColor'],
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                ),
                                child: IconMapper.icon(
                                  'creditcard',
                                  size: 20,
                                  color: statusInfo['color'],
                                ) ??
                                    Icon(
                                      Icons.credit_card,
                                      size: 20,
                                      color: statusInfo['color'],
                                    ),
                              ),
                              const SizedBox(width: AppTheme.spacing3),
                              // 정보
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
                                    const SizedBox(height: AppTheme.spacing1),
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
                              // 금액 및 상태
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatCurrency(payment.amount),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacing1),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconMapper.icon(
                                        statusInfo['icon'],
                                        size: 12,
                                        color: statusInfo['color'],
                                      ) ??
                                          Icon(
                                            Icons.info_outline,
                                            size: 12,
                                            color: statusInfo['color'],
                                          ),
                                      const SizedBox(width: AppTheme.spacing1),
                                      Text(
                                        statusInfo['label'],
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          fontSize: 12,
                                          color: statusInfo['color'],
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
    );
  }
}
