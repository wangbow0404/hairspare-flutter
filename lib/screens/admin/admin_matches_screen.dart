import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_search_filter_bar.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M5. 모델 매칭 관리
class AdminMatchesScreen extends StatefulWidget {
  const AdminMatchesScreen({super.key});

  @override
  State<AdminMatchesScreen> createState() => _AdminMatchesScreenState();
}

class _AdminMatchesScreenState extends State<AdminMatchesScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final result = await _adminService.getMatches(
        status: _statusFilter == 'all' ? null : _statusFilter,
      );
      if (mounted) setState(() { _items = result['matches'] ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelMatch(Map<String, dynamic> item) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '매칭 강제 취소',
      confirmLabel: '취소 실행',
      summary: '${item['designerName']} ↔ ${item['modelName']}',
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    await _adminService.forceCancelMatch(item['id'].toString(), reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('매칭이 취소되었습니다')));
    _load();
  }

  String _formatDate(String? v) {
    if (v == null) return '-';
    try { return DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(v).toLocal()); } catch (_) { return v; }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(title: '모델 매칭', subtitle: '디자이너-모델 매칭 현황 및 개입'),
        const SizedBox(height: AppTheme.spacing6),
        AdminSearchFilterBar(
          searchController: _searchController,
          filterTabs: const ['전체', '대기', '매칭됨'],
          selectedTab: _statusFilter == 'all' ? '전체' : _statusFilter == 'pending' ? '대기' : '매칭됨',
          onTabChanged: (tab) {
            setState(() => _statusFilter = tab == '전체' ? 'all' : tab == '대기' ? 'pending' : 'matched');
            _load();
          },
        ),
        const SizedBox(height: AppTheme.spacing6),
        SizedBox(
          height: 560,
          child: AdminTableCard(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('매칭 내역이 없습니다'))
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => Divider(color: AppTheme.adminPurple100.withValues(alpha: 0.5)),
                        itemBuilder: (context, i) {
                          final item = _items[i] as Map<String, dynamic>;
                          return ListTile(
                            title: Text('${item['designerName']} ↔ ${item['modelName']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${item['region']} · ${item['statusLabel']} · ${_formatDate(item['createdAt']?.toString())}'),
                            trailing: item['status'] == 'matched'
                                ? TextButton(onPressed: () => _cancelMatch(item), child: const Text('강제취소', style: TextStyle(color: AppTheme.urgentRed)))
                                : null,
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}
