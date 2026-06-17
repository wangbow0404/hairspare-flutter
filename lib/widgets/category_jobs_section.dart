import 'package:flutter/material.dart';
import 'package:hairspare/widgets/job/urgent_job_card_theme.dart';
import '../models/job.dart';
import '../theme/app_theme.dart';
import 'common/job_thumbnail.dart';
import 'stitch/stitch_section_header.dart';

enum CategoryType {
  region, // 지역 BEST
  hourly, // 시급 BEST
  daily, // 일급 BEST
  recommended, // 추천 BEST
}

class CategoryJobsSection extends StatefulWidget {
  final List<Job> allJobs;
  final String? selectedRegionId;
  final Map<String, bool> favoriteMap;
  final Function(Job) onJobTap;
  final Function(String, bool) onFavoriteToggle;
  /// 홈에서 QuickMenu 바로 아래 붙일 때 상단 여백 축소용. null이면 EdgeInsets.all(spacing4)
  final EdgeInsetsGeometry? sectionPadding;

  const CategoryJobsSection({
    super.key,
    required this.allJobs,
    this.selectedRegionId,
    required this.favoriteMap,
    required this.onJobTap,
    required this.onFavoriteToggle,
    this.sectionPadding,
  });

  @override
  State<CategoryJobsSection> createState() => _CategoryJobsSectionState();
}

class _CategoryJobsSectionState extends State<CategoryJobsSection> {
  CategoryType _selectedCategory = CategoryType.region;

  /// 시급 계산 함수 (시간 문자열에서 시간 추출)
  double calculateHourlyRate(Job job) {
    // timeStr 형식: "HH:mm" (예: "14:00", "18:00")
    // 기본 근무 시간을 4시간으로 가정
    const defaultHours = 4;

    // 시간 문자열 파싱 시도
    try {
      final timeParts = job.time.split(':');
      if (timeParts.isEmpty) return job.amount / defaultHours;

      final startHour = int.tryParse(timeParts[0]);
      if (startHour == null) return job.amount / defaultHours;

      // 시간대별 근무 시간 추정
      // 오전 (6-12): 4시간, 오후 (12-18): 4시간, 저녁 (18-22): 3시간
      int workHours = defaultHours;
      if (startHour >= 6 && startHour < 12) {
        workHours = 4; // 오전 근무
      } else if (startHour >= 12 && startHour < 18) {
        workHours = 4; // 오후 근무
      } else if (startHour >= 18 && startHour < 22) {
        workHours = 3; // 저녁 근무 (짧음)
      }

      return job.amount / workHours;
    } catch (e) {
      return job.amount / defaultHours;
    }
  }

  /// 카테고리별 공고 필터링 및 정렬
  List<Job> getFilteredJobs() {
    // allJobs가 비어있으면 빈 리스트 반환
    if (widget.allJobs.isEmpty) {
      return [];
    }

    List<Job> filtered = List.from(widget.allJobs);

    switch (_selectedCategory) {
      case CategoryType.region:
        // 지역 BEST: 선택된 지역이 있으면 해당 지역만, 없으면 전체 공고
        if (widget.selectedRegionId != null && widget.selectedRegionId!.isNotEmpty) {
          filtered = filtered
              .where((job) => job.regionId == widget.selectedRegionId)
              .toList();
        }
        // 최신순 정렬 (선택된 지역이 없어도 전체 공고를 최신순으로 정렬)
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case CategoryType.hourly:
        // 시급 BEST: 시급 계산 후 정렬
        filtered.sort((a, b) {
          final hourlyRateA = calculateHourlyRate(a);
          final hourlyRateB = calculateHourlyRate(b);
          return hourlyRateB.compareTo(hourlyRateA); // 내림차순
        });
        break;

      case CategoryType.daily:
        // 일급 BEST: 금액 기준 정렬
        filtered.sort((a, b) => b.amount.compareTo(a.amount)); // 내림차순
        break;

      case CategoryType.recommended:
        // 추천 BEST: 인기순 (급구 우선, 그 다음 최신순)
        filtered.sort((a, b) {
          if (a.isUrgent && !b.isUrgent) return -1;
          if (!a.isUrgent && b.isUrgent) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
    }

    // 최대 3개만 반환
    return filtered.take(3).toList();
  }

  /// 근무 시간 태그 (오전/오후/저녁)
  String getTimeTag(String timeStr) {
    try {
      final timeParts = timeStr.split(':');
      if (timeParts.isEmpty) return "오후";

      final hour = int.tryParse(timeParts[0]);
      if (hour == null) return "오후";

      if (hour >= 6 && hour < 12) return "오전";
      if (hour >= 12 && hour < 18) return "오후";
      if (hour >= 18 && hour < 22) return "저녁";
      return "야간";
    } catch (e) {
      return "오후";
    }
  }

  /// 남은 일수 계산
  int getDaysLeft(Job job) {
    if (job.countdown == null) return 0;
    return (job.countdown! / 86400).floor();
  }

  /// 금액 포맷팅
  String formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = getFilteredJobs();

    return Container(
      color: AppTheme.backgroundWhite,
      padding: widget.sectionPadding ?? const EdgeInsets.all(AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          const StitchSectionHeader(title: '카테고리별 인기 공고'),
          const SizedBox(height: AppTheme.spacing4),

          // 카테고리 버튼
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryButton('지역 BEST', CategoryType.region),
                const SizedBox(width: AppTheme.spacing2),
                _buildCategoryButton('시급 BEST', CategoryType.hourly),
                const SizedBox(width: AppTheme.spacing2),
                _buildCategoryButton('일급 BEST', CategoryType.daily),
                const SizedBox(width: AppTheme.spacing2),
                _buildCategoryButton('추천 BEST', CategoryType.recommended),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),

          // 카테고리별 공고 리스트
          if (filteredJobs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
              child: Center(
                child: Text(
                  '공고가 없습니다.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            )
          else
            ...filteredJobs.map((job) => _buildJobCard(job)),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, CategoryType category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.stitchPrimary
              : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.stitchTextSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    final isFavorite = widget.favoriteMap[job.id] ?? false;
    final daysLeft = getDaysLeft(job);
    final timeTag = getTimeTag(job.time);
    final isShortTerm = daysLeft == 0;
    final hourlyRate = _selectedCategory == CategoryType.hourly
        ? calculateHourlyRate(job)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: job.isUrgent
              ? AppTheme.urgentRed.withValues(alpha: 0.4)
              : AppTheme.borderGray,
        ),
        boxShadow: AppTheme.stitchSoftShadow,
      ),
      child: Stack(
        children: [
          // 찜 버튼
          Positioned(
            top: AppTheme.spacing4,
            right: AppTheme.spacing4,
            child: GestureDetector(
              onTap: () {
                widget.onFavoriteToggle(job.id, isFavorite);
              },
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing2),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppTheme.urgentRed : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ),

          if (job.isUrgent)
            const Positioned(
              top: AppTheme.spacing4,
              right: 64,
              child: UrgentJobBadge(),
            ),

          // 공고 내용
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing4),
            child: GestureDetector(
              onTap: () => widget.onJobTap(job),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 영역
                  JobThumbnail(
                    job: job,
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  const SizedBox(width: AppTheme.spacing3),

                  // 내용 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 태그 (오전/오후/저녁, 단기/장기)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: AppTheme.spacing1,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Text(
                                timeTag,
                                style: const TextStyle(
                                  color: AppTheme.stitchTextSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: AppTheme.spacing1,
                              ),
                              decoration: BoxDecoration(
                                color: isShortTerm
                                    ? AppTheme.stitchPrimary.withValues(alpha: 0.1)
                                    : AppTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Text(
                                isShortTerm ? '단기' : '장기',
                                style: TextStyle(
                                  color: isShortTerm
                                      ? AppTheme.stitchPrimary
                                      : AppTheme.stitchTextSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing2),

                        // 매장명
                        Text(
                          job.shopName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacing1),

                        // 금액 정보
                        Row(
                          children: [
                            Text(
                              '$daysLeft일 남음',
                              style: const TextStyle(
                                color: AppTheme.stitchTextSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            if (_selectedCategory == CategoryType.hourly && hourlyRate != null)
                              Text(
                                '시급 ${formatAmount(hourlyRate.toInt())}',
                                style: const TextStyle(
                                  color: AppTheme.stitchPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else if (_selectedCategory == CategoryType.daily)
                              Text(
                                '일급 ${formatAmount(job.amount)}',
                                style: const TextStyle(
                                  color: AppTheme.stitchPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else
                              Text(
                                formatAmount(job.amount),
                                style: const TextStyle(
                                  color: AppTheme.stitchPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing1),

                        // 신청 정보
                        Text(
                          '신청 0/${job.requiredCount}명',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
