import 'dart:async';

import 'package:flutter/material.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/job.dart';
import '../services/application_service.dart';
import '../services/job_service.dart';
import '../utils/error_handler.dart';
import '../utils/shop_applicant_counts.dart';

/// 샵「내 공고」목록: 탭 필터·검색·페이지네이션·당겨서 새로고침을 [JobService.getMyJobs]와 동기화.
class ShopJobsListViewModel extends ChangeNotifier {
  ShopJobsListViewModel({
    JobService? jobService,
    ApplicationService? applicationService,
  })  : _jobService = jobService ?? sl<JobService>(),
        _applicationService = applicationService ?? sl<ApplicationService>();

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final JobService _jobService;
  final ApplicationService _applicationService;

  static const int pageSize = 10;

  final TextEditingController searchController = TextEditingController();

  /// `all` | `published` | `closed` | `expired` | `draft`
  String statusFilter = 'all';

  List<Job> _allJobs = [];
  Map<String, int> applicantCounts = {};
  bool isLoading = true;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool hasMore = false;

  /// job.status가 published여도 시작 시간이 지났으면 expired 반환.
  static String effectiveStatus(Job job) {
    if (job.status != 'published') return job.status;
    try {
      final parts = job.time.split(':');
      if (parts.length < 2) return job.status;
      final jobStart = DateTime(
        int.parse(job.date.substring(0, 4)),
        int.parse(job.date.substring(5, 7)),
        int.parse(job.date.substring(8, 10)),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      return jobStart.isBefore(DateTime.now()) ? 'expired' : 'published';
    } catch (_) {
      return job.status;
    }
  }

  /// 탭 + 검색어 적용 결과.
  List<Job> get jobs {
    var list = _allJobs;
    if (statusFilter != 'all') {
      list = list.where((j) => effectiveStatus(j) == statusFilter).toList();
    }
    final search = searchController.text.trim().toLowerCase();
    if (search.isNotEmpty) {
      list = list.where((j) => j.title.toLowerCase().contains(search)).toList();
    }
    return list;
  }

  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  /// 검색어 입력 시 디바운스 후 전체 새로고침.
  void onSearchTextChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(refresh());
    });
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchController.clear();
    unawaited(refresh());
  }

  /// 탭 변경: API 재호출 없이 client-side 필터만 변경.
  Future<void> setStatusFilter(String value) async {
    if (statusFilter == value) return;
    statusFilter = value;
    notifyListeners();
  }

  /// 전체 공고를 새로 불러옴 (당겨서 새로고침·초기 로드·검색 공통).
  Future<void> refresh() async {
    if (_allJobs.isEmpty) {
      isLoading = true;
    } else {
      isRefreshing = true;
    }
    notifyListeners();

    try {
      _allJobs = await _jobService.getMyJobs();
      await _loadApplicantCounts();
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError('공고 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}');
      _allJobs = [];
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadInitial() => refresh();

  Future<void> loadMore() async {}

  Future<void> deleteJob(String jobId) async {
    try {
      await _jobService.deleteJob(jobId);
      await refresh();
      _m.showSuccess('공고가 삭제되었습니다');
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '삭제 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    }
  }

  Future<void> _loadApplicantCounts() async {
    try {
      final apps = await _applicationService.getShopApplications();
      applicantCounts = ShopApplicantCounts.perJobIds(
        jobIds: _allJobs.map((j) => j.id),
        applications: apps,
      );
      notifyListeners();
    } catch (_) {
      applicantCounts = {};
    }
  }

  int applicantCountFor(String jobId) => applicantCounts[jobId] ?? 0;

  Future<void> hideJob(String jobId) async {
    try {
      await _jobService.hideJob(jobId);
      await refresh();
      _m.showSuccess('공고가 숨김 처리되었습니다');
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '숨김 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    }
  }

  Future<void> unhideJob(String jobId) async {
    try {
      await _jobService.unhideJob(jobId);
      await refresh();
      _m.showSuccess('공고 숨김이 해제되었습니다');
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '숨김 해제 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    }
  }

  Future<void> closeJob(String jobId) async {
    try {
      await _jobService.updateJobStatus(jobId, 'closed');
      await refresh();
      _m.showSuccess('공고가 마감되었습니다');
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '마감 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    }
  }

  Future<void> reopenJob(String jobId) async {
    try {
      await _jobService.updateJobStatus(jobId, 'published');
      await refresh();
      _m.showSuccess('공고가 다시 오픈되었습니다');
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '재오픈 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    }
  }
}
