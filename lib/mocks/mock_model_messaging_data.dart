import '../models/notification.dart';
import '../services/chat_service.dart';

/// 모델 계정 전용 채팅·알림 mock (스페어 공고 채팅과 분리).
abstract final class MockModelMessagingData {
  MockModelMessagingData._();

  static const _modelId = 'mock-model-dev';
  static const _modelName = '모델테스트';

  static final Set<String> _readNotificationIds = {};
  static final Set<String> _dismissedNotificationIds = {};

  static final List<Map<String, dynamic>> _chatsJson = [
    {
      'id': 'model-chat-1',
      'shopId': 'mock-shop-1',
      'shopName': '빌라드블랑 강남점',
      'spareId': _modelId,
      'spareName': _modelName,
      'jobId': 'model-match-1',
      'jobTitle': '전체염색',
      'lastMessage': {
        'content': '내일 2시에 오시면 됩니다',
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 2))
            .toIso8601String(),
      },
      'unreadCount': 1,
    },
    {
      'id': 'model-chat-2',
      'shopId': 'shop-2',
      'shopName': '헤어스튜디오 A',
      'spareId': _modelId,
      'spareName': _modelName,
      'jobId': 'model-match-2',
      'jobTitle': '레이어드 컷',
      'lastMessage': {
        'content': '스타일링 레퍼런스 사진 보내드릴게요',
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
      },
      'unreadCount': 0,
    },
    {
      'id': 'model-chat-3',
      'shopId': 'shop-5',
      'shopName': '스타일리스트 C',
      'spareId': _modelId,
      'spareName': _modelName,
      'jobId': 'model-match-3',
      'jobTitle': '펌 모델',
      'lastMessage': {
        'content': '이번 주 화요일부터 가능하신가요?',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
      },
      'unreadCount': 1,
    },
    {
      'id': 'model-chat-4',
      'shopId': 'shop-6',
      'shopName': '커트 전문샵',
      'spareId': _modelId,
      'spareName': _modelName,
      'jobId': 'model-match-4',
      'jobTitle': '단발 컷',
      'lastMessage': {
        'content': '네, 협력 잘 부탁드려요',
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      'unreadCount': 0,
    },
  ];

  static final Map<String, List<Map<String, dynamic>>> _chatMessages = {
    'model-chat-1': [
      {
        'id': 'model-msg-1-1',
        'chatId': 'model-chat-1',
        'senderId': 'mock-shop-1',
        'senderName': '빌라드블랑 강남점',
        'senderRole': 'shop',
        'content': '안녕하세요! 전체염색 모델 매칭 문의드립니다.',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'isRead': true,
      },
      {
        'id': 'model-msg-1-2',
        'chatId': 'model-chat-1',
        'senderId': _modelId,
        'senderName': _modelName,
        'senderRole': 'model',
        'content': '네, 가능합니다!',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
        'isRead': true,
      },
      {
        'id': 'model-msg-1-3',
        'chatId': 'model-chat-1',
        'senderId': 'mock-shop-1',
        'senderName': '빌라드블랑 강남점',
        'senderRole': 'shop',
        'content': '내일 2시에 오시면 됩니다',
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 2))
            .toIso8601String(),
        'isRead': false,
      },
    ],
    'model-chat-2': [
      {
        'id': 'model-msg-2-1',
        'chatId': 'model-chat-2',
        'senderId': 'shop-2',
        'senderName': '헤어스튜디오 A',
        'senderRole': 'shop',
        'content': '스타일링 레퍼런스 사진 보내드릴게요',
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
        'isRead': true,
      },
    ],
    'model-chat-3': [
      {
        'id': 'model-msg-3-1',
        'chatId': 'model-chat-3',
        'senderId': 'shop-5',
        'senderName': '스타일리스트 C',
        'senderRole': 'shop',
        'content': '이번 주 화요일부터 가능하신가요?',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
        'isRead': false,
      },
    ],
    'model-chat-4': [
      {
        'id': 'model-msg-4-1',
        'chatId': 'model-chat-4',
        'senderId': _modelId,
        'senderName': _modelName,
        'senderRole': 'model',
        'content': '네, 협력 잘 부탁드려요',
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'isRead': true,
      },
    ],
  };

  static bool isModelChatId(String chatId) => chatId.startsWith('model-chat-');

  /// 알림 `relatedUserId`(shopId) → 모델 채팅방 ID.
  static String? findChatIdByShopId(String? shopId) {
    if (shopId == null || shopId.isEmpty) return null;
    for (final chat in _chatsJson) {
      if (chat['shopId']?.toString() == shopId) {
        return chat['id']?.toString();
      }
    }
    return null;
  }

  static String opponentRole(String viewerRole) =>
      viewerRole == 'shop' ? 'model' : 'shop';

  static int _countUnread(String chatId, String viewerRole) {
    final messages = _chatMessages[chatId];
    if (messages == null) return 0;
    final opponent = opponentRole(viewerRole);
    return messages
        .where(
          (m) => m['senderRole'] == opponent && m['isRead'] != true,
        )
        .length;
  }

  static void _syncUnread(String chatId, String viewerRole) {
    final index = _chatsJson.indexWhere((c) => c['id'] == chatId);
    if (index >= 0) {
      _chatsJson[index]['unreadCount'] = _countUnread(chatId, viewerRole);
    }
  }

  static Future<List<Chat>> getChats({String viewerRole = 'model'}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final chat in _chatsJson) {
      _syncUnread(chat['id'] as String, viewerRole);
    }
    return _chatsJson
        .map((j) => Chat.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  static Future<ChatWithMessages> getChatById(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final chatData = Map<String, dynamic>.from(
      _chatsJson.firstWhere(
        (c) => c['id'] == chatId,
        orElse: () => _chatsJson.first,
      ),
    );
    final messages = _chatMessages[chatId] ?? [];
    return ChatWithMessages.fromJson({'chat': chatData, 'messages': messages});
  }

  static Future<void> markChatAsRead(
    String chatId, {
    String viewerRole = 'model',
  }) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final messages = _chatMessages[chatId];
    if (messages != null) {
      final opponent = opponentRole(viewerRole);
      for (final message in messages) {
        if (message['senderRole'] == opponent) {
          message['isRead'] = true;
        }
      }
    }
    _syncUnread(chatId, viewerRole);
  }

  static Future<Message> sendMessage(
    String chatId,
    String content, {
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    final chatIndex = _chatsJson.indexWhere((c) => c['id'] == chatId);
    final Map<String, dynamic>? chat =
        chatIndex >= 0 ? _chatsJson[chatIndex] : null;

    final shopId = chat == null ? null : chat['shopId']?.toString();
    final shopName = chat == null ? null : chat['shopName']?.toString();

    final resolvedRole = senderRole ??
        (senderId != null && senderId == shopId ? 'shop' : 'model');
    final resolvedId = senderId ??
        (resolvedRole == 'shop' ? shopId ?? 'mock-shop-1' : _modelId);
    final resolvedName = senderName ??
        (resolvedRole == 'shop' ? shopName ?? '미용실' : _modelName);

    final messageJson = <String, dynamic>{
      'id': 'model-msg-$chatId-${now.millisecondsSinceEpoch}',
      'chatId': chatId,
      'senderId': resolvedId,
      'senderName': resolvedName,
      'senderRole': resolvedRole,
      'content': content,
      'createdAt': now.toIso8601String(),
      'isRead': true,
    };
    (_chatMessages[chatId] ??= []).add(messageJson);
    if (chatIndex >= 0) {
      _chatsJson[chatIndex]['lastMessage'] = {
        'content': content,
        'createdAt': now.toIso8601String(),
      };
      _chatsJson[chatIndex]['unreadCount'] = 0;
    }
    return Message.fromJson(messageJson);
  }

  static Future<void> deleteChat(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _chatsJson.removeWhere((c) => c['id'] == chatId);
    _chatMessages.remove(chatId);
  }

  /// 매칭 수락 시 채팅방 동적 생성.
  static Future<String> createChatForMatch({
    required String spareId,
    required String spareName,
    required String modelId,
    required String modelName,
    required String jobTitle,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final chatId = 'model-chat-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    _chatsJson.insert(0, {
      'id': chatId,
      'shopId': spareId,
      'shopName': spareName,
      'spareId': modelId,
      'spareName': modelName,
      'jobId': 'model-match-$chatId',
      'jobTitle': jobTitle,
      'lastMessage': {
        'content': '매칭이 성립되었습니다. 대화를 시작해 보세요!',
        'createdAt': now.toIso8601String(),
      },
      'unreadCount': 1,
    });
    _chatMessages[chatId] = [
      {
        'id': 'model-msg-$chatId-welcome',
        'chatId': chatId,
        'senderId': spareId,
        'senderName': spareName,
        'senderRole': 'shop',
        'content': '안녕하세요! 매칭 감사합니다. 일정 조율해 봐요.',
        'createdAt': now.toIso8601String(),
        'isRead': false,
      },
    ];
    return chatId;
  }

  static Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final all = [
      AppNotification.fromJson({
        'id': 'notif-model-1',
        'type': 'model_interest',
        'title': '새 관심',
        'message': '김수민 디자이너님이 전체염색 모델에 관심을 보냈습니다',
        'isRead': false,
        'createdAt': now.subtract(const Duration(minutes: 12)).toIso8601String(),
      }),
      AppNotification.fromJson({
        'id': 'notif-model-2',
        'type': 'schedule_reminder',
        'title': '예약 알림',
        'message': '내일 14:00 빌라드블랑 강남점 전체염색 시술 예정입니다',
        'isRead': false,
        'createdAt': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'scheduleDate':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${(now.day + 1).toString().padLeft(2, '0')}',
      }),
      AppNotification.fromJson({
        'id': 'notif-model-3',
        'type': 'message_received',
        'title': '새 메시지',
        'message': '빌라드블랑 강남점에서 메시지를 보냈습니다',
        'isRead': false,
        'createdAt': now.subtract(const Duration(hours: 3)).toIso8601String(),
        'relatedUserId': 'mock-shop-1',
      }),
      AppNotification.fromJson({
        'id': 'notif-model-4',
        'type': 'deposit_payment',
        'title': '보증금 결제',
        'message': '차홍룸 강남점 예약 보증금 ₩30,000 결제가 완료되었습니다',
        'isRead': true,
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
      }),
    ];
    return all
        .where((n) => !_dismissedNotificationIds.contains(n.id))
        .map(
          (n) => n.copyWith(
            isRead: n.isRead || _readNotificationIds.contains(n.id),
          ),
        )
        .toList();
  }

  static Future<void> markNotificationRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _readNotificationIds.add(notificationId);
  }

  static Future<void> dismissNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _dismissedNotificationIds.add(notificationId);
  }
}
