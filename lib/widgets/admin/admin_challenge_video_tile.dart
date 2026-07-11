import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../common/app_network_image.dart';

/// 챌린지 영상 검수 상태 (유튜브 노딱 스타일 포함)
class ChallengeVideoModeration {
  ChallengeVideoModeration._();

  static String statusOf(Map<String, dynamic> video) {
    final raw = video['moderationStatus']?.toString();
    if (raw != null && raw.isNotEmpty) return raw;
    return video['isPublic'] == true ? 'approved' : 'hidden';
  }

  static String label(String status) {
    switch (status) {
      case 'pending':
        return '검수 대기';
      case 'limited':
        return '제한 노출';
      case 'hidden':
        return '숨김';
      case 'approved':
      default:
        return '공개';
    }
  }

  static Color color(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.orange600;
      case 'limited':
        return const Color(0xFFF9A825);
      case 'hidden':
        return AdminStitchTheme.statusError;
      case 'approved':
      default:
        return AdminStitchTheme.emerald;
    }
  }

  static IconData icon(String status) {
    switch (status) {
      case 'pending':
        return Icons.rate_review_outlined;
      case 'limited':
        return Icons.monetization_on;
      case 'hidden':
        return Icons.visibility_off_outlined;
      case 'approved':
      default:
        return Icons.check_circle_outline;
    }
  }

  static int pendingCount(List<Map<String, dynamic>> videos) =>
      videos.where((v) => statusOf(v) == 'pending').length;
}

/// 관리자용 챌린지 영상 타일 — 검수 상태 뱃지 + 숨김/삭제/검수 액션
class AdminChallengeVideoTile extends StatelessWidget {
  const AdminChallengeVideoTile({
    super.key,
    required this.video,
    this.onApprove,
    this.onLimit,
    this.onHide,
    this.onDelete,
    this.onModerate,
  });

  final Map<String, dynamic> video;
  final VoidCallback? onApprove;
  final VoidCallback? onLimit;
  final VoidCallback? onHide;
  final VoidCallback? onDelete;
  final VoidCallback? onModerate;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = video['thumbnailUrl']?.toString();
    final status = ChallengeVideoModeration.statusOf(video);
    final statusColor = ChallengeVideoModeration.color(status);
    final note = video['moderationNote']?.toString();

    return Container(
      padding: const EdgeInsets.all(AdminStitchTheme.stackTight),
      decoration: BoxDecoration(
        color: AdminStitchTheme.bgSubtle,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        border: status == 'limited'
            ? Border.all(color: const Color(0xFFF9A825).withValues(alpha: 0.5), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
                          ? () => showFullScreenImage(context, thumbnailUrl)
                          : null,
                      child: SizedBox(
                        width: 72,
                        height: 48,
                        child: AppNetworkImage(
                          imageUrl: thumbnailUrl,
                          fit: BoxFit.cover,
                          fallbackIcon: Icons.play_circle_outline,
                        ),
                      ),
                    ),
                  ),
                  if (status == 'limited')
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: _YoutubeLimitedBadge(),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title']?.toString() ?? '(제목 없음)',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AdminStitchTheme.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '조회 ${video['views'] ?? 0} · 좋아요 ${video['likes'] ?? 0}',
                      style: AdminStitchTheme.labelSm.copyWith(
                        color: AdminStitchTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusChip(
                      status: status,
                      color: statusColor,
                      icon: ChallengeVideoModeration.icon(status),
                      label: ChallengeVideoModeration.label(status),
                    ),
                    if (note != null && note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AdminStitchTheme.labelSm.copyWith(
                          color: AdminStitchTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (action) {
                  switch (action) {
                    case 'approve':
                      onApprove?.call();
                    case 'limit':
                      onLimit?.call();
                    case 'hide':
                      onHide?.call();
                    case 'delete':
                      onDelete?.call();
                    case 'moderate':
                      onModerate?.call();
                  }
                },
                itemBuilder: (context) => [
                  if (status == 'pending' && onApprove != null)
                    const PopupMenuItem(
                      value: 'approve',
                      child: Text('✓ 승인 (공개)'),
                    ),
                  if (status != 'limited' && onLimit != null)
                    const PopupMenuItem(
                      value: 'limit',
                      child: Text('⚠ 제한 노출 (노딱)'),
                    ),
                  if (status != 'hidden' && onHide != null)
                    const PopupMenuItem(
                      value: 'hide',
                      child: Text('숨김'),
                    ),
                  if (onModerate != null)
                    const PopupMenuItem(
                      value: 'moderate',
                      child: Text('검수 메모…'),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        '삭제',
                        style: TextStyle(color: AdminStitchTheme.statusError),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 유튜브 노딱 느낌 — 노란 원 + $ 아이콘
class _YoutubeLimitedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFFF9A825),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: const Icon(
        Icons.attach_money,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.color,
    required this.icon,
    required this.label,
  });

  final String status;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
