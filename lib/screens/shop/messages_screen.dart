import 'package:flutter/material.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../services/chat_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/error_handler.dart';
import '../spare/chat_room_screen.dart';

/// Shop용 메시지 화면 (Next.js와 동일한 구조)
class ShopMessagesScreen extends StatefulWidget {
  const ShopMessagesScreen({super.key});

  @override
  State<ShopMessagesScreen> createState() => _ShopMessagesScreenState();
}

class _ShopMessagesScreenState extends State<ShopMessagesScreen> {
  String _activeTab = 'all';
  String? _swipedChatId;
  final ChatService _chatService = sl<ChatService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatProvider>().refreshChats(viewerRole: 'shop');
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
            appBar: SharedAppBar(
              title: '메시지',
              onBackPressed: () => NavigationHelper.safePop(context),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chatProvider.error!,
                    style: const TextStyle(color: AppTheme.urgentRed),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  ElevatedButton(
                    onPressed: () =>
                        chatProvider.refreshChats(viewerRole: 'shop'),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        final chats = chatProvider.chats;
        final filteredChats = _activeTab == 'unread'
            ? chats.where((chat) => (chat.unreadCount ?? 0) > 0).toList()
            : chats;

        return Scaffold(
          backgroundColor: AppTheme.backgroundGray,
          appBar: SharedAppBar(
            title: '메시지',
            onBackPressed: () => NavigationHelper.safePop(context),
            actions: [
              PopupMenuButton<String>(
                icon: IconMapper.icon(
                      'morehorizontal',
                      size: 24,
                      color: AppTheme.textSecondary,
                    ) ??
                    const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                onSelected: (value) async {
                  if (value == 'delete_all') {
                    await _showDeleteAllDialog(chatProvider);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text('전체 삭제'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
                        onTap: () {
                          setState(() {
                            _activeTab = 'all';
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: '안 읽음',
                        isActive: _activeTab == 'unread',
                        onTap: () {
                          setState(() {
                            _activeTab = 'unread';
                          });
                        },
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
                              '메시지가 없습니다',
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
                                setState(() {
                                  _swipedChatId = null;
                                });
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
                                    viewerRole: 'shop',
                                  );
                                }
                              });
                            },
                            onDelete: () => _showDeleteDialog(
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

  Future<void> _showDeleteDialog(
    ChatProvider chatProvider,
    String chatId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 삭제'),
        content: const Text('이 채팅방을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.urgentRed,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteChat(chatProvider, chatId);
    }
  }

  Future<void> _deleteChat(
    ChatProvider chatProvider,
    String chatId,
  ) async {
    try {
      await _chatService.deleteChat(chatId);
      chatProvider.removeChatLocally(chatId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('채팅방이 삭제되었습니다'),
            backgroundColor: AppTheme.primaryPurple,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        final appException = ErrorHandler.handleException(error);
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(appException);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteAllDialog(ChatProvider chatProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 채팅을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.urgentRed,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAllChats(chatProvider);
    }
  }

  Future<void> _deleteAllChats(ChatProvider chatProvider) async {
    try {
      for (final chat in chatProvider.chats) {
        try {
          await _chatService.deleteChat(chat.id);
        } catch (e) {
          // 개별 채팅 삭제 실패는 무시하고 계속 진행
        }
      }

      await chatProvider.refreshChats(viewerRole: 'shop');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 채팅이 삭제되었습니다'),
            backgroundColor: AppTheme.primaryPurple,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        final appException = ErrorHandler.handleException(error);
        final userFriendlyMessage =
            ErrorHandler.getUserFriendlyMessage(appException);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

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
                color: isActive ? AppTheme.primaryPurple : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppTheme.primaryPurple : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ChatListItem extends StatefulWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isSwiped;
  final ValueChanged<bool> onSwipeChanged;
  final String Function(DateTime) formatTime;

  const _ChatListItem({
    required this.chat,
    required this.onTap,
    this.onDelete,
    required this.isSwiped,
    required this.onSwipeChanged,
    required this.formatTime,
  });

  @override
  State<_ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<_ChatListItem> {
  double _dragDistance = 0.0;

  @override
  Widget build(BuildContext context) {
    // Shop용 메시지 화면에서는 상대방이 Spare이므로 spareName 표시
    final displayName = widget.chat.spareName.isNotEmpty 
        ? widget.chat.spareName 
        : '스페어';
    
    final preview = widget.chat.lastMessage?.content ?? '';

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
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  AppTheme.borderRadius(AppTheme.radiusFull),
                            ),
                            child: Text(
                              displayName.isNotEmpty ? displayName[0] : '?',
                              style: const TextStyle(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1,
                              ),
                            ),
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
                                        displayName,
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
                            Container(
                              padding: AppTheme.spacingSymmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: AppTheme.spacing1,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.urgentRed,
                                borderRadius: AppTheme.borderRadius(
                                  AppTheme.radiusFull,
                                ),
                              ),
                              child: Text(
                                (widget.chat.unreadCount ?? 0) > 9
                                    ? '9+'
                                    : '${widget.chat.unreadCount}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
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
