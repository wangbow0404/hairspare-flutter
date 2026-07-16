import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../core/router/app_router.dart';
import '../../core/router/app_routes.dart';
import '../../core/router/route_extras.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/chat_service.dart';
import '../../services/contact_violation_service.dart';
import '../../services/model_designer_match_service.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/contact_blocker.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/shell_navigation.dart';
import '../../services/block_service.dart';
import '../../widgets/chat/chat_contact_warning_banner.dart';
import '../../widgets/chat/contact_violation_blocked_modal.dart';
import '../../widgets/chat/payment_request_card.dart';
import '../../widgets/chat/payment_request_compose_sheet.dart';
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
  final PaymentRequestService _paymentRequestService =
      sl<PaymentRequestService>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  Chat? _chat;
  bool _isLoading = true;
  bool _isSending = false;
  final List<String> _recentOutgoingForContactCheck = [];
  static const int _recentOutgoingWindow = 8;
  Timer? _pollTimer;
  bool _isPolling = false;

  String _mySenderRole(User? user) {
    if (user?.role == UserRole.shop) return 'shop';
    if (user?.isModelAccount == true) return 'model';
    return 'spare';
  }

  bool _isMyMessage(Message message, User? currentUser, Chat chat) {
    if (currentUser == null) return false;

    // senderId(보낸 사람 id)가 있으면 그게 정답 — 내 id와 같을 때만 내 메시지다.
    // 예전엔 다를 때 아래 역할·슬롯 추측(fallback)으로 넘어가서, 모델↔디자이너
    // 채팅처럼 모델이 spareId 칸에 들어간 경우 상대(모델) 메시지를 내 것으로
    // 오인해 오른쪽에 표시하는 버그가 있었다. fallback은 senderId가 없을 때만 쓴다.
    if (message.senderId.isNotEmpty) {
      return message.senderId == currentUser.id;
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

  /// 결제요청/상태 메시지 중 같은 paymentId를 가진 더 최신 메시지가 뒤에
  /// 있으면 이미 처리된 것 — 버튼 없이 결과만 보여준다.
  bool _isPaymentActionSuperseded(int index) {
    final paymentId = _messages[index].payload?['paymentId'];
    if (paymentId == null) return false;
    for (var j = index + 1; j < _messages.length; j++) {
      if (_messages[j].payload?['paymentId'] == paymentId) return true;
    }
    return false;
  }

  Future<void> _openPaymentRequestSheet(Chat chat, String otherUserName, String otherUserId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myUserId = authProvider.currentUser?.id;
    if (myUserId == null) return;
    final created = await showPaymentRequestComposeSheet(
      context,
      chatId: chat.id,
      myUserId: myUserId,
      otherUserName: otherUserName,
      otherUserId: otherUserId,
    );
    if (created == true) await _pollNewMessages();
  }

  Future<void> _runPaymentAction(Future<void> Function() action) async {
    try {
      await action();
      await _pollNewMessages();
    } catch (e) {
      if (!mounted) return;
      final ex = ErrorHandler.handleException(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(ex)),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<void> _acceptPayment(String paymentId) =>
      _runPaymentAction(() => _paymentRequestService.acceptPayment(paymentId));

  Future<void> _declinePayment(String paymentId) => _runPaymentAction(
      () => _paymentRequestService.declinePayment(paymentId));

  /// "결제하기" — 채팅에서 바로 결제하지 않고 전용 결제 화면으로 이동한다.
  Future<void> _openPaymentScreen({
    required String paymentId,
    required int amount,
    String? purpose,
    required String counterpartyName,
  }) async {
    final paid = await ShellNavigation.pushPaymentRequestPay(
      context,
      PaymentRequestPayExtra(
        paymentId: paymentId,
        amount: amount,
        purpose: purpose,
        counterpartyName: counterpartyName,
      ),
    );
    if (paid == true) await _pollNewMessages();
  }

  @override
  void initState() {
    super.initState();
    _loadChat();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _pollNewMessages(),
    );
  }

  Future<void> _pollNewMessages() async {
    if (!mounted || _isPolling) return;
    _isPolling = true;
    try {
      final chatWithMessages = await _chatService.getChatById(widget.chatId);
      if (!mounted) return;

      final existingIds = _messages.map((m) => m.id).toSet();
      final incoming = chatWithMessages.messages;
      final hasNew = incoming.any((m) => !existingIds.contains(m.id));
      if (!hasNew) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      final newFromOther = incoming.any(
        (m) => !existingIds.contains(m.id) &&
            !_isMyMessage(m, currentUser, chatWithMessages.chat),
      );

      setState(() {
        _chat = chatWithMessages.chat;
        _messages = incoming;
      });

      if (newFromOther) {
        await context.read<ChatProvider>().markChatAsRead(
              widget.chatId,
              viewerRole: _mySenderRole(currentUser),
            );
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      // 폴링 실패는 조용히 무시 — 다음 주기에 다시 시도
    } finally {
      _isPolling = false;
    }
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

      _startPolling();
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
    final isAdminChat = _chat?.isAdminChat == true;

    if (!isAdminChat) {
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

  Future<void> _handleLeaveChat(BuildContext context, Chat chat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('대화를 종료하시겠습니까?'),
        content: const Text('종료하신 대화는 삭제되며, 다시 확인할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('나가기', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await _chatService.deleteChat(chat.id);
      if (!context.mounted) return;
      Provider.of<ChatProvider>(context, listen: false)
          .removeChatLocally(chat.id);
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      final appException = ErrorHandler.handleException(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Widget _buildAvatarBubble({
    required String? imageUrl,
    required String fallbackLetter,
    required List<Color> gradientColors,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: hasImage
            ? null
            : LinearGradient(colors: gradientColors),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasImage
          ? null
          : Center(
              child: Text(
                fallbackLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
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
    final otherUserAvatarUrl = isShop ? chat.spareProfileImage : chat.shopProfileImage;
    final isModelDesignerChat = _isModelDesignerChat(currentUser);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareAppBar(
        showBackButton: true,
        showSearch: false,
        showTrailingIcons: false,
        title: otherUserName,
        subtitle: jobSubtitle,
        avatarUrl: otherUserAvatarUrl ?? '',
        actions: [
          if (chat.isModelChat)
            IconButton(
              icon: const Icon(Icons.request_quote_outlined),
              tooltip: '결제 요청',
              onPressed: () =>
                  _openPaymentRequestSheet(chat, otherUserName, otherUserId),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '나가기',
            onPressed: () => _handleLeaveChat(context, chat),
          ),
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

                      if (message.type == 'payment_status') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
                          child: Center(
                            child: PaymentStatusBubble(
                              message: message,
                              currentUserId: currentUser?.id ?? '',
                              isSuperseded: _isPaymentActionSuperseded(index),
                              onPay: () {
                                final payload = message.payload ?? const {};
                                final paymentId =
                                    payload['paymentId']?.toString();
                                if (paymentId == null) return Future.value();
                                final amount = payload['amount'];
                                return _openPaymentScreen(
                                  paymentId: paymentId,
                                  amount: amount is int
                                      ? amount
                                      : int.tryParse(
                                              amount?.toString() ?? '') ??
                                          0,
                                  purpose: payload['purpose']?.toString(),
                                  counterpartyName: otherUserName,
                                );
                              },
                            ),
                          ),
                        );
                      }

                      final isPaymentRequest = message.type == 'payment_request';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
                        child: Row(
                          mainAxisAlignment:
                              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMyMessage && showProfile)
                              _buildAvatarBubble(
                                imageUrl: otherUserAvatarUrl,
                                fallbackLetter: message.senderName.isNotEmpty
                                    ? message.senderName[0]
                                    : '?',
                                gradientColors: [
                                  AppTheme.stitchPrimaryContainer,
                                  AppTheme.stitchPrimary,
                                ],
                              )
                            else if (!isMyMessage)
                              const SizedBox(width: 32),
                            const SizedBox(width: AppTheme.spacing2),
                            Flexible(
                              child: isPaymentRequest
                                  ? PaymentRequestCard(
                                      message: message,
                                      currentUserId: currentUser?.id ?? '',
                                      isSuperseded:
                                          _isPaymentActionSuperseded(index),
                                      onAccept: () {
                                        final paymentId = message
                                            .payload?['paymentId']
                                            ?.toString();
                                        if (paymentId == null) return Future.value();
                                        return _acceptPayment(paymentId);
                                      },
                                      onDecline: () {
                                        final paymentId = message
                                            .payload?['paymentId']
                                            ?.toString();
                                        if (paymentId == null) return Future.value();
                                        return _declinePayment(paymentId);
                                      },
                                    )
                                  : Container(
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
                              _buildAvatarBubble(
                                imageUrl: currentUser?.profileImage,
                                fallbackLetter: () {
                                  final name = currentUser?.name;
                                  return (name != null && name.isNotEmpty)
                                      ? name[0]
                                      : '나';
                                }(),
                                gradientColors: const [
                                  AppTheme.primaryPurple,
                                  AppTheme.primaryPurpleDarker,
                                ],
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

