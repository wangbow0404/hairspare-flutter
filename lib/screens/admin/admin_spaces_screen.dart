import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M6. 공간 대여·예약 관리
class AdminSpacesScreen extends StatefulWidget {
  const AdminSpacesScreen({super.key});

  @override
  State<AdminSpacesScreen> createState() => _AdminSpacesScreenState();
}

class _AdminSpacesScreenState extends State<AdminSpacesScreen> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;
  List<dynamic> _spaces = [];
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)..addListener(() { if (!_tabController.indexIsChanging) _load(); });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      if (_tabController.index == 0) {
        final r = await _adminService.getSpaces();
        if (mounted) setState(() { _spaces = r['spaces'] ?? []; _isLoading = false; });
      } else {
        final r = await _adminService.getSpaceBookings(status: 'pending');
        if (mounted) setState(() { _bookings = r['bookings'] ?? []; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelBooking(Map<String, dynamic> booking) async {
    final reason = await AdminActionDialog.show(context, title: '예약 강제 취소', confirmLabel: '취소', summary: booking['spaceName']?.toString(), isDanger: true);
    if (reason == null || !mounted) return;
    await _adminService.forceCancelBooking(booking['id'].toString(), reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('예약이 취소되었습니다')));
    _load();
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
        const AdminPageHeader(title: '공간 대여', subtitle: '공간 목록 및 예약 큐 관리'),
        const SizedBox(height: AppTheme.spacing4),
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryPurple,
          tabs: const [Tab(text: '공간'), Tab(text: '예약 (대기)')],
        ),
        const SizedBox(height: AppTheme.spacing4),
        SizedBox(
          height: 520,
          child: AdminTableCard(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tabController.index == 0
                    ? ListView.separated(
                        itemCount: _spaces.length,
                        separatorBuilder: (_, __) => Divider(color: AppTheme.adminPurple100.withValues(alpha: 0.5)),
                        itemBuilder: (_, i) {
                          final s = _spaces[i] as Map<String, dynamic>;
                          return ListTile(
                            title: Text(s['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${s['shopName']} · ${s['statusLabel']} · ${s['hourlyRate']}원/시간'),
                          );
                        },
                      )
                    : ListView.separated(
                        itemCount: _bookings.length,
                        separatorBuilder: (_, __) => Divider(color: AppTheme.adminPurple100.withValues(alpha: 0.5)),
                        itemBuilder: (_, i) {
                          final b = _bookings[i] as Map<String, dynamic>;
                          return ListTile(
                            title: Text(b['spaceName']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${b['userName']} · ${_formatDate(b['startAt']?.toString())} · ${b['amount']}원'),
                            trailing: b['status'] == 'pending'
                                ? TextButton(onPressed: () => _cancelBooking(b), child: const Text('취소', style: TextStyle(color: AppTheme.urgentRed)))
                                : Text(b['statusLabel']?.toString() ?? ''),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }
}
