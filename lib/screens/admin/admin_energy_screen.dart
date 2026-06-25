import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

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
  Timer? _updateTimer;

  static const _typeTabs = ['전체', '구매', '잠금', '반환', '몰수', '보상'];
  static const _typeMap = {
    '전체': '',
    '구매': 'purchase',
    '잠금': 'lock',
    '반환': 'return',
    '몰수': 'forfeit',
    '보상': 'reward',
  };

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadTransactions(showLoading: false);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTransactions({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);

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
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '에너지 거래 내역 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
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

  String _selectedTypeTab() {
    for (final e in _typeMap.entries) {
      if (e.value == _typeFilter) return e.key;
    }
    return '전체';
  }

  Future<void> _grantEnergy() async {
    final userController = TextEditingController();
    final amountController = TextEditingController(text: '100');
    final reason = await AdminActionDialog.show(
      context,
      title: '에너지 수동 지급',
      confirmLabel: '지급',
      extraFields: [
        AdminFieldConfig(label: '사용자 ID', controller: userController),
        AdminFieldConfig(
          label: '수량',
          controller: amountController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
    final userId = userController.text.trim();
    final amount = int.tryParse(amountController.text.trim()) ?? 0;
    userController.dispose();
    amountController.dispose();
    if (reason == null || userId.isEmpty || amount <= 0 || !mounted) return;
    try {
      await _adminService.grantEnergy(userId, amount, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('에너지가 지급되었습니다 (감사 로그 기록)')),
      );
      _loadTransactions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: '에너지 관리',
            subtitle: '에너지 거래 내역 조회 및 수동 지급',
            trailing: FilledButton.icon(
              onPressed: _grantEnergy,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('수동 지급'),
            ),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchSearchField(
            controller: _searchController,
            hint: '사용자, 이메일 검색...',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchFilterChips(
            tabs: _typeTabs,
            selectedTab: _selectedTypeTab(),
            onTabChanged: (tab) {
              setState(() {
                _typeFilter = _typeMap[tab] ?? '';
                _currentPage = 1;
              });
              _loadTransactions();
            },
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _transactions.isEmpty) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_transactions.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '거래 내역이 없습니다',
        emptyIcon: Icons.bolt_outlined,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == _transactions.length) {
              return _buildPagination();
            }
            final t = _transactions[index] as Map<String, dynamic>;
            final amount = t['amount'] as num? ?? 0;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < _transactions.length - 1
                    ? AdminStitchTheme.sectionGap
                    : 0,
              ),
              child: AdminStitchSimpleListCard(
                title: t['energyWallet']?['user']?['email']?.toString() ?? '-',
                subtitle:
                    '${t['typeLabel'] ?? t['type']} · ${amount > 0 ? '+' : ''}$amount개 · ${_formatDate(t['createdAt']?.toString() ?? '')}',
                icon: Icons.bolt_outlined,
                iconColor: amount >= 0
                    ? AdminStitchTheme.emerald
                    : AdminStitchTheme.statusError,
              ),
            );
          },
          childCount: _transactions.length + (_totalPages > 1 ? 1 : 0),
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
                    _loadTransactions();
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('$_currentPage / $_totalPages', style: AdminStitchTheme.bodyMd),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadTransactions();
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
