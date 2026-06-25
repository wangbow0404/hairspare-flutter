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

/// M6. 공간 대여·예약 관리
class AdminSpacesScreen extends StatefulWidget {
  const AdminSpacesScreen({super.key});

  @override
  State<AdminSpacesScreen> createState() => _AdminSpacesScreenState();
}

class _AdminSpacesScreenState extends State<AdminSpacesScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _spaces = [];
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  int _tabIndex = 0;

  static const _tabs = ['공간', '예약 (대기)'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      if (_tabIndex == 0) {
        final r = await _adminService.getSpaces();
        if (mounted) {
          setState(() {
            _spaces = r['spaces'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        final r = await _adminService.getSpaceBookings(status: 'pending');
        if (mounted) {
          setState(() {
            _bookings = r['bookings'] ?? [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
            ),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelBooking(Map<String, dynamic> booking) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '예약 강제 취소',
      confirmLabel: '취소',
      summary: booking['spaceName']?.toString(),
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    await _adminService.forceCancelBooking(booking['id'].toString(), reason: reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('예약이 취소되었습니다')),
    );
    _load();
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
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminStitchPageHeader(
            title: '공간 대여',
            subtitle: '공간 목록 및 예약 큐 관리',
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchFilterChips(
            tabs: _tabs,
            selectedTab: _tabs[_tabIndex],
            onTabChanged: (tab) {
              setState(() => _tabIndex = _tabs.indexOf(tab));
              _load();
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

    if (_tabIndex == 0) {
      if (_spaces.isEmpty) {
        return const AdminStitchListStateSliver.empty(
          emptyMessage: '등록된 공간이 없습니다',
          emptyIcon: Icons.meeting_room_outlined,
        );
      }
      return SliverPadding(
        padding: AdminStitchListScreenShell.listPadding(context),
        sliver: SliverList.separated(
          itemCount: _spaces.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AdminStitchTheme.sectionGap),
          itemBuilder: (_, i) {
            final s = _spaces[i] as Map<String, dynamic>;
            return AdminStitchSimpleListCard(
              title: s['name']?.toString() ?? '',
              subtitle:
                  '${s['shopName']} · ${s['statusLabel']} · ${s['hourlyRate']}원/시간',
              icon: Icons.chair_outlined,
            );
          },
        ),
      );
    }

    if (_bookings.isEmpty) {
      return const AdminStitchListStateSliver.empty(
        emptyMessage: '대기 중인 예약이 없습니다',
        emptyIcon: Icons.event_busy_outlined,
      );
    }
    return SliverPadding(
      padding: AdminStitchListScreenShell.listPadding(context),
      sliver: SliverList.separated(
        itemCount: _bookings.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AdminStitchTheme.sectionGap),
        itemBuilder: (_, i) {
          final b = _bookings[i] as Map<String, dynamic>;
          return AdminStitchSimpleListCard(
            title: b['spaceName']?.toString() ?? '',
            subtitle:
                '${b['userName']} · ${_formatDate(b['startAt']?.toString())} · ${b['amount']}원',
            icon: Icons.event_outlined,
            trailing: b['status'] == 'pending'
                ? TextButton(
                    onPressed: () => _cancelBooking(b),
                    child: const Text(
                      '취소',
                      style: TextStyle(color: AppTheme.urgentRed),
                    ),
                  )
                : Text(b['statusLabel']?.toString() ?? ''),
          );
        },
      ),
    );
  }
}
