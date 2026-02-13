import 'package:flutter/foundation.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class ScheduleProvider with ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 진행중 스케줄 수 (status가 "scheduled"인 것)
  int get scheduledCount => _schedules.where((s) => s.status == 'scheduled').length;

  /// 완료된 스케줄 수 (status가 "completed"인 것)
  int get completedCount => _schedules.where((s) => s.status == 'completed').length;

  /// 스케줄 목록 로드
  Future<void> loadSchedules({
    String? dateFrom,
    String? dateTo,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await _scheduleService.getSchedules(
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: status,
      );
      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _schedules = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 스케줄 취소
  Future<bool> cancelSchedule(String scheduleId) async {
    try {
      await _scheduleService.cancelSchedule(scheduleId);
      _schedules.removeWhere((schedule) => schedule.id == scheduleId);
      notifyListeners();
      return true;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
