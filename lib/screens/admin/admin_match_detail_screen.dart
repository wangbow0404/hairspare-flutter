import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// M5. 모델 매칭 상세
class AdminMatchDetailScreen extends StatefulWidget {
  const AdminMatchDetailScreen({
    super.key,
    required this.matchId,
    this.initialData,
  });

  final String matchId;
  final Map<String, dynamic>? initialData;

  @override
  State<AdminMatchDetailScreen> createState() => _AdminMatchDetailScreenState();
}

class _AdminMatchDetailScreenState extends State<AdminMatchDetailScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _match;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _match = widget.initialData;
      _isLoading = false;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _adminService.getMatchDetail(widget.matchId);
      if (!mounted) return;
      setState(() {
        _match = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e));
        _isLoading = false;
        if (_match == null && widget.initialData != null) {
          _match = widget.initialData;
        }
      });
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR')
          .format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'matched':
        return AppTheme.green600;
      case 'pending':
        return AppTheme.orange600;
      case 'declined':
        return AppTheme.urgentRed;
      default:
        return AdminStitchTheme.textSecondary;
    }
  }

  Future<void> _cancelMatch() async {
    final reason = await AdminActionDialog.show(
      context,
      title: '매칭 강제 취소',
      confirmLabel: '취소 실행',
      summary: '${_match?['designerName']} ↔ ${_match?['modelName']}',
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.forceCancelMatch(widget.matchId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('매칭이 취소되었습니다')),
      );
      context.pop();
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
    if (_isLoading && _match == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_match == null || _match!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? '매칭 정보를 찾을 수 없습니다'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final m = _match!;
    final status = m['status']?.toString();
    final isMatched = status == 'matched';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: AppTheme.spacing1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('매칭 상세', style: AdminStitchTheme.pageTitleMobile),
                    Text(
                      '${m['designerName']} ↔ ${m['modelName']}',
                      style: AdminStitchTheme.pageSubtitle.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  m['statusLabel']?.toString() ?? status ?? '-',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchCard(
            child: Column(
              children: [
                _DetailRow(label: '매칭 ID', value: m['id']?.toString() ?? '-'),
                _DetailRow(label: '지역', value: m['region']?.toString() ?? '-'),
                _DetailRow(label: '생성일', value: _formatDate(m['createdAt']?.toString())),
                _DetailRow(
                  label: '채팅방',
                  value: m['chatId'] != null ? '연결됨' : '없음',
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          const AdminStitchSectionTitle(title: '디자이너'),
          const SizedBox(height: AdminStitchTheme.stackTight),
          AdminStitchCard(
            onTap: m['designerId'] != null
                ? () => context.push(AppRoutes.adminUserDetail(m['designerId'].toString()))
                : null,
            child: _MemberRow(
              name: m['designerName']?.toString() ?? '-',
              subtitle: '스페어 · 디자이너',
            ),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          const AdminStitchSectionTitle(title: '모델'),
          const SizedBox(height: AdminStitchTheme.stackTight),
          AdminStitchCard(
            onTap: m['modelId'] != null
                ? () => context.push(AppRoutes.adminUserDetail(m['modelId'].toString()))
                : null,
            child: _MemberRow(
              name: m['modelName']?.toString() ?? '-',
              subtitle: '스페어 · 모델',
            ),
          ),
          if (isMatched) ...[
            const SizedBox(height: AdminStitchTheme.sectionGap),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _cancelMatch,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('매칭 강제 취소'),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.urgentRed),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: AdminStitchTheme.labelSm.copyWith(
                color: AdminStitchTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AdminStitchTheme.bodyMd)),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AdminStitchTheme.primaryFixed,
          child: Text(
            name.characters.first,
            style: const TextStyle(color: AdminStitchTheme.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AdminStitchTheme.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: AdminStitchTheme.labelSm.copyWith(
                  color: AdminStitchTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AdminStitchTheme.textSecondary),
      ],
    );
  }
}
