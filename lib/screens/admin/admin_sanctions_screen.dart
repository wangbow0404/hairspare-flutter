import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M13. 제재 실행·이력
class AdminSanctionsScreen extends StatefulWidget {
  const AdminSanctionsScreen({super.key});

  @override
  State<AdminSanctionsScreen> createState() => _AdminSanctionsScreenState();
}

class _AdminSanctionsScreenState extends State<AdminSanctionsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _sanctions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final r = await _adminService.getSanctions();
      if (mounted) {
        setState(() {
          _sanctions = r['sanctions'] ?? [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _liftSanction(Map<String, dynamic> item) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '제재 해제',
      confirmLabel: '해제',
      summary: item['userName']?.toString(),
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.liftSanction(item['id'].toString(), reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제재가 해제되었습니다')),
      );
      _load();
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

  String _formatDate(String? v) {
    if (v == null) return '-';
    try {
      return DateFormat('yyyy.MM.dd').format(DateTime.parse(v).toLocal());
    } catch (_) {
      return v;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminStitchPageHeader(
            title: '제재 실행·이력',
            subtitle: '제재 적용·해제 및 블랙리스트 관리',
          ),
          SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _sanctions.isEmpty) {
      return const AdminStitchListStateSliver.loading();
    }
    if (_sanctions.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '제재 이력이 없습니다',
        emptyIcon: Icons.gavel_outlined,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: _sanctions.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, i) {
          final s = _sanctions[i] as Map<String, dynamic>;
          final active = s['active'] == true;
          return AdminStitchSimpleListCard(
            title: s['userName']?.toString() ?? '',
            subtitle:
                '${s['typeLabel']} · ${s['reason']} · ${_formatDate(s['createdAt']?.toString())}',
            icon: Icons.gavel_outlined,
            iconColor: active
                ? AdminStitchTheme.statusError
                : AdminStitchTheme.textSecondary,
            trailing: active
                ? TextButton(
                    onPressed: () => _liftSanction(s),
                    child: const Text('해제'),
                  )
                : const Text(
                    '종료',
                    style: TextStyle(color: AppTheme.textTertiary),
                  ),
          );
        },
      ),
    );
  }
}
