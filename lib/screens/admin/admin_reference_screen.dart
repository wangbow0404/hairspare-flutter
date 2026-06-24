import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M17. 레퍼런스 데이터
class AdminReferenceScreen extends StatefulWidget {
  const AdminReferenceScreen({super.key});

  @override
  State<AdminReferenceScreen> createState() => _AdminReferenceScreenState();
}

class _AdminReferenceScreenState extends State<AdminReferenceScreen> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;
  Map<String, dynamic> _data = {};
  bool _isLoading = true;

  static const _tabs = ['지역', '샵등급', '매칭태그', '카테고리'];
  static const _tabKeys = ['regions', 'tiers', 'matchTags', 'categories'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final r = await _adminService.getReferenceData();
    if (mounted) setState(() { _data = r; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(title: '레퍼런스 데이터', subtitle: '지역·등급·태그·카테고리 CRUD'),
        const SizedBox(height: AppTheme.spacing4),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryPurple,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
        const SizedBox(height: AppTheme.spacing4),
        SizedBox(
          height: 520,
          child: AdminTableCard(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(4, (index) {
                      final key = _tabKeys[index];
                      final items = (_data[key] as List?) ?? [];
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => Divider(color: AppTheme.adminPurple100.withValues(alpha: 0.5)),
                        itemBuilder: (_, i) {
                          final item = items[i] as Map<String, dynamic>;
                          return ListTile(
                            title: Text(_itemTitle(key, item), style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(_itemSubtitle(key, item)),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('수정 (mock)')));
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ),
          ),
        ),
      ],
    );
  }

  String _itemTitle(String key, Map<String, dynamic> item) {
    switch (key) {
      case 'regions':
        return '${item['province']} ${item['city']} ${item['district']}';
      case 'tiers':
        return item['label']?.toString() ?? '';
      case 'matchTags':
        return item['label']?.toString() ?? '';
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
