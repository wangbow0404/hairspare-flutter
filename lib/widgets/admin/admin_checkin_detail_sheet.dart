import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';

/// 관리자 체크인 스케줄 상세 바텀 시트
class AdminCheckinDetailSheet extends StatelessWidget {
  const AdminCheckinDetailSheet({
    super.key,
    required this.schedule,
    required this.onIntervene,
  });

  final Map<String, dynamic> schedule;
  final Future<bool> Function(String action) onIntervene;

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> schedule,
    required Future<bool> Function(String action) onIntervene,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AdminCheckinDetailSheet(
        schedule: schedule,
        onIntervene: onIntervene,
      ),
    );
  }

  String _formatDateTime(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat('yyyy.MM.dd HH:mm', 'ko_KR')
          .format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  String _workTimeLine() {
    final date = schedule['date']?.toString() ?? '';
    final start = schedule['startTime']?.toString() ?? '';
    final end = schedule['endTime']?.toString();
    if (date.isEmpty) return '-';
    if (start.isEmpty) return date;
    if (end != null && end.isNotEmpty) return '$date $start ~ $end';
    return '$date $start';
  }

  String _stateLabel() {
    if (schedule['needsAttention'] == true) return '조치 필요';
    final label = schedule['stateLabel']?.toString();
    if (label != null && label.isNotEmpty) return label;
    return schedule['state']?.toString() ??
        schedule['status']?.toString() ??
        '-';
  }

  Color _stateColor() {
    if (schedule['needsAttention'] == true) return AdminStitchTheme.statusError;
    final state =
        (schedule['state'] ?? schedule['status'])?.toString().toLowerCase() ??
            '';
    switch (state) {
      case 'checked_in':
      case 'settlement_pending':
        return AppTheme.orange600;
      case 'completed':
      case 'done':
        return AdminStitchTheme.emerald;
      case 'pending':
      case 'scheduled':
        return AdminStitchTheme.primary;
      case 'cancelled':
      case 'noshow':
        return AdminStitchTheme.statusError;
      default:
        return AdminStitchTheme.textSecondary;
    }
  }

  String? _attentionReason() {
    final fromApi = schedule['attentionReason']?.toString();
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;
    if (schedule['needsAttention'] != true) return null;
    final date = schedule['date']?.toString();
    final start = schedule['startTime']?.toString();
    if (date == null || start == null) {
      return '예정된 근무 시간이 지났는데 체크인이 없습니다.';
    }
    return '근무 시작($date $start) 후 30분이 지났는데 체크인이 없습니다. '
        '노쇼 처리 또는 상태 확인이 필요합니다.';
  }

  @override
  Widget build(BuildContext context) {
    final spareName = schedule['spare']?['name']?.toString() ?? '-';
    final spareEmail = schedule['spare']?['email']?.toString() ?? '';
    final spareId = schedule['spare']?['id']?.toString();
    final shopName = schedule['shop']?['name']?.toString() ??
        schedule['job']?['shop']?['name']?.toString() ??
        '-';
    final shopId = schedule['shop']?['id']?.toString();
    final jobTitle = schedule['job']?['title']?.toString() ?? '-';
    final jobId = schedule['job']?['id']?.toString();
    final checkIn =
        schedule['checkInTime'] ?? schedule['checkIn'];
    final checkOut = schedule['checkOutTime'];
    final createdAt = schedule['createdAt']?.toString();
    final scheduleId = schedule['id']?.toString() ?? '-';
    final stateColor = _stateColor();
    final attentionReason = _attentionReason();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: AdminStitchTheme.surfaceCard,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AdminStitchTheme.radiusXl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AdminStitchTheme.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AdminStitchTheme.pageMargin,
                    20,
                    AdminStitchTheme.pageMargin,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              spareName,
                              style: AdminStitchTheme.headlineMd,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: stateColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _stateLabel(),
                              style: AdminStitchTheme.labelSm.copyWith(
                                color: stateColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '스케줄 ID · $scheduleId',
                        style: AdminStitchTheme.labelSm.copyWith(
                          color: AdminStitchTheme.textSecondary,
                        ),
                      ),
                      if (attentionReason != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AdminStitchTheme.statusError
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              AdminStitchTheme.radiusLg,
                            ),
                            border: Border.all(
                              color: AdminStitchTheme.statusError
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 20,
                                color: AdminStitchTheme.statusError,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '조치 필요',
                                      style: AdminStitchTheme.bodyMd.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AdminStitchTheme.statusError,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      attentionReason,
                                      style: AdminStitchTheme.bodyMd.copyWith(
                                        color: AdminStitchTheme.textSecondary,
                                        fontSize: 13,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const _SectionTitle('참여자'),
                      const SizedBox(height: 10),
                      _LinkTile(
                        icon: Icons.person_outline,
                        label: '스페어',
                        title: spareName,
                        subtitle: spareEmail.isNotEmpty ? spareEmail : null,
                        onTap: spareId != null
                            ? () {
                                Navigator.pop(context);
                                context.push(
                                  AppRoutes.adminUserDetail(spareId),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 8),
                      _LinkTile(
                        icon: Icons.store_outlined,
                        label: '미용실',
                        title: shopName,
                        onTap: shopId != null
                            ? () {
                                Navigator.pop(context);
                                context.push(
                                  AppRoutes.adminUserDetail(shopId),
                                );
                              }
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const _SectionTitle('근무 정보'),
                      const SizedBox(height: 10),
                      _LinkTile(
                        icon: Icons.work_outline,
                        label: '공고',
                        title: jobTitle,
                        onTap: jobId != null
                            ? () {
                                Navigator.pop(context);
                                context.push(AppRoutes.adminJobDetail(jobId));
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: '근무 일시', value: _workTimeLine()),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: '체크인',
                        value: checkIn != null
                            ? _formatDateTime(checkIn.toString())
                            : '미체크인',
                        valueColor: checkIn == null
                            ? AdminStitchTheme.statusError
                            : null,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: '체크아웃',
                        value: checkOut != null
                            ? _formatDateTime(checkOut.toString())
                            : '-',
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        label: '등록일',
                        value: _formatDateTime(createdAt),
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('관리자 개입'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final ok = await onIntervene('complete');
                                if (ok && context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('강제 완료'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final ok = await onIntervene('cancel');
                                if (ok && context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AdminStitchTheme.statusError,
                              ),
                              child: const Text('강제 취소'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            final ok = await onIntervene('noshow');
                            if (ok && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AdminStitchTheme.statusError,
                          ),
                          child: const Text('노쇼 처리'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AdminStitchTheme.labelSm.copyWith(
        color: AdminStitchTheme.textSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AdminStitchTheme.bodyMd.copyWith(
              color: AdminStitchTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AdminStitchTheme.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
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
      color: AdminStitchTheme.bgSubtle,
      borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AdminStitchTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AdminStitchTheme.labelSm.copyWith(
                        color: AdminStitchTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: AdminStitchTheme.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
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
                  size: 20,
                  color: AdminStitchTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
