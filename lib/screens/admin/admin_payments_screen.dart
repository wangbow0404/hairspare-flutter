import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_search_filter_bar.dart';
import '../../widgets/admin/admin_table_card.dart';
import 'admin_payment_detail_screen.dart';

/// 관리자 결제 관리 화면
class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _payments = [];
  bool _isLoading = true;
  String _statusFilter = '';
  String _typeFilter = '';
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    // 5초마다 자동 업데이트
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadPayments(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPayments({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _adminService.getPayments(
        status: _statusFilter.isEmpty ? null : _statusFilter,
        type: _typeFilter.isEmpty ? null : _typeFilter,
        page: _currentPage,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _payments = result['payments'] ?? [];
          _totalPages = result['pagination']?['totalPages'] ?? 1;
          _total = result['pagination']?['total'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('결제 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(amount);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusLabel(String status) {
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
        return status;
    }
  }

  Color _getStatusBadgeColor(String status) {
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

  String _getTypeLabel(String type) {
    switch (type) {
      case 'energy_purchase':
        return '에너지 구매';
      case 'subscription':
        return '구독';
      case 'premium_fix':
        return '프리미엄 고정';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/payments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: '결제 관리',
            subtitle: '전체 결제 내역을 조회하고 관리할 수 있습니다',
          ),
          SizedBox(height: AppTheme.spacing6),
          AdminSearchFilterBar(
            searchController: _searchController,
            searchHint: '주문번호, 사용자로 검색...',
            filterDropdown: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: _statusFilter.isEmpty ? null : _statusFilter,
                  hint: const Text('전체 상태'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('전체 상태')),
                    DropdownMenuItem(value: 'success', child: Text('성공')),
                    DropdownMenuItem(value: 'pending', child: Text('대기')),
                    DropdownMenuItem(value: 'failed', child: Text('실패')),
                    DropdownMenuItem(value: 'cancelled', child: Text('취소')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _statusFilter = value ?? '';
                      _currentPage = 1;
                    });
                    _loadPayments();
                  },
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                SizedBox(width: AppTheme.spacing2),
                DropdownButton<String>(
                  value: _typeFilter.isEmpty ? null : _typeFilter,
                  hint: const Text('전체 유형'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('전체 유형')),
                    DropdownMenuItem(value: 'energy_purchase', child: Text('에너지 구매')),
                    DropdownMenuItem(value: 'subscription', child: Text('구독')),
                    DropdownMenuItem(value: 'premium_fix', child: Text('프리미엄 고정')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _typeFilter = value ?? '';
                      _currentPage = 1;
                    });
                    _loadPayments();
                  },
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing6),
          SizedBox(
            height: 600,
            child: AdminTableCard(
              child: _isLoading && _payments.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _payments.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacing8),
                            child: Text(
                              '결제 내역이 없습니다',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 900),
                            child: Column(
                              children: [
                                AdminTableHeader(
                              headers: ['주문 정보', '사용자', '유형', '금액', '상태', '결제일'],
                              flexValues: [1, 1, 1, 1, 1, 1],
                            ),
                            // 테이블 본문
                            Expanded(
                              child: ListView.builder(
                                itemCount: _payments.length,
                                itemBuilder: (context, index) {
                                  final payment = _payments[index];
                                  final statusColor = _getStatusBadgeColor(payment['status'] ?? '');
                                  final paymentId = payment['id']?.toString();
                                  return InkWell(
                                    onTap: paymentId != null
                                        ? () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => AdminPaymentDetailScreen(
                                                  paymentId: paymentId,
                                                  initialData: payment,
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacing4,
                                      vertical: AppTheme.spacing3,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: AppTheme.adminPurple100.withOpacity(0.5)),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${payment['orderId'] ?? ''} (${payment['paymentMethod'] ?? '-'})',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            payment['user']?['email'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            _getTypeLabel(payment['type'] ?? ''),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            _formatCurrency((payment['amount'] ?? 0) as int),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppTheme.spacing2,
                                              vertical: AppTheme.spacing1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              _getStatusLabel(payment['status'] ?? ''),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: statusColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            _formatDate(payment['createdAt'] ?? ''),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // 페이지네이션
                            if (_totalPages > 1)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing6,
                                  vertical: AppTheme.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.adminPurple50.withOpacity(0.3),
                                      AppTheme.adminPink50.withOpacity(0.3),
                                    ],
                                  ),
                                  border: Border(
                                    top: BorderSide(color: AppTheme.adminPurple100, width: 2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '총 $_total건 중 ${(_currentPage - 1) * 20 + 1}-${(_currentPage * 20).clamp(0, _total)}건 표시',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: _currentPage > 1
                                              ? () {
                                                  setState(() {
                                                    _currentPage--;
                                                  });
                                                  _loadPayments();
                                                }
                                              : null,
                                          child: const Text('이전'),
                                        ),
                                        SizedBox(width: AppTheme.spacing2),
                                        TextButton(
                                          onPressed: _currentPage < _totalPages
                                              ? () {
                                                  setState(() {
                                                    _currentPage++;
                                                  });
                                                  _loadPayments();
                                                }
                                              : null,
                                          child: const Text('다음'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
