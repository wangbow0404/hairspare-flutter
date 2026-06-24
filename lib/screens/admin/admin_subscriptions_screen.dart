import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M11. 구독·크리에이터 관리
class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() => _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState extends State<AdminSubscriptionsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _subscriptions = [];
  List<dynamic> _creators = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final subs = await _adminService.getSubscriptions();
      final creators = await _adminService.getCreators();
      if (mounted) {
        setState(() {
          _subscriptions = subs['subscriptions'] ?? [];
          _creators = creators['creators'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCreator(Map<String, dynamic> creator) async {
    final reason = await AdminActionDialog.show(context, title: '크리에이터 인증', confirmLabel: '인증', summary: creator['name']?.toString());
    if (reason == null || !mounted) return;
    try {
      await _adminService.verifyCreator(creator['id'].toString(), reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('크리에이터 인증 완료')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(title: '구독·크리에이터', subtitle: '구독 현황 및 크리에이터 인증'),
        const SizedBox(height: AppTheme.spacing6),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          const Text('크리에이터', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.spacing3),
          Wrap(
            spacing: AppTheme.spacing3,
            runSpacing: AppTheme.spacing3,
            children: _creators.map((c) {
              final map = c as Map<String, dynamic>;
              return AdminTableCard(
                padding: const EdgeInsets.all(AppTheme.spacing4),
                child: SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(map['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                          if (map['verified'] == true)
                            const Icon(Icons.verified, color: AppTheme.primaryPurple, size: 18),
                        ],
                      ),
                      Text('구독자 ${map['subscriberCount']} · 영상 ${map['videoCount']}'),
                      if (map['verified'] != true)
                        TextButton(onPressed: () => _verifyCreator(map), child: const Text('인증하기')),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.spacing6),
          SizedBox(
            height: 320,
            child: AdminTableCard(
              child: ListView.separated(
                itemCount: _subscriptions.length,
                separatorBuilder: (_, __) => Divider(color: AppTheme.adminPurple100.withValues(alpha: 0.5)),
                itemBuilder: (_, i) {
                  final s = _subscriptions[i] as Map<String, dynamic>;
                  return ListTile(
                    title: Text('${s['userName']} → ${s['creatorName']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${s['amount']}원/월'),
                    trailing: Text(s['isActive'] == true ? '활성' : '해지', style: TextStyle(color: s['isActive'] == true ? AppTheme.green600 : AppTheme.textSecondary)),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
