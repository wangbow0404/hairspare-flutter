import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/challenge_service.dart';
import '../../models/challenge_comment.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// 챌린지 댓글 화면
class ChallengeCommentsScreen extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;

  const ChallengeCommentsScreen({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
  });

  @override
  State<ChallengeCommentsScreen> createState() => _ChallengeCommentsScreenState();
}

class _ChallengeCommentsScreenState extends State<ChallengeCommentsScreen> {
  int _currentNavIndex = 0;
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
      print('댓글 로드 오류: ${appException.toString()}');
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
        for (var comment in _comments) {
          if (comment.id == commentId) {
            comment.isLiked = !comment.isLiked;
            comment.likes += comment.isLiked ? 1 : -1;
            break;
          }
          // 대댓글 확인
          for (var reply in comment.replies) {
            if (reply.id == commentId) {
              reply.isLiked = !reply.isLiked;
              reply.likes += reply.isLiked ? 1 : -1;
              break;
            }
          }
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: Colors.white) ??
              const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '댓글',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 댓글 목록
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconMapper.icon('messagecircle', size: 48, color: Colors.grey) ??
                                const Icon(Icons.comment_outlined, size: 48, color: Colors.grey),
                            const SizedBox(height: AppTheme.spacing3),
                            const Text(
                              '댓글이 없습니다',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(AppTheme.spacing4),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return _CommentItem(
                            comment: _comments[index],
                            onLike: () => _toggleLike(_comments[index].id),
                            formatTime: _formatTime,
                          );
                        },
                      ),
          ),
          // 댓글 입력 영역
          Container(
            padding: EdgeInsets.all(AppTheme.spacing3),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing3,
                          vertical: AppTheme.spacing2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing2),
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
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
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

class _CommentItem extends StatelessWidget {
  final ChallengeComment comment;
  final VoidCallback onLike;
  final String Function(DateTime) formatTime;

  const _CommentItem({
    required this.comment,
    required this.onLike,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[700],
                ),
                child: Center(
                  child: Text(
                    comment.userAvatar ?? '👤',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacing2),
              // 댓글 내용
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        Text(
                          formatTime(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing1),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    // 좋아요 버튼
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked ? AppTheme.urgentRed : Colors.grey[500],
                          ),
                          SizedBox(width: AppTheme.spacing1),
                          Text(
                            comment.likes.toString(),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
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
          // 대댓글
          if (comment.replies.isNotEmpty) ...[
            SizedBox(height: AppTheme.spacing2),
            Padding(
              padding: EdgeInsets.only(left: 52),
              child: Column(
                children: comment.replies.map((reply) {
                  return Container(
                    margin: EdgeInsets.only(bottom: AppTheme.spacing2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[800],
                          ),
                          child: Center(
                            child: Text(
                              reply.userAvatar ?? '👤',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    reply.userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.spacing2),
                                  Text(
                                    formatTime(reply.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppTheme.spacing1),
                              Text(
                                reply.content,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

