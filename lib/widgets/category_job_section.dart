import 'package:flutter/material.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import 'job_card.dart';

enum CategoryType {
  region, // 지역 BEST
  hourly, // 시급 BEST
  daily, // 일급 BEST
  recommended, // 추천 BEST
}

class CategoryJobSection extends StatefulWidget {
  final Map<CategoryType, List<Job>> categoryJobs;
  final Function(Job)? onJobTap;
  final Function(String, bool)? onFavoriteToggle;
  final Map<String, bool> favoriteMap;

  const CategoryJobSection({
    super.key,
    required this.categoryJobs,
    this.onJobTap,
    this.onFavoriteToggle,
    this.favoriteMap = const {},
  });

  @override
  State<CategoryJobSection> createState() => _CategoryJobSectionState();
}

class _CategoryJobSectionState extends State<CategoryJobSection> {
  CategoryType _selectedCategory = CategoryType.region;

  @override
  Widget build(BuildContext context) {
    final selectedJobs = widget.categoryJobs[_selectedCategory] ?? [];

    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4, // px-4
        vertical: AppTheme.spacing6, // py-6
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite, // bg-white
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀
          Text(
            '카테고리별 인기 공고',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 20, // text-xl
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary, // text-gray-900
            ),
          ),
          SizedBox(height: AppTheme.spacing4), // mb-4

          // 탭 버튼들
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryTabButton(
                  label: '지역 BEST',
                  category: CategoryType.region,
                  isSelected: _selectedCategory == CategoryType.region,
                  onTap: () => setState(() => _selectedCategory = CategoryType.region),
                ),
                SizedBox(width: AppTheme.spacing2), // gap-2
                _CategoryTabButton(
                  label: '시급 BEST',
                  category: CategoryType.hourly,
                  isSelected: _selectedCategory == CategoryType.hourly,
                  onTap: () => setState(() => _selectedCategory = CategoryType.hourly),
                ),
                SizedBox(width: AppTheme.spacing2), // gap-2
                _CategoryTabButton(
                  label: '일급 BEST',
                  category: CategoryType.daily,
                  isSelected: _selectedCategory == CategoryType.daily,
                  onTap: () => setState(() => _selectedCategory = CategoryType.daily),
                ),
                SizedBox(width: AppTheme.spacing2), // gap-2
                _CategoryTabButton(
                  label: '추천 BEST',
                  category: CategoryType.recommended,
                  isSelected: _selectedCategory == CategoryType.recommended,
                  isRecommended: true,
                  onTap: () => setState(() => _selectedCategory = CategoryType.recommended),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing4), // mb-4

          // 선택된 카테고리의 공고 리스트
          selectedJobs.isEmpty
              ? Padding(
                  padding: AppTheme.spacingVertical(AppTheme.spacing8), // py-8
                  child: Center(
                    child: Text(
                      '공고가 없습니다.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14, // text-sm
                        color: AppTheme.textTertiary, // text-gray-500
                      ),
                    ),
                  ),
                )
              : Column(
                  children: selectedJobs.map((job) {
                    return JobCard(
                      job: job,
                      isUrgent: job.isUrgent,
                      isFavorite: widget.favoriteMap[job.id] ?? false,
                      onTap: () => widget.onJobTap?.call(job),
                      onFavoriteToggle: widget.onFavoriteToggle != null
                          ? () => widget.onFavoriteToggle!(
                              job.id, !(widget.favoriteMap[job.id] ?? false))
                          : null,
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

class _CategoryTabButton extends StatelessWidget {
  final String label;
  final CategoryType category;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onTap;

  const _CategoryTabButton({
    required this.label,
    required this.category,
    required this.isSelected,
    this.isRecommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppTheme.spacingSymmetric(
          horizontal: AppTheme.spacing4, // px-4
          vertical: AppTheme.spacing2, // py-2
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPurple // bg-purple-600
              : AppTheme.backgroundGray, // bg-gray-100
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg), // rounded-lg
          border: isRecommended && isSelected
              ? Border.all(color: AppTheme.primaryBlue, width: 2) // border-2 border-blue-500
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontSize: 14, // text-sm
            fontWeight: FontWeight.w500, // font-medium
            color: isSelected
                ? Colors.white // text-white
                : AppTheme.textGray700, // text-gray-700
          ),
        ),
      ),
    );
  }
}
