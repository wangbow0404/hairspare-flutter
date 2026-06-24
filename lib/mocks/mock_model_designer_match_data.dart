import '../models/model_home_data.dart';
import 'mock_matching_data.dart';

/// @deprecated [MockMatchingData]로 위임 — 하위 호환.
abstract final class MockModelDesignerMatchData {
  MockModelDesignerMatchData._();

  static bool isModelDesignerChatId(String chatId) =>
      MockMatchingData.isModelDesignerChatId(chatId);

  static bool hasActiveMatch(String chatId) {
    final matches = MockMatchingData.getMatches(
      modelUserId: MockMatchingData.modelId,
    );
    return matches.any((m) => m.chatId == chatId);
  }

  static String? chatIdForInterest(String interestId) {
    final like = MockMatchingData.getLikeById(interestId);
    return like?.chatId;
  }

  static List<ModelHomeInterest> homeInterests() =>
      MockMatchingData.pendingHomeInterests();

  static Future<void> cancelMatchByChatId(String chatId) async {
    return MockMatchingData.cancelMatchByChatId(chatId);
  }
}
