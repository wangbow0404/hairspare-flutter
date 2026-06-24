import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hairspare/core/router/route_extras.dart';
import 'package:hairspare/utils/shell_navigation.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/icon_mapper.dart';
import 'package:hairspare/view_models/education_detail_view_model.dart';
import 'package:hairspare/widgets/spare_app_bar.dart';
import 'education_screen.dart';

/// 교육 상세 화면 (개선된 레이아웃)
class EducationDetailScreen extends StatelessWidget {
  final Education education;

  const EducationDetailScreen({
    super.key,
    required this.education,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          EducationDetailViewModel(education: education)..loadEnrollmentStatus(),
      child: Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareAppBar(
        showBackButton: true,
        actions: [
          IconButton(
            icon: IconMapper.icon('share', size: 22, color: AppTheme.textPrimary) ??
                const Icon(Icons.share, size: 22, color: AppTheme.textPrimary),
            onPressed: () => Share.share(
              '${education.title}\n참가비: 에너지 ${education.energyCost}개',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageSection(context),
            Padding(
              padding: AppTheme.spacingSymmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTags(context),
                  const SizedBox(height: AppTheme.spacing3),
                  Text(
                    education.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  _buildQuickInfoGrid(context),
                  const SizedBox(height: AppTheme.spacing4),
                  _buildDetailBox(context),
                  const SizedBox(height: AppTheme.spacing4),
                  _buildDescriptionBox(context),
                  if ((education.curriculumSchedule != null && education.curriculumSchedule!.isNotEmpty) ||
                      (education.curriculum != null && education.curriculum!.isNotEmpty)) ...[
                    const SizedBox(height: AppTheme.spacing4),
                    _buildCurriculumSection(context),
                  ],
                  if (education.instructorName != null) ...[
                    const SizedBox(height: AppTheme.spacing4),
                    _buildSectionBox(
                      context,
                      title: '강사 소개',
                      icon: Icons.person,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            education.instructorName!,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (education.instructorBio != null) ...[
                            const SizedBox(height: AppTheme.spacing2),
                            Text(
                              education.instructorBio!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (education.benefits != null && education.benefits!.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacing4),
                    _buildSectionBox(
                      context,
                      title: '이런 점이 좋아요',
                      icon: Icons.star,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: education.benefits!
                            .map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: AppTheme.spacing2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle,
                                          size: 18, color: AppTheme.primaryGreen),
                                      const SizedBox(width: AppTheme.spacing2),
                                      Expanded(
                                        child: Text(
                                          b,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontSize: 13,
                                                color: AppTheme.textPrimary,
                                                height: 1.4,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                  if (education.targetAudience != null) ...[
                    const SizedBox(height: AppTheme.spacing4),
                    _buildSectionBox(
                      context,
                      title: '이런 분들께 추천',
                      icon: Icons.groups,
                      child: Text(
                        education.targetAudience!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  if (education.reviews != null && education.reviews!.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacing4),
                    _buildReviewsSection(context),
                  ],
                  const SizedBox(height: AppTheme.spacing6),
                  _buildApplyButton(context),
                  const SizedBox(height: AppTheme.spacing8),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final hasImage = education.imageUrl != null &&
        education.imageUrl!.isNotEmpty;
    final isNetwork = hasImage && education.imageUrl!.startsWith('http');

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.75),
            AppTheme.primaryBlue.withValues(alpha: 0.65),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            isNetwork
                ? Image.network(
                    education.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                  )
                : Image.asset(
                    education.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                  )
          else
            _buildPlaceholderIcon(),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.school,
        size: 72,
        color: Colors.white.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: AppTheme.spacing2,
      runSpacing: AppTheme.spacing2,
      children: [
        if (education.isUrgent)
          _tag('🚀 급구', AppTheme.urgentRed, Colors.white),
        if (education.isLive)
          _tag('LIVE', const Color(0xFFEF4444), Colors.white),
        _tag(
          education.isOnline ? '온라인' : '오프라인',
          education.isOnline ? Colors.blue.shade100 : Colors.green.shade100,
          education.isOnline ? Colors.blue.shade700 : Colors.green.shade700,
        ),
        _tag(
          education.category,
          AppTheme.primaryPurple.withValues(alpha: 0.15),
          AppTheme.primaryPurple,
        ),
        if (education.duration != null)
          _tag(education.duration!, AppTheme.backgroundGray, AppTheme.textSecondary),
      ],
    );
  }

  Widget _tag(String label, Color bg, Color fg) {
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildQuickInfoGrid(BuildContext context) {
    final hasEducationDate = education.startDate != null;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickInfoItem(
                context,
                icon: Icons.flash_on,
                label: '참가비',
                value: '에너지 ${education.energyCost}개',
                valueColor: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: _buildQuickInfoItem(
                context,
                icon: Icons.event,
                label: '마감일',
                value: DateFormat('M/d', 'ko_KR').format(education.deadline),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing3),
        Row(
          children: [
            Expanded(
              child: _buildQuickInfoItem(
                context,
                icon: Icons.people,
                label: '신청',
                value: '${education.applicants}/${education.maxApplicants}명',
              ),
            ),
            const SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: _buildQuickInfoItem(
                context,
                icon: hasEducationDate ? Icons.calendar_month : Icons.videocam,
                label: hasEducationDate ? '교육일' : '진행',
                value: hasEducationDate
                    ? (education.endDate != null &&
                            education.endDate != education.startDate
                        ? '${DateFormat('M/d', 'ko_KR').format(education.startDate!)}~${DateFormat('M/d', 'ko_KR').format(education.endDate!)}'
                        : DateFormat('M/d', 'ko_KR').format(education.startDate!))
                    : (education.isOnline ? '온라인' : '오프라인'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
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
            children: [
              Icon(icon, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.textPrimary,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBox(BuildContext context) {
    final items = <Widget>[
      if (!education.isOnline)
        _buildInfoRow(context, Icons.location_on, '위치',
            '${education.province}${education.district != null ? ' ${education.district}' : ''}'),
      if (!education.isOnline) const SizedBox(height: AppTheme.spacing3),
      if (education.startDate != null) ...[
        _buildInfoRow(context, Icons.event_available, '교육 진행일자',
            education.endDate != null && education.endDate != education.startDate
                ? '${DateFormat('yyyy년 M월 d일', 'ko_KR').format(education.startDate!)} ~ ${DateFormat('M월 d일', 'ko_KR').format(education.endDate!)}'
                : DateFormat('yyyy년 M월 d일', 'ko_KR').format(education.startDate!)),
        const SizedBox(height: AppTheme.spacing3),
      ],
      _buildInfoRow(context, Icons.flash_on, '참가비',
          '에너지 ${education.energyCost}개'),
      const SizedBox(height: AppTheme.spacing3),
      _buildInfoRow(context, Icons.people, '신청 현황',
          '${education.applicants}/${education.maxApplicants}명'),
      const SizedBox(height: AppTheme.spacing3),
      _buildInfoRow(context, Icons.calendar_today, '마감일',
          DateFormat('yyyy년 M월 d일', 'ko_KR').format(education.deadline)),
    ];

    return Container(
      width: double.infinity,
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상세 정보',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryPurple),
        const SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              children: [
                TextSpan(text: '$label  ', style: const TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '소개',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Text(
            education.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBox(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
              Icon(icon, size: 18, color: AppTheme.primaryPurple),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          child,
        ],
      ),
    );
  }

  Widget _buildCurriculumSection(BuildContext context) {
    if (education.curriculumSchedule != null && education.curriculumSchedule!.isNotEmpty) {
      return _buildSectionBox(
        context,
        title: '커리큘럼',
        icon: Icons.menu_book,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: education.curriculumSchedule!.map((day) {
            final dateStr = DateFormat('M월 d일', 'ko_KR').format(day.date);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${day.day}일차 ($dateStr)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    day.content,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }
    return _buildSectionBox(
      context,
      title: '커리큘럼',
      icon: Icons.menu_book,
      child: Text(
        education.curriculum ?? '',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 13,
          color: AppTheme.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return _ExpandableReviewsSection(
      title: education.title,
      reviews: education.reviews!,
      averageRating: education.averageRating ?? 0.0,
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return Consumer<EducationDetailViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoadingStatus) {
          return const SizedBox(
            height: 52,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final blockReason = vm.applyBlockReason;
        final enrolled = vm.isEnrolled;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enrolled
                ? () {
                    ShellNavigation.pushEnrollmentDetail(
                      context,
                      vm.enrollment!.id,
                    );
                  }
                : vm.canApply
                    ? () async {
                        final result = await ShellNavigation.pushEducationCheckout(
                          context,
                          education,
                        );
                        if (result == true && context.mounted) {
                          await vm.loadEnrollmentStatus();
                        } else if (context.mounted) {
                          await vm.loadEnrollmentStatus();
                        }
                      }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: enrolled
                  ? AppTheme.primaryGreen
                  : AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.borderGray,
              disabledForegroundColor: AppTheme.textTertiary,
              padding: AppTheme.spacingSymmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
              ),
              elevation: 0,
            ),
            child: Text(
              enrolled
                  ? '신청 내역 보기'
                  : blockReason ?? '신청하기',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            ),
          ),
        );
      },
    );
  }
}

/// 펼치기/접기 가능한 리뷰 섹션
class _ExpandableReviewsSection extends StatefulWidget {
  final String title;
  final List<EducationReview> reviews;
  final double averageRating;

  const _ExpandableReviewsSection({
    required this.title,
    required this.reviews,
    required this.averageRating,
  });

  @override
  State<_ExpandableReviewsSection> createState() => _ExpandableReviewsSectionState();
}

class _ExpandableReviewsSectionState extends State<_ExpandableReviewsSection> {
  static const int _initialCount = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final reviews = widget.reviews;
    final displayedReviews = _expanded ? reviews : reviews.take(_initialCount).toList();
    final hasMore = reviews.length > _initialCount;

    return Container(
      width: double.infinity,
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
              const Icon(Icons.star, size: 18, color: AppTheme.yellow500),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                '리뷰',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              TextButton(
                onPressed: () {
                  ShellNavigation.pushReviews(
                    context,
                    ReviewsListRouteArgs(
                      title: '${widget.title} 리뷰',
                      averageRating: widget.averageRating,
                      reviews: widget.reviews,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '+더보기',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: AppTheme.yellow500),
                  const SizedBox(width: AppTheme.spacing1),
                  Text(
                    widget.averageRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    ' (${reviews.length}개)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          ...displayedReviews.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                              i < r.rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: AppTheme.yellow500,
                            )),
                        const SizedBox(width: AppTheme.spacing2),
                        Text(
                          r.userName,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('M/d', 'ko_KR').format(r.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(
                      r.comment,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )),
          if (hasMore)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() => _expanded = !_expanded);
                },
                child: Text(
                  _expanded ? '접기' : '열기',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
