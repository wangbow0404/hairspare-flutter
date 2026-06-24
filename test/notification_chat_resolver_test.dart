import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/models/notification.dart';
import 'package:hairspare/utils/notification_chat_resolver.dart';

void main() {
  test('model message notification resolves chat by shop id', () {
    final notification = AppNotification.fromJson({
      'id': 'n1',
      'type': 'message_received',
      'title': '새 메시지',
      'message': '빌라드블랑 강남점에서 메시지를 보냈습니다',
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
      'relatedUserId': 'mock-shop-1',
    });

    expect(
      NotificationChatResolver.resolveChatId(
        notification,
        audience: 'model',
      ),
      'model-chat-1',
    );
  });

  test('spare message notification resolves chat by shop id', () {
    final notification = AppNotification.fromJson({
      'id': 'n2',
      'type': 'message_received',
      'title': '새 메시지',
      'message': '빌라드블랑 강남점에서 메시지를 보냈습니다',
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
      'relatedUserId': 'mock-shop-1',
    });

    expect(
      NotificationChatResolver.resolveChatId(
        notification,
        audience: 'spare',
      ),
      'chat-mock-1',
    );
  });
}
