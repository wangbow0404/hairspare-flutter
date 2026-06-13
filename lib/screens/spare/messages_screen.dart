import 'package:flutter/material.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/spare_app_bar.dart';
import 'chat_room_screen.dart';

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
      context.read<ChatProvider>().refreshChats(viewerRole: 'spare');
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
    String chatId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('채팅방 삭제'),
        content: const Text('이 채팅방을 삭제하시겠습니까?'),
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
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _chatService.deleteChat(chatId);
      if (!mounted) return;
      chatProvider.removeChatLocally(chatId);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('채팅방이 삭제되었습니다'),
          backgroundColor: AppTheme.primaryBlue,
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
          return Scaffold(
            backgroundColor: AppTheme.backgroundGray,
            appBar: const SpareAppBar(
              showBackButton: true,
              showSearch: false,
              showTrailingIcons: false,
              title: '메시지',
            ),
            body: Center(
              child: Padding(
                padding: AppTheme.spacing(AppTheme.spacing4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chatProvider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.urgentRed),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    ElevatedButton(
                      onPressed: () =>
                          chatProvider.refreshChats(viewerRole: 'spare'),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final filteredChats = _activeTab == 'unread'
            ? chatProvider.chats
                .where((chat) => (chat.unreadCount ?? 0) > 0)
                .toList()
            : chatProvider.chats;

        return Scaffold(
          backgroundColor: AppTheme.backgroundGray,
          appBar: const SpareAppBar(
            showBackButton: true,
            showSearch: false,
            showTrailingIcons: false,
            title: '메시지',
          ),
          body: Column(
            children: [
              Container(
                color: AppTheme.backgroundWhite,
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: '전체',
                        isActive: _activeTab == 'all',
                        onTap: () => setState(() => _activeTab = 'all'),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: '안 읽음',
                        isActive: _activeTab == 'unread',
                        onTap: () => setState(() => _activeTab = 'unread'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredChats.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconMapper.icon(
                                  'messagecircle',
                                  size: 64,
                                  color: AppTheme.textTertiary,
                                ) ??
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: AppTheme.textTertiary,
                                ),
                            const SizedBox(height: AppTheme.spacing4),
                            Text(
                              _activeTab == 'unread'
                                  ? '읽지 않은 메시지가 없습니다'
                                  : '메시지가 없습니다',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
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
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      ChatRoomScreen(chatId: chat.id),
                                ),
                              ).then((_) {
                                if (mounted) {
                                  chatProvider.refreshChats(
                                    viewerRole: 'spare',
                                  );
                                }
                              });
                            },
                            onDelete: () => _confirmDelete(
                              context,
                              chatProvider,
                              chat.id,
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: AppTheme.spacing(AppTheme.spacing4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppTheme.primaryBlue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color:
                      isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
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
                            letter: widget.chat.shopName.isNotEmpty
                                ? widget.chat.shopName[0]
                                : '?',
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
                                        widget.chat.shopName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
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
                                          color: AppTheme.textSecondary,
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
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          color: AppTheme.primaryBlue,
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
