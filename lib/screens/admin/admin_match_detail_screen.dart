import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';

/// 관리자 모델 매칭 상세 화면 — 디자이너/모델을 각각 눌러서 회원 상세로,
/// 매칭됐으면 연결된 채팅방으로도 이동할 수 있다.
class AdminMatchDetailScreen extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic>? initialData;

  const AdminMatchDetailScreen({
    super.key,
    required this.matchId,
    this.initialData,
  });

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
    _loadMatch();
  }

  Future<void> _loadMatch() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _adminService.getMatchDetail(widget.matchId);
      if (mounted) {
        setState(() {
          _match = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandler.getUserFriendlyMessage(
            ErrorHandler.handleException(e),
          );
          _isLoading = false;
          if (_match == null && widget.initialData != null) {
            _match = widget.initialData;
          }
        });
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      return DateFormat(
        'yyyy년 M월 d일 HH:mm',
        'ko_KR',
      ).format(DateTime.parse(dateString).toLocal());
    } catch (_) {
      return dateString;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'matched':
        return AdminStitchTheme.emerald;
      case 'pending':
        return AppTheme.orange600;
      case 'declined':
        return AdminStitchTheme.textSecondary;
      default:
        return AdminStitchTheme.textSecondary;
    }
  }

  Future<void> _cancelMatch() async {
    final match = _match;
    if (match == null) return;
    final designerName = match['designerName']?.toString() ?? '-';
    final modelName = match['modelName']?.toString() ?? '-';
    final reason = await AdminActionDialog.show(
      context,
      title: '매칭 강제 취소',
      confirmLabel: '취소 실행',
      summary: '$designerName ↔ $modelName',
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.forceCancelMatch(widget.matchId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('매칭이 취소되었습니다')));
      _loadMatch();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '강제 취소 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AdminStitchTheme.bgSubtle,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                  color: AdminStitchTheme.onSurface,
                ),
                const SizedBox(width: AdminStitchTheme.stackTight),
                const Text('매칭 상세', style: AdminStitchTheme.headlineMd),
              ],
            ),
            const SizedBox(height: AdminStitchTheme.sectionGap),
            if (_isLoading && _match == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacing8),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null && _match == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.urgentRed),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      TextButton(
                        onPressed: _loadMatch,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_match != null)
              _buildContent()
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final match = _match!;
    final status = match['status']?.toString() ?? '';
    final statusLabel = match['statusLabel']?.toString() ?? status;
    final statusColor = _statusColor(status);
    final designerId = match['designerId']?.toString();
    final designerName = match['designerName']?.toString() ?? '-';
    final modelId = match['modelId']?.toString();
    final modelName = match['modelName']?.toString() ?? '-';
    final region = match['region']?.toString() ?? '-';
    final chatId = match['chatId']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusHero(
          statusLabel: statusLabel,
          statusColor: statusColor,
          createdAtLabel: _formatDate(match['createdAt']?.toString()),
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        const _SectionLabel('매칭 정보'),
        const SizedBox(height: AdminStitchTheme.stackTight),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _NavCard(
                  icon: Icons.person_outline,
                  label: '디자이너',
                  title: designerName,
                  onTap: designerId != null
                      ? () =>
                            context.push(AppRoutes.adminUserDetail(designerId))
                      : null,
                ),
              ),
              const SizedBox(width: AdminStitchTheme.stackTight),
              Expanded(
                child: _NavCard(
                  icon: Icons.face_retouching_natural_outlined,
                  label: '모델',
                  title: modelName,
                  subtitle: region,
                  onTap: modelId != null
                      ? () => context.push(AppRoutes.adminUserDetail(modelId))
                      : null,
                ),
              ),
            ],
          ),
        ),
        if (chatId != null && chatId.isNotEmpty) ...[
          const SizedBox(height: AdminStitchTheme.sectionGap),
          const _SectionLabel('연결된 채팅'),
          const SizedBox(height: AdminStitchTheme.stackTight),
          _NavCard(
            icon: Icons.chat_bubble_outline,
            label: '채팅방',
            title: '$designerName ↔ $modelName',
            onTap: () => context.push(AppRoutes.adminChat(chatId)),
          ),
        ],
        if (status == 'matched') ...[
          const SizedBox(height: AdminStitchTheme.sectionGap),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _cancelMatch,
              icon: const Icon(Icons.cancel_outlined, size: 20),
              label: const Text('강제 취소'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminStitchTheme.statusError,
                side: BorderSide(
                  color: AdminStitchTheme.statusError.withValues(alpha: 0.4),
                  width: 2,
                ),
                minimumSize: const Size.fromHeight(
                  AdminStitchTheme.buttonHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AdminStitchTheme.radiusXl,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 상태를 크게 강조하는 히어로 카드 — 상태색으로 옅게 틴트된 배경 +
/// 점(dot) 배지 + 매칭 요청 일시.
class _StatusHero extends StatelessWidget {
  const _StatusHero({
    required this.statusLabel,
    required this.statusColor,
    required this.createdAtLabel,
  });

  final String statusLabel;
  final Color statusColor;
  final String createdAtLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: AdminStitchTheme.labelSm.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          Text(
            '매칭 요청 일시 $createdAtLabel',
            style: AdminStitchTheme.bodyMd.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text, style: AdminStitchTheme.sectionHeader),
    );
  }
}

/// 다른 상세 화면으로 이동하는 탭 가능한 카드. onTap이 없으면(대상 id 없음)
/// 화살표 없이 비활성 상태로 보인다.
class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.icon,
    required this.label,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminStitchTheme.surfaceCard,
      borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
        child: Container(
          padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
            border: Border.all(color: AdminStitchTheme.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AdminStitchTheme.primaryFixed,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: AdminStitchTheme.primary),
              ),
              const SizedBox(width: AdminStitchTheme.stackTight),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AdminStitchTheme.bodyMd.copyWith(
                        color: AdminStitchTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AdminStitchTheme.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AdminStitchTheme.bodyMd.copyWith(
                          color: AdminStitchTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AdminStitchTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
