/// 톡방 내 전화번호/연락처 공유 방지용 검사
/// 01012345678, 공일공일이삼사오육칠팔, 12345678 등 차단

class ContactBlocker {
  /// 메시지에 전화번호·연락처로 추정되는 패턴이 있는지 검사
  /// 있으면 true (전송 차단)
  static bool containsBlockedPattern(String text) {
    if (text.isEmpty) return false;

    // 010-1234-5678, 01012345678, 010 1234 5678
    if (RegExp(r'010[\s\-]?\d{4}[\s\-]?\d{4}').hasMatch(text)) return true;
    if (RegExp(r'01[0-9]\d{7,8}').hasMatch(text)) return true;

    // 8자리 이상 연속 숫자 (12345678, 1234-5678 등)
    final digitsOnly = text.replaceAll(RegExp(r'[\s\-\.]'), '');
    if (RegExp(r'\d{8,}').hasMatch(digitsOnly)) return true;

    // 3-4-4, 3-3-4 등 전화번호 형식
    if (RegExp(r'\d{3}[\s\-]\d{3,4}[\s\-]\d{4}').hasMatch(text)) return true;

    // 한글 숫자 읽기: 공일공일이삼사오육칠팔, 공일공-일이삼사오육칠팔 등
    const hangulDigits = '공일이삼사오육칠팔구영';
    final hangulOnly = text.split('').where((c) => hangulDigits.contains(c)).join('');
    if (hangulOnly.length >= 8) return true;

    // 이메일 형식
    if (RegExp(r'[\w\.-]+@[\w\.-]+\.\w+').hasMatch(text)) return true;

    return false;
  }

  static const String blockedMessage =
      '전화번호, 이메일 등 연락처 공유는 이용약관 위반입니다. HAIRSPARE 내에서 안전하게 소통해주세요.';
}
