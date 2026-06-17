import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../models/schedule.dart';
import '../../services/review_service.dart';
import '../../services/schedule_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/schedule_work_session.dart';
import '../../utils/schedule_cancel_flow.dart';
import '../../utils/schedule_cancellation_policy.dart';
import '../../widgets/common/glass_modal.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/korean_table_calendar_builders.dart';
import '../../widgets/schedule/schedule_refined_list_card.dart';
import '../../widgets/schedule/schedule_work_complete_review_modal.dart';
import '../../utils/navigation_helper.dart';

/// Next.js와 동일한 스케줄 화면
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    super.key,
    this.initialDay,
    this.focusJobId,
    this.focusScheduleId,
    this.openProposalReview = false,
  });

  final DateTime? initialDay;
  final String? focusJobId;
  final String? focusScheduleId;
  final bool openProposalReview;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  Schedule? _selectedSchedule;
  Schedule? _reviewSchedule;
  bool _reviewSubmitting = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final ScheduleService _scheduleService = ScheduleService();
  Timer? _phaseRefreshTimer;

  @override
  void initState() {
    super.initState();
    final day = widget.initialDay;
    _selectedDay = day != null
        ? DateTime(day.year, day.month, day.day)
        : DateTime.now();
    _focusedDay = _selectedDay!;
    _loadSchedules();
    _phaseRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted && !_isLoading && _schedules.isNotEmpty) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _phaseRefreshTimer?.cancel();
    super.dispose();
  }

  int _getDDay(DateTime scheduleDate) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final target = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
    );
    return target.difference(today).inDays;
  }

  String _getDDayLabel(DateTime scheduleDate) {
    final d = _getDDay(scheduleDate);
    if (d < 0) return '완료';
    if (d == 0) return 'D-day';
    return 'D-$d';
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final schedules = await _scheduleService.getSchedules();
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
      _applyDeepLinkFocus();
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage =
            error.toString().contains('connection errored') ||
                error.toString().contains('XMLHttpRequest')
            ? '서버에 연결할 수 없습니다. Next.js 서버가 실행 중인지 확인해주세요.'
            : '스케줄을 불러오는 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Schedule? _findFocusSchedule() {
    if (widget.focusScheduleId != null) {
      final byId = _schedules
          .where((s) => s.id == widget.focusScheduleId)
          .toList();
      if (byId.isNotEmpty) return byId.first;
    }
    if (widget.focusJobId != null) {
      final byJob = _schedules
          .where((s) => s.jobId == widget.focusJobId)
          .toList();
      if (byJob.isNotEmpty) return byJob.first;
    }
    return null;
  }

  void _applyDeepLinkFocus() {
    if (!mounted) return;
    final focus = _findFocusSchedule();
    if (focus != null) {
      final parsed = DateTime.tryParse(focus.date);
      if (parsed != null) {
        setState(() {
          _selectedDay = DateTime(parsed.year, parsed.month, parsed.day);
          _focusedDay = _selectedDay!;
        });
      }
    }

    if (!widget.openProposalReview) return;
    Schedule? proposal;
    if (focus != null && focus.status == 'proposed') {
      proposal = focus;
    } else {
      for (final s in _schedules) {
        if (s.status != 'proposed') continue;
        if (widget.focusJobId != null && s.jobId != widget.focusJobId) {
          continue;
        }
        proposal = s;
        break;
      }
    }
    if (proposal == null) return;
    final proposalSchedule = proposal;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final resolved = await NavigationHelper.navigateToWorkProposalDetail(
        context,
        proposalSchedule,
      );
      if (resolved == true && mounted) {
        await _loadSchedules();
      }
    });
  }

  void _handleScheduleClick(Schedule schedule) {
    if (schedule.status == 'proposed') {
      NavigationHelper.navigateToWorkProposalDetail(context, schedule).then((
        resolved,
      ) {
        if (resolved == true && mounted) {
          _loadSchedules();
        }
      });
      return;
    }
    setState(() {
      _selectedSchedule = schedule;
    });
  }

  void _closeReviewModal() {
    if (_reviewSubmitting) return;
    setState(() => _reviewSchedule = null);
  }

  void _replaceScheduleInList(Schedule updated) {
    final i = _schedules.indexWhere((x) => x.id == updated.id);
    if (i >= 0) {
      _schedules = List<Schedule>.from(_schedules)..[i] = updated;
    }
  }

  void _onWorkCheck(Schedule schedule) {
    final messenger = sl<GlobalMessengerService>();
    final blocked = ScheduleWorkSession.workCheckBlockedMessage(
      schedule,
      DateTime.now(),
    );
    if (blocked != null) {
      messenger.showInfo(blocked);
      return;
    }
    setState(() => _reviewSchedule = schedule);
  }

  Future<void> _submitThumbsUp() async {
    final s = _reviewSchedule;
    if (s == null || _reviewSubmitting) return;
    setState(() => _reviewSubmitting = true);
    final messenger = sl<GlobalMessengerService>();
    try {
      final updated = await sl<ScheduleService>().checkInSchedule(s.id);
      try {
        await sl<ReviewService>().sendThumbsUp(jobId: s.jobId);
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _reviewSubmitting = false;
        _reviewSchedule = null;
        _replaceScheduleInList(updated);
      });
      messenger.showSuccess('근무체크가 완료되었습니다!');
    } catch (_) {
      if (mounted) {
        setState(() => _reviewSubmitting = false);
      }
      messenger.showError('근무 체크에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  Future<void> _submitCheckInOnly() async {
    final s = _reviewSchedule;
    if (s == null || _reviewSubmitting) return;
    setState(() => _reviewSubmitting = true);
    final messenger = sl<GlobalMessengerService>();
    try {
      final updated = await sl<ScheduleService>().checkInSchedule(s.id);
      if (!mounted) return;
      setState(() {
        _reviewSubmitting = false;
        _reviewSchedule = null;
        _replaceScheduleInList(updated);
      });
      messenger.showSuccess('근무체크가 완료되었습니다!');
    } catch (_) {
      if (mounted) {
        setState(() => _reviewSubmitting = false);
      }
      messenger.showError('근무 체크에 실패했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  void _onScheduleCancelledLocally(String scheduleId) {
    setState(() {
      _schedules.removeWhere((s) => s.id == scheduleId);
      _selectedSchedule = null;
    });
  }

  Map<String, List<Schedule>> _groupSchedulesByDate() {
    final grouped = <String, List<Schedule>>{};
    for (final schedule in _schedules) {
      if (!grouped.containsKey(schedule.date)) {
        grouped[schedule.date] = [];
      }
      grouped[schedule.date]!.add(schedule);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SpareSubpageAppBar(
          title: '스케줄표',
          showBackButton: Navigator.canPop(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final schedulesByDate = _groupSchedulesByDate();
    final sortedDates = schedulesByDate.keys.toList()..sort();

    // 선택된 날짜에 해당하는 스케줄만 표시 (선택 없으면 전체)
    final datesToShow = _selectedDay != null
        ? sortedDates.where((d) {
            final dt = DateTime.parse(d);
            return dt.year == _selectedDay!.year &&
                dt.month == _selectedDay!.month &&
                dt.day == _selectedDay!.day;
          }).toList()
        : sortedDates;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '스케줄표',
        showBackButton: Navigator.canPop(context),
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 70,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 월별 캘린더
                  Container(
                    margin: AppTheme.spacing(AppTheme.spacing4),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundWhite,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(color: AppTheme.borderGray),
                      boxShadow: AppTheme.stitchSoftShadow,
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selected, focused) {
                        setState(() {
                          _selectedDay = selected;
                          _focusedDay = focused;
                        });
                      },
                      onPageChanged: (focused) {
                        setState(() => _focusedDay = focused);
                      },
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (format) {
                        setState(() => _calendarFormat = format);
                      },
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                        CalendarFormat.twoWeeks: '2 weeks',
                      },
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: false,
                      ),
                      locale: 'ko_KR',
                      eventLoader: (day) {
                        final key =
                            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                        return schedulesByDate.containsKey(key) ? [''] : [];
                      },
                      calendarStyle: const CalendarStyle(
                        markerDecoration: BoxDecoration(
                          color: AppTheme.stitchPrimaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                      calendarBuilders: KoreanTableCalendarBuilders.forSelection(
                        selectedDay: _selectedDay ?? _focusedDay,
                      ),
                    ),
                  ),
                  if (sortedDates.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      child: StitchEmptyState(
                        message: '확정된 일정이 없습니다',
                        iconName: 'calendar',
                      ),
                    )
                  else if (datesToShow.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      child: StitchEmptyState(
                        message: '선택한 날짜에 일정이 없습니다',
                        iconName: 'calendar',
                      ),
                    )
                  else
                    ...datesToShow.map((date) {
                      final schedules = schedulesByDate[date]!;
                      final dateTime = DateTime.parse(date);
                      final today = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      );
                      final dayOnly = DateTime(
                        dateTime.year,
                        dateTime.month,
                        dateTime.day,
                      );
                      final isPast = dayOnly.isBefore(today);

                      return Container(
                        margin: const EdgeInsets.only(
                          left: AppTheme.spacing4,
                          right: AppTheme.spacing4,
                          bottom: AppTheme.spacing6,
                        ),
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          color: AppTheme.backgroundWhite,
                          boxShadow: AppTheme.stitchSoftShadow,
                          border: Border.all(color: AppTheme.borderGray),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat(
                                      'yyyy년 M월 d일 (E)',
                                      'ko_KR',
                                    ).format(dateTime),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                          color: AppTheme.textPrimary,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacing2),
                                Container(
                                  padding: AppTheme.spacingSymmetric(
                                    horizontal: AppTheme.spacing3,
                                    vertical: AppTheme.spacing1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPast
                                        ? AppTheme.surfaceContainerLow
                                        : AppTheme.primaryPurpleLight,
                                    borderRadius: AppTheme.borderRadius(
                                      AppTheme.radiusFull,
                                    ),
                                  ),
                                  child: Text(
                                    _getDDayLabel(dateTime),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isPast
                                              ? AppTheme.stitchTextSecondary
                                              : AppTheme.stitchPrimary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing3),
                            ...schedules.map((schedule) {
                              final now = DateTime.now();
                              final statusLabel = schedule.status == 'proposed'
                                  ? '제안 대기'
                                  : ScheduleWorkSession.statusTagLabel(
                                      schedule,
                                      now,
                                    );
                              final showWorkCheck =
                                  schedule.status != 'completed' &&
                                  schedule.status != 'proposed' &&
                                  schedule.checkInTime == null;
                              final workCheckReady =
                                  ScheduleWorkSession.isWorkCheckReady(
                                    schedule,
                                    now,
                                  );

                              return ScheduleRefinedListCard(
                                schedule: schedule,
                                statusLabel: statusLabel,
                                workCheckReady: workCheckReady,
                                onCardTap: () => _handleScheduleClick(schedule),
                                onWorkCheckTap: () => _onWorkCheck(schedule),
                                showWorkCheckButton: showWorkCheck,
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            // 스케줄 상세 모달
            if (_selectedSchedule != null)
              _ScheduleDetailModal(
                schedule: _selectedSchedule!,
                onClose: () {
                  setState(() {
                    _selectedSchedule = null;
                  });
                },
                onCancelled: _onScheduleCancelledLocally,
              ),
            if (_reviewSchedule != null)
              ScheduleWorkCompleteReviewModal(
                shopName: _reviewSchedule!.job?.shopName ?? '매장',
                jobTitle: _reviewSchedule!.job?.title ?? '공고',
                onClose: _closeReviewModal,
                onThumbsUp: _submitThumbsUp,
                onCheckInOnly: _submitCheckInOnly,
                isSubmitting: _reviewSubmitting,
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleDetailModal extends StatefulWidget {
  final Schedule schedule;
  final VoidCallback onClose;
  final ValueChanged<String> onCancelled;

  const _ScheduleDetailModal({
    required this.schedule,
    required this.onClose,
    required this.onCancelled,
  });

  @override
  State<_ScheduleDetailModal> createState() => _ScheduleDetailModalState();
}

class _ScheduleDetailModalState extends State<_ScheduleDetailModal> {
  bool _isCancelling = false;

  Future<void> _handleCancel() async {
    if (_isCancelling) return;
    setState(() => _isCancelling = true);
    try {
      await ScheduleCancelFlow.requestCancel(
        context: context,
        schedule: widget.schedule,
        actor: CancellationActor.spare,
        onSuccess: () {
          widget.onCancelled(widget.schedule.id);
          widget.onClose();
        },
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleDate = DateTime.parse(widget.schedule.date);
    final isPast = scheduleDate.isBefore(DateTime.now());
    final eligibility = ScheduleCancellationPolicy.evaluate(
      widget.schedule,
      context: CancellationContext.scheduleDetail,
      actor: CancellationActor.spare,
    );
    final canCancel = eligibility.canCancelInApp;
    final showBlockedBanner = !canCancel &&
        eligibility.status != CancellationEligibilityStatus.blockedAlreadyCancelled;

    return GlassModal(
      onDismiss: widget.onClose,
      isLocked: _isCancelling,
      child: GlassModalPanel(
        width: math.min(
          448,
          MediaQuery.sizeOf(context).width - AppTheme.spacing4 * 2,
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassModalHeader(
                title: '스케줄 상세',
                onClose: widget.onClose,
                isCloseEnabled: !_isCancelling,
              ),
              const SizedBox(height: 8),
              const Center(
                child: GlassModalHeroIcon(
                  emoji: '📋',
                  size: 56,
                  gradientColors: [
                    Color(0xFFE0E7FF),
                    Color(0xFFF5F3FF),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.schedule.job?.title ?? '공고 제목 없음',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      Text(
                        widget.schedule.job?.shopName ?? '매장명 없음',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      _buildInfoRow(
                        IconMapper.icon(
                              'calendar',
                              size: 20,
                              color: AppTheme.textTertiary,
                            ) ??
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppTheme.textTertiary,
                            ),
                        DateFormat(
                          'yyyy년 M월 d일 (E)',
                          'ko_KR',
                        ).format(scheduleDate),
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      _buildInfoRow(
                        IconMapper.icon(
                              'clock',
                              size: 20,
                              color: AppTheme.textTertiary,
                            ) ??
                            const Icon(
                              Icons.access_time,
                              size: 20,
                              color: AppTheme.textTertiary,
                            ),
                        '${widget.schedule.startTime}${widget.schedule.endTime != null ? ' ~ ${widget.schedule.endTime}' : ''}',
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      _buildInfoRow(
                        IconMapper.icon(
                              'dollarsign',
                              size: 20,
                              color: AppTheme.textTertiary,
                            ) ??
                            const Icon(
                              Icons.attach_money,
                              size: 20,
                              color: AppTheme.textTertiary,
                            ),
                        '${NumberFormat('#,###').format(widget.schedule.job?.amount ?? 0)}원',
                      ),
                      const SizedBox(height: AppTheme.spacing2),
                      _buildInfoRow(
                        IconMapper.icon(
                              'users',
                              size: 20,
                              color: AppTheme.textTertiary,
                            ) ??
                            const Icon(
                              Icons.people,
                              size: 20,
                              color: AppTheme.textTertiary,
                            ),
                        '필요 인원: ${widget.schedule.job?.requiredCount ?? 0}명',
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      if (canCancel)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isCancelling ? null : _handleCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.urgentRed,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: AppTheme.spacing(AppTheme.spacing3),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.borderRadius(
                                  AppTheme.radiusLg,
                                ),
                              ),
                            ),
                            child: Text(
                              _isCancelling ? '취소 중...' : '스케줄 취소',
                            ),
                          ),
                        )
                          else if (showBlockedBanner)
                        Container(
                          width: double.infinity,
                          padding: AppTheme.spacing(AppTheme.spacing3),
                          decoration: BoxDecoration(
                            color: AppTheme.orange50.withValues(alpha: 0.55),
                            borderRadius: AppTheme.borderRadius(
                              AppTheme.radiusLg,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          child: Text(
                            eligibility.blockedMessage ??
                                '앱에서 취소할 수 없는 일정입니다.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.orange600,
                                  height: 1.45,
                                ),
                          ),
                        ),
                      if (isPast)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppTheme.spacing2,
                          ),
                          child: Text(
                            '이미 지난 스케줄입니다',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(Widget icon, String text) {
    return Row(
      children: [
        icon,
        const SizedBox(width: AppTheme.spacing2),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: AppTheme.textGray700,
          ),
        ),
      ],
    );
  }
}
