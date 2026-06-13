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
import '../services/energy_service.dart';
import '../services/favorite_service.dart';
import '../services/job_service.dart';
import '../services/schedule_service.dart';
import '../services/verification_service.dart';
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
  }) : _jobService = jobService ?? sl<JobService>(),
       _favoriteService = favoriteService ?? sl<FavoriteService>(),
       _verificationService = verificationService ?? sl<VerificationService>(),
       _energyService = energyService ?? sl<EnergyService>(),
       _scheduleService = scheduleService ?? sl<ScheduleService>();

  final String jobId;
  final bool shopOwnerMode;

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final JobService _jobService;
  final FavoriteService _favoriteService;
  final VerificationService _verificationService;
  final EnergyService _energyService;
  final ScheduleService _scheduleService;

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
  bool proposalSubmitting = false;

  bool get isProposalMode =>
      engagement == SpareJobEngagement.proposed && linkedSchedule != null;

  /// 부가 데이터는 병렬, 공고 본문은 [loadJob]으로 로드 (기존 initState와 동일).
  Future<void> loadInitial() async {
    unawaited(_refreshVerification());
    unawaited(_refreshFavorite());
    unawaited(_refreshEnergy());
    await loadJob();
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

  Future<void> _refreshEngagement() async {
    try {
      final schedules = await _scheduleService.getSchedules();
      final forJob = schedules.where((s) => s.jobId == jobId).toList();
      if (forJob.isEmpty) {
        linkedSchedule = null;
        engagement = SpareJobEngagement.open;
      } else {
        final proposed = forJob.where((s) => s.status == 'proposed').toList();
        if (proposed.isNotEmpty) {
          linkedSchedule = proposed.first;
          engagement = SpareJobEngagement.proposed;
        } else {
          linkedSchedule = forJob.first;
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
    if (!identityVerified) {
      showVerificationModal = true;
      notifyListeners();
      return;
    }
    if (job == null) return;
    if (energyBalance < job!.energy) {
      _m.showMessage('에너지가 부족합니다');
      return;
    }
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
      energyBalance -= job!.energy;
      showConfirmModal = false;
      notifyListeners();
      _m.showSuccess(
        '지원이 완료되었습니다. 미용실의 승인을 기다려주세요. 연락하기로 소통할 수 있습니다.',
      );
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
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
      await _refreshEngagement();
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
}
