/// 연락처 전송 시도 누적·채팅방 삭제·샵 패널티 정책.
/// 서버 최종 집행 원칙 — mock·클라이언트는 동일 규칙을 미리 적용.
library;

import 'contact_blocker.dart';

enum ContactViolationOutcome {
  /// 시도만 기록 (3회 미만)
  attemptRecorded,

  /// 동일 대화방 3회 적발 → 대화방 삭제
  chatDeleted,

  /// 스페어 3회 적발 → 지원 취소·잠금 에너지 몰수
  applicationCancelled,

  /// 샵 1일 대화·공고 제한
  shopDailyPenalty,

  /// 샵 누적 3회 → 계정 탈퇴·블랙리스트
  shopAccountTerminated,
}

class ContactViolationResult {
  const ContactViolationResult({
    required this.attemptCount,
    required this.maxAttempts,
    required this.outcome,
    required this.userMessage,
    this.chatDeleted = false,
    this.applicationCancelled = false,
    this.energyForfeited = 0,
    this.shopChatBlockedUntil,
    this.shopJobPostingBlockedUntil,
    this.accountTerminated = false,
  });

  final int attemptCount;
  final int maxAttempts;
  final ContactViolationOutcome outcome;
  final String userMessage;
  final bool chatDeleted;
  final bool applicationCancelled;
  final int energyForfeited;
  final DateTime? shopChatBlockedUntil;
  final DateTime? shopJobPostingBlockedUntil;
  final bool accountTerminated;

  int get remainingAttempts =>
      (maxAttempts - attemptCount).clamp(0, maxAttempts);
}

abstract final class ContactViolationPolicy {
  ContactViolationPolicy._();

  static const int maxAttemptsPerChat = 3;
  static const int shopPenaltyDays = 1;
  static const int maxShopRoomPenaltiesBeforeBan = 3;

  static const String chatDeletionNotice =
      '연락처 전송시도 3회 적발시 해당 대화방은 자동으로 삭제됩니다.';

  static const String spareApplicationCancelledNotice =
      '스페어가 3회 적발되면 지원이 취소되며, 잠금된 에너지는 몰수됩니다 '
      '(매장으로 이전되지 않습니다).';

  static const String shopPenaltyNotice =
      '샵이 3회 적발되면 1일간 모든 대화와 공고 등록이 제한됩니다. '
      '동일 사업자가 3회 제재를 받으면 계정이 자동 탈퇴되며 재가입이 불가합니다.';

  static List<String> modalDetailLines({required bool isShop}) {
    return [
      chatDeletionNotice,
      if (!isShop) spareApplicationCancelledNotice,
      if (isShop) shopPenaltyNotice,
    ];
  }

  static String modalStatusLine(ContactViolationResult result) {
    if (result.accountTerminated) {
      return '연락처 공유 위반 누적으로 계정이 탈퇴 처리되었습니다.';
    }
    if (result.applicationCancelled) {
      final energy = result.energyForfeited;
      final energyLine = energy > 0 ? ' 잠금 에너지 $energy개가 몰수되었습니다.' : '';
      return '연락처 전송 시도 ${result.maxAttempts}회가 누적되어 '
          '지원이 취소되었습니다.$energyLine';
    }
    if (result.chatDeleted) {
      return '연락처 전송 시도 ${result.maxAttempts}회가 누적되어 '
          '해당 대화방이 삭제되었습니다.';
    }
    return '${result.attemptCount}/${result.maxAttempts}회 적발 · '
        '${result.remainingAttempts}회 남음';
  }

  static String attemptMessage({
    required int attemptCount,
    required int maxAttempts,
    required bool chatDeleted,
    bool isShop = false,
  }) {
    if (chatDeleted) {
      return modalStatusLine(
        ContactViolationResult(
          attemptCount: attemptCount,
          maxAttempts: maxAttempts,
          outcome: ContactViolationOutcome.chatDeleted,
          userMessage: '',
          chatDeleted: true,
        ),
      );
    }
    final lines = [
      ContactBlocker.bannerMessage,
      ...modalDetailLines(isShop: isShop),
      '($attemptCount/$maxAttempts회 적발 · '
      '${maxAttempts - attemptCount}회 남음)',
    ];
    return lines.join('\n');
  }
}
