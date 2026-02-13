import 'package:dio/dio.dart';
import '../utils/api_client.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class Chat {
  final String id;
  final String shopId;
  final String shopName;
  final String spareId;
  final String spareName;
  final String? jobId;
  final String? jobTitle;
  final LastMessage? lastMessage;
  final int? unreadCount;

  Chat({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.spareId,
    required this.spareName,
    this.jobId,
    this.jobTitle,
    this.lastMessage,
    this.unreadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id']?.toString() ?? '',
      shopId: json['shopId']?.toString() ?? json['shop']?['id']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? json['shop']?['name']?.toString() ?? '미용실',
      spareId: json['spareId']?.toString() ?? json['spare']?['id']?.toString() ?? '',
      spareName: json['spareName']?.toString() ?? json['spare']?['name']?.toString() ?? '스페어',
      jobId: json['jobId']?.toString(),
      jobTitle: json['jobTitle']?.toString() ?? json['job']?['title']?.toString(),
      lastMessage: json['lastMessage'] != null || json['messages'] != null
          ? LastMessage.fromJson(
              json['lastMessage'] ?? (json['messages'] is List && (json['messages'] as List).isNotEmpty
                  ? (json['messages'] as List)[0]
                  : null))
          : null,
      unreadCount: json['unreadCount'] is int
          ? json['unreadCount']
          : int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
    );
  }
}

class LastMessage {
  final String content;
  final DateTime createdAt;

  LastMessage({
    required this.content,
    required this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }
}

class ChatService {
  final ApiClient _apiClient = ApiClient();

  /// 채팅 목록 조회
  Future<List<Chat>> getChats() async {
    try {
      final response = await _apiClient.dio.get('/api/chats');

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
    try {
      final response = await _apiClient.dio.get('/api/chats/$chatId');

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
  Future<Message> sendMessage(String chatId, String content) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/messages',
        data: {
          'chatId': chatId,
          'content': content,
        },
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

  /// 채팅 삭제
  Future<void> deleteChat(String chatId) async {
    try {
      final response = await _apiClient.dio.delete('/api/chats/$chatId');

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

  ChatWithMessages({
    required this.chat,
    required this.messages,
  });

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

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      chatId: json['chatId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? json['sender']?['id']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? json['sender']?['name']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? json['sender']?['role']?.toString() ?? 'spare',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
