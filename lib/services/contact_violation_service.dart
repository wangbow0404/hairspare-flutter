import 'package:dio/dio.dart';

import '../core/di/service_locator.dart';
import '../mocks/mock_shop_data.dart';
import '../mocks/mock_spare_data.dart';
import '../utils/api_config.dart';
import '../utils/contact_violation_policy.dart';
import '../utils/error_handler.dart';

class ContactViolationService {
  final Dio _dio = sl<Dio>();

  /// 연락처 전송 시도 1회 기록. 3회 시 대화방 삭제·샵 패널티 집행.
  Future<ContactViolationResult> recordAttempt({
    required String chatId,
    required String senderId,
    required String senderRole,
    required String shopId,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.recordContactViolationAttempt(
        chatId: chatId,
        senderId: senderId,
        senderRole: senderRole,
        shopId: shopId,
      );
    }
    try {
      final response = await _dio.post(
        '/api/chats/$chatId/contact-violations',
        data: {
          'senderId': senderId,
          'senderRole': senderRole,
          'shopId': shopId,
        },
      );
      final data = response.data['data'] ?? response.data;
      return ContactViolationResult(
        attemptCount: data['attemptCount'] as int? ?? 1,
        maxAttempts: data['maxAttempts'] as int? ??
            ContactViolationPolicy.maxAttemptsPerChat,
        outcome: ContactViolationOutcome.values.byName(
          data['outcome']?.toString() ?? 'attemptRecorded',
        ),
        userMessage: data['userMessage']?.toString() ?? '',
        chatDeleted: data['chatDeleted'] as bool? ?? false,
        applicationCancelled: data['applicationCancelled'] as bool? ?? false,
        energyForfeited: data['energyForfeited'] as int? ?? 0,
        accountTerminated: data['accountTerminated'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 샵 대화 차단 여부 (mock·서버 공통 진입점).
  void assertSenderCanChat({required String senderRole}) {
    if (senderRole == 'shop') {
      MockShopData.assertCanChat();
    }
  }

  /// 현재 샵 대화 차단 만료 시각 (UI 배너용).
  DateTime? shopChatBlockedUntil() => MockShopData.chatBlockedUntil;
}
