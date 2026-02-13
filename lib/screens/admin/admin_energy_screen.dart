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

/// 관리자 에너지 관리 화면
class AdminEnergyScreen extends StatefulWidget {
  const AdminEnergyScreen({super.key});

  @override
  State<AdminEnergyScreen> createState() => _AdminEnergyScreenState();
}

class _AdminEnergyScreenState extends State<AdminEnergyScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _typeFilter = '';
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    // 5초마다 자동 업데이트
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadTransactions(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTransactions({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _adminService.getEnergyTransactions(
        type: _typeFilter.isEmpty ? null : _typeFilter,
        page: _currentPage,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _transactions = result['transactions'] ?? [];
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
              content: Text('에너지 거래 내역 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'purchase':
        return '구매';
      case 'lock':
        return '잠금';
      case 'return':
        return '반환';
      case 'forfeit':
        return '몰수';
      case 'reward':
        return '보상';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'purchase':
        return Colors.green;
      case 'lock':
        return Colors.yellow;
      case 'return':
        return Colors.blue;
      case 'forfeit':
        return Colors.red;
      case 'reward':
        return AppTheme.primaryPurple;
      default:
        return Colors.grey;
    }
  }

  String _getStateLabel(String state) {
    switch (state) {
      case 'completed':
        return '완료';
      case 'pending':
        return '대기';
      case 'failed':
        return '실패';
      default:
        return state;
    }
  }

  Color _getStateBadgeColor(String state) {
    switch (state) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.yellow;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/energy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: '에너지 관리',
            subtitle: '에너지 거래 내역을 조회하고 관리할 수 있습니다',
          ),
          SizedBox(height: AppTheme.spacing6),
          AdminSearchFilterBar(
            searchController: _searchController,
            searchHint: '사용자, 이메일로 검색...',
            filterDropdown: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: _typeFilter.isEmpty ? '' : _typeFilter,
                  hint: const Text('전체 유형'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('전체 유형')),
                    DropdownMenuItem(value: 'purchase', child: Text('구매')),
                    DropdownMenuItem(value: 'lock', child: Text('잠금')),
                    DropdownMenuItem(value: 'return', child: Text('반환')),
                    DropdownMenuItem(value: 'forfeit', child: Text('몰수')),
                    DropdownMenuItem(value: 'reward', child: Text('보상')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _typeFilter = value ?? '';
                      _currentPage = 1;
                    });
                    _loadTransactions();
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
              child: _isLoading && _transactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _transactions.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacing8),
                            child: Text(
                              '거래 내역이 없습니다',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 900, minHeight: 400),
                            child: SizedBox(
                              height: 580,
                              child: Column(
                              children: [
                                AdminTableHeader(
                                  headers: ['사용자', '유형', '금액', '공고', '상태', '거래일'],
                                  flexValues: [1, 1, 1, 1, 1, 1],
                                ),
                            // 테이블 본문
                            Expanded(
                              child: ListView.builder(
                                itemCount: _transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = _transactions[index];
                                  final typeColor = _getTypeColor(transaction['type'] ?? '');
                                  final stateColor = _getStateBadgeColor(transaction['state'] ?? '');
                                  return Container(
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
                                            transaction['energyWallet']?['user']?['email'] ?? '-',
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
                                            _getTypeLabel(transaction['type'] ?? ''),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: typeColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${(transaction['amount'] ?? 0) > 0 ? '+' : ''}${transaction['amount'] ?? 0}개',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: (transaction['amount'] ?? 0) > 0 ? Colors.green : Colors.red,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            transaction['job']?['title'] ?? '-',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
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
                                              color: stateColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              _getStateLabel(transaction['state'] ?? ''),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: stateColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            _formatDate(transaction['createdAt'] ?? ''),
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
                                                  _loadTransactions();
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
                                                  _loadTransactions();
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
          ),
        ],
      ),
    );
  }
}
