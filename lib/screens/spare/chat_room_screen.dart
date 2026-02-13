import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/error_handler.dart';
import '../../services/chat_service.dart';
import '../spare/messages_screen.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'package:intl/intl.dart';

/// Next.js와 동일한 채팅방 화면
class ChatRoomScreen extends StatefulWidget {
  final String chatId;

  const ChatRoomScreen({super.key, required this.chatId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService _chatService = ChatService();
  int _currentNavIndex = 0;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  Chat? _chat;
  bool _isLoading = true;
  bool _isSending = false;

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
      setState(() {
        _chat = chatWithMessages.chat;
        _messages = chatWithMessages.messages;
        _isLoading = false;
      });
      
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) {
      return;
    }

    final content = _messageController.text.trim();
    _messageController.clear();
    setState(() {
      _isSending = true;
    });

    try {
      final newMessage = await _chatService.sendMessage(widget.chatId, content);
      
      setState(() {
        _messages.add(newMessage);
        _isSending = false;
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
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_chat == null) {
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
        ),
        body: const Center(
          child: Text('채팅방을 찾을 수 없습니다.'),
        ),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.id;
    final isShop = authProvider.currentUser?.role == UserRole.shop;
    final otherUserName = isShop ? _chat!.spareName : _chat!.shopName;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherUserName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (_chat!.jobTitle != null && _chat!.jobTitle!.isNotEmpty)
              Text(
                _chat!.jobTitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 연락처 공유 안내 문구
          Container(
            margin: AppTheme.spacing(AppTheme.spacing4),
            padding: AppTheme.spacing(AppTheme.spacing3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.orange50, AppTheme.urgentRedLight],
              ),
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              border: Border(
                left: BorderSide(color: AppTheme.orange500, width: 4),
              ),
            ),
            child: Row(
              children: [
                const Text('🚨', style: TextStyle(fontSize: 24)),
                SizedBox(width: AppTheme.spacing2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '연락처 공유 주의사항',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.orange500,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing1 / 2),
                      Text(
                        '전화번호, 이메일, 주소 등 연락처 공유는 HAIRSPARE 이용약관 위반입니다. 플랫폼 내에서 안전하게 소통해주세요.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppTheme.orange500.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                      final isMyMessage = message.senderId == currentUserId;
                      final prevMessage = index > 0 ? _messages[index - 1] : null;
                      final showProfile = prevMessage == null ||
                          prevMessage.senderId != message.senderId;

                      return Padding(
                        padding: EdgeInsets.only(bottom: AppTheme.spacing4),
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
                            SizedBox(width: AppTheme.spacing2),
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
                                        padding: EdgeInsets.only(bottom: AppTheme.spacing1),
                                        child: Text(
                                          message.senderName,
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isMyMessage
                                                ? Colors.white.withOpacity(0.7)
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
                                    SizedBox(height: AppTheme.spacing1 / 2),
                                    Text(
                                      _formatTime(message.createdAt),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        fontSize: 12,
                                        color: isMyMessage
                                            ? Colors.white.withOpacity(0.7)
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: AppTheme.spacing2),
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
                                    authProvider.currentUser?.name?.isNotEmpty == true
                                        ? authProvider.currentUser!.name![0]
                                        : '나',
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
            decoration: BoxDecoration(
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
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        borderSide: BorderSide(color: AppTheme.borderGray),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        borderSide: BorderSide(color: AppTheme.borderGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
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
                SizedBox(width: AppTheme.spacing2),
                IconButton(
                  onPressed: _isSending ? null : _sendMessage,
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
}

