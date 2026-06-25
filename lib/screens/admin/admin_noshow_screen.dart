import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

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
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadHistory(showLoading: false);
      });
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHistory({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);

    try {
      final result = await _adminService.getNoShowHistory(
        page: _currentPage,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _history = result['history'] ?? [];
          _totalPages = result['pagination']?['totalPages'] ?? 1;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '노쇼 이력 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
              ),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      return DateFormat('yyyy.MM.dd HH:mm', 'ko_KR')
          .format(DateTime.parse(dateString).toLocal());
    } catch (_) {
      return dateString;
    }
  }

  String _roleLabel(String role) {
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

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminStitchPageHeader(
            title: '노쇼 관리',
            subtitle: '노쇼 이력 조회 및 관리',
          ),
          SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _history.isEmpty) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_history.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '노쇼 이력이 없습니다',
        emptyIcon: Icons.warning_amber_outlined,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == _history.length) {
              return _buildPagination();
            }
            final item = _history[index] as Map<String, dynamic>;
            final user = item['energyWallet']?['user'] as Map?;
            final role = user?['role']?.toString() ?? '';
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _history.length - 1
                    ? AdminStitchTheme.sectionGap
                    : 0,
              ),
              child: AdminStitchSimpleListCard(
                title: user?['name']?.toString() ?? '-',
                subtitle:
                    '${item['job']?['title'] ?? '-'} · ${item['job']?['shop']?['name'] ?? '-'} · ${_formatDate(item['noshowDate']?.toString() ?? '')}',
                icon: Icons.warning_amber_outlined,
                iconColor: AdminStitchTheme.statusError,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminStitchTheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _roleLabel(role),
                    style: AdminStitchTheme.labelSm.copyWith(
                      fontSize: 10,
                      color: AdminStitchTheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: _history.length + (_totalPages > 1 ? 1 : 0),
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
                    _loadHistory();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('$_currentPage / $_totalPages', style: AdminStitchTheme.bodyMd),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadHistory();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
