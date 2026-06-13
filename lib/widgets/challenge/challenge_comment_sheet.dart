import 'package:flutter/material.dart';

import '../../models/challenge_comment.dart';
import '../../services/challenge_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';

/// 댓글 시트 콘텐츠 위젯
class ChallengeCommentSheetContent extends StatefulWidget {
  const ChallengeCommentSheetContent({
    super.key,
    required this.challengeId,
    required this.commentTitle,
    this.scrollController,
    this.onPullDownAtTop,
    this.onClose,
  });

  final String challengeId;
  final String commentTitle;
  final ScrollController? scrollController;
  final VoidCallback? onPullDownAtTop;
  final VoidCallback? onClose;

  @override
  State<ChallengeCommentSheetContent> createState() => _ChallengeCommentSheetContentState();
}

class _ChallengeCommentSheetContentState extends State<ChallengeCommentSheetContent> {
  final ChallengeService _challengeService = ChallengeService();
  final TextEditingController _commentController = TextEditingController();
  List<ChallengeComment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // API 호출하여 댓글 목록 가져오기
      final comments = await _challengeService.getChallengeComments(widget.challengeId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      debugPrint('댓글 로드 오류: ${appException.toString()}');
      // API 실패 시 빈 리스트로 설정
      setState(() {
        _comments = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_commentController.text.trim().isEmpty) return;

    final content = _commentController.text.trim();
    _commentController.clear();

    try {
      // API 호출하여 댓글 등록
      final newComment = await _challengeService.createChallengeComment(
        challengeId: widget.challengeId,
        content: content,
      );

      setState(() {
        _comments.insert(0, newComment);
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('댓글 등록 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      // 실패 시 입력 내용 복원
      _commentController.text = content;
    }
  }

  Future<void> _toggleLike(String commentId) async {
    try {
      // API 호출하여 댓글 좋아요/좋아요 취소
      await _challengeService.toggleCommentLike(widget.challengeId, commentId);

      setState(() {
        final comment = _comments.firstWhere((c) => c.id == commentId);
        comment.isLiked = !comment.isLiked;
        comment.likes += comment.isLiked ? 1 : -1;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('좋아요 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (widget.onPullDownAtTop == null) return false;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta;
      if (delta != null &&
          delta < 0 &&
          notification.metrics.pixels <= 0 &&
          notification.dragDetails != null) {
        widget.onPullDownAtTop!();
        return true;
      }
    }

    if (notification is OverscrollNotification &&
        notification.overscroll < 0 &&
        notification.metrics.pixels <= 0) {
      widget.onPullDownAtTop!();
      return true;
    }

    return false;
  }

  Widget _buildSheetHeader() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing2),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.commentTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey[800], height: 1),
      ],
    );
  }

  List<Widget> _commentSlivers() {
    if (_isLoading) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      ];
    }

    if (_comments.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  IconMapper.icon(
                        'messagecircle',
                        size: 48,
                        color: Colors.grey,
                      ) ??
                      const Icon(
                        Icons.comment_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                  const SizedBox(height: AppTheme.spacing3),
                  const Text(
                    '댓글이 없습니다',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(AppTheme.spacing3),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ChallengeCommentSheetItem(
                comment: _comments[index],
                onLike: () => _toggleLike(_comments[index].id),
                formatTime: _formatTime,
              );
            },
            childCount: _comments.length,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: CustomScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: _buildSheetHeader()),
                ..._commentSlivers(),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            ),
          ),
        ),
        // 댓글 입력 영역
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing3),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border(
              top: BorderSide(color: Colors.grey[800]!, width: 1),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[500]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing3,
                        vertical: AppTheme.spacing2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing2),
                IconButton(
                  icon: IconMapper.icon('send', size: 24, color: Colors.white) ??
                      const Icon(Icons.send, size: 24, color: Colors.white),
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChallengeCommentSheetItem extends StatelessWidget {
  final ChallengeComment comment;
  final VoidCallback onLike;
  final String Function(DateTime) formatTime;

  const ChallengeCommentSheetItem({super.key, 
    required this.comment,
    required this.onLike,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[700],
            ),
            child: Center(
              child: Text(
                comment.userAvatar ?? '👤',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing2),
                    Text(
                      formatTime(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing1),
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        comment.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: comment.isLiked ? AppTheme.urgentRed : Colors.grey[500],
                      ),
                      const SizedBox(width: AppTheme.spacing1),
                      Text(
                        comment.likes.toString(),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
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
