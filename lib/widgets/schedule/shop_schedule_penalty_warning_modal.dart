import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../utils/schedule_cancellation_policy.dart';
import '../common/glass_modal.dart';

/// 샵 일방 취소 누적 패널티 경고 (GlassModal).
abstract final class ShopSchedulePenaltyWarningModal {
  ShopSchedulePenaltyWarningModal._();

  static Future<bool> show({
    required BuildContext context,
    required int cancelCount,
    required ShopCancellationWarningLevel warningLevel,
    DateTime? suspendedUntil,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => GlassModal(
        onDismiss: () => Navigator.pop(ctx, false),
        child: GlassModalPanel(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: GlassModalHeroIcon(
                  emoji: '🚨',
                  size: 64,
                  gradientColors: [
                    Color(0xFFFEE2E2),
                    Color(0xFFFFEDD5),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '일방 취소 패널티 안내',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                _bodyText(
                  cancelCount: cancelCount,
                  warningLevel: warningLevel,
                  suspendedUntil: suspendedUntil,
                ),
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textGray700,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '안내 확인 후 계속',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
    return result == true;
  }

  static String _bodyText({
    required int cancelCount,
    required ShopCancellationWarningLevel warningLevel,
    DateTime? suspendedUntil,
  }) {
    final limit = ScheduleCancellationPolicy.shopUnilateralCancelLimit30d;
    final days = ScheduleCancellationPolicy.shopJobPostingSuspensionDays;

    if (warningLevel == ShopCancellationWarningLevel.suspended &&
        suspendedUntil != null) {
      final until = DateFormat('M월 d일').format(suspendedUntil);
      return '최근 30일 일방 취소가 $cancelCount회입니다. '
          '신규 공고 등록이 $until까지 제한된 상태입니다. '
          '기존 확정 근무 취소는 계속 가능하지만, 취소 시 스페어에게 채팅 알림이 전송됩니다.';
    }

    if (warningLevel == ShopCancellationWarningLevel.suspensionImminent) {
      return '최근 30일 일방 취소 $cancelCount회입니다. '
          '이번 취소 시 누적 $limit회에 도달하여 '
          '${days}일간 신규 공고 등록이 제한됩니다. '
          '스페어 채팅방에 취소 알림이 자동 전송됩니다.';
    }

    return '최근 30일 일방 취소 $cancelCount회입니다. '
        '누적 $limit회 이상 시 ${days}일간 신규 공고 등록이 제한됩니다. '
        '취소 시 공고 에너지·수수료는 환불되지 않을 수 있습니다.';
  }
}
