import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M7. 교육 관리
class AdminEducationsScreen extends StatefulWidget {
  const AdminEducationsScreen({super.key});

  @override
  State<AdminEducationsScreen> createState() => _AdminEducationsScreenState();
}

class _AdminEducationsScreenState extends State<AdminEducationsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final r = await _adminService.getEducations();
      if (mounted) {
        setState(() {
          _items = r['educations'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _hideEducation(Map<String, dynamic> item) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '교육 숨김',
      confirmLabel: '숨김',
      summary: item['title']?.toString(),
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    await _adminService.hideEducation(item['id'].toString(), reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('교육이 숨김 처리되었습니다')),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminStitchPageHeader(
            title: '교육 관리',
            subtitle: '교육 공고 승인·숨김·수강 환불',
          ),
          SizedBox(height: AdminStitchTheme.sectionGap),
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
        emptyMessage: '교육 공고가 없습니다',
        emptyIcon: Icons.school_outlined,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, i) {
          final e = _items[i] as Map<String, dynamic>;
          final isPending = e['status'] == 'pending';
          return AdminStitchSimpleListCard(
            title: e['title']?.toString() ?? '',
            subtitle:
                '${e['instructor']} · ${e['applicantCount']}/${e['maxApplicants']} · ${e['energyCost']} 에너지 · ${e['isOnline'] == true ? '온라인' : '오프라인'}',
            icon: Icons.school_outlined,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.orange100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '승인 대기',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.orange600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.visibility_off_outlined, size: 20),
                  onPressed: () => _hideEducation(e),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
