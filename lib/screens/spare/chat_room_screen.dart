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
import '../../services/model_designer_match_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/contact_blocker.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import '../../services/block_service.dart';
import '../../widgets/chat/chat_contact_warning_banner.dart';
import '../../widgets/chat/contact_violation_blocked_modal.dart';
import '../../widgets/common/report_sheet.dart';
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
  final ModelDesignerMatchService _modelDesignerMatchService =
      sl<ModelDesignerMatchService>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  Chat? _chat;
  bool _isLoading = true;
  bool _isSending = false;
  final List<String> _recentOutgoingForContactCheck = [];
  static const int _recentOutgoingWindow = 8;

  String _mySenderRole(User? user) {
    if (user?.role == UserRole.shop) return 'shop';
    if (user?.isModelAccount == true) return 'model';
    return 'spare';
  }

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

    if (currentUser.isModelAccount) {
      return (message.senderRole == 'model' || message.senderRole == 'spare') &&
          (chat.spareId == currentUser.id ||
              message.senderId == chat.spareId);
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

  bool _isModelDesignerChat(User? user) =>
      user?.isModelAccount == true &&
      _modelDesignerMatchService.isModelDesignerChat(widget.chatId);

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

  Future<void> _handleContactViolation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final chat = _chat;
    if (chat == null || currentUser == null) return;

    final myRole = _mySenderRole(currentUser);
    final isShop = myRole == 'shop';
    final result = await _contactViolationService.recordAttempt(
      chatId: widget.chatId,
      senderId: currentUser.id,
      senderRole: myRole,
      shopId: chat.shopId,
    );

    if (!mounted) return;

    await ContactViolationBlockedModal.show(
      context: context,
      result: result,
      isShop: isShop,
    );

    if (!mounted) return;

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
      await _handleContactViolation();
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
    final otherUserId = isShop ? chat.spareId : chat.shopId;
    final shopChatBlockedUntil = isShop
        ? _contactViolationService.shopChatBlockedUntil()
        : null;
    final isShopChatBlocked = shopChatBlockedUntil != null &&
        DateTime.now().isBefore(shopChatBlockedUntil);

    final jobSubtitle = chat.jobTitle?.trim().isNotEmpty == true
        ? chat.jobTitle!
        : null;
    final isModelDesignerChat = _isModelDesignerChat(currentUser);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareAppBar(
        showBackButton: true,
        showSearch: false,
        showTrailingIcons: false,
        title: otherUserName,
        subtitle: jobSubtitle,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'report') {
                await showReportSheet(
                  context,
                  reportedUserId: otherUserId,
                  referenceId: chat.id,
                  referenceType: 'chat',
                );
              } else if (value == 'block') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('차단하기'),
                    content: Text('$otherUserName 님을 차단하시겠습니까?\n차단 후에는 상대방이 회원님을 찾을 수 없습니다.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('차단', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  try {
                    await sl<BlockService>().blockUser(otherUserId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$otherUserName 님이 차단되었습니다')),
                      );
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('차단 실패: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'report', child: Text('신고하기')),
              PopupMenuItem(value: 'block', child: Text('차단하기', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (isModelDesignerChat)
            const _ModelDesignerChatPolicyBanner(),
          if (isShopChatBlocked)
            ChatShopPenaltyBanner(until: shopChatBlockedUntil),
          const ChatContactWarningBanner(),
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
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.stitchPrimaryContainer,
                                      AppTheme.stitchPrimary,
                                    ],
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
                                      ? AppTheme.stitchPrimaryContainer
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
                        borderSide: const BorderSide(color: AppTheme.stitchPrimaryContainer, width: 2),
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
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.stitchPrimaryContainer),
                          ),
                        )
                      : IconMapper.icon('send', size: 24, color: AppTheme.stitchPrimaryContainer) ??
                          const Icon(Icons.send, size: 24, color: AppTheme.stitchPrimaryContainer),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.stitchPrimaryContainer,
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

class _ModelDesignerChatPolicyBanner extends StatelessWidget {
  const _ModelDesignerChatPolicyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      color: AppTheme.surfaceContainerLow,
      child: const Text(
        '매칭된 디자이너와만 대화할 수 있어요. 채팅방을 삭제하면 매칭이 자동으로 취소됩니다.',
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.stitchTextSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

