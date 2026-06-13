import '../models/schedule.dart';
import 'schedule_work_session.dart';

/// 스케줄 취소 정책 버전.
enum ScheduleCancellationPolicyVersion {
  /// 근무 시작 24시간 전까지만 앱 취소 허용.
  v1StrictD1,

  /// 확정(scheduled) 일방 취소 — 시작 전까지 허용 + 역할별 패널티.
  v2Unilateral,
}

/// 취소 요청 맥락.
enum CancellationContext {
  overlapResolution,
  scheduleDetail,
  general,
}

/// 취소 주체.
enum CancellationActor {
  spare,
  shop,
}

enum CancellationEligibilityStatus {
  allowed,
  blockedWithinCutoff,
  blockedAfterStart,
  blockedCompleted,
  blockedAlreadyCancelled,
  blockedNotScheduled,
}

enum CancellationPenaltyTier {
  none,
  spareEnergyForfeit,
  shopUnilateral,
}

/// 샵 누적 일방 취소 경고 단계.
enum ShopCancellationWarningLevel {
  none,
  warning,
  suspensionImminent,
  suspended,
}

/// [ScheduleCancellationPolicy.evaluate] 결과.
class CancellationEligibility {
  const CancellationEligibility({
    required this.status,
    this.hoursUntilStart,
    this.penaltySummary,
    this.blockedMessage,
    this.penaltyTier = CancellationPenaltyTier.none,
    this.energyForfeit = 0,
    this.shopWarningLevel = ShopCancellationWarningLevel.none,
    this.shopUnilateralCancelCount30d = 0,
  });

  final CancellationEligibilityStatus status;
  final int? hoursUntilStart;
  final String? penaltySummary;
  final String? blockedMessage;
  final CancellationPenaltyTier penaltyTier;
  final int energyForfeit;
  final ShopCancellationWarningLevel shopWarningLevel;
  final int shopUnilateralCancelCount30d;

  bool get canCancelInApp => status == CancellationEligibilityStatus.allowed;

  String get eligibilityChipLabel => switch (status) {
        CancellationEligibilityStatus.allowed => '취소 가능',
        CancellationEligibilityStatus.blockedWithinCutoff => 'D-1 이내 취소 불가',
        CancellationEligibilityStatus.blockedAfterStart => '근무 시작 후',
        CancellationEligibilityStatus.blockedCompleted => '완료된 근무',
        CancellationEligibilityStatus.blockedAlreadyCancelled => '취소됨',
        CancellationEligibilityStatus.blockedNotScheduled => '확정 전',
      };
}

/// 스케줄 취소 규칙 (클라이언트·mock·API 문서와 동기화).
abstract final class ScheduleCancellationPolicy {
  ScheduleCancellationPolicy._();

  static const ScheduleCancellationPolicyVersion activeVersion =
      ScheduleCancellationPolicyVersion.v2Unilateral;

  /// v1 호환 — v2에서는 미사용(시작 전까지 취소 허용).
  static const int minHoursBeforeCancel = 24;

  static const int shopUnilateralCancelLimit30d = 3;
  static const int shopJobPostingSuspensionDays = 7;

  static const String cancelBlockedCode = 'CANCEL_BLOCKED_WITHIN_CUTOFF';
  static const String cancelBlockedAfterStartCode = 'CANCEL_BLOCKED_AFTER_START';

  static const String consentCheckboxLabel =
      '취소·패널티 안내를 확인했으며, 상대에게 알림이 전송됨에 동의합니다.';

  static List<String> policyBulletLines({
    CancellationActor actor = CancellationActor.spare,
  }) {
    return switch (actor) {
      CancellationActor.spare => [
        '확정된 근무를 취소하면 예약 에너지는 환불되지 않습니다.',
        '취소 시 해당 매장·스페어 채팅방에 자동으로 알림이 전송됩니다.',
        '근무 시작 시각 이후에는 앱에서 취소할 수 없습니다.',
        '무단 결근(노쇼) 시 추가 패널티가 적용될 수 있습니다.',
      ],
      CancellationActor.shop => [
        '확정된 근무를 취소하면 공고에 사용된 에너지·수수료는 환불되지 않을 수 있습니다.',
        '취소 시 스페어 채팅방에 자동으로 알림이 전송됩니다.',
        '최근 30일 일방 취소 ${shopUnilateralCancelLimit30d}회 이상 시 '
        '${shopJobPostingSuspensionDays}일간 신규 공고 등록이 제한됩니다.',
        '근무 시작 시각 이후에는 앱에서 취소할 수 없습니다.',
      ],
    };
  }

  static ShopCancellationWarningLevel shopWarningLevelForCount(int count) {
    if (count >= shopUnilateralCancelLimit30d) {
      return ShopCancellationWarningLevel.suspended;
    }
    if (count >= shopUnilateralCancelLimit30d - 1) {
      return ShopCancellationWarningLevel.suspensionImminent;
    }
    if (count >= 1) {
      return ShopCancellationWarningLevel.warning;
    }
    return ShopCancellationWarningLevel.none;
  }

  static CancellationEligibility evaluate(
    Schedule schedule, {
    CancellationContext context = CancellationContext.general,
    CancellationActor actor = CancellationActor.spare,
    DateTime? now,
    int shopUnilateralCancelCount30d = 0,
    DateTime? shopJobPostingSuspendedUntil,
  }) {
    if (activeVersion == ScheduleCancellationPolicyVersion.v1StrictD1) {
      return _evaluateV1(
        schedule,
        context: context,
        actor: actor,
        now: now,
      );
    }
    return _evaluateV2(
      schedule,
      actor: actor,
      now: now,
      shopUnilateralCancelCount30d: shopUnilateralCancelCount30d,
      shopJobPostingSuspendedUntil: shopJobPostingSuspendedUntil,
    );
  }

  static CancellationEligibility _evaluateV1(
    Schedule schedule, {
    required CancellationContext context,
    required CancellationActor actor,
    DateTime? now,
  }) {
    if (schedule.status == 'cancelled') {
      return const CancellationEligibility(
        status: CancellationEligibilityStatus.blockedAlreadyCancelled,
        blockedMessage: '이미 취소된 일정입니다.',
      );
    }
    if (schedule.status == 'completed' || schedule.checkInTime != null) {
      return const CancellationEligibility(
        status: CancellationEligibilityStatus.blockedCompleted,
        blockedMessage: '완료된 근무는 앱에서 취소할 수 없습니다.',
      );
    }

    final clock = now ?? DateTime.now();
    final start = ScheduleWorkSession.startDateTime(schedule);
    final hoursUntilStart = start.difference(clock).inHours;

    if (hoursUntilStart < minHoursBeforeCancel) {
      final contactHint = actor == CancellationActor.shop
          ? '스페어에게 직접 연락하거나 고객센터에 문의해 주세요.'
          : '매장에 문의해 주세요.';
      return CancellationEligibility(
        status: CancellationEligibilityStatus.blockedWithinCutoff,
        hoursUntilStart: hoursUntilStart,
        blockedMessage:
            '근무 시작 $minHoursBeforeCancel시간 이내에는 앱에서 취소할 수 없습니다. '
            '$contactHint',
      );
    }

    return CancellationEligibility(
      status: CancellationEligibilityStatus.allowed,
      hoursUntilStart: hoursUntilStart,
      penaltySummary:
          '취소 시 예약금(에너지) 환불·패널티는 운영 정책에 따르며, '
          '늦은 취소·노쇼 시 차감될 수 있습니다.',
    );
  }

  static CancellationEligibility _evaluateV2(
    Schedule schedule, {
    required CancellationActor actor,
    DateTime? now,
    required int shopUnilateralCancelCount30d,
    DateTime? shopJobPostingSuspendedUntil,
  }) {
    if (schedule.status == 'cancelled') {
      return const CancellationEligibility(
        status: CancellationEligibilityStatus.blockedAlreadyCancelled,
        blockedMessage: '이미 취소된 일정입니다.',
      );
    }
    if (schedule.status == 'completed' || schedule.checkInTime != null) {
      return const CancellationEligibility(
        status: CancellationEligibilityStatus.blockedCompleted,
        blockedMessage: '완료된 근무는 앱에서 취소할 수 없습니다.',
      );
    }
    if (schedule.status == 'proposed') {
      return const CancellationEligibility(
        status: CancellationEligibilityStatus.blockedNotScheduled,
        blockedMessage: '제안 대기 중인 일정은 수락/거절로 처리해 주세요.',
      );
    }
    if (schedule.status != 'scheduled') {
      return const CancellationEligibility(
        status: CancellationEligibilityStatus.blockedNotScheduled,
        blockedMessage: '확정된 근무만 취소할 수 있습니다.',
      );
    }

    final clock = now ?? DateTime.now();
    final start = ScheduleWorkSession.startDateTime(schedule);
    if (!clock.isBefore(start)) {
      return CancellationEligibility(
        status: CancellationEligibilityStatus.blockedAfterStart,
        hoursUntilStart: start.difference(clock).inHours,
        blockedMessage: '근무가 시작된 후에는 앱에서 취소할 수 없습니다. '
            '매장·고객센터에 문의해 주세요.',
      );
    }

    final hoursUntilStart = start.difference(clock).inHours;
    final energyForfeit = schedule.job?.energy ?? 0;
    final warningLevel = actor == CancellationActor.shop
        ? shopWarningLevelForCount(shopUnilateralCancelCount30d)
        : ShopCancellationWarningLevel.none;

    if (actor == CancellationActor.spare) {
      return CancellationEligibility(
        status: CancellationEligibilityStatus.allowed,
        hoursUntilStart: hoursUntilStart,
        penaltyTier: CancellationPenaltyTier.spareEnergyForfeit,
        energyForfeit: energyForfeit,
        penaltySummary: energyForfeit > 0
            ? '예약 에너지 ${energyForfeit}E는 환불되지 않습니다.'
            : '예약 에너지는 환불되지 않습니다.',
      );
    }

    final suspendedActive = shopJobPostingSuspendedUntil != null &&
        clock.isBefore(shopJobPostingSuspendedUntil);
    final shopSummary = StringBuffer(
      '공고 에너지·수수료는 환불되지 않을 수 있습니다. '
      '최근 30일 일방 취소 ${shopUnilateralCancelCount30d}회',
    );
    if (shopUnilateralCancelCount30d + 1 >= shopUnilateralCancelLimit30d) {
      shopSummary.write(
        ' — 이번 취소 시 ${shopJobPostingSuspensionDays}일간 신규 공고 등록이 제한됩니다.',
      );
    } else {
      shopSummary.write('.');
    }
    if (suspendedActive) {
      shopSummary.write(' (현재 공고 등록 제한 기간입니다.)');
    }

    return CancellationEligibility(
      status: CancellationEligibilityStatus.allowed,
      hoursUntilStart: hoursUntilStart,
      penaltyTier: CancellationPenaltyTier.shopUnilateral,
      energyForfeit: energyForfeit,
      shopWarningLevel: warningLevel,
      shopUnilateralCancelCount30d: shopUnilateralCancelCount30d,
      penaltySummary: shopSummary.toString(),
    );
  }

  static List<Schedule> cancellableFrom(
    Iterable<Schedule> schedules, {
    CancellationContext context = CancellationContext.overlapResolution,
    CancellationActor actor = CancellationActor.spare,
    DateTime? now,
    int shopUnilateralCancelCount30d = 0,
  }) {
    return schedules
        .where(
          (s) => evaluate(
            s,
            context: context,
            actor: actor,
            now: now,
            shopUnilateralCancelCount30d: shopUnilateralCancelCount30d,
          ).canCancelInApp,
        )
        .toList();
  }

  static bool canResolveOverlapByCancellation(
    List<Schedule> conflicts, {
    DateTime? now,
    CancellationActor actor = CancellationActor.spare,
  }) {
    return cancellableFrom(
      conflicts,
      context: CancellationContext.overlapResolution,
      now: now,
      actor: actor,
    ).isNotEmpty;
  }

  static String blockedOverlapMessage() {
    if (activeVersion == ScheduleCancellationPolicyVersion.v1StrictD1) {
      return '겹치는 근무가 모두 근무 시작 $minHoursBeforeCancel시간 이내입니다. '
          '앱에서 취소할 수 없으니 매장에 문의한 뒤 다시 시도해 주세요.';
    }
    return '겹치는 근무를 앱에서 취소할 수 없습니다. '
        '근무 시작 후이거나 확정되지 않은 일정일 수 있습니다. '
        '스케줄표에서 확인해 주세요.';
  }
}
