import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../mocks/mock_shop_data.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';
import '../utils/error_handler.dart';
import '../utils/schedule_cancellation_policy.dart';
import '../utils/schedule_session_audience.dart';
import '../widgets/schedule/schedule_cancel_confirm_sheet.dart';
import '../widgets/schedule/shop_schedule_cancel_reason_sheet.dart';
import '../widgets/schedule/shop_schedule_penalty_warning_modal.dart';

/// 스페어·샵 공통 스케줄 취소 플로우.
abstract final class ScheduleCancelFlow {
  ScheduleCancelFlow._();

  static CancellationEligibility _evaluate(
    Schedule schedule,
    CancellationActor actor, {
    bool isModelMode = false,
  }) {
    final shopState = actor == CancellationActor.shop
        ? MockShopData.shopCancellationState()
        : (count: 0, suspendedUntil: null);
    final audience = ScheduleSessionAudience.fromModelMode(isModelMode);
    return ScheduleCancellationPolicy.evaluate(
      schedule,
      actor: actor,
      shopUnilateralCancelCount30d: shopState.count,
      shopJobPostingSuspendedUntil: shopState.suspendedUntil,
    ).forAudience(audience);
  }

  /// 취소 성공 시 `true`. 취소·변경 요청 없이 닫으면 `false`.
  static Future<bool> requestCancel({
    required BuildContext context,
    required Schedule schedule,
    required CancellationActor actor,
    bool isModelMode = false,
    VoidCallback? onSuccess,
  }) async {
    final messenger = sl<GlobalMessengerService>();
    final eligibility = _evaluate(
      schedule,
      actor,
      isModelMode: isModelMode,
    );

    if (!eligibility.canCancelInApp) {
      messenger.showError(
        eligibility.blockedMessage ??
            ScheduleCancellationPolicy.blockedOverlapMessage(),
      );
      return false;
    }

    if (actor == CancellationActor.shop) {
      if (eligibility.shopWarningLevel != ShopCancellationWarningLevel.none) {
        final warned = await ShopSchedulePenaltyWarningModal.show(
          context: context,
          cancelCount: eligibility.shopUnilateralCancelCount30d,
          warningLevel: eligibility.shopWarningLevel,
          suspendedUntil: MockShopData.jobPostingSuspendedUntil,
        );
        if (!warned || !context.mounted) return false;
      }

      final reasonResult = await ShopScheduleCancelReasonSheet.show(
        context: context,
        scheduleId: schedule.id,
      );
      if (!context.mounted || reasonResult == null) return false;

      if (reasonResult.isRescheduleRequest) {
        return _handleShopReschedule(
          context: context,
          scheduleId: schedule.id,
          cancelReason: reasonResult.cancelReason,
          rescheduleDate: reasonResult.rescheduleDate!,
          onSuccess: onSuccess,
        );
      }

      if (reasonResult.cancelReason == null ||
          reasonResult.cancelReason!.trim().isEmpty) {
        messenger.showError('취소 사유를 입력해 주세요.');
        return false;
      }

      return _confirmAndCancel(
        context: context,
        schedule: schedule,
        actor: actor,
        eligibility: eligibility,
        cancelReason: reasonResult.cancelReason,
        isModelMode: isModelMode,
        onSuccess: onSuccess,
      );
    }

    return _confirmAndCancel(
      context: context,
      schedule: schedule,
      actor: actor,
      eligibility: eligibility,
      isModelMode: isModelMode,
      onSuccess: onSuccess,
    );
  }

  static Future<bool> _handleShopReschedule({
    required BuildContext context,
    required String scheduleId,
    required String? cancelReason,
    required DateTime rescheduleDate,
    VoidCallback? onSuccess,
  }) async {
    final messenger = sl<GlobalMessengerService>();
    try {
      await sl<ScheduleService>().requestScheduleChange(
        scheduleId: scheduleId,
        newDate: rescheduleDate,
        reason: cancelReason,
      );
      if (!context.mounted) return true;
      messenger.showSuccess(
        '스페어에게 일정 변경 요청을 보냈습니다. 수락 시 일정이 변경됩니다.',
      );
      onSuccess?.call();
      return true;
    } catch (e) {
      messenger.showError(
        ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
      );
      return false;
    }
  }

  static Future<bool> _confirmAndCancel({
    required BuildContext context,
    required Schedule schedule,
    required CancellationActor actor,
    required CancellationEligibility eligibility,
    String? cancelReason,
    bool isModelMode = false,
    VoidCallback? onSuccess,
  }) async {
    if (!context.mounted) return false;

    final audience = ScheduleSessionAudience.fromModelMode(isModelMode);

    final agreed = await ScheduleCancelConfirmSheet.show(
      context: context,
      schedulesToCancel: [schedule],
      title: actor == CancellationActor.shop
          ? '스케줄 취소'
          : audience.cancelConfirmTitle(),
      actor: actor,
      eligibility: eligibility,
      isModelMode: isModelMode,
    );
    if (!agreed || !context.mounted) return false;

    final messenger = sl<GlobalMessengerService>();
    try {
      await sl<ScheduleService>().cancelSchedule(
        schedule.id,
        cancelReason: cancelReason,
        actor: actor,
      );
      if (!context.mounted) return true;
      messenger.showSuccess('스케줄이 취소되었습니다.');
      onSuccess?.call();
      return true;
    } catch (e) {
      messenger.showError(
        ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
      );
      return false;
    }
  }
}
