import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_search_filter_bar.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M14. 콘텐츠 모더레이션
class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _typeFilter = 'all';

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
      final r = await _adminService.getContentItems(type: _typeFilter == 'all' ? null : _typeFilter, flagged: 'true');
      if (mounted) setState(() { _items = r['items'] ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _hide(Map<String, dynamic> item) async {
    final reason = await AdminActionDialog.show(context, title: '콘텐츠 숨김', confirmLabel: '숨김', summary: item['title']?.toString(), isDanger: true);
    if (reason == null || !mounted) return;
    await _adminService.hideContent(item['id'].toString(), reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('콘텐츠가 숨김 처리되었습니다')));
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final reason = await AdminActionDialog.show(context, title: '콘텐츠 삭제', confirmLabel: '삭제', summary: item['title']?.toString(), isDanger: true);
    if (reason == null || !mounted) return;
    await _adminService.deleteContent(item['id'].toString(), reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('콘텐츠가 삭제되었습니다')));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(title: '콘텐츠 모더레이션', subtitle: '챌린지 영상·댓글 신고 처리'),
        const SizedBox(height: AppTheme.spacing6),
        AdminSearchFilterBar(
          searchController: _searchController,
          filterTabs: const ['전체', '영상', '댓글'],
          selectedTab: _typeFilter == 'all' ? '전체' : _typeFilter == 'challenge' ? '영상' : '댓글',
          onTabChanged: (tab) {
            setState(() => _typeFilter = tab == '전체' ? 'all' : tab == '영상' ? 'challenge' : 'comment');
            _load();
          },
        ),
        const SizedBox(height: AppTheme.spacing6),
        SizedBox(
          height: 520,
          child: AdminTableCard(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => Divider(color: AppTheme.adminPurple100.withValues(alpha: 0.5)),
                    itemBuilder: (_, i) {
                      final item = _items[i] as Map<String, dynamic>;
                      return ListTile(
                        leading: Icon(item['type'] == 'challenge' ? Icons.videocam : Icons.comment, color: AppTheme.urgentRed),
                        title: Text(item['title']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${item['typeLabel']} · ${item['authorName']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.visibility_off), onPressed: () => _hide(item)),
                            IconButton(icon: const Icon(Icons.delete, color: AppTheme.urgentRed), onPressed: () => _delete(item)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
