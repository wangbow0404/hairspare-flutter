import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/schedule_work_session.dart';
import '../../view_models/job_detail_view_model.dart';
import '../common/job_thumbnail.dart';
import 'job_detail_formatters.dart';
import 'job_detail_header.dart';
import 'job_detail_hero_favorite_button.dart';

/// 구인 상세 스크롤 본문 (히어로 ~ 상세 정보).
class JobDetailScrollBody extends StatelessWidget {
  const JobDetailScrollBody({
    super.key,
    required this.job,
    required this.hasApplied,
    this.forShopOwner = false,
    this.onEdit,
    this.onDelete,
  });

  final Job job;
  final bool hasApplied;

  /// 샵 내 공고 미리보기 — 찜·지원 안내 숨김.
  final bool forShopOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JobDetailViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JobDetailHeader(
          onBack: () => NavigationHelper.safePop(context),
          onShare: forShopOwner ? null : vm.shareJob,
          trailing: forShopOwner
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 22),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: AppTheme.urgentRed,
                        ),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                )
              : null,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroSection(context, vm),
                _buildTitleSection(context),
                if (!forShopOwner && vm.isProposalMode)
                  _buildProposalNotice(context, vm),
                if (forShopOwner) _buildShopOwnerStatusBanner(context),
                _buildQuickInfoGrid(context),
                if (!forShopOwner) _buildHowToApplySection(context),
                _buildDetailSection(context),
                SizedBox(height: _scrollBottomPadding(context, vm)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 하단 고정 [JobDetailBottomBar] 높이만큼 스크롤 여백.
  double _scrollBottomPadding(BuildContext context, JobDetailViewModel vm) {
    if (forShopOwner) return AppTheme.spacing6;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    if (vm.isLocked) return 220 + safeBottom;
    if (vm.isProposalMode) return 120 + safeBottom;
    return 100 + safeBottom;
  }

  Widget _buildHeroSection(BuildContext context, JobDetailViewModel vm) {
    return SizedBox(
      height: 288,
      child: Stack(
        fit: StackFit.expand,
        children: [
          JobThumbnail(
            job: job,
            width: double.infinity,
            height: 288,
            borderRadius: BorderRadius.zero,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            top: AppTheme.spacing4,
            left: AppTheme.spacing4,
            child: Row(
              children: [
                if (job.isUrgent)
                  Container(
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing2 - 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.urgentRed,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '급구',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (job.isUrgent && job.isPremium)
                  const SizedBox(width: AppTheme.spacing2),
                if (!forShopOwner && job.isPremium)
                  Container(
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing2 - 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.stitchPrimaryContainer,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '프리미엄',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!forShopOwner)
            Positioned(
              top: AppTheme.spacing4,
              right: AppTheme.spacing4,
              child: JobDetailHeroFavoriteButton(
                isFavorite: vm.isFavorite,
                isLoading: vm.isTogglingFavorite,
                onTap: vm.toggleFavorite,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShopOwnerStatusBanner(BuildContext context) {
    return Padding(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing6,
        vertical: AppTheme.spacing2,
      ),
      child: Wrap(
        spacing: AppTheme.spacing2,
        runSpacing: AppTheme.spacing2,
        children: [
          _shopOwnerPill(
            context,
            label: job.status == 'expired'
                ? '지난 공고'
                : job.status == 'closed'
                    ? '마감'
                    : '진행중',
            fg: job.status == 'expired'
                ? Colors.blue.shade700
                : job.status == 'closed'
                    ? AppTheme.textSecondary
                    : Colors.green.shade700,
            bg: job.status == 'expired'
                ? Colors.blue.shade50
                : job.status == 'closed'
                    ? AppTheme.backgroundGray
                    : Colors.green.shade50,
            border: job.status == 'expired'
                ? Colors.blue.shade200
                : job.status == 'closed'
                    ? AppTheme.borderGray
                    : Colors.green.shade300,
          ),
          if (job.isHidden)
            _shopOwnerPill(
              context,
              label: '숨김',
              fg: AppTheme.textSecondary,
              bg: AppTheme.backgroundGray,
              border: AppTheme.borderGray,
            ),
          if (job.isUrgent)
            _shopOwnerPill(
              context,
              label: '급구',
              fg: AppTheme.urgentRed,
              bg: AppTheme.urgentRed.withValues(alpha: 0.08),
              border: AppTheme.urgentRed.withValues(alpha: 0.35),
            ),
        ],
      ),
    );
  }

  Widget _shopOwnerPill(
    BuildContext context, {
    required String label,
    required Color fg,
    required Color bg,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Padding(
      padding: AppTheme.spacing(AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            job.shopName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              color: AppTheme.textSecondary,
            ),
          ),
          // 급구 카운트다운 배너
          if (job.isUrgent && job.countdown != null) ...[
            const SizedBox(height: AppTheme.spacing6),
            Container(
              padding: AppTheme.spacing(AppTheme.spacing5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.urgentRed, Color(0xFFDC2626)],
                ),
                borderRadius: AppTheme.borderRadius(AppTheme.radius2xl),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⏰ 남은 시간',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing1),
                      Text(
                        jobDetailCountdownText(job.countdown),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '마감 시간',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing1),
                      Text(
                        jobDetailDeadlineTime(job.countdown),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProposalNotice(BuildContext context, JobDetailViewModel vm) {
    final schedule = vm.linkedSchedule;
    if (schedule == null) return const SizedBox.shrink();

    final shop = job.shopName;
    final timeLine = schedule.endTime != null && schedule.endTime!.isNotEmpty
        ? '${schedule.startTime} ~ ${schedule.endTime}'
        : '${schedule.startTime} ~ ${ScheduleWorkSession.formatHm(ScheduleWorkSession.endDateTime(schedule))}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing6,
        0,
        AppTheme.spacing6,
        AppTheme.spacing4,
      ),
      child: Container(
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
            Container(
              padding: AppTheme.spacingSymmetric(
                horizontal: AppTheme.spacing3,
                vertical: AppTheme.spacing1,
              ),
              decoration: BoxDecoration(
                color: AppTheme.purple100,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
              ),
              child: Text(
                '제안 대기',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.purple700,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              '$shop에서 보낸 근무 제안입니다. 내용을 확인한 뒤 하단에서 수락 또는 거절해 주세요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              '일정: ${schedule.date} · $timeLine',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '금액: ${NumberFormat('#,###').format(job.amount)}원',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoGrid(BuildContext context) {
    return Padding(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppTheme.spacing3,
        mainAxisSpacing: AppTheme.spacing3,
        childAspectRatio: 1.6,
        children: [
          _buildQuickInfoItem(
            context,
            icon:
                IconMapper.icon(
                  'mappin',
                  size: 16,
                  color: AppTheme.stitchPrimaryContainer,
                ) ??
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.stitchPrimaryContainer,
                ),
            label: '근무 지역',
            value: jobDetailRegionName(job.regionId),
          ),
          _buildQuickInfoItem(
            context,
            icon:
                IconMapper.icon(
                  'clock',
                  size: 16,
                  color: AppTheme.stitchPrimaryContainer,
                ) ??
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.stitchPrimaryContainer,
                ),
            label: '근무 시간',
            value:
                '${jobDetailFormatJobDate(job.date)}\n${jobDetailFormatJobTime(job)}',
          ),
          _buildQuickInfoItem(
            context,
            icon:
                IconMapper.icon(
                  'users',
                  size: 16,
                  color: AppTheme.primaryGreen,
                ) ??
                const Icon(
                  Icons.people,
                  size: 16,
                  color: AppTheme.primaryGreen,
                ),
            label: '모집 인원',
            value: '${job.requiredCount}명',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(
    BuildContext context, {
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: AppTheme.spacing2),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHowToApplySection(BuildContext context) {
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing6,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3E8FF), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '지원 방법',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '간단한 3단계로 지원이 완료됩니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing6),
          _buildStepItem(
            context,
            step: 1,
            title: '공고 확인하기',
            description: '근무 지역, 시간, 급여 등 상세 정보를 꼼꼼히 확인하세요.',
          ),
          const SizedBox(height: AppTheme.spacing4),
          _buildStepItem(
            context,
            step: 2,
            title: '지원하기 버튼 클릭',
            description: '지원하기 버튼을 눌러 지원을 완료하세요.',
          ),
          const SizedBox(height: AppTheme.spacing4),
          _buildStepItem(
            context,
            step: 3,
            title: '매장 확인 및 출근',
            description: '매장에서 지원을 확인하면 출근 시간에 맞춰 근무하시면 됩니다.',
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context, {
    required int step,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray.withValues(alpha: 0.5)),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.stitchPrimaryContainer,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context) {
    return Padding(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '상세 정보',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          // 급여 정보
          Container(
            width: double.infinity,
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0FDF4), Color(0xFFD1FAE5)],
              ),
              borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.green100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '급여',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.green700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                Text(
                  '${NumberFormat('#,###').format(job.amount)}원',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.green700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing1),
                Text(
                  '당일 지급',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: AppTheme.green700.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          // 근무 조건
          Container(
            width: double.infinity,
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '근무 조건',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                _buildConditionItem(
                  context,
                  '근무 날짜: ${jobDetailFormatJobDate(job.date)}',
                ),
                const SizedBox(height: AppTheme.spacing2),
                _buildConditionItem(
                  context,
                  '근무 시간: ${jobDetailFormatJobTime(job)}',
                ),
                const SizedBox(height: AppTheme.spacing2),
                _buildConditionItem(
                  context,
                  '위치: ${jobDetailRegionName(job.regionId)}',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          // 매장 정보
          Container(
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
                  '매장 정보',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                _buildShopInfoItem(
                  context,
                  '매장명',
                  job.isPremium ? '${job.shopName} (프리미엄)' : job.shopName,
                ),
                const SizedBox(height: AppTheme.spacing3),
                _buildShopInfoItem(
                  context,
                  '위치',
                  '${jobDetailRegionName(job.regionId)} 인근',
                ),
                const SizedBox(height: AppTheme.spacing4),
                _buildContactButton(context),
                const SizedBox(height: AppTheme.spacing4),
                Wrap(
                  spacing: AppTheme.spacing2,
                  runSpacing: AppTheme.spacing2,
                  children: [
                    if (job.isPremium)
                      _buildTag(
                        context,
                        '프리미엄 매장',
                        AppTheme.purple100,
                        AppTheme.purple700,
                      ),
                    _buildTag(
                      context,
                      '최신 시설',
                      AppTheme.blue200.withValues(alpha: 0.3),
                      AppTheme.stitchPrimaryContainer,
                    ),
                    _buildTag(
                      context,
                      '${jobDetailRegionName(job.regionId)} 인근',
                      AppTheme.green100,
                      AppTheme.green700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconMapper.icon(
              'checkcircle2',
              size: 18,
              color: AppTheme.stitchPrimaryContainer,
            ) ??
            const Icon(
              Icons.check_circle,
              size: 18,
              color: AppTheme.stitchPrimaryContainer,
            ),
        const SizedBox(width: AppTheme.spacing2),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: AppTheme.textGray700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildContactButton(BuildContext context) {
    final vm = context.read<JobDetailViewModel>();
    final canContact = hasApplied && !vm.contactBanned;
    final label = vm.contactBanned
        ? '연락처 위반으로 지원 취소됨'
        : (canContact ? '연락하기' : '지원 후 연락 가능');
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: canContact
            ? () async {
                final chatId = await vm.resolveContactChatId();
                if (chatId != null && context.mounted) {
                  NavigationHelper.navigateToChat(context, chatId);
                }
              }
            : null,
        icon: Icon(
          Icons.chat_bubble_outline,
          size: 18,
          color: canContact ? AppTheme.stitchPrimaryContainer : AppTheme.textTertiary,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: canContact ? AppTheme.stitchPrimaryContainer : AppTheme.textTertiary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: canContact ? AppTheme.stitchPrimaryContainer : AppTheme.borderGray,
          ),
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing3,
          ),
        ),
      ),
    );
  }

  Widget _buildShopInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacing1),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTag(
    BuildContext context,
    String text,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
