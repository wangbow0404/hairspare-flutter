import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/chat_service.dart';
import '../../services/model_designer_match_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_segment_tabs.dart';
import '../../utils/messaging_audience.dart';
import '../../utils/messaging_navigation.dart';

/// 스페어 메시지(채팅) 목록 — [ChatProvider]와 동일한 mock/API 데이터 사용.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _activeTab = 'all';
  String? _swipedChatId;
  final ChatService _chatService = sl<ChatService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final audience = MessagingAudience.resolve(context);
      context.read<ChatProvider>().refreshChats(viewerRole: audience);
    });
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';

    return DateFormat('M월 d일', 'ko_KR').format(date);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ChatProvider chatProvider,
    String chatId, {
    required bool isModelDesignerChat,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isModelDesignerChat ? '채팅방 나가기' : '채팅방 삭제'),
        content: Text(
          isModelDesignerChat
              ? '채팅방을 삭제하면 매칭이 자동으로 취소됩니다.'
              : '이 채팅방을 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.urgentRed,
            ),
            child: Text(isModelDesignerChat ? '나가기' : '삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      if (isModelDesignerChat) {
        await sl<ModelDesignerMatchService>().deleteChatAndCancelMatch(chatId);
      } else {
        await _chatService.deleteChat(chatId);
      }
      if (!mounted) return;
      chatProvider.removeChatLocally(chatId);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isModelDesignerChat
                ? '채팅방을 나갔습니다. 매칭이 취소되었습니다.'
                : '채팅방이 삭제되었습니다',
          ),
          backgroundColor: AppTheme.stitchPrimaryContainer,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final appException = ErrorHandler.handleException(error);
      messenger.showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (chatProvider.isLoading && chatProvider.chats.isEmpty) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundGray,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (chatProvider.error != null && chatProvider.chats.isEmpty) {
          final audience = MessagingAudience.resolve(context);
          return Scaffold(
            backgroundColor: AppTheme.backgroundGray,
            appBar: const SpareSubpageAppBar(
              title: '메시지',
              showBackButton: true,
            ),
            body: StitchEmptyState(
              message: chatProvider.error!,
              iconName: 'alertcircle',
              actionLabel: '다시 시도',
              onAction: () =>
                  chatProvider.refreshChats(viewerRole: audience),
            ),
          );
        }

        final filteredChats = _activeTab == 'unread'
            ? chatProvider.chats
                .where((chat) => (chat.unreadCount ?? 0) > 0)
                .toList()
            : chatProvider.chats;

        final tabIndex = _activeTab == 'unread' ? 1 : 0;
        final audience = MessagingAudience.resolve(context);
        final isModelMessaging = audience == 'model';

        return Scaffold(
          backgroundColor: AppTheme.backgroundGray,
          appBar: SpareSubpageAppBar(
            title: '메시지',
            showBackButton: Navigator.canPop(context),
          ),
          body: Column(
            children: [
              if (isModelMessaging) const _ModelMessagingPolicyBanner(),
              StitchSegmentTabs(
                tabs: const ['전체', '안 읽음'],
                activeIndex: tabIndex,
                onChanged: (index) {
                  setState(() => _activeTab = index == 1 ? 'unread' : 'all');
                },
              ),
              Expanded(
                child: filteredChats.isEmpty
                    ? StitchEmptyState(
                        message: _activeTab == 'unread'
                            ? '읽지 않은 메시지가 없습니다'
                            : isModelMessaging
                                ? '매칭된 디자이너와의 대화가 없습니다'
                                : '메시지가 없습니다',
                        iconName: 'messagecircle',
                      )
                    : ListView.builder(
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          return _ChatListItem(
                            chat: chat,
                            isSwiped: _swipedChatId == chat.id,
                            onTap: () {
                              if (_swipedChatId != null &&
                                  _swipedChatId != chat.id) {
                                setState(() => _swipedChatId = null);
                              }
                              context
                                  .push<void>(
                                    MessagingNavigation.chatRouteForContext(
                                      context,
                                      chat.id,
                                    ),
                                  )
                                  .then((_) {
                                if (mounted) {
                                  chatProvider.refreshChats(
                                    viewerRole: audience,
                                  );
                                }
                              });
                            },
                            onDelete: () => _confirmDelete(
                              context,
                              chatProvider,
                              chat.id,
                              isModelDesignerChat: isModelMessaging &&
                                  sl<ModelDesignerMatchService>()
                                      .isModelDesignerChat(chat.id),
                            ),
                            onSwipeChanged: (isSwiped) {
                              setState(() {
                                _swipedChatId = isSwiped ? chat.id : null;
                              });
                            },
                            formatTime: _formatTime,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _chatPreviewLine(Chat chat) {
  final parts = <String>[
    if (chat.jobTitle != null && chat.jobTitle!.isNotEmpty) chat.jobTitle!,
    if (chat.lastMessage != null && chat.lastMessage!.content.isNotEmpty)
      chat.lastMessage!.content,
  ];
  return parts.join(' · ');
}

class _ChatListItem extends StatefulWidget {
  const _ChatListItem({
    required this.chat,
    required this.onTap,
    required this.isSwiped,
    required this.onSwipeChanged,
    required this.formatTime,
    this.onDelete,
  });

  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isSwiped;
  final ValueChanged<bool> onSwipeChanged;
  final String Function(DateTime) formatTime;

  @override
  State<_ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<_ChatListItem> {
  double _dragDistance = 0.0;

  @override
  Widget build(BuildContext context) {
    final preview = _chatPreviewLine(widget.chat);
    // 상대방 이름은 "내 역할이 shop이냐"가 아니라 "이 채팅방의 shopId 슬롯에
    // 내가 들어있냐"로 판단한다 — 모델↔디자이너 채팅은 양쪽 다 실제 역할이
    // 'spare'라 role 기반 판단이 불가능하다(chat_room_screen.dart와 동일 이유).
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    final amInShopSlot =
        currentUserId != null && currentUserId == widget.chat.shopId;
    final otherName =
        amInShopSlot ? widget.chat.spareName : widget.chat.shopName;

    return GestureDetector(
      onHorizontalDragStart: (_) => _dragDistance = 0.0,
      onHorizontalDragUpdate: (details) {
        _dragDistance += details.delta.dx;
        if (details.delta.dx < -10 && !widget.isSwiped) {
          widget.onSwipeChanged(true);
        } else if (details.delta.dx > 10 && widget.isSwiped) {
          widget.onSwipeChanged(false);
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < -500) {
          widget.onSwipeChanged(true);
        } else if (details.velocity.pixelsPerSecond.dx > 500) {
          widget.onSwipeChanged(false);
        } else if (_dragDistance < -50) {
          widget.onSwipeChanged(true);
        } else {
          widget.onSwipeChanged(false);
        }
        _dragDistance = 0.0;
      },
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (widget.isSwiped)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 80,
                child: Material(
                  color: AppTheme.backgroundWhite,
                  child: InkWell(
                    onTap: () {
                      widget.onDelete?.call();
                      widget.onSwipeChanged(false);
                    },
                    child: ColoredBox(
                      color: AppTheme.urgentRed.withValues(alpha: 0.1),
                      child: Center(
                        child: IconMapper.icon(
                              'trash',
                              size: 24,
                              color: AppTheme.urgentRed,
                            ) ??
                            const Icon(
                              Icons.delete_outline,
                              size: 24,
                              color: AppTheme.urgentRed,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(right: widget.isSwiped ? 80 : 0),
              child: Material(
                color: AppTheme.backgroundWhite,
                child: InkWell(
                  onTap: widget.onTap,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppTheme.borderGray),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing3,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _ChatAvatarLetter(
                            letter: otherName.isNotEmpty ? otherName[0] : '?',
                          ),
                          const SizedBox(width: AppTheme.spacing3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        otherName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.stitchTextPrimary,
                                          height: 1.25,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (widget.chat.lastMessage != null)
                                      Text(
                                        widget.formatTime(
                                          widget.chat.lastMessage!.createdAt,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.stitchTextSecondary,
                                          height: 1.25,
                                        ),
                                      ),
                                  ],
                                ),
                                if (preview.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    preview,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.25,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if ((widget.chat.unreadCount ?? 0) > 0) ...[
                            const SizedBox(width: AppTheme.spacing2),
                            _ChatUnreadBadge(
                              count: widget.chat.unreadCount ?? 0,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAvatarLetter extends StatelessWidget {
  const _ChatAvatarLetter({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primaryPurpleLight,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: AppTheme.stitchPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          height: 1,
        ),
      ),
    );
  }
}

class _ChatUnreadBadge extends StatelessWidget {
  const _ChatUnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing2,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: AppTheme.urgentRed,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}

class _ModelMessagingPolicyBanner extends StatelessWidget {
  const _ModelMessagingPolicyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderGray, width: 1),
        ),
      ),
      child: const Text(
        '매칭된 디자이너와만 대화할 수 있어요. 채팅방을 삭제하면 매칭이 자동으로 취소됩니다.',
        style: TextStyle(
          fontSize: 13,
          color: AppTheme.stitchTextSecondary,
          height: 1.45,
        ),
      ),
    );
  }
}
