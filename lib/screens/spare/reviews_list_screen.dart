import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/spare_app_bar.dart';

/// 전체 리뷰 보기용 데이터
class ReviewItem {
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewItem({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

/// 전체 리뷰 페이지
class ReviewsListScreen extends StatelessWidget {
  final String title;
  final double averageRating;
  final List<ReviewItem> reviews;

  const ReviewsListScreen({
    super.key,
    required this.title,
    required this.averageRating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareAppBar(showBackButton: true),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, size: 24, color: AppTheme.yellow500),
                SizedBox(width: AppTheme.spacing2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing2),
            Row(
              children: [
                Icon(Icons.star, size: 20, color: AppTheme.yellow500),
                SizedBox(width: AppTheme.spacing1),
                Text(
                  averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  ' (${reviews.length}개)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing6),
            ...reviews.map((r) => Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: AppTheme.spacing4),
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.borderGray),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                                i < r.rating ? Icons.star : Icons.star_border,
                                size: 18,
                                color: AppTheme.yellow500,
                              )),
                          SizedBox(width: AppTheme.spacing3),
                          Text(
                            r.userName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('yyyy.M.d', 'ko_KR').format(r.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing3),
                      Text(
                        r.comment,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
