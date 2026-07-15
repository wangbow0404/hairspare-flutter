import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/schedule.dart';
import '../models/shop_tier.dart';
import '../services/schedule_service.dart';
import '../services/spare_service.dart';
import '../utils/error_handler.dart';
import '../utils/schedule_space_rental.dart';
import '../utils/schedule_work_session.dart';

/// Shop 스케줄 화면용 ViewModel. API·등급 계산·모달 상태를 담당한다.
class ShopScheduleViewModel extends ChangeNotifier {
  ShopScheduleViewModel({
    ScheduleService? scheduleService,
    SpareService? spareService,
  })  : _scheduleService = scheduleService ?? sl<ScheduleService>(),
        _spareService = spareService ?? sl<SpareService>();

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final ScheduleService _scheduleService;
  final SpareService _spareService;

  List<Schedule> schedules = [];
  bool isLoading = true;
  Schedule? selectedSchedule;
  bool showThumbsUpModal = false;
  ShopTierInfo? tierInfo;
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  Set<String> completedDates = {};

  Future<void> loadInitial() => loadData();

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();
    try {
      await _loadSchedules();
    } catch (error) {
      final appException = ErrorHandler.handleException(error);
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTierInfo() async {
    final completedSchedules =
        schedules.where((s) => s.status == 'completed').length;
    final thumbsUpReceived = (completedSchedules * 0.8).round();

    tierInfo = ShopTierInfo(
      currentTier: ShopTierInfo.calculateTier(
        completedSchedules,
        thumbsUpReceived,
      ),
      completedSchedules: completedSchedules,
      thumbsUpReceived: thumbsUpReceived,
      maxJobPosts: ShopTierInfo.calculateMaxJobPosts(
        ShopTierInfo.calculateTier(completedSchedules, thumbsUpReceived),
      ),
    );
    notifyListeners();
  }

  Future<void> _loadSchedules() async {
    try {
      final list = await _scheduleService.getSchedules(ownerId: 'me');
      schedules = list;
      completedDates = list
          .where((s) => s.status == 'completed')
          .map((s) => s.date)
          .toSet();
      notifyListeners();
      await _loadTierInfo();
    } catch (error) {
      debugPrint('스케줄 로드 오류: $error');
    }
  }

  Map<String, dynamic> getTierTitle() {
    if (tierInfo == null) {
      return {
        'title': '등급 시스템 시작하기',
        'subtitle': '2026년 등급을 올려보세요!',
        'emoji': '🏆',
      };
    }

    final tier = tierInfo!.currentTier;
    final completed = tierInfo!.completedSchedules;
    final nextTier = tier.getNextTier();

    if (nextTier == null) {
      return {
        'title': '최고 등급 달성!',
        'subtitle': 'VIP 등급을 유지하고 계세요!',
        'emoji': tier.emoji,
      };
    }

    if (completed == 0) {
      return {
        'title': '등급 시스템 시작하기',
        'subtitle': '2026년 등급을 올려보세요!',
        'emoji': '🏆',
      };
    } else if (completed < 5) {
      return {
        'title': '시작이 반!',
        'subtitle': '$completed개 완료! 계속 노력해보세요!',
        'emoji': tier.emoji,
      };
    } else if (completed < 20) {
      return {
        'title': '열심히 하는 중!',
        'subtitle': '$completed개 완료! 다음 등급까지!',
        'emoji': tier.emoji,
      };
    } else {
      return {
        'title': '프로 미용실!',
        'subtitle': '$completed개 완료! ${nextTier.name} 등급까지!',
        'emoji': tier.emoji,
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
          (s.status == 'scheduled' || s.status == 'completed'),
    );
  }

  bool isCompleted(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return completedDates.contains(dateStr);
  }

  List<Schedule> getSchedulesForDate(DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return schedules
        .where((s) => s.date == dateStr && s.status == 'scheduled')
        .toList();
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final daySchedules = schedules
        .where(
          (s) =>
              s.date == dateStr &&
              (s.status == 'scheduled' || s.status == 'completed'),
        )
        .toList();
    if (daySchedules.isEmpty) {
      selectedSchedule = null;
    } else {
      selectedSchedule = daySchedules.firstWhere(
        (s) => s.status == 'scheduled',
        orElse: () => daySchedules.first,
      );
    }
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

  void handleScheduleClick(Schedule schedule) {
    selectedSchedule = schedule;
    notifyListeners();
  }

  /// 알림 등에서 특정 공고의 스케줄로 바로 이동할 때 사용 — 해당 날짜로 달력을
  /// 옮기고 스케줄을 선택된 상태로 만든다.
  void selectScheduleByJobId(String jobId) {
    final matches = schedules.where((s) => s.jobId == jobId).toList();
    if (matches.isEmpty) return;
    matches.sort((a, b) => a.status == 'scheduled' ? -1 : 1);
    final target = matches.first;
    final parsedDate = DateTime.tryParse(target.date);
    if (parsedDate != null) {
      selectedDate = parsedDate;
      currentMonth = DateTime(parsedDate.year, parsedDate.month);
    }
    selectedSchedule = target;
    notifyListeners();
  }

  String? settlementBlockedMessageFor(Schedule schedule) {
    if (ScheduleSpaceRental.isSpaceRental(schedule)) return null;
    return ScheduleWorkSession.settlementBlockedMessage(schedule);
  }

  bool canSettleSchedule(Schedule schedule) =>
      ScheduleWorkSession.canSettle(schedule);

  void handleConfirmWork(String scheduleId) {
    final schedule = schedules.firstWhere((s) => s.id == scheduleId);
    final blocked = settlementBlockedMessageFor(schedule);
    if (blocked != null) {
      _m.showError(blocked);
      return;
    }
    selectedSchedule = schedule;
    showThumbsUpModal = true;
    notifyListeners();
  }

  Future<void> handleThumbsUpConfirm(bool giveThumbsUp) async {
    if (selectedSchedule == null) return;

    final blocked = settlementBlockedMessageFor(selectedSchedule!);
    if (blocked != null) {
      _m.showError(blocked);
      return;
    }

    try {
      final result = await _scheduleService.confirmWork(
        scheduleId: selectedSchedule!.id,
        thumbsUp: giveThumbsUp,
      );

      if (giveThumbsUp) {
        try {
          await _spareService.giveThumbsUpToSpare(selectedSchedule!.spareId);
        } catch (e) {
          debugPrint('응원 전송 실패: $e');
        }
      }

      final message = giveThumbsUp
          ? '정산이 완료되었습니다.\n정산 금액: ${NumberFormat('#,###').format(result['amount'])}원\n\n👍 응원을 보냈습니다!\n\n등급이 업데이트되었습니다.'
          : '정산이 완료되었습니다.\n정산 금액: ${NumberFormat('#,###').format(result['amount'])}원\n\n등급이 업데이트되었습니다.';

      _m.showSuccess(
        message,
        duration: const Duration(seconds: 4),
      );

      showThumbsUpModal = false;
      selectedSchedule = null;
      notifyListeners();

      await _loadSchedules();
      await _loadTierInfo();
    } catch (error) {
      _m.showError(
        ErrorHandler.getUserFriendlyMessage(
          ErrorHandler.handleException(error),
        ),
      );
    }
  }

  void dismissThumbsUpModal() {
    showThumbsUpModal = false;
    selectedSchedule = null;
    notifyListeners();
  }

  /// 이미 정산 완료된 근무를 취소해달라고 관리자에게 요청 (실제 취소는 관리자 승인 후 처리됨).
  Future<bool> requestSettlementCancel(String scheduleId, String reason) async {
    try {
      await _scheduleService.requestSettlementCancel(scheduleId, reason: reason);
      _m.showSuccess('정산취소 요청을 접수했습니다. 관리자 확인 후 처리됩니다.');
      return true;
    } catch (error) {
      _m.showError(
        ErrorHandler.getUserFriendlyMessage(
          ErrorHandler.handleException(error),
        ),
      );
      return false;
    }
  }

  /// 출근 시각이 지났는데 체크인이 없는 스케줄을 노쇼로 신고.
  Future<bool> reportNoShow(String scheduleId, String reason) async {
    try {
      await _scheduleService.reportNoShow(scheduleId, reason: reason);
      _m.showSuccess('노쇼 신고를 접수했습니다. 해당 스케줄은 취소 처리되었습니다.');
      await _loadSchedules();
      return true;
    } catch (error) {
      _m.showError(
        ErrorHandler.getUserFriendlyMessage(
          ErrorHandler.handleException(error),
        ),
      );
      return false;
    }
  }
}
