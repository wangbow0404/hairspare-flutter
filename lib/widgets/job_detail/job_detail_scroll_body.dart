import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/job.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../utils/job_filter_utils.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/schedule_work_session.dart';
import '../../view_models/job_detail_view_model.dart';
import '../common/app_network_image.dart';
import '../common/job_thumbnail.dart';
import 'job_detail_formatters.dart';
import 'job_detail_header.dart';
import 'job_detail_hero_favorite_button.dart';

/// 구인 상세 스크롤 본문 (히어로 ~ 상세 정보). PDF a안 02 화면 기준.
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
                          color: HairSpareColors.statusUrgent,
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
                if (forShopOwner) _buildShopOwnerStatusBanner(context),
                _buildTitleSection(context),
                if (job.isUrgent && job.countdown != null)
                  _buildUrgentCountdown(context),
                if (!forShopOwner && vm.isProposalMode)
                  _buildProposalNotice(context, vm),
                _buildInfoTable(context),
                if (job.description != null && job.description!.trim().isNotEmpty)
                  _buildDescriptionSection(context),
                _buildLocationSection(context),
                if (!forShopOwner) ...[
                  const SizedBox(height: AppTheme.spacing2),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                    ),
                    child: _buildContactButton(context),
                  ),
                ],
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
    return _JobDetailHeroCarousel(
      job: job,
      vm: vm,
      forShopOwner: forShopOwner,
    );
  }

  Widget _buildShopOwnerStatusBanner(BuildContext context) {
    return Padding(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
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

  /// 제목(샵명·지역) + 지역 + 초보가능/당일정산 태그.
  Widget _buildTitleSection(BuildContext context) {
    final regionName = jobDetailRegionName(job.regionId);
    final tags = <String>[
      if (JobFilterUtils.matches('beginner', job)) '초보가능',
      if (JobFilterUtils.matches('same_day', job)) '당일정산',
    ];

    return Padding(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            regionName.isNotEmpty ? '${job.shopName} · $regionName' : job.shopName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: HairSpareColors.textPrimary,
            ),
          ),
          if (regionName.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing1),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: HairSpareColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  regionName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: HairSpareColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing3),
            Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing3,
                        vertical: AppTheme.spacing1,
                      ),
                      decoration: BoxDecoration(
                        color: HairSpareColors.surfaceMuted,
                        borderRadius:
                            AppTheme.borderRadius(AppTheme.radiusFull),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: HairSpareColors.textStrong,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUrgentCountdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        0,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      child: Container(
        padding: AppTheme.spacingSymmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing3,
        ),
        decoration: BoxDecoration(
          color: HairSpareColors.statusUrgent.withValues(alpha: 0.08),
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
          border: Border.all(
            color: HairSpareColors.statusUrgent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '마감까지 ${jobDetailCountdownText(job.countdown)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: HairSpareColors.statusUrgent,
              ),
            ),
            Text(
              jobDetailDeadlineTime(job.countdown),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: HairSpareColors.statusUrgent,
              ),
            ),
          ],
        ),
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
        AppTheme.spacing4,
        0,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      child: Container(
        width: double.infinity,
        padding: AppTheme.spacing(AppTheme.spacing4),
        decoration: BoxDecoration(
          color: HairSpareColors.surfaceMuted,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
          border: Border.all(color: HairSpareColors.border),
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
                color: HairSpareColors.brandPrimarySoft,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
              ),
              child: const Text(
                '제안 대기',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: HairSpareColors.brandPrimary,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              '$shop에서 보낸 근무 제안입니다. 내용을 확인한 뒤 하단에서 수락 또는 거절해 주세요.',
              style: const TextStyle(
                fontSize: 14,
                color: HairSpareColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              '일정: ${schedule.date} · $timeLine',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: HairSpareColors.textPrimary,
              ),
            ),
            Text(
              '금액: ${NumberFormat('#,###').format(job.amount)}원',
              style: const TextStyle(
                fontSize: 13,
                color: HairSpareColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 일정 / 역할 / 급여 정보 테이블 (PDF a안 02).
  Widget _buildInfoTable(BuildContext context) {
    return Padding(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      child: Column(
        children: [
          _infoRow(
            context,
            label: '일정',
            value:
                '${jobDetailRelativeDayLabel(job.date)} ${jobDetailFormatJobTime(job)}',
          ),
          const Divider(height: AppTheme.spacing6, color: HairSpareColors.border),
          _infoRow(context, label: '역할', value: job.title),
          const Divider(height: AppTheme.spacing6, color: HairSpareColors.border),
          _infoRow(
            context,
            label: '급여',
            value: '${NumberFormat('#,###').format(job.amount)}원',
            valueColor: HairSpareColors.brandPrimary,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: HairSpareColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: valueColor ?? HairSpareColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Padding(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '공고 설명',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: HairSpareColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Text(
            job.description!.trim(),
            style: const TextStyle(
              fontSize: 14,
              color: HairSpareColors.textStrong,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  /// 위치 — 실제 좌표 데이터가 없어 정적 플레이스홀더 + 외부 지도 앱 검색으로 대체.
  Widget _buildLocationSection(BuildContext context) {
    final regionName = jobDetailRegionName(job.regionId);
    final query = Uri.encodeComponent('${job.shopName} $regionName');

    return Padding(
      padding: AppTheme.spacingSymmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '위치',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: HairSpareColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: HairSpareColors.placeholderWarm,
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: const Center(
              child: Icon(
                Icons.location_on,
                size: 32,
                color: HairSpareColors.brandPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          Row(
            children: [
              Expanded(
                child: Text(
                  regionName.isEmpty ? job.shopName : '$regionName · ${job.shopName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: HairSpareColors.textStrong,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse('https://map.naver.com/p/search/$query'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text(
                  '지도에서 보기 >',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: HairSpareColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          color: canContact ? HairSpareColors.brandPrimary : AppTheme.textTertiary,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: canContact ? HairSpareColors.brandPrimary : AppTheme.textTertiary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: canContact ? HairSpareColors.brandPrimary : AppTheme.borderGray,
          ),
          padding: AppTheme.spacingSymmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing3,
          ),
        ),
      ),
    );
  }
}

/// 공고 상세 히어로 이미지 캐러셀. 이미지가 여러 장이면 좌우 스와이프로 넘길 수 있다.
class _JobDetailHeroCarousel extends StatefulWidget {
  const _JobDetailHeroCarousel({
    required this.job,
    required this.vm,
    required this.forShopOwner,
  });

  final Job job;
  final JobDetailViewModel vm;
  final bool forShopOwner;

  @override
  State<_JobDetailHeroCarousel> createState() => _JobDetailHeroCarouselState();
}

class _JobDetailHeroCarouselState extends State<_JobDetailHeroCarousel> {
  int _currentPage = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    final images = widget.job.images ?? [];
    if (page < 0 || page >= images.length) return;
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.job.images ?? [];
    final job = widget.job;
    final vm = widget.vm;

    return SizedBox(
      height: 288,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 이미지 영역 — GestureDetector로 좌우 드래그 수동 처리
          if (images.isNotEmpty)
            GestureDetector(
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < -200) _goTo(_currentPage + 1);
                if (v > 200) _goTo(_currentPage - 1);
              },
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (_, index) => AppNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            JobThumbnail(
              job: job,
              width: double.infinity,
              height: 288,
              borderRadius: BorderRadius.zero,
            ),
          // 상단→중앙 그라데이션 오버레이
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
          // 급구 · 프리미엄 배지
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
                      color: HairSpareColors.statusUrgent,
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
                if (!widget.forShopOwner && job.isPremium)
                  Container(
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing3,
                      vertical: AppTheme.spacing2 - 2,
                    ),
                    decoration: BoxDecoration(
                      color: HairSpareColors.brandPrimary,
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
          // 찜 버튼 (스페어 전용)
          if (!widget.forShopOwner)
            Positioned(
              top: AppTheme.spacing4,
              right: AppTheme.spacing4,
              child: JobDetailHeroFavoriteButton(
                isFavorite: vm.isFavorite,
                isLoading: vm.isTogglingFavorite,
                onTap: vm.toggleFavorite,
              ),
            ),
          // 좌우 화살표 버튼 (2장 이상, 클릭으로 넘기기)
          if (images.length > 1) ...[
            if (_currentPage > 0)
              Positioned(
                left: AppTheme.spacing2,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _goTo(_currentPage - 1),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentPage < images.length - 1)
              Positioned(
                right: AppTheme.spacing2,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _goTo(_currentPage + 1),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
          // 페이지 인디케이터 (2장 이상)
          if (images.length > 1)
            Positioned(
              bottom: AppTheme.spacing3,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
