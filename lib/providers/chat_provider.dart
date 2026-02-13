import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Chat> _chats = [];
  bool _isLoading = false;
  String? _error;

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
  Future<void> loadChats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chats = await _chatService.getChats();
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
  Future<void> refreshChats() async {
    await loadChats();
  }
}
