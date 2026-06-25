import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

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
      final r = await _adminService.getContentItems(
        type: _typeFilter == 'all' ? null : _typeFilter,
        flagged: 'true',
      );
      if (mounted) {
        setState(() {
          _items = r['items'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _hide(Map<String, dynamic> item) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '콘텐츠 숨김',
      confirmLabel: '숨김',
      summary: item['title']?.toString(),
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    await _adminService.hideContent(item['id'].toString(), reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('콘텐츠가 숨김 처리되었습니다')),
    );
    _load();
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '콘텐츠 삭제',
      confirmLabel: '삭제',
      summary: item['title']?.toString(),
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    await _adminService.deleteContent(item['id'].toString(), reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('콘텐츠가 삭제되었습니다')),
    );
    _load();
  }

  String _selectedTab() {
    switch (_typeFilter) {
      case 'challenge':
        return '영상';
      case 'comment':
        return '댓글';
      default:
        return '전체';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminStitchPageHeader(
            title: '콘텐츠 모더레이션',
            subtitle: '챌린지 영상·댓글 신고 처리',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchSearchField(
            controller: _searchController,
            hint: '제목, 작성자 검색...',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchFilterChips(
            tabs: const ['전체', '영상', '댓글'],
            selectedTab: _selectedTab(),
            onTabChanged: (tab) {
              setState(() {
                _typeFilter = tab == '전체'
                    ? 'all'
                    : tab == '영상'
                        ? 'challenge'
                        : 'comment';
              });
              _load();
            },
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _items.isEmpty) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_items.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '신고된 콘텐츠가 없습니다',
        emptyIcon: Icons.video_library_outlined,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, i) {
          final item = _items[i] as Map<String, dynamic>;
          return AdminStitchContentCard(
            title: item['title']?.toString() ?? '',
            subtitle:
                '${item['typeLabel']} · ${item['authorName']}',
            isVideo: item['type'] == 'challenge',
            onHide: () => _hide(item),
            onDelete: () => _delete(item),
          );
        },
      ),
    );
  }
}
