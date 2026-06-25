import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin/admin_stitch_list_cards.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M10. 포인트·미션 관리
class AdminPointsScreen extends StatefulWidget {
  const AdminPointsScreen({super.key});

  @override
  State<AdminPointsScreen> createState() => _AdminPointsScreenState();
}

class _AdminPointsScreenState extends State<AdminPointsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _transactions = [];
  List<dynamic> _missions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final txs = await _adminService.getPointTransactions();
    final missions = await _adminService.getMissions();
    if (mounted) {
      setState(() {
        _transactions = txs['transactions'] ?? [];
        _missions = missions['missions'] ?? [];
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? v) {
    if (v == null) return '-';
    try {
      return DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(v).toLocal());
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
            title: '포인트·미션',
            subtitle: '포인트 거래 내역 및 미션 설정',
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
          AdminStitchCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('미션 설정', style: AdminStitchTheme.sectionHeader),
                const SizedBox(height: AdminStitchTheme.stackTight),
                ..._missions.map((m) {
                  final map = m as Map<String, dynamic>;
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(map['label']?.toString() ?? ''),
                    subtitle: Text(
                      '보상 ${map['reward']}P · 일일 ${map['dailyCap']}회',
                    ),
                    value: map['active'] == true,
                    onChanged: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('미션 설정 변경 (mock)')),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          Text('거래 내역', style: AdminStitchTheme.sectionHeader),
          const SizedBox(height: AdminStitchTheme.stackTight),
          ..._transactions.map((t) {
            final map = t as Map<String, dynamic>;
            final suspicious = map['suspicious'] == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: AdminStitchTheme.sectionGap),
              child: AdminStitchSimpleListCard(
                title: map['userName']?.toString() ?? '',
                subtitle:
                    '${map['description']} · ${_formatDate(map['createdAt']?.toString())}',
                icon: Icons.stars_outlined,
                iconColor: suspicious
                    ? AppTheme.urgentRed
                    : AdminStitchTheme.emerald,
                trailing: Text(
                  '${map['typeLabel']} ${map['amount']}P',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: suspicious ? AppTheme.urgentRed : AppTheme.green600,
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
