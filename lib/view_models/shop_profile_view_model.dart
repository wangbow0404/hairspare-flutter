import 'package:flutter/foundation.dart';

import '../services/schedule_service.dart';
import '../services/work_check_service.dart';

class ShopProfileViewModel extends ChangeNotifier {
  ShopProfileViewModel({
    WorkCheckService? workCheckService,
    ScheduleService? scheduleService,
  })  : _workCheckService = workCheckService ?? WorkCheckService(),
        _scheduleService = scheduleService ?? ScheduleService();

  final WorkCheckService _workCheckService;
  final ScheduleService _scheduleService;

  bool isLoading = true;
  int vipTotalCompleted = 0;
  String vipLevel = 'bronze';
  int ongoingSchedules = 0;

  Future<void> loadInitial() async {
    isLoading = true;
    notifyListeners();

    try {
      final vipStats = await _workCheckService.getShopStats();
      vipTotalCompleted = vipStats['totalCompleted'] as int? ?? 0;
      vipLevel = (vipStats['vipLevel'] ?? vipStats['tier'] ?? 'bronze').toString();
    } catch (_) {}

    try {
      final schedules = await _scheduleService.getTodaySchedules();
      ongoingSchedules = schedules.length;
    } catch (_) {}

    isLoading = false;
    notifyListeners();
  }
}
