import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';

/// 관리자 ↔ 회원 1:1 채팅방
class AdminChatRoomScreen extends StatefulWidget {
  const AdminChatRoomScreen({
    super.key,
    required this.chatId,
    this.member,
  });

  final String chatId;
  final Map<String, dynamic>? member;

  @override
  State<AdminChatRoomScreen> createState() => _AdminChatRoomScreenState();
}

class _AdminChatRoomScreenState extends State<AdminChatRoomScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _member;
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _member = widget.member;
    _loadChat();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _isSending) return;
      _loadChat(showLoading: false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  String get _memberName =>
      _member?['name']?.toString() ?? '회원';

  String get _memberRoleLabel =>
      _member?['roleLabel']?.toString() ?? '';

  Future<void> _loadChat({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final data = await _adminService.getAdminChat(widget.chatId);
      if (!mounted) return;
      setState(() {
        _member = (data['member'] as Map?)?.cast<String, dynamic>() ?? _member;
        _messages = data['messages'] ?? [];
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      if (showLoading) {
        setState(() => _isLoading = false);
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
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _controller.clear();
    try {
      await _adminService.sendAdminChatMessage(widget.chatId, content);
      await _loadChat(showLoading: false);
    } catch (e) {
      if (!mounted) return;
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
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(String? value) {
    if (value == null || value.isEmpty) return '';
    try {
      return DateFormat('a h:mm', 'ko_KR')
          .format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  bool _isAdminMessage(Map<String, dynamic> message) {
    final role = message['senderRole']?.toString();
    return role == 'admin' || role == 'shop';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AdminStitchTheme.bgSubtle,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_memberName, style: AdminStitchTheme.headlineMd),
                        if (_memberRoleLabel.isNotEmpty)
                          Text(
                            _memberRoleLabel,
                            style: AdminStitchTheme.labelSm.copyWith(
                              color: AdminStitchTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AdminStitchTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '고객센터',
                      style: AdminStitchTheme.labelSm.copyWith(
                        color: AdminStitchTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          '대화를 시작해 보세요.\n회원 앱 메시지함에 채팅방이 생성됩니다.',
                          textAlign: TextAlign.center,
                          style: AdminStitchTheme.bodyMd.copyWith(
                            color: AdminStitchTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AdminStitchTheme.pageMargin,
                          vertical: 12,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (_, index) {
                          final msg =
                              _messages[index] as Map<String, dynamic>;
                          final isMine = _isAdminMessage(msg);
                          return _MessageBubble(
                            content: msg['content']?.toString() ?? '',
                            time: _formatTime(msg['createdAt']?.toString()),
                            isMine: isMine,
                          );
                        },
                      ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AdminStitchTheme.pageMargin,
                8,
                AdminStitchTheme.pageMargin,
                12,
              ),
              decoration: BoxDecoration(
                color: AdminStitchTheme.surfaceCard,
                border: Border(
                  top: BorderSide(color: AdminStitchTheme.borderDefault),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '메시지 입력...',
                        filled: true,
                        fillColor: AdminStitchTheme.bgSubtle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      maxLines: 4,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _send,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.content,
    required this.time,
    required this.isMine,
  });

  final String content;
  final String time;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine
        ? AdminStitchTheme.primary
        : AdminStitchTheme.surfaceCard;
    final textColor =
        isMine ? AdminStitchTheme.onPrimary : AdminStitchTheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                border: isMine
                    ? null
                    : Border.all(color: AdminStitchTheme.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: AdminStitchTheme.bodyMd.copyWith(color: textColor),
                  ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: AdminStitchTheme.labelSm.copyWith(
                        color: isMine
                            ? AdminStitchTheme.onPrimary.withValues(alpha: 0.8)
                            : AdminStitchTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
