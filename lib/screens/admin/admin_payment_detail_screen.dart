import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/admin/admin_table_card.dart';
import '../../widgets/admin/admin_action_dialog.dart';

/// 관리자 결제 상세 화면
class AdminPaymentDetailScreen extends StatefulWidget {
  final String paymentId;
  final Map<String, dynamic>? initialData;

  const AdminPaymentDetailScreen({
    super.key,
    required this.paymentId,
    this.initialData,
  });

  @override
  State<AdminPaymentDetailScreen> createState() => _AdminPaymentDetailScreenState();
}

class _AdminPaymentDetailScreenState extends State<AdminPaymentDetailScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _payment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _payment = widget.initialData;
      _isLoading = false;
    }
    _loadPayment();
  }

  Future<void> _loadPayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _adminService.getPaymentDetail(widget.paymentId);
      if (mounted) {
        setState(() {
          _payment = data as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final appException = ErrorHandler.handleException(e);
        setState(() {
          _error = ErrorHandler.getUserFriendlyMessage(appException);
          _isLoading = false;
          if (_payment == null && widget.initialData != null) {
            _payment = widget.initialData;
          }
        });
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(amount);
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'success':
        return '성공';
      case 'pending':
        return '대기';
      case 'failed':
        return '실패';
      case 'cancelled':
        return '취소';
      default:
        return status ?? '-';
    }
  }

  Color _getStatusBadgeColor(String? status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.yellow;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getTypeLabel(String? type) {
    switch (type) {
      case 'energy_purchase':
        return '에너지 구매';
      case 'subscription':
        return '구독';
      case 'premium_fix':
        return '프리미엄 고정';
      default:
        return type ?? '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                color: AppTheme.textPrimary,
              ),
              const SizedBox(width: AppTheme.spacing2),
              const Text(
                '결제 상세',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing6),
          if (_isLoading && _payment == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing8),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null && _payment == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: AppTheme.urgentRed),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    TextButton(
                      onPressed: _loadPayment,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            )
          else if (_payment != null)
            _buildContent()
          else
            const SizedBox.shrink(),
        ],
      );
  }

  Widget _buildContent() {
    final payment = _payment!;
    final statusColor = _getStatusBadgeColor(payment['status']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTableCard(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      payment['orderId'] ?? '-',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        _getStatusLabel(payment['status']),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing6),
                _buildInfoRow('결제 방식', payment['paymentMethod'] ?? '-'),
                _buildInfoRow('유형', _getTypeLabel(payment['type'])),
                _buildInfoRow('금액', _formatCurrency((payment['amount'] ?? 0) as int)),
                _buildInfoRow('결제일', _formatDate(payment['createdAt'])),
                _buildInfoRow('사용자', payment['user']?['name'] ?? '-'),
                _buildInfoRow('이메일', payment['user']?['email'] ?? '-'),
                const SizedBox(height: AppTheme.spacing6),
                const Divider(height: 1),
                const SizedBox(height: AppTheme.spacing4),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () => _refund(),
                      icon: const Icon(Icons.undo, size: 18),
                      label: const Text('환불 처리'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.urgentRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refund() async {
    final amount = (_payment?['amount'] ?? 0) as int;
    final reason = await AdminActionDialog.show(
      context,
      title: '결제 환불',
      confirmLabel: '환불',
      summary: '주문 ${_payment?['orderId']} · ${_formatCurrency(amount)}',
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.refundPayment(widget.paymentId, amount: amount, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('환불이 처리되었습니다 (감사 로그 기록)')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
    }
  }
}
