import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../services/review_service.dart';
import '../../utils/error_handler.dart';

/// Next.js와 동일한 리뷰 화면
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  List<_Review> _reviews = [];
  bool _showForm = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _commentController = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final reviews = await _reviewService.getReviews();
      setState(() {
        _reviews = reviews.map((review) {
          return _Review(
            id: review.id,
            shopName: review.shopName,
            rating: review.rating,
            comment: review.comment,
            date: DateFormat('yyyy-MM-dd').format(review.createdAt),
          );
        }).toList();
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final messenger = ScaffoldMessenger.of(context);
      // API 호출하여 리뷰 등록 (shopId는 서비스에서 자동으로 찾음)
      final review = await _reviewService.createReview(
        shopName: _shopNameController.text.trim(),
        shopId: null, // shopName으로 자동 검색
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      final newReview = _Review(
        id: review.id,
        shopName: review.shopName,
        rating: review.rating,
        comment: review.comment,
        date: DateFormat('yyyy-MM-dd').format(review.createdAt),
      );

      setState(() {
        _reviews.insert(0, newReview);
        _showForm = false;
        _shopNameController.clear();
        _commentController.clear();
        _rating = 5;
      });

      messenger.showSnackBar(
        const SnackBar(
          content: Text('후기가 등록되었습니다.'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(
        title: '후기',
        showHubActions: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showForm = !_showForm;
              });
            },
            child: Text(
              _showForm ? '취소' : '후기 작성',
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: Column(
          children: [
            if (_showForm) ...[
              // 후기 작성 폼
              Container(
                padding: AppTheme.spacing(AppTheme.spacing4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '후기 작성',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      // 미용실명
                      TextFormField(
                        controller: _shopNameController,
                        decoration: AppTheme.inputDecoration.copyWith(
                          labelText: '미용실명',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '미용실명을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      // 평점
                      DropdownButtonFormField<int>(
                        initialValue: _rating,
                        decoration: AppTheme.inputDecoration.copyWith(
                          labelText: '평점',
                        ),
                        items: [5, 4, 3, 2, 1].map((rating) {
                          return DropdownMenuItem(
                            value: rating,
                            child: Text('$rating점'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _rating = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      // 후기 내용
                      TextFormField(
                        controller: _commentController,
                        decoration: AppTheme.inputDecoration.copyWith(
                          labelText: '후기 내용',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '후기 내용을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      // 등록하기 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: AppTheme.spacing(AppTheme.spacing3),
                          ),
                          child: Text(
                            _isLoading ? '등록 중…' : '등록하기',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
            ],
            // 리뷰 목록
            ..._reviews.map((review) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
                padding: AppTheme.spacing(AppTheme.spacing4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.shopName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 20,
                              color: AppTheme.yellow400,
                            ),
                            const SizedBox(width: AppTheme.spacing1 / 2),
                            Text(
                              '${review.rating}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      review.comment,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      review.date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Review {
  final String id;
  final String shopName;
  final int rating;
  final String comment;
  final String date;

  _Review({
    required this.id,
    required this.shopName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}
