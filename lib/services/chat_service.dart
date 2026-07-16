import 'package:dio/dio.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';
import '../mocks/mock_spare_data.dart';
import '../models/schedule.dart';
import '../mocks/mock_shop_data.dart';
import '../utils/schedule_cancellation_policy.dart';
import '../core/di/service_locator.dart';

class Chat {
  final String id;
  final String shopId;
  final String shopName;
  final String? shopProfileImage;
  final String spareId;
  final String spareName;
  final String? spareProfileImage;
  final String? jobId;
  final String? jobTitle;
  final LastMessage? lastMessage;
  final int? unreadCount;
  final bool isAdminChat;
  final bool isModelChat;

  Chat({
    required this.id,
    required this.shopId,
    required this.shopName,
    this.shopProfileImage,
    required this.spareId,
    required this.spareName,
    this.spareProfileImage,
    this.jobId,
    this.jobTitle,
    this.lastMessage,
    this.unreadCount,
    this.isAdminChat = false,
    this.isModelChat = false,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id']?.toString() ?? '',
      shopId:
          json['shopId']?.toString() ?? json['shop']?['id']?.toString() ?? '',
      shopName:
          json['shopName']?.toString() ??
          json['shop']?['name']?.toString() ??
          '미용실',
      shopProfileImage:
          json['shopProfileImage']?.toString() ??
          json['shop']?['profileImage']?.toString(),
      spareId:
          json['spareId']?.toString() ?? json['spare']?['id']?.toString() ?? '',
      spareName:
          json['spareName']?.toString() ??
          json['spare']?['name']?.toString() ??
          '스페어',
      spareProfileImage:
          json['spareProfileImage']?.toString() ??
          json['spare']?['profileImage']?.toString(),
      jobId: json['jobId']?.toString(),
      jobTitle:
          json['jobTitle']?.toString() ?? json['job']?['title']?.toString(),
      lastMessage: () {
        final data =
            json['lastMessage'] ??
            (json['messages'] is List && (json['messages'] as List).isNotEmpty
                ? (json['messages'] as List)[0]
                : null);
        return data != null
            ? LastMessage.fromJson(Map<String, dynamic>.from(data as Map))
            : null;
      }(),
      unreadCount: json['unreadCount'] is int
          ? json['unreadCount']
          : int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
      isAdminChat: json['isAdminChat'] == true,
      isModelChat: json['isModelChat'] == true,
    );
  }
}

class LastMessage {
  final String content;
  final DateTime createdAt;

  LastMessage({required this.content, required this.createdAt});

  factory LastMessage.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LastMessage(content: '', createdAt: DateTime.now());
    }
    return LastMessage(
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ChatService {
  final Dio _dio = sl<Dio>();

  /// 채팅 목록 조회
  Future<List<Chat>> getChats({String viewerRole = 'spare'}) async {
    if (ApiConfig.useMockData) {
      return await MockSpareData.getChats(viewerRole: viewerRole);
    }
    try {
      final response = await _dio.get('/api/chats');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> chatsJson = data is List
            ? data
            : (data is Map && data['chats'] != null
                  ? (data['chats'] as List)
                  : []);
        return chatsJson
            .whereType<Map<String, dynamic>>()
            .map((json) => Chat.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          '채팅 목록 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 채팅방 정보 조회 (메시지 포함)
  Future<ChatWithMessages> getChatById(String chatId) async {
    if (ApiConfig.useMockData) return await MockSpareData.getChatById(chatId);
    try {
      final response = await _dio.get('/api/chats/$chatId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return ChatWithMessages.fromJson(data);
      } else {
        throw ServerException(
          '채팅방 조회 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 메시지 전송
  Future<Message> sendMessage(
    String chatId,
    String content, {
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    if (senderRole == 'shop') {
      MockShopData.assertCanChat();
    }
    if (ApiConfig.useMockData) {
      return MockSpareData.sendMessage(
        chatId,
        content,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
      );
    }
    try {
      final response = await _dio.post(
        '/api/messages',
        data: {'chatId': chatId, 'content': content},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return Message.fromJson(data);
      } else {
        throw ServerException(
          '메시지 전송 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 확정 근무 취소 시 상대 채팅방에 시스템 알림.
  Future<void> sendScheduleCancellationNotice({
    required Schedule schedule,
    required CancellationActor actor,
    String? cancelReason,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.sendScheduleCancellationNotice(
        schedule: schedule,
        actor: actor,
        cancelReason: cancelReason,
      );
    }
    try {
      await _dio.post(
        '/api/schedules/${schedule.id}/cancel-notice',
        data: {
          'actor': actor.name,
          if (cancelReason != null && cancelReason.isNotEmpty)
            'cancelReason': cancelReason,
        },
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공고 지원·연락용 채팅방 (없으면 생성).
  Future<String> ensureChatForJobApplication({
    required String jobId,
    required String jobTitle,
    required String shopName,
    required String spareId,
    required String spareName,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.ensureChatForJobApplication(
        jobId: jobId,
        jobTitle: jobTitle,
        shopName: shopName,
        spareId: spareId,
        spareName: spareName,
      );
    }
    try {
      final response = await _dio.post(
        '/api/chats/ensure',
        data: {
          'jobId': jobId,
          'jobTitle': jobTitle,
          'shopName': shopName,
          'spareId': spareId,
          'spareName': spareName,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final chatId = data['chatId']?.toString() ?? data['id']?.toString();
        if (chatId != null && chatId.isNotEmpty) return chatId;
      }
      throw ServerException(
        '채팅방 생성 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 모델 매칭 성공 시 모델과의 채팅방 (없으면 생성).
  Future<String> ensureChatForModel({
    required String modelId,
    required String modelName,
    required String spareId,
    required String spareName,
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.ensureChatForModel(
        modelId: modelId,
        modelName: modelName,
        spareId: spareId,
        spareName: spareName,
      );
    }
    try {
      // 백엔드 /api/chats/ensure는 jobId 없이 shopId·spareId만 보내면
      // 1:1 채팅방을 찾거나 만든다. shopId는 생략하면 호출자(현재 로그인 사용자)로
      // 자동 채워지므로, 모델은 항상 spareId 슬롯에 넣어주면 된다.
      final response = await _dio.post(
        '/api/chats/ensure',
        data: {
          'spareId': modelId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final chatId = data['chatId']?.toString() ?? data['id']?.toString();
        if (chatId != null && chatId.isNotEmpty) return chatId;
      }
      throw ServerException(
        '채팅방 생성 실패: ${response.statusMessage}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 공간 대여 스케줄에 연결된 채팅방 id 조회.
  Future<String?> findChatIdForSpaceSchedule(Schedule schedule) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.findChatIdForSpaceSchedule(schedule);
    }
    try {
      final response = await _dio.get('/api/schedules/${schedule.id}/chat');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['chatId']?.toString();
      }
      return null;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 채팅방 읽음 처리
  Future<void> markChatAsRead(
    String chatId, {
    String viewerRole = 'spare',
  }) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.markChatAsRead(chatId, viewerRole: viewerRole);
    }
    try {
      final response = await _dio.post('/api/chats/$chatId/read');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '읽음 처리 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioException(e);
    } catch (e) {
      throw ErrorHandler.handleException(e);
    }
  }

  /// 채팅 삭제
  Future<void> deleteChat(String chatId) async {
    if (ApiConfig.useMockData) {
      return MockSpareData.deleteChat(chatId);
    }
    try {
      final response = await _dio.delete('/api/chats/$chatId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          '채팅 삭제 실패: ${response.statusMessage}',
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

class ChatWithMessages {
  final Chat chat;
  final List<Message> messages;

  ChatWithMessages({required this.chat, required this.messages});

  factory ChatWithMessages.fromJson(Map<String, dynamic> json) {
    final chatData = json['chat'] ?? json;
    final messagesData = json['messages'] ?? [];

    return ChatWithMessages(
      chat: Chat.fromJson(chatData),
      messages: (messagesData as List)
          .whereType<Map<String, dynamic>>()
          .map((msgJson) => Message.fromJson(msgJson))
          .toList(),
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'spare' | 'shop'
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String? type; // null | 'payment_request' | 'payment_status'
  final Map<String, dynamic>? payload;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.createdAt,
    this.isRead = false,
    this.type,
    this.payload,
  });

  factory Message.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Message(
        id: '',
        chatId: '',
        senderId: '',
        senderName: '',
        senderRole: 'spare',
        content: '',
        createdAt: DateTime.now(),
      );
    }
    return Message(
      id: json['id']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      senderId:
          json['senderId']?.toString() ??
          json['sender']?['id']?.toString() ??
          '',
      senderName:
          json['senderName']?.toString() ??
          json['sender']?['name']?.toString() ??
          '',
      senderRole:
          json['senderRole']?.toString() ??
          json['sender']?['role']?.toString() ??
          'spare',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type']?.toString(),
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
    );
  }
}
