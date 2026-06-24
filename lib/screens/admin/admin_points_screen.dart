import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_table_card.dart';

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
    try { return DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(v).toLocal()); } catch (_) { return v; }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(title: '포인트·미션', subtitle: '포인트 거래 내역 및 미션 설정'),
        const SizedBox(height: AppTheme.spacing6),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          AdminTableCard(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('미션 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppTheme.spacing3),
                ..._missions.map((m) {
                  final map = m as Map<String, dynamic>;
                  return SwitchListTile(
                    title: Text(map['label']?.toString() ?? ''),
                    subtitle: Text('보상 ${map['reward']}P · 일일 ${map['dailyCap']}회'),
                    value: map['active'] == true,
                    onChanged: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('미션 설정 변경 (mock)')));
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing6),
          SizedBox(
            height: 400,
            child: AdminTableCard(
              child: ListView.separated(
                itemCount: _transactions.length,
                separatorBuilder: (_, __) => Divider(color: AppTheme.adminPurple100.withValues(alpha: 0.5)),
                itemBuilder: (_, i) {
                  final t = _transactions[i] as Map<String, dynamic>;
                  final suspicious = t['suspicious'] == true;
                  return ListTile(
                    title: Text(t['userName']?.toString() ?? '', style: TextStyle(fontWeight: FontWeight.w600, color: suspicious ? AppTheme.urgentRed : AppTheme.textPrimary)),
                    subtitle: Text('${t['description']} · ${_formatDate(t['createdAt']?.toString())}'),
                    trailing: Text('${t['typeLabel']} ${t['amount']}P', style: TextStyle(fontWeight: FontWeight.w600, color: suspicious ? AppTheme.urgentRed : AppTheme.green600)),
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
