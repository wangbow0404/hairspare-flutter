import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/education_enrollment.dart';
import '../models/schedule.dart';
import '../services/education_service.dart';
import '../services/review_service.dart';
import '../services/schedule_service.dart';
import '../utils/error_handler.dart';
import '../utils/schedule_session_audience.dart';
import '../utils/schedule_work_session.dart';

/// 스페어 근무체크 화면 ViewModel (캘린더·체크인·평가 모달 상태).
class WorkCheckViewModel extends ChangeNotifier {
  WorkCheckViewModel({
    ScheduleService? scheduleService,
    ReviewService? reviewService,
    EducationService? educationService,
    DateTime? initialDay,
    String? focusJobId,
    String? focusScheduleId,
    this.isModelMode = false,
  }) : _scheduleService = scheduleService ?? sl<ScheduleService>(),
       _reviewService = reviewService ?? sl<ReviewService>(),
       _educationService = educationService ?? sl<EducationService>(),
       _initialDay = initialDay,
       _focusJobId = focusJobId,
       _focusScheduleId = focusScheduleId;

  final DateTime? _initialDay;
  final String? _focusJobId;
  final String? _focusScheduleId;
  final bool isModelMode;

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final ScheduleService _scheduleService;
  final ReviewService _reviewService;
  final EducationService _educationService;

  List<Schedule> schedules = [];
  List<EducationEnrollment> educationEnrollments = [];
  int consecutiveDays = 0;
  int energyFromWork = 0;
  bool isLoading = true;
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  String? selectedScheduleId;
  Set<String> checkedDays = {};
  Set<String> viewedDates = {};
  Map<String, String> pendingApprovals = {};

  /// 달력에서 일정 있는 날짜를 누르거나 미체크 배너를 누를 때마다 증가한다.
  /// 스크롤 컨트롤러를 가진 화면이 이 값의 변화를 감지해 선택된 근무 카드로
  /// 스크롤한다.
  int scrollToCardRequest = 0;

  bool showRatingModal = false;
  String? ratedShopName;
  String? ratedJobId;
  String? ratedJobTitle;
  bool reviewSubmitting = false;

  bool isSearchOpen = false;

  Future<void> loadInitial() => loadData();

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();
    try {
      await _loadSchedules();
      await _loadEducationEnrollments();
      await _loadWorkCheckStats();
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
    } finally {
      isLoading = false;
      _applyInitialFocus();
      if (isModelMode && selectedScheduleId == null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
        if (hasScheduledWork(selectedDate)) {
          final first = schedules.where(
            (s) => s.date == dateStr && s.status == 'scheduled',
          );
          if (first.isNotEmpty) {
            selectedScheduleId = first.first.id;
          }
        }
      }
      notifyListeners();
    }
  }

  void _applyInitialFocus() {
    final day = _initialDay;
    if (day != null) {
      selectedDate = DateTime(day.year, day.month, day.day);
      currentMonth = DateTime(day.year, day.month);
    }

    final schedule = findScheduleForFocus(
      scheduleId: _focusScheduleId,
      jobId: _focusJobId,
    );
    if (schedule != null) {
      selectedScheduleId = schedule.id;
      final parsed = DateTime.tryParse(schedule.date);
      if (parsed != null) {
        selectedDate = DateTime(parsed.year, parsed.month, parsed.day);
        currentMonth = DateTime(parsed.year, parsed.month);
      }
    }
  }

  /// 알림·deep link용 — 제안/확정/출근 등 모든 확정 일정 조회.
  Schedule? findScheduleForFocus({String? scheduleId, String? jobId}) {
    if (scheduleId != null) {
      for (final s in schedules) {
        if (s.id == scheduleId) return s;
      }
    }
    if (jobId != null) {
      for (final s in schedules) {
        if (s.jobId == jobId &&
            s.status != 'rejected' &&
            s.status != 'cancelled') {
          return s;
        }
      }
    }
    return null;
  }

  bool get hasDeepLinkScheduleFocus =>
      _focusScheduleId != null || _focusJobId != null;

  Schedule? findScheduleForProposal({String? scheduleId, String? jobId}) {
    final focused = findScheduleForFocus(
      scheduleId: scheduleId,
      jobId: jobId,
    );
    if (focused != null && focused.status == 'proposed') {
      return focused;
    }
    if (scheduleId != null) return null;
    for (final s in schedules) {
      if (s.status == 'proposed') return s;
    }
    return null;
  }

  Future<void> _loadEducationEnrollments() async {
    try {
      educationEnrollments = await _educationService.getMyEnrollments();
      notifyListeners();
    } catch (e) {
      debugPrint('교육 신청 로드 오류: $e');
    }
  }

  bool hasEducationOnDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return educationEnrollments.any((e) => e.scheduleDateYmd == dateStr);
  }

  bool hasAnyCalendarEvent(DateTime date) =>
      hasScheduledWork(date) || hasEducationOnDate(date);

  List<EducationEnrollment> getEnrollmentsForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return educationEnrollments
        .where((e) => e.scheduleDateYmd == dateStr)
        .toList();
  }

  Future<void> _loadSchedules() async {
    try {
      final list = await _scheduleService.getSchedules(
        ownerId: isModelMode ? 'model' : 'me',
      );
      schedules = list;
      final completedDates = <String>{};
      for (final schedule in list) {
        if (schedule.status == 'completed') {
          completedDates.add(schedule.date);
        }
      }
      checkedDays = completedDates;
      notifyListeners();
    } catch (e) {
      debugPrint('스케줄 로드 오류: $e');
    }
  }

  Future<void> _loadWorkCheckStats() async {
    try {
      final stats = await _scheduleService.getWorkCheckStats();
      consecutiveDays = stats['consecutiveDays'] as int? ?? 0;
      energyFromWork = stats['energyFromWork'] as int? ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('근무 통계 로드 오류: $e');
      consecutiveDays = 0;
      energyFromWork = 0;
      notifyListeners();
    }
  }

  int get upcomingScheduleCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return schedules.where((s) {
      final parsed = DateTime.tryParse(s.date);
      if (parsed == null) return false;
      final day = DateTime(parsed.year, parsed.month, parsed.day);
      return !day.isBefore(today);
    }).length;
  }

  Map<String, dynamic> getModelScheduleTitle() {
    final count = upcomingScheduleCount;
    if (count == 0) {
      return {
        'title': '시술 일정 관리',
        'subtitle': '매칭된 시술 일정이 여기에 표시돼요',
        'emoji': '📅',
        'pillLabel': '예정 일정',
        'pillValue': '0건',
      };
    }
    return {
      'title': '다가오는 시술',
      'subtitle': '확정·조율 중인 시술 일정을 확인하세요',
      'emoji': '💜',
      'pillLabel': '예정 일정',
      'pillValue': '$count건',
    };
  }

  Map<String, dynamic> getWorkCheckTitle(int days) {
    if (days == 0) {
      return {
        'title': '근무체크 시작하기',
        'subtitle': '2026년 에너지를 채우기 시작해보세요!',
        'emoji': '🚀',
      };
    } else if (days == 1) {
      return {
        'title': '스페어 비기너!',
        'subtitle': '2026년 에너지를 채우기 시작했어요! 부릉!',
        'emoji': '🌱',
      };
    } else if (days < 3) {
      return {
        'title': '시작이 반!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '🌱',
      };
    } else if (days < 5) {
      return {
        'title': '열심히 하는 중!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '💪',
      };
    } else if (days < 7) {
      return {
        'title': '꾸준함의 힘!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '🔥',
      };
    } else if (days < 10) {
      return {
        'title': '프로 스페어!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '⭐',
      };
    } else if (days == 10) {
      return {
        'title': '에너지 획득!',
        'subtitle': '$days일 연속 근무로 에너지 1개를 받았어요!',
        'emoji': '⚡',
      };
    } else {
      return {
        'title': '에너지 마스터!',
        'subtitle': '$days일 연속 근무 중이에요!',
        'emoji': '⚡',
      };
    }
  }

  List<DateTime> getDaysInMonth(DateTime month) {
    final year = month.year;
    final monthValue = month.month;
    final firstDay = DateTime(year, monthValue, 1);
    final lastDay = DateTime(year, monthValue + 1, 0);
    final days = <DateTime>[];

    final startDayOfWeek = firstDay.weekday % 7;
    for (int i = 0; i < startDayOfWeek; i++) {
      days.add(DateTime(year, monthValue, -i));
    }

    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(year, monthValue, day));
    }

    return days;
  }

  bool hasScheduledWork(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return schedules.any(
      (s) =>
          s.date == dateStr &&
          (s.status == 'scheduled' ||
              s.status == 'completed' ||
              (!isModelMode && s.status == 'proposed')),
    );
  }

  Schedule? getWorkInfo(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    try {
      return schedules.firstWhere((s) => s.date == dateStr);
    } catch (e) {
      return null;
    }
  }

  bool isChecked(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return checkedDays.contains(dateStr) ||
        schedules.any(
          (s) =>
              s.date == dateStr &&
              (s.status == 'completed' || s.checkInTime != null),
        );
  }

  List<Schedule> getSchedulesForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return schedules
        .where((s) => s.date == dateStr && s.status == 'scheduled')
        .toList();
  }

  void setSearchOpen(bool value) {
    isSearchOpen = value;
    notifyListeners();
  }

  void goToPreviousMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    notifyListeners();
  }

  void selectDate(DateTime date, {required bool hasWork}) {
    selectedDate = date;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    if (hasWork) {
      viewedDates = {...viewedDates, dateStr};
    }
    selectedScheduleId = null;
    if (hasWork) {
      final firstScheduled = schedules.where(
        (s) =>
            s.date == dateStr &&
            s.status == 'scheduled' &&
            !isChecked(date),
      );
      if (firstScheduled.isNotEmpty) {
        selectedScheduleId = firstScheduled.first.id;
      }
    }
    // 일정(근무·교육)이 있는 날짜를 누르면 해당 카드로 스크롤을 요청한다.
    if (hasWork) {
      scrollToCardRequest++;
    }
    notifyListeners();
  }

  void selectSchedule(String scheduleId, String scheduleDateStr) {
    selectedScheduleId = scheduleId;
    viewedDates = {...viewedDates, scheduleDateStr};
    notifyListeners();
  }

  /// 미체크 배너 탭 시 해당 스케줄 날짜·월로 이동하고 카드를 선택한다.
  void focusSchedule(Schedule schedule) {
    final date = DateTime.tryParse(schedule.date);
    if (date != null) {
      currentMonth = DateTime(date.year, date.month);
      selectedDate = date;
    }
    selectedScheduleId = schedule.id;
    viewedDates = {...viewedDates, schedule.date};
    scrollToCardRequest++;
    notifyListeners();
  }

  Future<void> handleCheckIn() async {
    if (selectedScheduleId == null) return;

    final audience = ScheduleSessionAudience.fromModelMode(isModelMode);

    try {
      final selectedSchedule = schedules.firstWhere(
        (s) => s.id == selectedScheduleId,
      );

      if (selectedSchedule.status == 'completed' ||
          selectedSchedule.checkInTime != null) {
        _m.showInfo(audience.alreadyCompletedMessage());
        return;
      }

      final blocked = ScheduleWorkSession.workCheckBlockedMessage(
        selectedSchedule,
        DateTime.now(),
        audience: audience,
      );
      if (blocked != null) {
        _m.showInfo(blocked);
        return;
      }

      final shopName = selectedSchedule.job?.shopName ?? '매장';
      final jobId = selectedSchedule.jobId;
      ratedShopName = shopName;
      ratedJobId = jobId;
      ratedJobTitle = selectedSchedule.job?.title ?? '공고';
      showRatingModal = true;
      notifyListeners();
    } catch (e) {
      _m.showError(audience.scheduleInfoNotFoundMessage());
    }
  }

  /// 리뷰 모달만 닫기 (체크인 API 호출 없음).
  void dismissRatingModalUiOnly() {
    if (reviewSubmitting) return;
    showRatingModal = false;
    ratedShopName = null;
    ratedJobId = null;
    ratedJobTitle = null;
    notifyListeners();
  }

  Future<void> handleThumbsUp() async {
    final audience = ScheduleSessionAudience.fromModelMode(isModelMode);
    if (ratedJobId == null || selectedScheduleId == null) {
      showRatingModal = false;
      ratedShopName = null;
      ratedJobId = null;
      ratedJobTitle = null;
      notifyListeners();
      return;
    }
    if (reviewSubmitting) return;

    final selectedSchedule = schedules.firstWhere(
      (s) => s.id == selectedScheduleId,
    );
    final dateStr = selectedSchedule.date;
    final shopName = ratedShopName ?? '매장';

    reviewSubmitting = true;
    pendingApprovals = {...pendingApprovals, dateStr: shopName};
    notifyListeners();

    try {
      final updatedSchedule = await _scheduleService.checkInSchedule(
        selectedScheduleId!,
      );

      try {
        await _reviewService.sendThumbsUp(jobId: ratedJobId!);
      } catch (e) {
        debugPrint('응원 데이터 전송 실패: $e');
      }

      schedules = schedules.map((s) {
        if (s.id == selectedScheduleId) {
          return updatedSchedule;
        }
        return s;
      }).toList();
      checkedDays = {...checkedDays, dateStr};
      pendingApprovals = Map<String, String>.from(pendingApprovals)
        ..remove(dateStr);
      showRatingModal = false;
      ratedShopName = null;
      ratedJobId = null;
      ratedJobTitle = null;
      selectedScheduleId = null;
      reviewSubmitting = false;
      notifyListeners();

      await _loadWorkCheckStats();
      _m.showSuccess(audience.checkCompleteSuccessMessage());
    } catch (e) {
      pendingApprovals = Map<String, String>.from(pendingApprovals)
        ..remove(dateStr);
      showRatingModal = false;
      ratedShopName = null;
      ratedJobId = null;
      ratedJobTitle = null;
      reviewSubmitting = false;
      notifyListeners();
      final appException = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
    }
  }

  Future<void> handleCloseRatingModal() async {
    final audience = ScheduleSessionAudience.fromModelMode(isModelMode);
    if (selectedScheduleId == null) {
      showRatingModal = false;
      ratedShopName = null;
      ratedJobId = null;
      ratedJobTitle = null;
      notifyListeners();
      return;
    }
    if (reviewSubmitting) return;

    final selectedSchedule = schedules.firstWhere(
      (s) => s.id == selectedScheduleId,
    );
    final dateStr = selectedSchedule.date;
    final shopName = selectedSchedule.job?.shopName ?? '매장';

    reviewSubmitting = true;
    pendingApprovals = {...pendingApprovals, dateStr: shopName};
    notifyListeners();

    try {
      final updatedSchedule = await _scheduleService.checkInSchedule(
        selectedScheduleId!,
      );

      schedules = schedules.map((s) {
        if (s.id == selectedScheduleId) {
          return updatedSchedule;
        }
        return s;
      }).toList();
      checkedDays = {...checkedDays, dateStr};
      pendingApprovals = Map<String, String>.from(pendingApprovals)
        ..remove(dateStr);
      showRatingModal = false;
      ratedShopName = null;
      ratedJobId = null;
      ratedJobTitle = null;
      selectedScheduleId = null;
      reviewSubmitting = false;
      notifyListeners();

      await _loadWorkCheckStats();
      _m.showSuccess(audience.checkCompleteSuccessMessage());
    } catch (e) {
      pendingApprovals = Map<String, String>.from(pendingApprovals)
        ..remove(dateStr);
      showRatingModal = false;
      ratedShopName = null;
      ratedJobId = null;
      ratedJobTitle = null;
      reviewSubmitting = false;
      notifyListeners();
      final appException = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
    }
  }
}
