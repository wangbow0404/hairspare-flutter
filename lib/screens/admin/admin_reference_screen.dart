import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M17. 레퍼런스 데이터
class AdminReferenceScreen extends StatefulWidget {
  const AdminReferenceScreen({super.key});

  @override
  State<AdminReferenceScreen> createState() => _AdminReferenceScreenState();
}

class _AdminReferenceScreenState extends State<AdminReferenceScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _data = {};
  bool _isLoading = true;
  int _tabIndex = 0;

  static const _tabs = ['지역', '샵등급', '매칭태그', '카테고리'];
  static const _tabKeys = ['regions', 'tiers', 'matchTags', 'categories'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final r = await _adminService.getReferenceData();
    if (mounted) {
      setState(() {
        _data = r;
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _currentItems {
    final key = _tabKeys[_tabIndex];
    return (_data[key] as List?) ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminStitchPageHeader(
            title: '레퍼런스 데이터',
            subtitle: '지역·등급·태그·카테고리 CRUD',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchFilterChips(
            tabs: _tabs,
            selectedTab: _tabs[_tabIndex],
            onTabChanged: (tab) {
              setState(() => _tabIndex = _tabs.indexOf(tab));
            },
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AdminStitchListStateSliver.loading();
    }
    final items = _currentItems;
    if (items.isEmpty) {
      return AdminStitchListStateSliver.empty(
        emptyMessage: '${_tabs[_tabIndex]} 데이터가 없습니다',
      );
    }
    final key = _tabKeys[_tabIndex];
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, i) {
          final item = items[i] as Map<String, dynamic>;
          return AdminStitchSimpleListCard(
            title: _itemTitle(key, item),
            subtitle: _itemSubtitle(key, item),
            icon: Icons.dataset_outlined,
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('수정 (mock)')),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _itemTitle(String key, Map<String, dynamic> item) {
    switch (key) {
      case 'regions':
        return '${item['province']} ${item['city']} ${item['district']}';
      case 'tiers':
      case 'matchTags':
      case 'categories':
        return item['label']?.toString() ?? '';
      default:
        return item.toString();
    }
  }

  String _itemSubtitle(String key, Map<String, dynamic> item) {
    switch (key) {
      case 'tiers':
        return '공고 ${item['maxJobs']}개';
      case 'matchTags':
        return item['category']?.toString() ?? '';
      default:
        return item['id']?.toString() ?? '';
    }
  }
}
