import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_navigation.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_empty_state.dart';

/// 샵 결제 정보 — 구독 현황 · 결제 내역 · 결제 수단 관리.
class ShopPaymentScreen extends StatefulWidget {
  const ShopPaymentScreen({super.key});

  @override
  State<ShopPaymentScreen> createState() => _ShopPaymentScreenState();
}

class _ShopPaymentScreenState extends State<ShopPaymentScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _subscription;
  List<Map<String, dynamic>> _paymentHistory = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    setState(() => _isLoading = true);
    try {
      // TODO: 구독 정보 및 결제 내역 API 연동
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
            'status': 'success',
            'description': '프리미엄 구독 (1개월)',
            'createdAt': DateTime.now().subtract(const Duration(days: 5)),
          },
          {
            'id': 'pay-2',
            'type': 'premium_job',
            'amount': 5000,
            'status': 'success',
            'description': '프리미엄 고정 공고',
            'createdAt': DateTime.now().subtract(const Duration(days: 2)),
          },
          {
            'id': 'pay-3',
            'type': 'chat',
            'amount': 2000,
            'status': 'pending',
            'description': '추가 채팅 1회',
            'createdAt': DateTime.now().subtract(const Duration(days: 1)),
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 정보 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'success':
      case 'completed':
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

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
  }

  String _formatCurrency(int amount) {
    return '₩${NumberFormat('#,###').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '결제 정보',
        onBackPressed: () => AppNavigation.backFromShopPayment(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppTheme.spacing(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacing2),
                  _SubscriptionCard(subscription: _subscription),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    '결제 내역',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.stitchTextPrimary,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundWhite,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(color: AppTheme.borderGray),
                      boxShadow: AppTheme.stitchSoftShadow,
                    ),
                    child: _paymentHistory.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(AppTheme.spacing8),
                            child: StitchEmptyState(
                              message: '결제 내역이 없습니다',
                              iconName: 'creditcard',
                            ),
                          )
                        : Column(
                            children: _paymentHistory.map((payment) {
                              final statusInfo =
                                  _getStatusInfo(payment['status'] as String);
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
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: statusInfo['bgColor'],
                                        borderRadius: AppTheme.borderRadius(
                                            AppTheme.radiusFull),
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payment['description'] as String,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.textPrimary,
                                                ),
                                          ),
                                          const SizedBox(
                                              height: AppTheme.spacing1),
                                          Text(
                                            _formatDate(
                                                payment['createdAt'] as DateTime),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontSize: 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatCurrency(
                                              payment['amount'] as int),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
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
                                                Icon(Icons.info_outline,
                                                    size: 12,
                                                    color: statusInfo['color']),
                                            const SizedBox(
                                                width: AppTheme.spacing1),
                                            Text(
                                              statusInfo['label'],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
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
                  const SizedBox(height: AppTheme.spacing4),
                  _PaymentMethodCard(onAddPressed: () {
                    // TODO: 결제 수단 추가 화면으로 이동
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.subscription});
  final Map<String, dynamic>? subscription;

  @override
  Widget build(BuildContext context) {
    final planName = subscription?['name'] ?? '무료';
    final isActive = subscription?['isActive'] == true;
    final dailyFreeChats = subscription?['dailyFreeChats'] ?? 0;
    final isFree = subscription?['id'] == 'free';

    return Container(
      padding: AppTheme.spacing(AppTheme.spacing6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.stitchSoftShadow,
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
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 24,
                  color: AppTheme.primaryPurple,
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 구독 플랜',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(
                      '$planName 플랜',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          _InfoRow(label: '일일 무료 채팅', value: '$dailyFreeChats회'),
          const SizedBox(height: AppTheme.spacing2),
          _InfoRow(
            label: '구독 상태',
            value: isActive ? '활성' : '비활성',
            valueColor:
                isActive ? AppTheme.primaryGreen : AppTheme.textSecondary,
          ),
          if (isFree) ...[
            const SizedBox(height: AppTheme.spacing4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 구독 플랜 화면으로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: AppTheme.spacingSymmetric(
                      vertical: AppTheme.spacing3,
                      horizontal: AppTheme.spacing4),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusLg),
                  ),
                ),
                child: const Text('구독 플랜 보기'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.onAddPressed});
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '결제 수단 관리',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Container(
            padding: AppTheme.spacing(AppTheme.spacing3),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: const Row(
              children: [
                Icon(Icons.credit_card, size: 20, color: AppTheme.textSecondary),
                SizedBox(width: AppTheme.spacing3),
                Text(
                  '등록된 결제 수단이 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGray700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAddPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                padding: AppTheme.spacingSymmetric(
                    vertical: AppTheme.spacing2, horizontal: AppTheme.spacing4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
              child: const Text(
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
    );
  }
}
