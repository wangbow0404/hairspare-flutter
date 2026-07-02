import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/job.dart';
import '../models/schedule.dart';
import '../models/spare_job_engagement.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../mocks/mock_auth_data.dart';
import '../services/chat_service.dart';
import '../services/energy_service.dart';
import '../services/favorite_service.dart';
import '../services/job_service.dart';
import '../services/schedule_service.dart';
import '../services/verification_service.dart';
import '../utils/app_exception.dart';
import '../utils/error_handler.dart';
import '../utils/region_helper.dart';
import '../utils/schedule_work_session.dart';

/// 스페어 구인 상세 화면 ViewModel (찜, 본인인증, 에너지, 지원 확인).
class JobDetailViewModel extends ChangeNotifier {
  JobDetailViewModel({
    required this.jobId,
    this.shopOwnerMode = false,
    JobService? jobService,
    FavoriteService? favoriteService,
    VerificationService? verificationService,
    EnergyService? energyService,
    ScheduleService? scheduleService,
    ChatService? chatService,
  }) : _jobService = jobService ?? sl<JobService>(),
       _favoriteService = favoriteService ?? sl<FavoriteService>(),
       _verificationService = verificationService ?? sl<VerificationService>(),
       _energyService = energyService ?? sl<EnergyService>(),
       _scheduleService = scheduleService ?? sl<ScheduleService>(),
       _chatService = chatService ?? sl<ChatService>();

  final String jobId;
  final bool shopOwnerMode;

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final JobService _jobService;
  final FavoriteService _favoriteService;
  final VerificationService _verificationService;
  final EnergyService _energyService;
  final ScheduleService _scheduleService;
  final ChatService _chatService;

  Job? job;
  Schedule? linkedSchedule;
  SpareJobEngagement engagement = SpareJobEngagement.open;
  String? error;
  bool isLoading = true;

  bool isFavorite = false;
  bool isTogglingFavorite = false;
  bool showConfirmModal = false;
  bool isLocked = false;
  bool showVerificationModal = false;
  bool identityVerified = false;
  int energyBalance = 0;
  bool hasApplied = false;
  bool contactBanned = false;
  bool proposalSubmitting = false;
  bool showLowEnergySheet = false;

  bool get isProposalMode =>
      engagement == SpareJobEngagement.proposed && linkedSchedule != null;

  /// 부가 데이터는 병렬, 공고 본문은 [loadJob]으로 로드 (기존 initState와 동일).
  Future<void> loadInitial() async {
    unawaited(_refreshVerification());
    unawaited(_refreshFavorite());
    await loadJob();
    await _refreshApplicationState();
    await _refreshEngagement();
  }

  String get primaryActionLabel {
    switch (engagement) {
      case SpareJobEngagement.open:
        return '지원하기';
      case SpareJobEngagement.proposed:
        return '제안 확인';
      case SpareJobEngagement.scheduled:
        return '스케줄표에서 확인';
      case SpareJobEngagement.workCheckReady:
        return '근무체크하기';
    }
  }

  bool get usesSchedulePrimaryAction =>
      engagement != SpareJobEngagement.open;

  Future<void> _refreshApplicationState() async {
    if (shopOwnerMode) return;
    try {
      contactBanned = await _jobService.isContactBannedForJob(jobId);
      final status = await _jobService.getSpareApplicationStatusForJob(jobId);
      if (contactBanned ||
          status == 'cancelled_contact_violation') {
        hasApplied = false;
        isLocked = false;
        contactBanned = true;
      } else if (status == 'pending') {
        hasApplied = true;
        isLocked = true;
      } else if (status == 'approved') {
        hasApplied = true;
        isLocked = false;
      } else {
        hasApplied = false;
        isLocked = false;
      }
    } catch (_) {
      // 유지
    }
    notifyListeners();
  }

  Future<void> _refreshEngagement({String? preferredScheduleId}) async {
    try {
      final schedules = await _scheduleService.getSchedules();
      final forJob = schedules.where((s) => s.jobId == jobId).toList();
      if (forJob.isEmpty) {
        linkedSchedule = null;
        engagement = SpareJobEngagement.open;
      } else {
        final proposed = forJob.where((s) => s.status == 'proposed').toList();
        if (proposed.isNotEmpty) {
          linkedSchedule = preferredScheduleId == null
              ? proposed.first
              : proposed.firstWhere(
                  (s) => s.id == preferredScheduleId,
                  orElse: () => proposed.first,
                );
          engagement = SpareJobEngagement.proposed;
        } else {
          if (preferredScheduleId != null) {
            final match =
                forJob.where((s) => s.id == preferredScheduleId).toList();
            linkedSchedule = match.isNotEmpty ? match.first : forJob.first;
          } else {
            linkedSchedule = forJob.first;
          }
          final now = DateTime.now();
          if (ScheduleWorkSession.isWorkCheckReady(linkedSchedule!, now)) {
            engagement = SpareJobEngagement.workCheckReady;
          } else {
            engagement = SpareJobEngagement.scheduled;
          }
        }
      }
    } catch (_) {
      linkedSchedule = null;
      engagement = SpareJobEngagement.open;
    }
    notifyListeners();
  }

  Future<void> loadJob() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      job = shopOwnerMode
          ? await _jobService.getMyJobById(jobId)
          : await _jobService.getJobById(jobId);
      error = null;
    } catch (e) {
      error = e.toString();
      job = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshVerification() async {
    try {
      final status = await _verificationService.getVerificationStatus();
      identityVerified = status['identityVerified'] as bool? ?? false;
    } catch (_) {
      identityVerified = false;
    }
    notifyListeners();
  }

  Future<void> _refreshFavorite() async {
    try {
      isFavorite = await _favoriteService.isFavorite(jobId);
    } catch (_) {
      isFavorite = false;
    }
    notifyListeners();
  }

  Future<void> _refreshEnergy() async {
    try {
      final wallet = await _energyService.getWallet();
      energyBalance = wallet['balance'] ?? 0;
    } catch (_) {
      energyBalance = 0;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    if (isTogglingFavorite) return;
    isTogglingFavorite = true;
    notifyListeners();

    try {
      if (isFavorite) {
        await _favoriteService.removeFavorite(jobId);
        isFavorite = false;
      } else {
        await _favoriteService.addFavorite(jobId);
        isFavorite = true;
      }
      unawaited(sl<FavoriteProvider>().loadFavorites());
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
    } finally {
      isTogglingFavorite = false;
      notifyListeners();
    }
  }

  void requestApply() {
    if (contactBanned) {
      _m.showError('연락처 위반으로 이 공고 지원이 취소되어 다시 지원할 수 없습니다.');
      return;
    }
    if (!identityVerified) {
      showVerificationModal = true;
      notifyListeners();
      return;
    }
    if (job == null) return;
    showConfirmModal = true;
    notifyListeners();
  }

  void dismissVerificationModal() {
    showVerificationModal = false;
    notifyListeners();
  }

  void dismissConfirmModal() {
    showConfirmModal = false;
    notifyListeners();
  }

  void dismissLowEnergySheet() {
    showLowEnergySheet = false;
    notifyListeners();
  }

  Future<void> refreshJobSnapshot() async {
    try {
      job = shopOwnerMode
          ? await _jobService.getMyJobById(jobId)
          : await _jobService.getJobById(jobId);
      notifyListeners();
    } catch (_) {}
  }

  Future<List<Schedule>> findApplyConflicts() async {
    final j = job;
    if (j == null) return [];
    return _scheduleService.findApplyConflictsForJob(j);
  }

  Future<List<Schedule>> findAcceptProposalConflicts() async {
    final s = linkedSchedule;
    if (s == null) return [];
    return _scheduleService.findAcceptProposalConflicts(s.id);
  }

  Future<void> refreshEngagementOnly() async {
    await _refreshEngagement(preferredScheduleId: linkedSchedule?.id);
  }

  /// 겹침 해소용 — 현재 화면의 제안이 아닌 다른 `proposed` 일정 거절.
  Future<int> autoRejectOverlappingProposals(
    Iterable<Schedule> conflicts,
  ) async {
    final currentId = linkedSchedule?.id;
    var rejected = 0;
    for (final schedule in conflicts) {
      if (schedule.status != 'proposed') continue;
      if (schedule.id == currentId) continue;
      await _scheduleService.rejectWorkProposal(schedule.id);
      rejected++;
    }
    if (rejected > 0) {
      await _refreshEngagement(preferredScheduleId: currentId);
    }
    return rejected;
  }

  Future<void> confirmApply() async {
    if (job == null) return;
    final conflicts = await findApplyConflicts();
    if (conflicts.isNotEmpty) {
      _m.showError(
        '같은 날 겹치는 근무가 있습니다. 기존 근무를 취소한 뒤 지원해 주세요.',
      );
      return;
    }
    isLoading = true;
    notifyListeners();

    try {
      await _jobService.applyToJob(jobId);
      isLocked = true;
      hasApplied = true;
      await _refreshEnergy();
      showConfirmModal = false;
      notifyListeners();
      _m.showSuccess(
        '지원이 완료되었습니다. 미용실의 승인을 기다려주세요. 연락하기로 소통할 수 있습니다.',
      );
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      final msg = appException.message;
      // 서버가 에너지 부족 코드를 반환한 경우 — 충전 바텀시트 표시
      if (appException is ValidationException &&
          (msg.contains('에너지') || msg.contains('energy'))) {
        showConfirmModal = false;
        showLowEnergySheet = true;
        notifyListeners();
      } else {
        _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptProposal() async {
    final schedule = linkedSchedule;
    if (schedule == null || proposalSubmitting) return false;
    proposalSubmitting = true;
    notifyListeners();
    try {
      await _scheduleService.acceptWorkProposal(schedule.id);
      _m.showSuccess('근무 제안을 수락했습니다. 스케줄표에 반영되었습니다.');
      await _refreshEngagement(preferredScheduleId: schedule.id);
      return true;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
      return false;
    } finally {
      proposalSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> rejectProposal() async {
    final schedule = linkedSchedule;
    if (schedule == null || proposalSubmitting) return false;
    proposalSubmitting = true;
    notifyListeners();
    try {
      await _scheduleService.rejectWorkProposal(schedule.id);
      _m.showInfo('근무 제안을 거절했습니다.');
      return true;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
      return false;
    } finally {
      proposalSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> shareJob() async {
    final j = job;
    if (j == null) return;
    try {
      final regionName = RegionHelper.getRegionName(j.regionId);
      final shareText =
          '${j.title}\n'
          '$regionName · ${j.date} ${j.time}\n'
          '시급: ${NumberFormat('#,###').format(j.amount)}원\n'
          '에너지: ${j.energy}개';
      await Share.share(shareText, subject: j.title);
    } catch (e) {
      _m.showError('공유 실패: $e');
    }
  }

  /// 지원 후 매장과 1:1 채팅방 id (없으면 생성).
  Future<String?> resolveContactChatId() async {
    final j = job;
    if (j == null || !hasApplied || contactBanned) return null;
    try {
      final user = sl<AuthProvider>().currentUser ?? MockAuthData.spareUser();
      return await _chatService.ensureChatForJobApplication(
        jobId: j.id,
        jobTitle: j.title,
        shopName: j.shopName,
        spareId: user.id,
        spareName: user.name ?? user.username,
      );
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
      return null;
    }
  }
}
