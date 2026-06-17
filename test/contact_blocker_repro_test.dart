import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/utils/contact_blocker.dart';

void main() {
  test('allows acknowledgement after schedule question', () {
    final recent = ['네, 감사합니다. 내일 2시 출근이 맞나요?'];
    expect(
      ContactBlocker.shouldBlockSend('네 알겠습니다', recentOutgoing: recent),
      isFalse,
    );
  });
}
