import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/contact_blocker.dart';
import '../../utils/contact_violation_policy.dart';
import '../common/glass_modal.dart';

/// 연락처 공유 시도 차단 시 상세 패널티 안내 모달.
abstract final class ContactViolationBlockedModal {
  ContactViolationBlockedModal._();

  static Future<void> show({
    required BuildContext context,
    required ContactViolationResult result,
    required bool isShop,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final statusLine = ContactViolationPolicy.modalStatusLine(result);
        final detailLines = ContactViolationPolicy.modalDetailLines(
          isShop: isShop,
        );

        return GlassModal(
          onDismiss: () => Navigator.of(dialogContext).pop(),
          child: GlassModalPanel(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassModalHeader(
                  title: '연락처 공유 차단',
                  onClose: () => Navigator.of(dialogContext).pop(),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text('🚨', style: TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 12),
                Text(
                  ContactBlocker.bannerMessage,
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 14),
                ...detailLines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '· ',
                          style: TextStyle(
                            color: AppTheme.urgentRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            line,
                            style: Theme.of(dialogContext)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.textGray700,
                                  height: 1.45,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.urgentRedLight.withValues(alpha: 0.85),
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                    border: Border.all(
                      color: AppTheme.urgentRed.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    statusLine,
                    textAlign: TextAlign.center,
                    style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                          color: AppTheme.urgentRed,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
