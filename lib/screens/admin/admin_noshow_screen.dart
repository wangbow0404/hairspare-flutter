import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_table_card.dart';

/// 관리자 노쇼 관리 화면
class AdminNoshowScreen extends StatefulWidget {
  const AdminNoshowScreen({super.key});

  @override
  State<AdminNoshowScreen> createState() => _AdminNoshowScreenState();
}

class _AdminNoshowScreenState extends State<AdminNoshowScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _history = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // 5초마다 자동 업데이트
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadHistory(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _adminService.getNoShowHistory(
        page: _currentPage,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _history = result['history'] ?? [];
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
              content: Text('노쇼 이력 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
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

  String _getRoleLabel(String role) {
    switch (role) {
      case 'spare':
        return '스페어';
      case 'shop':
        return '미용실';
      case 'seller':
        return '판매자';
      default:
        return role;
    }
  }

  Color _getRoleBadgeColor(String role) {
    switch (role) {
      case 'spare':
        return Colors.blue;
      case 'shop':
        return AppTheme.primaryPurple;
      case 'seller':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/noshow',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: '노쇼 관리',
            subtitle: '노쇼 이력을 조회하고 관리할 수 있습니다',
          ),
          SizedBox(height: AppTheme.spacing6),
          SizedBox(
            height: 600,
            child: AdminTableCard(
              child: _isLoading && _history.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _history.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacing8),
                            child: Text(
                              '노쇼 이력이 없습니다',
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
                                  headers: ['사용자', '공고 정보', '미용실', '노쇼 일시', '등록일'],
                                  flexValues: [1, 2, 1, 1, 1],
                                ),
                            // 테이블 본문
                            Expanded(
                              child: ListView.builder(
                                itemCount: _history.length,
                                itemBuilder: (context, index) {
                                  final item = _history[index];
                                  final roleColor = _getRoleBadgeColor(item['energyWallet']?['user']?['role'] ?? '');
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
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['energyWallet']?['user']?['name'] ?? '-',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppTheme.textSecondary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: AppTheme.spacing2,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: roleColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                                ),
                                                child: Text(
                                                  _getRoleLabel(item['energyWallet']?['user']?['role'] ?? ''),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: roleColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item['job']?['title'] ?? '-',
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
                                            item['job']?['shop']?['name'] ?? '-',
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
                                            _formatDate(item['noshowDate'] ?? ''),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.urgentRed,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            _formatDate(item['createdAt'] ?? ''),
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
                                                  _loadHistory();
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
                                                  _loadHistory();
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
