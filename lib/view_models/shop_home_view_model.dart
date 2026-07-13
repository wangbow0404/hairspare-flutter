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
import '../mocks/mock_shop_data.dart';
import '../services/spare_service.dart';
import '../utils/error_handler.dart';
import '../utils/region_helper.dart';
import '../utils/shop_applicant_counts.dart';

/// 샵 홈 탭: 등록 공고 수·스페어 목록·알림. 홈에는 공고 **피드**를 두지 않고 [ShopJobsListScreen] 등에서만 관리.
class ShopHomeViewModel extends ChangeNotifier {
  ShopHomeViewModel({
    required this.notificationProvider,
    JobService? jobService,
    SpareService? spareService,
    ApplicationService? applicationService,
  })  : _jobService = jobService ?? sl<JobService>(),
        _spareService = spareService ?? sl<SpareService>(),
        _applicationService = applicationService ?? sl<ApplicationService>();

  final NotificationProvider notificationProvider;

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final JobService _jobService;
  final SpareService _spareService;
  final ApplicationService _applicationService;

  bool isLoading = true;

  List<SpareProfile> popularSpares = [];
  List<SpareProfile> newSpares = [];
  List<SpareProfile> nearbySpares = [];
  List<SpareProfile> regularSpares = [];

  /// 샵(카페) 주변 지역 — 추후 프로필 API 연동.
  String shopRegionId = MockShopData.mockShopHomeRegionId;
  String shopRegionLabel = '';
  /// 진행중(published) 공고 수.
  int activeJobCount = 0;
  /// status=pending 지원 건수.
  int pendingApplicantsCount = 0;
  /// 오늘 모델 매칭 건수.
  int todayModelMatchingCount = 0;

  Timer? _pollTimer;

  /// 알림·내 공고·지원자·스페어 목록을 병렬 로드합니다.
  Future<void> loadInitial() async {
    isLoading = true;
    notifyListeners();

    try {
      shopRegionLabel = RegionHelper.districtShortName(shopRegionId);
      final nearbyIds = RegionHelper.nearbyRegionIds(shopRegionId);

      final results = await Future.wait<dynamic>([
        notificationProvider.loadNotifications(audience: 'shop'),
        _jobService.getMyJobs(),
        _applicationService.getShopApplications(),
        MockShopData.getTodayModelMatchingCount(),
        _spareService.getSpares(sortBy: 'popular', limit: 10),
        _spareService.getSpares(sortBy: 'newest', limit: 8),
        _spareService.getSpares(
          sortBy: 'popular',
          regionIds: nearbyIds,
          limit: 10,
        ),
        _spareService.getSpares(sortBy: 'popular'),
      ]);

      final jobs = results[1] as List<Job>;
      final applications = results[2] as List<Application>;

      activeJobCount =
          jobs.where((j) => j.status == 'published').length;
      pendingApplicantsCount =
          ShopApplicantCounts.pending(applications);
      todayModelMatchingCount = results[3] as int;

      popularSpares = results[4] as List<SpareProfile>;
      newSpares = results[5] as List<SpareProfile>;
      nearbySpares = results[6] as List<SpareProfile>;

      final allSpares = results[7] as List<SpareProfile>;
      final nearbySet = nearbyIds.toSet();
      regularSpares = allSpares
          .where((s) => !nearbySet.contains(s.regionId))
          .toList();
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

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      notificationProvider.refreshNotifications();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
