import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/utils/contact_blocker.dart';

void main() {
  group('ContactBlocker', () {
    test('blocks plain mobile number', () {
      expect(ContactBlocker.shouldBlockSend('01012345678'), isTrue);
      expect(ContactBlocker.shouldBlockSend('010-1234-5678'), isTrue);
    });

    test('blocks hangul digit phone in one message', () {
      expect(
        ContactBlocker.shouldBlockSend('공일공구사칠오'),
        isTrue,
      );
      expect(ContactBlocker.shouldBlockSend('공일공일이삼사오육칠팔'), isTrue);
    });

    test('blocks short digit fragments', () {
      expect(ContactBlocker.shouldBlockSend('9475'), isTrue);
      expect(ContactBlocker.shouldBlockSend('5603'), isTrue);
      expect(ContactBlocker.shouldBlockSend('오육공삼'), isTrue);
    });

    test('blocks split across recent messages', () {
      expect(
        ContactBlocker.shouldBlockSend(
          '5603',
          recentOutgoing: ['9475'],
        ),
        isTrue,
      );
      expect(
        ContactBlocker.shouldBlockSend(
          '구사칠오',
          recentOutgoing: ['공일공', '오육공삼'],
        ),
        isTrue,
      );
    });

    test('allows normal chat', () {
      expect(
        ContactBlocker.shouldBlockSend('내일 2시에 뵙겠습니다'),
        isFalse,
      );
      expect(ContactBlocker.shouldBlockSend('감사합니다!'), isFalse);
    });

    test('allows reply after schedule question (no false positive)', () {
      expect(
        ContactBlocker.shouldBlockSend(
          '네 알겠습니다',
          recentOutgoing: ['네, 감사합니다. 내일 2시 출근이 맞나요?'],
        ),
        isFalse,
      );
    });
  });
}
