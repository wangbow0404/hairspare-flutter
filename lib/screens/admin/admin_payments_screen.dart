import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

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

  static const _statusTabs = ['전체', '성공', '대기', '실패', '취소'];
  static const _statusMap = {
    '전체': '',
    '성공': 'success',
    '대기': 'pending',
    '실패': 'failed',
    '취소': 'cancelled',
  };

  static const _typeTabs = ['전체', '에너지 구매', '구독', '프리미엄 고정'];
  static const _typeMap = {
    '전체': '',
    '에너지 구매': 'energy_purchase',
    '구독': 'subscription',
    '프리미엄 고정': 'premium_fix',
  };

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadPayments(showLoading: false);
      });
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
      setState(() => _isLoading = true);
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
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '결제 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
              ),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(amount);
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

  String _selectedStatusTab() {
    for (final entry in _statusMap.entries) {
      if (entry.value == _statusFilter) return entry.key;
    }
    return '전체';
  }

  String _selectedTypeTab() {
    for (final entry in _typeMap.entries) {
      if (entry.value == _typeFilter) return entry.key;
    }
    return '전체';
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminStitchPageHeader(
            title: '결제 관리',
            subtitle: '전체 결제 내역을 조회하고 관리할 수 있습니다',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchSearchField(
            controller: _searchController,
            hint: '주문번호, 사용자로 검색...',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchFilterChips(
            tabs: _statusTabs,
            selectedTab: _selectedStatusTab(),
            onTabChanged: (tab) {
              setState(() {
                _statusFilter = _statusMap[tab] ?? '';
                _currentPage = 1;
              });
              _loadPayments();
            },
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          AdminStitchFilterChips(
            tabs: _typeTabs,
            selectedTab: _selectedTypeTab(),
            onTabChanged: (tab) {
              setState(() {
                _typeFilter = _typeMap[tab] ?? '';
                _currentPage = 1;
              });
              _loadPayments();
            },
          ),
          if (_total > 0) ...[
            const SizedBox(height: AdminStitchTheme.sectionGap),
            Text(
              '총 $_total건',
              style: AdminStitchTheme.bodyMd.copyWith(
                color: AdminStitchTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _payments.isEmpty) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_payments.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '결제 내역이 없습니다',
        emptyIcon: Icons.payment_outlined,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == _payments.length) {
              return _buildPagination();
            }
            final payment = _payments[index] as Map<String, dynamic>;
            final paymentId = payment['id']?.toString();
            final orderId = payment['orderId']?.toString() ?? '-';
            final userEmail = payment['user']?['email']?.toString() ?? '-';
            final amount = _formatCurrency((payment['amount'] ?? 0) as int);
            final statusLabel = _getStatusLabel(payment['status']?.toString() ?? '');
            final typeLabel = _getTypeLabel(payment['type']?.toString() ?? '');

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _payments.length - 1
                    ? AdminStitchTheme.sectionGap
                    : 0,
              ),
              child: AdminStitchSimpleListCard(
                title: orderId,
                subtitle: '$userEmail · $amount · $typeLabel · $statusLabel',
                icon: Icons.payment_outlined,
                onTap: paymentId != null
                    ? () => context.push(
                          AppRoutes.adminPaymentDetail(paymentId),
                          extra: payment,
                        )
                    : null,
              ),
            );
          },
          childCount: _payments.length + (_totalPages > 1 ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.only(top: AdminStitchTheme.sectionGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadPayments();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '$_currentPage / $_totalPages',
            style: AdminStitchTheme.bodyMd,
          ),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadPayments();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
