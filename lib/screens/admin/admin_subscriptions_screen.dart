import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M11. 구독·크리에이터 관리
class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() =>
      _AdminSubscriptionsScreenState();
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
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCreator(Map<String, dynamic> creator) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '크리에이터 인증',
      confirmLabel: '인증',
      summary: creator['name']?.toString(),
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.verifyCreator(
        creator['id'].toString(),
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('크리에이터 인증 완료')),
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

  @override
  Widget build(BuildContext context) {
    return AdminStitchListScreenShell(
      header: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminStitchPageHeader(
            title: '구독·크리에이터',
            subtitle: '구독 현황 및 크리에이터 인증',
          ),
          SizedBox(height: AdminStitchTheme.sectionGap),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AdminStitchListStateSliver.loading();
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text('크리에이터', style: AdminStitchTheme.sectionHeader),
          const SizedBox(height: AdminStitchTheme.stackTight),
          ..._creators.map((c) {
            final map = c as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: AdminStitchTheme.sectionGap),
              child: AdminStitchSimpleListCard(
                title: map['name']?.toString() ?? '',
                subtitle:
                    '구독자 ${map['subscriberCount']} · 영상 ${map['videoCount']}',
                icon: Icons.verified_outlined,
                trailing: map['verified'] == true
                    ? const Icon(Icons.verified, color: AppTheme.primaryPurple)
                    : TextButton(
                        onPressed: () => _verifyCreator(map),
                        child: const Text('인증하기'),
                      ),
              ),
            );
          }),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          Text('구독 목록', style: AdminStitchTheme.sectionHeader),
          const SizedBox(height: AdminStitchTheme.stackTight),
          ..._subscriptions.map((s) {
            final map = s as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: AdminStitchTheme.sectionGap),
              child: AdminStitchSimpleListCard(
                title: '${map['userName']} → ${map['creatorName']}',
                subtitle: '${map['amount']}원/월',
                icon: Icons.subscriptions_outlined,
                trailing: Text(
                  map['isActive'] == true ? '활성' : '해지',
                  style: TextStyle(
                    color: map['isActive'] == true
                        ? AppTheme.green600
                        : AdminStitchTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ]),
      ),
    );
  }
}
