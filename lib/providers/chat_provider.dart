import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import '../utils/error_handler.dart';

class ChatProvider with ChangeNotifier {
  ChatProvider(this._chatService);

  final ChatService _chatService;
  List<Chat> _chats = [];
  bool _isLoading = false;
  String? _error;
  String _viewerRole = 'spare';

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 읽지 않은 메시지 총 개수
  int get totalUnreadCount {
    return _chats.fold<int>(
      0,
      (sum, chat) => sum + (chat.unreadCount ?? 0),
    );
  }

  /// 채팅 목록 로드
  Future<void> loadChats({String viewerRole = 'spare'}) async {
    _viewerRole = viewerRole;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chats = await _chatService.getChats(viewerRole: viewerRole);
      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _chats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 채팅 목록 새로고침
  Future<void> refreshChats({String? viewerRole}) async {
    await loadChats(viewerRole: viewerRole ?? _viewerRole);
  }

  /// 목록에서 채팅 제거 (mock 삭제·UI 동기화).
  void removeChatLocally(String chatId) {
    _chats = _chats.where((c) => c.id != chatId).toList();
    notifyListeners();
  }

  /// 채팅방 진입 후 읽음 — 배지·목록 미읽음 수 갱신.
  Future<void> markChatAsRead(
    String chatId, {
    String? viewerRole,
  }) async {
    final role = viewerRole ?? _viewerRole;
    try {
      await _chatService.markChatAsRead(chatId, viewerRole: role);
      _chats = _chats
          .map(
            (chat) => chat.id == chatId
                ? Chat(
                    id: chat.id,
                    shopId: chat.shopId,
                    shopName: chat.shopName,
                    spareId: chat.spareId,
                    spareName: chat.spareName,
                    jobId: chat.jobId,
                    jobTitle: chat.jobTitle,
                    lastMessage: chat.lastMessage,
                    unreadCount: 0,
                  )
                : chat,
          )
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider.markChatAsRead: $e');
    }
  }
}
