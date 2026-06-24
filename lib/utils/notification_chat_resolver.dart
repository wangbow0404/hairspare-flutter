import '../mocks/mock_model_messaging_data.dart';
import '../mocks/mock_spare_data.dart';
import '../models/notification.dart';

/// 알림의 `relatedUserId` 등으로 채팅방 ID를 찾는다.
abstract final class NotificationChatResolver {
  NotificationChatResolver._();

  static String? resolveChatId(
    AppNotification notification, {
    required String audience,
  }) {
    final shopId = notification.relatedUserId?.trim();
    if (shopId == null || shopId.isEmpty) return null;

    return switch (audience) {
      'model' => MockModelMessagingData.findChatIdByShopId(shopId),
      'shop' =>
        MockSpareData.findChatIdBySpareId(shopId) ??
            MockSpareData.findChatIdByShopId(shopId),
      _ => MockSpareData.findChatIdByShopId(shopId),
    };
  }
}
