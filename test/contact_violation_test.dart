import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/mocks/mock_auth_data.dart';
import 'package:hairspare/mocks/mock_shop_data.dart';
import 'package:hairspare/mocks/mock_spare_data.dart';
import 'package:hairspare/utils/contact_violation_policy.dart';

void main() {
  group('Contact violation enforcement', () {
    setUp(() {
      MockSpareData.resetContactViolationEnforcementState();
      MockShopData.chatBlockedUntil = null;
      MockShopData.jobPostingSuspendedUntil = null;
      MockShopData.contactViolationRoomCount = 0;
      MockAuthData.isShopAccountTerminated = false;
      MockAuthData.blacklistedBusinessIdentifiers.clear();
    });

    test('records attempts until chat deleted at 3', () async {
      const chatId = 'chat-violation-attempt-only';
      MockSpareData.registerTestChat(chatId: chatId);
      for (var i = 1; i <= 2; i++) {
        final r = await MockSpareData.recordContactViolationAttempt(
          chatId: chatId,
          senderId: 'mock-spare-1',
          senderRole: 'spare',
          shopId: 'mock-shop-1',
        );
        expect(r.attemptCount, i);
        expect(r.chatDeleted, isFalse);
      }

      final third = await MockSpareData.recordContactViolationAttempt(
        chatId: chatId,
        senderId: 'mock-spare-1',
        senderRole: 'spare',
        shopId: 'mock-shop-1',
      );
      expect(third.chatDeleted, isTrue);
      expect(third.applicationCancelled, isFalse);
      final chats = await MockSpareData.getChats();
      expect(chats.any((c) => c.id == chatId), isFalse);
    });

    test('shop third strike applies daily penalty', () async {
      final result = await MockSpareData.recordContactViolationAttempt(
        chatId: 'chat-mock-2',
        senderId: 'mock-shop-1',
        senderRole: 'shop',
        shopId: 'mock-shop-1',
      );
      // Need 3 attempts - call 2 more times on same chat
      await MockSpareData.recordContactViolationAttempt(
        chatId: 'chat-mock-2',
        senderId: 'mock-shop-1',
        senderRole: 'shop',
        shopId: 'mock-shop-1',
      );
      final third = await MockSpareData.recordContactViolationAttempt(
        chatId: 'chat-mock-2',
        senderId: 'mock-shop-1',
        senderRole: 'shop',
        shopId: 'mock-shop-1',
      );

      expect(third.chatDeleted, isTrue);
      expect(MockShopData.contactViolationRoomCount, 1);
      expect(MockShopData.chatBlockedUntil, isNotNull);
      expect(MockShopData.jobPostingSuspendedUntil, isNotNull);
      expect(third.outcome, ContactViolationOutcome.shopDailyPenalty);
      expect(result, isNotNull);
    });

    test('shop third room penalty terminates account and blacklists', () {
      MockShopData.contactViolationRoomCount = 2;
      final result = MockShopData.applyContactViolationPenalty('mock-shop-1');

      expect(result.accountTerminated, isTrue);
      expect(MockAuthData.isShopAccountTerminated, isTrue);
      expect(MockAuthData.blacklistedBusinessIdentifiers, isNotEmpty);
      expect(
        () => MockAuthData.assertCanRegisterShop(username: '2'),
        throwsA(isA<Exception>()),
      );
    });
    test('spare third strike cancels application and bans re-contact', () async {
      final jobId = MockSpareData.overlapDemoJobId;
      final chatId = 'chat-job-$jobId';
      MockSpareData.registerTestChat(chatId: chatId, jobId: jobId);
      await MockShopData.addApplication(
        jobId: jobId,
        spare: {
          'id': 'mock-spare-1',
          'username': 'spare1',
          'name': '테스트 스페어',
          'email': 'spare@test.com',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      MockSpareData.recordLockedEnergyForJobApplication(
        jobId: jobId,
        spareId: 'mock-spare-1',
        amount: 2,
      );

      for (var i = 0; i < 2; i++) {
        await MockSpareData.recordContactViolationAttempt(
          chatId: chatId,
          senderId: 'mock-spare-1',
          senderRole: 'spare',
          shopId: 'mock-shop-1',
        );
      }

      final third = await MockSpareData.recordContactViolationAttempt(
        chatId: chatId,
        senderId: 'mock-spare-1',
        senderRole: 'spare',
        shopId: 'mock-shop-1',
      );

      expect(third.applicationCancelled, isTrue);
      expect(third.chatDeleted, isTrue);
      expect(
        MockSpareData.isContactBannedForJob(
          jobId: jobId,
          spareId: 'mock-spare-1',
        ),
        isTrue,
      );
      final status = await MockShopData.spareApplicationStatusForJob(
        jobId: jobId,
        spareId: 'mock-spare-1',
      );
      expect(status, 'cancelled_contact_violation');
      expect(
        () => MockSpareData.ensureChatForJobApplication(
          jobId: jobId,
          jobTitle: '테스트 공고',
          shopName: '테스트 샵',
          spareId: 'mock-spare-1',
          spareName: '테스트 스페어',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
