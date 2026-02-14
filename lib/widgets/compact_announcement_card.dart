import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/space_rental.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';

/// 공고/공간대여/교육 통합 컴팩트 카드 (작은 이미지, 공통 레이아웃)
enum AnnouncementType { job, spaceRental, education }

class CompactAnnouncementCard extends StatelessWidget {
  final AnnouncementType type;
  final Job? job;
  final SpaceRental? spaceRental;
  final dynamic education; // Education from education_screen
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const CompactAnnouncementCard({
    super.key,
    required this.type,
    this.job,
    this.spaceRental,
    this.education,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(AppTheme.spacing4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 작은 이미지 (80x80)
                    _buildImage(context),
                    SizedBox(width: AppTheme.spacing3),
                    Expanded(
                      child: _buildContent(context),
                    ),
                  ],
                ),
              ),
              if (onFavoriteToggle != null)
                Positioned(
                  top: AppTheme.spacing2,
                  right: AppTheme.spacing2,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onFavoriteToggle,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacing2),
                        child: IconMapper.icon(
                          'heart',
                          size: 20,
                          color: isFavorite ? AppTheme.urgentRed : AppTheme.textTertiary,
                        ) ??
                            Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isFavorite ? AppTheme.urgentRed : AppTheme.textTertiary,
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    Color color1;
    Color color2;
    IconData icon;
    String? imageUrl;
    switch (type) {
      case AnnouncementType.job:
        color1 = AppTheme.green200;
        color2 = AppTheme.blue200;
        icon = Icons.work;
        imageUrl = job?.images != null && job!.images!.isNotEmpty ? job!.images!.first : null;
        break;
      case AnnouncementType.spaceRental:
        color1 = AppTheme.primaryPurple.withOpacity(0.3);
        color2 = AppTheme.primaryBlue.withOpacity(0.3);
        icon = Icons.store;
        imageUrl = spaceRental?.imageUrls != null && spaceRental!.imageUrls!.isNotEmpty
            ? spaceRental!.imageUrls!.first
            : null;
        break;
      case AnnouncementType.education:
        color1 = AppTheme.primaryPurple.withOpacity(0.3);
        color2 = AppTheme.primaryBlue.withOpacity(0.3);
        icon = Icons.school;
        imageUrl = education?.imageUrl;
        break;
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
      ),
      child: ClipRRect(
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        child: imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(icon, size: 32, color: Colors.white.withOpacity(0.8)),
              )
            : Icon(icon, size: 32, color: Colors.white.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (type) {
      case AnnouncementType.job:
        return _buildJobContent(context);
      case AnnouncementType.spaceRental:
        return _buildSpaceRentalContent(context);
      case AnnouncementType.education:
        return _buildEducationContent(context);
    }
  }

  Widget _buildJobContent(BuildContext context) {
    if (job == null) return const SizedBox.shrink();
    final j = job!;
    final timeTag = _getTimeTag(j.time);
    final isShortTerm = _isShortTerm(j.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppTheme.spacing2,
          runSpacing: AppTheme.spacing1,
          children: [
            _tag(timeTag, AppTheme.green100, AppTheme.green700),
            _tag(isShortTerm ? '단기' : '장기', isShortTerm ? AppTheme.purple100 : AppTheme.backgroundGray, AppTheme.textSecondary),
          ],
        ),
        SizedBox(height: AppTheme.spacing1),
        // 공고 메인: 제목이 가장 크게
        Text(
          j.title.isNotEmpty ? j.title : '공고',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if ((j.shopName ?? '').isNotEmpty) ...[
          SizedBox(height: AppTheme.spacing1),
          Text(
            j.shopName!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        SizedBox(height: AppTheme.spacing1),
        Text(
          '${j.date} ${j.time ?? ''}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppTheme.spacing1),
        Text(
          '금액: ₩${NumberFormat('#,###').format(j.amount)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSpaceRentalContent(BuildContext context) {
    if (spaceRental == null) return const SizedBox.shrink();
    final s = spaceRental!;
    final slotStr = _getSpaceTimeSummary(s);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tag('공간대여', AppTheme.primaryPurple.withOpacity(0.15), AppTheme.primaryPurple),
        SizedBox(height: AppTheme.spacing1),
        Text(
          s.shopName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppTheme.spacing1),
        Text(
          s.fullAddress,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppTheme.spacing1),
        Text(
          '시간당 ₩${NumberFormat('#,###').format(s.pricePerHour)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (slotStr.isNotEmpty)
          Text(
            slotStr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppTheme.primaryBlue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildEducationContent(BuildContext context) {
    if (education == null) return const SizedBox.shrink();
    // education has: title, description, price, province, district, deadline, isOnline, isUrgent, applicants, maxApplicants
    final e = education;
    final title = e.title ?? '교육';
    final price = e.price ?? 0;
    final deadline = e.deadline;
    final isOnline = e.isOnline ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppTheme.spacing2,
          runSpacing: AppTheme.spacing1,
          children: [
            if (e.isUrgent == true) _tag('급구', AppTheme.urgentRed.withOpacity(0.2), AppTheme.urgentRed),
            _tag(isOnline ? '온라인' : '오프라인', Colors.blue.shade100, Colors.blue.shade700),
          ],
        ),
        SizedBox(height: AppTheme.spacing1),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppTheme.spacing1),
        if (deadline != null)
          Text(
            '마감: ${DateFormat('yyyy-MM-dd').format(deadline is DateTime ? deadline : DateTime.parse(deadline.toString()))}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        SizedBox(height: AppTheme.spacing1),
        Text(
          '금액: ₩${NumberFormat('#,###').format(price)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _tag(String label, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing2, vertical: AppTheme.spacing1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }

  String _getTimeTag(String? timeStr) {
    if (timeStr == null) return '오후';
    try {
      final hour = int.parse(timeStr.split(':')[0]);
      if (hour >= 6 && hour < 12) return '오전';
      if (hour >= 12 && hour < 18) return '오후';
      if (hour >= 18 && hour < 22) return '저녁';
      return '야간';
    } catch (e) {
      return '오후';
    }
  }

  bool _isShortTerm(String? date) {
    if (date == null) return false;
    try {
      final jobDate = DateTime.parse(date);
      final today = DateTime.now();
      return jobDate.difference(DateTime(today.year, today.month, today.day)).inDays == 0;
    } catch (e) {
      return false;
    }
  }

  String _getSpaceTimeSummary(SpaceRental s) {
    if (s.availableSlots.isEmpty) return '';
    final slots = s.availableSlots.where((slot) => slot.isAvailable).toList();
    if (slots.isEmpty) return '';
    slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    final first = slots.first;
    final today = DateTime.now();
    final slotDate = DateTime(first.startTime.year, first.startTime.month, first.startTime.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysDiff = slotDate.difference(todayDate).inDays;
    String dateStr;
    if (daysDiff == 0) {
      dateStr = '오늘';
    } else if (daysDiff == 1) {
      dateStr = '내일';
    } else {
      dateStr = DateFormat('M/d', 'ko_KR').format(slotDate);
    }
    return '$dateStr ${DateFormat('HH:mm').format(first.startTime)}-${DateFormat('HH:mm').format(first.endTime)}';
  }
}
