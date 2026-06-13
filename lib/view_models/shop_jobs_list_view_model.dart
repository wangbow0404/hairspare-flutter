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

  /// `all`(진행+마감) | `published` | `closed` | `expired` | `draft`
  String statusFilter = 'all';

  List<Job> jobs = [];
  Map<String, int> applicantCounts = {};
  bool isLoading = true;

  /// 첫 로드 이후 검색·당겨서 새로고침 등 (목록 유지하며 갱신).
  bool isRefreshing = false;
  bool isLoadingMore = false;

  /// 다음 페이지가 있는지 (마지막 응답 길이가 [pageSize] 미만이면 false).
  bool hasMore = true;

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

  /// 탭 변경: 목록을 비운 뒤 첫 페이지부터 다시 로드.
  Future<void> setStatusFilter(String value) async {
    if (statusFilter == value) return;
    statusFilter = value;
    jobs.clear();
    hasMore = true;
    notifyListeners();
    await refresh();
  }

  String get _searchParam {
    final t = searchController.text.trim();
    return t.isEmpty ? '' : t;
  }

  String? get _statusApiParam {
    if (statusFilter == 'all') return 'active';
    return statusFilter;
  }

  Future<List<Job>> _fetchPage({required int offset}) {
    return _jobService.getMyJobs(
      status: _statusApiParam,
      search: _searchParam.isEmpty ? null : _searchParam,
      limit: pageSize,
      offset: offset,
    );
  }

  /// 당겨서 새로고침·초기 로드·검색 공통: 오프셋 0부터 다시 채움.
  Future<void> refresh() async {
    final empty = jobs.isEmpty;
    if (empty) {
      isLoading = true;
      isRefreshing = false;
    } else {
      isRefreshing = true;
      isLoading = false;
    }
    isLoadingMore = false;
    hasMore = true;
    notifyListeners();

    try {
      final batch = await _fetchPage(offset: 0);
      jobs = List<Job>.from(batch);
      hasMore = batch.length >= pageSize;
      await _loadApplicantCounts();
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '공고 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
      jobs = [];
      hasMore = false;
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadInitial() => refresh();

  /// 무한 스크롤: 바닥 근처에서 호출.
  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isLoading || isRefreshing) return;
    isLoadingMore = true;
    notifyListeners();

    try {
      final batch = await _fetchPage(offset: jobs.length);
      jobs = [...jobs, ...batch];
      hasMore = batch.length >= pageSize;
      await _loadApplicantCounts();
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '추가 로드 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

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
        jobIds: jobs.map((j) => j.id),
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
