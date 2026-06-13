/// 연락처 전송 시도 누적·채팅방 삭제·샵 패널티 정책.
/// 서버 최종 집행 원칙 — mock·클라이언트는 동일 규칙을 미리 적용.
library;

import 'contact_blocker.dart';

enum ContactViolationOutcome {
  /// 시도만 기록 (3회 미만)
  attemptRecorded,

  /// 동일 대화방 3회 적발 → 대화방 삭제
  chatDeleted,

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
    this.shopChatBlockedUntil,
    this.shopJobPostingBlockedUntil,
    this.accountTerminated = false,
  });

  final int attemptCount;
  final int maxAttempts;
  final ContactViolationOutcome outcome;
  final String userMessage;
  final bool chatDeleted;
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

  static const String shopPenaltyNotice =
      '샵이 3회 적발되면 1일간 모든 대화와 공고 등록이 제한됩니다. '
      '동일 사업자가 3회 제재를 받으면 계정이 자동 탈퇴되며 재가입이 불가합니다.';

  static String attemptMessage({
    required int attemptCount,
    required int maxAttempts,
    required bool chatDeleted,
  }) {
    final base = ContactBlocker.blockedMessage;
    if (chatDeleted) {
      return '$base\n연락처 전송 시도 $maxAttempts회가 누적되어 '
          '해당 대화방이 삭제되었습니다.';
    }
    return '$base\n($attemptCount/$maxAttempts회 적발 · '
        '${maxAttempts - attemptCount}회 남음)';
  }
}
