import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/admin_stitch_theme.dart';

/// 발송 이력 상세 — 탭 시 보낸 제목·본문·대상 확인.
class AdminNotificationHistoryDetailSheet extends StatelessWidget {
  const AdminNotificationHistoryDetailSheet({
    super.key,
    required this.title,
    required this.body,
    required this.audience,
    required this.recipientCount,
    required this.sentAt,
  });

  final String title;
  final String body;
  final String audience;
  final int recipientCount;
  final String sentAt;

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> item,
  }) {
    final sentAtRaw = item['sentAt']?.toString();
    String sentAtLabel = sentAtRaw ?? '-';
    if (sentAtRaw != null) {
      try {
        sentAtLabel =
            DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(sentAtRaw).toLocal());
      } catch (_) {}
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: AdminNotificationHistoryDetailSheet(
          title: item['title']?.toString() ?? '',
          body: item['body']?.toString() ?? '',
          audience: item['audience']?.toString() ?? '-',
          recipientCount: (item['recipientCount'] as num?)?.toInt() ?? 0,
          sentAt: sentAtLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AdminStitchTheme.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AdminStitchTheme.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('발송 내역', style: AdminStitchTheme.sectionHeader),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                Text(
                  title,
                  style: AdminStitchTheme.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AdminStitchTheme.stackTight),
                Text(
                  '$audience · $recipientCount명 · $sentAt',
                  style: AdminStitchTheme.bodyMd.copyWith(
                    color: AdminStitchTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                Text(
                  '본문',
                  style: AdminStitchTheme.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AdminStitchTheme.stackTight),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
                  decoration: BoxDecoration(
                    color: AdminStitchTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
                    border: Border.all(color: AdminStitchTheme.borderDefault),
                  ),
                  child: Text(
                    body.isEmpty ? '(본문 없음)' : body,
                    style: AdminStitchTheme.bodyMd.copyWith(height: 1.6),
                  ),
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
