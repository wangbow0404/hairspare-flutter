import 'package:dio/dio.dart';

import '../core/di/service_locator.dart';
import '../mocks/mock_matching_data.dart';
import '../utils/api_config.dart';
import '../utils/app_exception.dart';
import '../utils/error_handler.dart';
import 'matching_service.dart';

/// 모델 ↔ 디자이너 매칭 — 채팅방 삭제(나가기) 시 매칭 취소.
class ModelDesignerMatchService {
  final Dio _dio = sl<Dio>();

  bool isModelDesignerChat(String chatId) =>
      MockMatchingData.isModelDesignerChatId(chatId);

  /// 채팅방 삭제 + 매칭 자동 취소 (모델–디자이너 채팅 전용).
  Future<void> deleteChatAndCancelMatch(String chatId) async {
    if (ApiConfig.useMockData) {
      if (!isModelDesignerChat(chatId)) return;
      await sl<MatchingService>().cancelMatchByChatId(chatId);
      return;
    }
    try {
      final response = await _dio.post(
        '/api/model-designer-matches/leave',
        data: {'chatId': chatId},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '매칭 취소 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }
}
