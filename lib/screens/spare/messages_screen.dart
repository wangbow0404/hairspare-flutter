import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/chat_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/error_handler.dart';
import '../../utils/app_exception.dart';
import '../spare/chat_room_screen.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 메시지 화면
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _currentNavIndex = 0;
  List<Chat> _chats = [];
  bool _isLoading = true;
  String _activeTab = 'all';
  String? _swipedChatId; // 현재 스와이프된 채팅 ID
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final chats = await _chatService.getChats();
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final appException = ErrorHandler.handleException(error);
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(appException);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filteredChats = _activeTab == 'unread'
        ? _chats.where((chat) => (chat.unreadCount ?? 0) > 0).toList()
        : _chats;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => NavigationHelper.safePop(context),
        ),
        title: Text(
          '메시지',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: IconMapper.icon('morehorizontal', size: 24, color: AppTheme.textSecondary) ??
                const Icon(Icons.more_vert, color: AppTheme.textSecondary),
            onSelected: (value) async {
              if (value == 'delete_all') {
                await _showDeleteAllDialog();
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
          // 탭 버튼
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
          // 채팅 목록
          Expanded(
            child: filteredChats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconMapper.icon('messagecircle', size: 64, color: AppTheme.textTertiary) ??
                            const Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textTertiary),
                        SizedBox(height: AppTheme.spacing4),
                        Text(
                          '메시지가 없습니다',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          // 다른 채팅이 스와이프되어 있으면 닫기
                          if (_swipedChatId != null && _swipedChatId != chat.id) {
                            setState(() {
                              _swipedChatId = null;
                            });
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(chatId: chat.id),
                            ),
                          );
                        },
                        onDelete: () async {
                          await _showDeleteDialog(chat.id);
                        },
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          
          // 네비게이션 처리
          switch (index) {
            case 0:
              // 홈으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              // 결제로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              // 찜으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              // 마이(프로필)로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(String chatId) async {
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
      await _deleteChat(chatId);
    }
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      await _chatService.deleteChat(chatId);
      setState(() {
        _chats.removeWhere((chat) => chat.id == chatId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('채팅방이 삭제되었습니다'),
            backgroundColor: AppTheme.primaryBlue,
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

  Future<void> _showDeleteAllDialog() async {
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
      await _deleteAllChats();
    }
  }

  Future<void> _deleteAllChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 모든 채팅 삭제
      for (final chat in _chats) {
        try {
          await _chatService.deleteChat(chat.id);
        } catch (e) {
          // 개별 채팅 삭제 실패는 무시하고 계속 진행
        }
      }

      // 채팅 목록 새로고침
      await _loadChats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 채팅이 삭제되었습니다'),
            backgroundColor: AppTheme.primaryBlue,
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
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
    return GestureDetector(
      onHorizontalDragStart: (_) {
        _dragDistance = 0.0;
      },
      onHorizontalDragUpdate: (details) {
        _dragDistance += details.delta.dx;
        // 오른쪽에서 왼쪽으로 스와이프 감지
        if (details.delta.dx < -10 && !widget.isSwiped) {
          widget.onSwipeChanged(true);
        } else if (details.delta.dx > 10 && widget.isSwiped) {
          widget.onSwipeChanged(false);
        }
      },
      onHorizontalDragEnd: (details) {
        // 스와이프 속도가 충분히 크면 삭제 버튼 표시 유지
        if (details.velocity.pixelsPerSecond.dx < -500) {
          widget.onSwipeChanged(true);
        } else if (details.velocity.pixelsPerSecond.dx > 500) {
          widget.onSwipeChanged(false);
        } else {
          // 스와이프 거리에 따라 결정
          if (_dragDistance < -50) {
            widget.onSwipeChanged(true);
          } else if (_dragDistance > 50) {
            widget.onSwipeChanged(false);
          } else {
            // 거리가 충분하지 않으면 원래 상태로 복귀
            widget.onSwipeChanged(false);
          }
        }
        _dragDistance = 0.0;
      },
      child: Stack(
        children: [
          // 삭제 버튼 (스와이프 시 표시)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: widget.isSwiped ? 0 : -80,
            top: 0,
            bottom: 0,
            width: 80,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderGray),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onDelete?.call();
                    widget.onSwipeChanged(false);
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppTheme.urgentRed.withOpacity(0.1),
                    child: IconMapper.icon('trash', size: 24, color: AppTheme.urgentRed) ??
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
          // 채팅 아이템
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: 0,
            right: widget.isSwiped ? 80 : 0,
            top: 0,
            bottom: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                child: Container(
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderGray),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 프로필 이미지
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        ),
                        child: widget.chat.shopName.isNotEmpty
                            ? Center(
                                child: Text(
                                  widget.chat.shopName[0],
                                  style: TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : IconMapper.icon('user', size: 24, color: AppTheme.primaryBlue) ??
                                const Icon(Icons.person, size: 24, color: AppTheme.primaryBlue),
                      ),
                      SizedBox(width: AppTheme.spacing3),
                      // 채팅 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.chat.shopName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.chat.lastMessage != null)
                                  Text(
                                    widget.formatTime(widget.chat.lastMessage!.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing1 / 2),
                            if (widget.chat.lastMessage != null)
                              Text(
                                widget.chat.lastMessage!.content,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      // 읽지 않은 메시지 개수
                      if ((widget.chat.unreadCount ?? 0) > 0)
                        Container(
                          padding: AppTheme.spacingSymmetric(
                            horizontal: AppTheme.spacing2,
                            vertical: AppTheme.spacing1,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.urgentRed,
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                          ),
                          child: Text(
                            (widget.chat.unreadCount ?? 0) > 9 ? '9+' : '${widget.chat.unreadCount}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

