/// 톡방 내 전화번호/연락처 공유 방지용 검사 (UX·선제 차단).
/// 보안상 신뢰 가능한 차단은 Chat API 서버에서 동일 규칙으로 적용해야 함.
/// 참고: `docs/SECURITY_PATCH_GUIDE.md` Phase 2.1
library;

class ContactBlocker {
  ContactBlocker._();

  /// 채팅방 상단 배너용 짧은 안내.
  static const String bannerMessage =
      '전화번호, 이메일 등 연락처 공유는 이용약관 위반입니다. '
      'HAIRSPARE 내에서 안전하게 소통해주세요.';

  /// 스낵바 등 짧은 차단 안내 (배너와 동일).
  static const String blockedMessage = bannerMessage;

  static const String _hangulDigitChars = '공일이삼사오육칠팔구영륙';

  static const Map<String, String> _hangulToDigit = {
    '공': '0',
    '영': '0',
    '일': '1',
    '이': '2',
    '삼': '3',
    '사': '4',
    '오': '5',
    '육': '6',
    '륙': '6',
    '칠': '7',
    '팔': '8',
    '구': '9',
  };

  /// 연속 3글자 이상 한글 숫자 읽기만 번호 후보로 추출 (내일·감사·이 등 단어 오탐 방지).
  static final RegExp _hangulDigitRunPattern = RegExp(
    '[$_hangulDigitChars]{3,}',
  );

  /// "150,000원", "20만원" 등 원화 금액 표현 — 채팅 내 가격 협상(결제 요청 등)과
  /// 정면 충돌하는 오탐을 막기 위해 번호 후보 추출 전에 미리 제거한다.
  /// 한 번 협상 메시지에 금액이 섞이면 이후 무관한 메시지(예: "감사합니다")까지
  /// "최근 메시지 합산" 검사에 걸려 대화방이 삭제되는 문제가 있었다.
  static final RegExp _wonAmountPattern = RegExp(r'\d[\d,]*\s*만?\s*원');

  static String _stripWonAmounts(String text) =>
      text.replaceAll(_wonAmountPattern, '');

  /// 단일 메시지 검사
  static bool containsBlockedPattern(String text) {
    if (text.trim().isEmpty) return false;
    return _analyzeDigitStream(_digitRunsFromText(text).join());
  }

  /// 여러 메시지에 나눠 보낸 번호(9475 + 5603 등) 검사
  static bool containsBlockedPatternInRecent(
    Iterable<String> recentMessages, {
    String? pendingMessage,
  }) {
    final parts = <String>[
      ...recentMessages,
      if (pendingMessage != null && pendingMessage.trim().isNotEmpty)
        pendingMessage,
    ];
    if (parts.isEmpty) return false;

    final combinedRuns = parts
        .expand(_digitRunsFromText)
        .join();
    return _analyzeDigitStream(combinedRuns);
  }

  /// 메시지에서 번호 후보 숫자열 목록 추출 (금액 표현은 미리 제외).
  static List<String> _digitRunsFromText(String text) {
    final cleaned = _stripWonAmounts(text);
    final runs = <String>[];

    for (final match in RegExp(r'\d{3,}').allMatches(cleaned)) {
      runs.add(match.group(0)!);
    }

    for (final match in _hangulDigitRunPattern.allMatches(cleaned)) {
      runs.add(_hangulRunToDigits(match.group(0)!));
    }

    return runs;
  }

  static String _hangulRunToDigits(String run) {
    final buffer = StringBuffer();
    for (final ch in run.split('')) {
      final mapped = _hangulToDigit[ch];
      if (mapped != null) buffer.write(mapped);
    }
    return buffer.toString();
  }

  static bool _analyzeDigitStream(String digits) {
    if (digits.isEmpty) return false;

    if (RegExp(r'010\d{7,8}').hasMatch(digits)) return true;
    if (RegExp(r'01[016789]\d{7,8}').hasMatch(digits)) return true;

    if (digits.length >= 8) return true;

    if (digits.length >= 4 && digits.length <= 7) return true;

    if (digits.startsWith('010') && digits.length >= 3) return true;

    return false;
  }

  /// 레거시 호출부 호환 — 한글·기호 포함 원문도 함께 검사 (금액 표현은 미리 제외)
  static bool containsBlockedPatternLegacy(String text) {
    if (text.isEmpty) return false;
    final cleaned = _stripWonAmounts(text);

    if (RegExp(r'010[\s\-]?\d{4}[\s\-]?\d{4}').hasMatch(cleaned)) return true;
    if (RegExp(r'01[0-9][\s\-]?\d{3,4}[\s\-]?\d{4}').hasMatch(cleaned)) {
      return true;
    }

    final digitsOnly = cleaned.replaceAll(RegExp(r'[\s\-\.]'), '');
    if (RegExp(r'\d{8,}').hasMatch(digitsOnly)) return true;
    if (RegExp(r'\d{3}[\s\-]\d{3,4}[\s\-]\d{4}').hasMatch(cleaned)) return true;

    for (final match in _hangulDigitRunPattern.allMatches(cleaned)) {
      if (match.group(0)!.length >= 5) return true;
    }

    if (RegExp(r'[\w\.-]+@[\w\.-]+\.\w+').hasMatch(text)) return true;

    return false;
  }

  /// 단일 + 최근 메시지 + 레거시 규칙 통합
  static bool shouldBlockSend(
    String content, {
    Iterable<String> recentOutgoing = const [],
  }) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;
    if (containsBlockedPatternLegacy(trimmed)) return true;
    if (containsBlockedPattern(trimmed)) return true;
    if (containsBlockedPatternInRecent(recentOutgoing, pendingMessage: trimmed)) {
      return true;
    }
    return false;
  }
}
