import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_table_card.dart';

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
      if (mounted) setState(() { _sanctions = r['sanctions'] ?? []; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _liftSanction(Map<String, dynamic> item) async {
    final reason = await AdminActionDialog.show(context, title: '제재 해제', confirmLabel: '해제', summary: item['userName']?.toString());
    if (reason == null || !mounted) return;
    try {
      await _adminService.liftSanction(item['id'].toString(), reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제재가 해제되었습니다')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
    }
  }

  String _formatDate(String? v) {
    if (v == null) return '-';
    try { return DateFormat('yyyy.MM.dd').format(DateTime.parse(v).toLocal()); } catch (_) { return v; }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(title: '제재 실행·이력', subtitle: '제재 적용·해제 및 블랙리스트 관리'),
        const SizedBox(height: AppTheme.spacing6),
        SizedBox(
          height: 560,
          child: AdminTableCard(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _sanctions.length,
                    separatorBuilder: (_, __) => Divider(color: AppTheme.adminPurple100.withValues(alpha: 0.5)),
                    itemBuilder: (_, i) {
                      final s = _sanctions[i] as Map<String, dynamic>;
                      final active = s['active'] == true;
                      return ListTile(
                        title: Text(s['userName']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${s['typeLabel']} · ${s['reason']} · ${_formatDate(s['createdAt']?.toString())}'),
                        trailing: active
                            ? TextButton(onPressed: () => _liftSanction(s), child: const Text('해제'))
                            : const Text('종료', style: TextStyle(color: AppTheme.textTertiary)),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
