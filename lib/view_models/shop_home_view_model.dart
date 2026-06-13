import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/application.dart';
import '../models/job.dart';
import '../models/spare_profile.dart';
import '../providers/notification_provider.dart';
import '../services/application_service.dart';
import '../services/job_service.dart';
import '../services/schedule_service.dart';
import '../services/spare_service.dart';
import '../utils/error_handler.dart';
import '../utils/shop_applicant_counts.dart';

/// 샵 홈 탭: 등록 공고 수·스페어 목록·알림. 홈에는 공고 **피드**를 두지 않고 [ShopJobsListScreen] 등에서만 관리.
class ShopHomeViewModel extends ChangeNotifier {
  ShopHomeViewModel({
    required this.notificationProvider,
    JobService? jobService,
    SpareService? spareService,
    ApplicationService? applicationService,
    ScheduleService? scheduleService,
  })  : _jobService = jobService ?? sl<JobService>(),
        _spareService = spareService ?? sl<SpareService>(),
        _applicationService = applicationService ?? sl<ApplicationService>(),
        _scheduleService = scheduleService ?? sl<ScheduleService>();

  final NotificationProvider notificationProvider;

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final JobService _jobService;
  final SpareService _spareService;
  final ApplicationService _applicationService;
  final ScheduleService _scheduleService;

  bool isLoading = true;

  List<SpareProfile> popularSpares = [];
  List<SpareProfile> newSpares = [];
  List<SpareProfile> regularSpares = [];
  /// 진행중(published) 공고 수.
  int activeJobCount = 0;
  /// status=pending 지원 건수.
  int pendingApplicantsCount = 0;
  /// 오늘 scheduled 일정 건수.
  int todayScheduleCount = 0;

  /// 알림·내 공고·지원자·스페어 목록을 병렬 로드합니다.
  Future<void> loadInitial() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        notificationProvider.loadNotifications(audience: 'shop'),
        _jobService.getMyJobs(),
        _applicationService.getShopApplications(),
        _scheduleService.getTodaySchedules(),
        _spareService.getSpares(sortBy: 'popular', limit: 10),
        _spareService.getSpares(sortBy: 'newest', limit: 10),
        _spareService.getSpares(limit: 10),
      ]);

      final jobs = results[1] as List<Job>;
      final applications = results[2] as List<Application>;
      final todaySchedules = results[3] as List;

      activeJobCount =
          jobs.where((j) => j.status == 'published').length;
      pendingApplicantsCount =
          ShopApplicantCounts.pending(applications);
      todayScheduleCount = todaySchedules.length;

      popularSpares = results[4] as List<SpareProfile>;
      newSpares = results[5] as List<SpareProfile>;
      regularSpares = results[6] as List<SpareProfile>;
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '데이터 로드 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
