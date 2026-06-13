import 'package:flutter/material.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../core/router/app_router.dart';
import '../../core/router/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/chat_service.dart';
import '../../services/contact_violation_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/contact_blocker.dart';
import '../../utils/contact_violation_policy.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/chat/chat_contact_warning_banner.dart';
import '../../widgets/spare_app_bar.dart';

/// Next.js와 동일한 채팅방 화면
class ChatRoomScreen extends StatefulWidget {
  final String chatId;

  const ChatRoomScreen({super.key, required this.chatId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService _chatService = sl<ChatService>();
  final ContactViolationService _contactViolationService =
      sl<ContactViolationService>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  Chat? _chat;
  bool _isLoading = true;
  bool _isSending = false;
  final List<String> _recentOutgoingForContactCheck = [];
  static const int _recentOutgoingWindow = 8;

  String _mySenderRole(User? user) =>
      user?.role == UserRole.shop ? 'shop' : 'spare';

  bool _isMyMessage(Message message, User? currentUser, Chat chat) {
    if (currentUser == null) return false;

    if (message.senderId.isNotEmpty && message.senderId == currentUser.id) {
      return true;
    }

    if (currentUser.role == UserRole.shop) {
      return message.senderRole == 'shop' &&
          (chat.shopId == currentUser.id ||
              message.senderId == chat.shopId);
    }

    return message.senderRole == 'spare' &&
        (chat.spareId == currentUser.id ||
            message.senderId == chat.spareId);
  }

  bool _isSameSender(Message a, Message b) {
    if (a.senderId.isNotEmpty && b.senderId.isNotEmpty) {
      return a.senderId == b.senderId;
    }
    return a.senderRole == b.senderRole;
  }

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChat() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final chatWithMessages = await _chatService.getChatById(widget.chatId);
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      setState(() {
        _chat = chatWithMessages.chat;
        _messages = chatWithMessages.messages;
        _isLoading = false;
        _recentOutgoingForContactCheck
          ..clear()
          ..addAll(
            chatWithMessages.messages
                .where((m) => _isMyMessage(m, currentUser, chatWithMessages.chat))
                .map((m) => m.content)
                .toList()
                .reversed
                .take(_recentOutgoingWindow)
                .toList()
                .reversed,
          );
      });

      await context.read<ChatProvider>().markChatAsRead(
            widget.chatId,
            viewerRole: _mySenderRole(currentUser),
          );

      // 스크롤을 맨 아래로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final appException = ErrorHandler.handleException(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleContactViolation(String content) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final chat = _chat;
    if (chat == null || currentUser == null) return;

    final myRole = _mySenderRole(currentUser);
    final result = await _contactViolationService.recordAttempt(
      chatId: widget.chatId,
      senderId: currentUser.id,
      senderRole: myRole,
      shopId: chat.shopId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.userMessage),
        backgroundColor: AppTheme.urgentRed,
        duration: const Duration(seconds: 5),
      ),
    );

    if (result.accountTerminated) {
      await authProvider.logout();
      if (!mounted) return;
      appRouter.go(AppRoutes.shopLogin);
      return;
    }

    if (result.chatDeleted) {
      context.read<ChatProvider>().removeChatLocally(widget.chatId);
      if (mounted) Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) {
      return;
    }

    final content = _messageController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final myRole = _mySenderRole(currentUser);

    try {
      _contactViolationService.assertSenderCanChat(senderRole: myRole);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorHandler.getUserFriendlyMessage(
                ErrorHandler.handleException(e),
              ),
            ),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      return;
    }

    if (ContactBlocker.shouldBlockSend(
      content,
      recentOutgoing: _recentOutgoingForContactCheck,
    )) {
      await _handleContactViolation(content);
      return;
    }

    _messageController.clear();
    setState(() {
      _isSending = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      final myRole = _mySenderRole(currentUser);
      final newMessage = await _chatService.sendMessage(
        widget.chatId,
        content,
        senderId: currentUser?.id,
        senderName: currentUser?.name,
        senderRole: myRole,
      );
      
      setState(() {
        _messages.add(newMessage);
        _isSending = false;
        _recentOutgoingForContactCheck.add(content);
        if (_recentOutgoingForContactCheck.length > _recentOutgoingWindow) {
          _recentOutgoingForContactCheck.removeAt(0);
        }
      });

      // 스크롤을 맨 아래로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return '방금 전';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    }
    
    return DateFormat('M월 d일', 'ko_KR').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SpareAppBar(
          showBackButton: true,
          showSearch: false,
          showTrailingIcons: false,
          title: '채팅',
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_chat == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SpareAppBar(
          showBackButton: true,
          showSearch: false,
          showTrailingIcons: false,
          title: '채팅',
        ),
        body: Center(
          child: Text('채팅방을 찾을 수 없습니다.'),
        ),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final chat = _chat!;
    final isShop = currentUser?.role == UserRole.shop;
    final otherUserName = isShop ? chat.spareName : chat.shopName;
    final shopChatBlockedUntil = isShop
        ? _contactViolationService.shopChatBlockedUntil()
        : null;
    final isShopChatBlocked = shopChatBlockedUntil != null &&
        DateTime.now().isBefore(shopChatBlockedUntil);

    final jobSubtitle = chat.jobTitle?.trim().isNotEmpty == true
        ? chat.jobTitle!
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareAppBar(
        showBackButton: true,
        showSearch: false,
        showTrailingIcons: false,
        title: otherUserName,
        subtitle: jobSubtitle,
      ),
      body: Column(
        children: [
          if (isShopChatBlocked)
            ChatShopPenaltyBanner(until: shopChatBlockedUntil),
          ChatContactWarningBanner(
            extraLine: isShop ? ContactViolationPolicy.shopPenaltyNotice : null,
            tint: isShop ? AppTheme.urgentRed : AppTheme.orange500,
          ),
          // 메시지 목록
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      '아직 메시지가 없습니다. 대화를 시작해보세요!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMyMessage =
                          _isMyMessage(message, currentUser, chat);
                      final prevMessage = index > 0 ? _messages[index - 1] : null;
                      final showProfile = prevMessage == null ||
                          !_isSameSender(prevMessage, message);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
                        child: Row(
                          mainAxisAlignment:
                              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMyMessage && showProfile)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                                  ),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                ),
                                child: Center(
                                  child: Text(
                                    message.senderName.isNotEmpty
                                        ? message.senderName[0]
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else if (!isMyMessage)
                              const SizedBox(width: 32),
                            const SizedBox(width: AppTheme.spacing2),
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: AppTheme.spacing(AppTheme.spacing3),
                                decoration: BoxDecoration(
                                  color: isMyMessage
                                      ? AppTheme.primaryBlue
                                      : AppTheme.backgroundWhite,
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                  border: isMyMessage
                                      ? null
                                      : Border.all(color: AppTheme.borderGray),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMyMessage && showProfile)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: AppTheme.spacing1),
                                        child: Text(
                                          message.senderName,
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isMyMessage
                                                ? Colors.white.withValues(alpha: 0.7)
                                                : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      message.content,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: isMyMessage ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing1 / 2),
                                    Text(
                                      _formatTime(message.createdAt),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        fontSize: 12,
                                        color: isMyMessage
                                            ? Colors.white.withValues(alpha: 0.7)
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            if (isMyMessage && showProfile)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.primaryPurple, AppTheme.primaryPurpleDarker],
                                  ),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                ),
                                child: Center(
                                    child: Text(
                                        () {
                                          final name = authProvider.currentUser?.name;
                                          return (name != null && name.isNotEmpty) ? name[0] : '나';
                                        }(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else if (isMyMessage)
                              const SizedBox(width: 32),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // 메시지 입력
          Container(
            padding: AppTheme.spacing(AppTheme.spacing3),
            decoration: const BoxDecoration(
              color: AppTheme.backgroundWhite,
              border: Border(
                top: BorderSide(color: AppTheme.borderGray),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !isShopChatBlocked,
                    decoration: InputDecoration(
                      hintText: isShopChatBlocked
                          ? '대화 제한 중입니다'
                          : '메시지를 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        borderSide: const BorderSide(color: AppTheme.borderGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        borderSide: const BorderSide(color: AppTheme.borderGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                      ),
                      contentPadding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing2,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundGray,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                IconButton(
                  onPressed: (_isSending || isShopChatBlocked)
                      ? null
                      : _sendMessage,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                          ),
                        )
                      : IconMapper.icon('send', size: 24, color: AppTheme.primaryBlue) ??
                          const Icon(Icons.send, size: 24, color: AppTheme.primaryBlue),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: AppTheme.spacing(AppTheme.spacing2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

