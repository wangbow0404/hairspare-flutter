import '../models/application.dart';
import '../models/business_registration_ocr_result.dart';
import '../models/business_registration_validation.dart';
import '../models/job.dart';
import '../models/notification.dart';
import '../models/spare_profile.dart';
import '../utils/job_popularity.dart';
import '../utils/application_status_utils.dart';
import '../utils/app_exception.dart';
import '../utils/job_work_date_utils.dart';
import '../utils/contact_violation_policy.dart';
import '../utils/schedule_cancellation_policy.dart';
import '../utils/shop_applicant_counts.dart';
import 'mock_auth_data.dart';
import 'mock_spare_data.dart';

/// 미용실(Shop) 화면용 Mock 데이터
class MockShopData {
  static final List<Map<String, dynamic>> _sparesJson = [
    {
      'id': 'spare-mock-1',
      'name': '김디자이너',
      'role': 'designer',
      'regionId': 'region-1',
      'experience': 3,
      'rating': 4.8,
      'reviewCount': 24,
      'thumbsUpCount': 12,
      'specialties': ['컷', '펌'],
      'availableTimes': ['주말'],
      'hourlyRate': 80000,
      'isVerified': true,
      'isLicenseVerified': true,
      'noShowCount': 0,
      'completedJobs': 45,
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'spare-mock-2',
      'name': '이스텝',
      'role': 'step',
      'regionId': 'region-1',
      'experience': 1,
      'rating': 4.5,
      'reviewCount': 8,
      'thumbsUpCount': 5,
      'specialties': ['셰이빙', '세팅'],
      'availableTimes': ['평일', '주말'],
      'isVerified': true,
      'isLicenseVerified': false,
      'noShowCount': 0,
      'completedJobs': 12,
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  // ——— 샵「내 공고」목록 (mock 인메모리) ———

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 근무일을 오늘 기준 미래로 잡아 QA 시 바로 만료되지 않게 함.
  static List<Map<String, dynamic>> _createMyJobsJson() {
    final today = DateTime.now();
    final created = DateTime.now().toIso8601String();
    return [
      {
        'id': 'job-mock-1',
        'title': '오후 스텝 급구',
        'shopName': '빌라드블랑 강남점',
        'date': _ymd(today.add(const Duration(days: 2))),
        'time': '14:00',
        'endTime': '22:00',
        'amount': 50000,
        'energy': 5,
        'requiredCount': 1,
        'regionId': 'seoul-gangnam',
        'isUrgent': true,
        'isPremium': false,
        'isHidden': false,
        'status': 'published',
        'ownerId': 'me',
        'createdAt': created,
      },
      {
        'id': 'job-mock-2',
        'title': '주말 디자이너 대타',
        'shopName': '헤어스튜디오 A',
        'date': _ymd(today.add(const Duration(days: 3))),
        'time': '10:00',
        'endTime': '18:00',
        'amount': 80000,
        'energy': 4,
        'requiredCount': 1,
        'regionId': 'seoul-mapo',
        'isUrgent': false,
        'isPremium': false,
        'isHidden': false,
        'status': 'closed',
        'ownerId': 'me',
        'createdAt': created,
      },
      {
        'id': 'job-mock-3',
        'title': '평일 오전 스텝 (초보 가능)',
        'shopName': '빌라드블랑 강남점',
        'date': _ymd(today.add(const Duration(days: 4))),
        'time': '09:00',
        'endTime': '13:00',
        'amount': 45000,
        'energy': 2,
        'requiredCount': 2,
        'regionId': 'seoul-gangnam',
        'isUrgent': false,
        'isPremium': false,
        'isHidden': false,
        'status': 'published',
        'ownerId': 'me',
        'createdAt': created,
      },
    ];
  }

  static final List<Map<String, dynamic>> _myJobsJson = _createMyJobsJson();

  static Set<String> get _ownerJobIds => _myJobsJson
      .map((j) => j['id']?.toString() ?? '')
      .where((id) => id.isNotEmpty)
      .toSet();

  static bool _spareListingSynced = false;

  static Future<void> _syncShopJobsToSpareListing() async {
    if (_spareListingSynced) return;
    for (final raw in _myJobsJson) {
      final job = Job.fromJson(Map<String, dynamic>.from(raw));
      await _syncPublicListing(job);
    }
    _spareListingSynced = true;
  }

  static Map<String, dynamic> _jobSnapshot(String jobId) {
    final found = _myJobsJson.firstWhere(
      (j) => j['id'] == jobId,
      orElse: () => <String, dynamic>{},
    );
    if (found.isNotEmpty) {
      return Map<String, dynamic>.from(found);
    }
    final spareOnly = MockSpareData.jobJsonSnapshot(jobId);
    if (spareOnly != null) {
      return spareOnly;
    }
    return <String, dynamic>{'id': jobId};
  }

  /// mock-spare-1(로그인) ↔ spare-mock-1(지원·프로필) 통일.
  static String normalizeSpareId(String spareId) {
    if (spareId == 'mock-spare-1') return 'spare-mock-1';
    return spareId;
  }

  static void _syncEmbeddedApplicationJobs(String jobId) {
    final snapshot = _jobSnapshot(jobId);
    if (snapshot.length <= 1) return;
    for (var i = 0; i < _shopApplicationsJson.length; i++) {
      final raw = Map<String, dynamic>.from(_shopApplicationsJson[i]);
      final job = raw['job'];
      if (job is! Map || job['id']?.toString() != jobId) continue;
      _shopApplicationsJson[i] = {...raw, 'job': snapshot};
    }
  }

  static Map<String, dynamic> _hydrateApplicationRow(
    Map<String, dynamic> raw,
  ) {
    final copy = Map<String, dynamic>.from(raw);
    final job = copy['job'];
    if (job is Map) {
      final jobId = job['id']?.toString();
      if (jobId != null && jobId.isNotEmpty) {
        final fresh = _jobSnapshot(jobId);
        if (fresh.length > 1) copy['job'] = fresh;
      }
    }
    return copy;
  }

  static Future<List<SpareProfile>> getSpares() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sparesJson.map((j) => SpareProfile.fromJson(j)).toList();
  }

  static Future<SpareProfile> getSpareById(String spareId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final found = _sparesJson.firstWhere(
      (j) => j['id'] == spareId,
      orElse: () => _sparesJson.first,
    );
    return SpareProfile.fromJson(Map<String, dynamic>.from(found));
  }

  static final Set<String> _dismissedNotificationIds = {};

  static Future<void> dismissNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 80));
    _dismissedNotificationIds.add(notificationId);
  }

  /// 샵 홈·알림 벨용 — 스페어 지원·공고 운영 알림.
  static Future<List<AppNotification>> getShopNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final all = [
      ...MockSpareData.shopSpaceNotifications,
      AppNotification.fromJson({
        'id': 'notif-shop-1',
        'type': 'application_received',
        'title': '새 지원',
        'message': '김디자이너님이 「오후 스텝 급구」에 지원했습니다',
        'isRead': false,
        'createdAt': now.toIso8601String(),
        'relatedJobId': 'job-mock-1',
        'relatedUserId': 'spare-mock-1',
      }),
      AppNotification.fromJson({
        'id': 'notif-shop-2',
        'type': 'application_received',
        'title': '새 지원',
        'message': '이스텝님이 「평일 오전 스텝 (초보 가능)」에 지원했습니다',
        'isRead': false,
        'createdAt': now.subtract(const Duration(minutes: 12)).toIso8601String(),
        'relatedJobId': 'job-mock-3',
        'relatedUserId': 'spare-mock-2',
      }),
      AppNotification.fromJson({
        'id': 'notif-shop-3',
        'type': 'job_closing',
        'title': '공고 마감 임박',
        'message': '「오후 스텝 급구」 모집 마감이 2시간 남았습니다',
        'isRead': false,
        'createdAt': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'relatedJobId': 'job-mock-1',
      }),
    ];
    return all
        .where((n) => !_dismissedNotificationIds.contains(n.id))
        .toList();
  }

  static final List<Map<String, dynamic>> _shopApplicationsJson = [
    {
      'id': 'app-mock-1',
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'job': _jobSnapshot('job-mock-1'),
      'spare': {
        'id': 'spare-mock-1',
        'username': '1',
        'name': '김디자이너',
        'email': 'spare@example.com',
        'role': 'spare',
        'createdAt': DateTime.now().toIso8601String(),
      },
    },
    {
      'id': 'app-mock-2',
      'status': 'pending',
      'createdAt': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
      'job': _jobSnapshot('job-mock-3'),
      'spare': {
        'id': 'spare-mock-2',
        'username': 'lee_step',
        'name': '이스텝',
        'email': 'lee@example.com',
        'role': 'spare',
        'createdAt': DateTime.now().toIso8601String(),
      },
    },
    {
      'id': 'app-mock-3',
      'status': 'approved',
      'createdAt':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'job': _jobSnapshot('job-mock-2'),
      'spare': {
        'id': 'spare-mock-3',
        'username': 'park_des',
        'name': '박디자이너',
        'email': 'park@example.com',
        'role': 'spare',
        'createdAt': DateTime.now().toIso8601String(),
      },
    },
  ];

  static Future<List<Application>> getShopApplications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final ownerIds = _ownerJobIds;
    return _shopApplicationsJson
        .where((raw) {
          final job = raw['job'];
          if (job is! Map) return false;
          return ownerIds.contains(job['id']?.toString());
        })
        .map((j) => Application.fromJson(_hydrateApplicationRow(j)))
        .toList();
  }

  /// 스페어「내 지원」— 로그인 스페어 본인 지원만.
  static Future<List<Application>> getSpareApplications(String spareId) async {
    final key = normalizeSpareId(spareId);
    final all = await getShopApplications();
    return all
        .where((a) => normalizeSpareId(a.spare.id) == key)
        .toList();
  }

  /// 스페어 지원 시 샵 [_shopApplicationsJson]에 추가.
  static Future<void> addApplication({
    required String jobId,
    required Map<String, dynamic> spare,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final snapshot = _jobSnapshot(jobId);
    if (snapshot.length <= 1) {
      throw NotFoundException('공고를 찾을 수 없습니다');
    }

    final status = snapshot['status']?.toString() ?? '';
    if (status != 'published') {
      throw ValidationException('지원할 수 없는 공고입니다');
    }
    if (snapshot['isHidden'] == true) {
      throw ValidationException('지원할 수 없는 공고입니다');
    }

    final spareId = normalizeSpareId(spare['id']?.toString() ?? '');
    final duplicate = _shopApplicationsJson.any((raw) {
      final job = raw['job'];
      final s = raw['spare'];
      if (job is! Map || s is! Map) return false;
      if (job['id']?.toString() != jobId) return false;
      if (normalizeSpareId(s['id']?.toString() ?? '') != spareId) {
        return false;
      }
      final appStatus =
          ApplicationStatusUtils.normalize(raw['status']?.toString() ?? '');
      if (appStatus == 'cancelled_contact_violation') {
        throw ValidationException(
          '연락처 위반으로 취소된 공고입니다. 다시 지원할 수 없습니다.',
        );
      }
      return appStatus == 'pending' || appStatus == 'approved';
    });
    if (duplicate) {
      throw ValidationException('이미 지원한 공고입니다');
    }

    _shopApplicationsJson.insert(
      0,
      {
        'id': 'app-mock-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'lockedEnergy': _energyFromJobSnapshot(snapshot),
        'job': snapshot,
        'spare': {
          ...spare,
          'id': spareId,
          'role': 'spare',
        },
      },
    );
  }

  static int _energyFromJobSnapshot(Map<String, dynamic> snapshot) {
    final raw = snapshot['energy'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  /// 연락처 위반 3회 — 스페어 지원 취소. 잠금 에너지 반환값(몰수 기록용).
  static Future<int> cancelApplicationForContactViolation({
    required String jobId,
    required String spareId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final norm = normalizeSpareId(spareId);
    final index = _shopApplicationsJson.indexWhere((raw) {
      final job = raw['job'];
      final s = raw['spare'];
      if (job is! Map || s is! Map) return false;
      if (job['id']?.toString() != jobId) return false;
      if (normalizeSpareId(s['id']?.toString() ?? '') != norm) return false;
      final appStatus =
          ApplicationStatusUtils.normalize(raw['status']?.toString() ?? '');
      return appStatus == 'pending';
    });
    if (index < 0) return 0;

    final raw = Map<String, dynamic>.from(_shopApplicationsJson[index]);
    final locked = raw['lockedEnergy'] is int
        ? raw['lockedEnergy'] as int
        : int.tryParse(raw['lockedEnergy']?.toString() ?? '') ?? 0;
    _shopApplicationsJson[index] = {
      ...raw,
      'status': 'cancelled_contact_violation',
      'cancelledAt': DateTime.now().toIso8601String(),
      'cancelReason': 'contact_violation',
    };
    return locked;
  }

  /// 스페어·공고 지원 상태 (없으면 null).
  static Future<String?> spareApplicationStatusForJob({
    required String jobId,
    required String spareId,
  }) async {
    final norm = normalizeSpareId(spareId);
    for (final raw in _shopApplicationsJson) {
      final job = raw['job'];
      final s = raw['spare'];
      if (job is! Map || s is! Map) continue;
      if (job['id']?.toString() != jobId) continue;
      if (normalizeSpareId(s['id']?.toString() ?? '') != norm) continue;
      return ApplicationStatusUtils.normalize(raw['status']?.toString() ?? '');
    }
    return null;
  }

  /// 인기도 산정용 — 지원·조회 집계 (mock).
  static Map<String, JobPopularityMetrics> popularityMetricsForJobs(
    Iterable<String> jobIds,
  ) {
    final applicationCounts = <String, int>{};
    for (final raw in _shopApplicationsJson) {
      final job = raw['job'];
      if (job is! Map) continue;
      final id = job['id']?.toString();
      if (id == null || id.isEmpty) continue;
      final status =
          ApplicationStatusUtils.normalize(raw['status']?.toString() ?? '');
      if (status == 'pending' || status == 'approved') {
        applicationCounts[id] = (applicationCounts[id] ?? 0) + 1;
      }
    }

    return {
      for (final id in jobIds)
        id: JobPopularityMetrics(
          applicationCount: applicationCounts[id] ?? 0,
          viewCount: MockSpareData.mockViewCountForJob(id),
        ),
    };
  }

  static Job? _jobRecordForId(String jobId) {
    final index = _myJobsJson.indexWhere((j) => j['id'] == jobId);
    if (index < 0) return null;
    return Job.fromJson(Map<String, dynamic>.from(_myJobsJson[index]));
  }

  static Future<({bool jobAutoClosed})> approveShopApplication(
    String applicationId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index =
        _shopApplicationsJson.indexWhere((a) => a['id'] == applicationId);
    if (index < 0) {
      throw NotFoundException('지원 정보를 찾을 수 없습니다');
    }

    final raw = Map<String, dynamic>.from(_shopApplicationsJson[index]);
    if (ApplicationStatusUtils.normalize(raw['status']?.toString() ?? '') !=
        'pending') {
      throw ValidationException('이미 처리된 지원입니다');
    }

    final applications = _shopApplicationsJson
        .map((j) => Application.fromJson(Map<String, dynamic>.from(j)))
        .toList();
    final application = applications[index];
    final job = _jobRecordForId(application.job.id) ?? application.job;

    if (job.status == 'closed') {
      throw ValidationException('이미 마감된 공고입니다');
    }
    if (ShopApplicantCounts.isApprovalFull(job, applications)) {
      throw ValidationException(
        '모집 인원(${job.requiredCount}명)이 모두 찼습니다',
      );
    }

    _shopApplicationsJson[index] = {
      ...raw,
      'status': 'approved',
    };

    MockSpareData.addScheduleFromApprovedApplication(
      applicationId: applicationId,
      job: job,
      spareId: normalizeSpareId(application.spare.id),
      spareName: application.spare.name ?? application.spare.username,
    );

    final approvedAfter = ShopApplicantCounts.approvedForJob(
      job.id,
      _shopApplicationsJson.map(
        (j) => Application.fromJson(Map<String, dynamic>.from(j)),
      ),
    );

    var jobAutoClosed = false;
    if (approvedAfter >= job.requiredCount) {
      await updateMyJob(job.id, {'status': 'closed'});
      jobAutoClosed = true;
    }

    return (jobAutoClosed: jobAutoClosed);
  }

  static Future<bool> rejectShopApplication(String applicationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index =
        _shopApplicationsJson.indexWhere((a) => a['id'] == applicationId);
    if (index < 0) return false;
    _shopApplicationsJson[index] = {
      ...Map<String, dynamic>.from(_shopApplicationsJson[index]),
      'status': 'rejected',
    };
    return true;
  }

  static Future<Map<String, dynamic>> getShopStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'totalCompleted': 23,
      'vipLevel': 'silver',
      'tier': 'silver',
      'nextCount': 7,
      'progress': 0.7,
    };
  }

  /// mock 사업자등록증 OCR — 체크섬 유효 번호 124-81-00998.
  static Future<BusinessRegistrationOcrResult> mockScanBusinessRegistration() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return BusinessRegistrationOcrResult(
      requestId: 'mock-ocr-${DateTime.now().millisecondsSinceEpoch}',
      businessNumber: '124-81-00998',
      businessNumberConfidence: 0.96,
      businessName: '헤어스페어 강남점',
      businessNameConfidence: 0.94,
      representativeName: '김원장',
      representativeNameConfidence: 0.91,
      businessType: '서비스업',
      businessTypeConfidence: 0.88,
      businessCategory: '미용업',
      businessCategoryConfidence: 0.87,
      address: '서울특별시 강남구 테헤란로 123, 2층',
      addressConfidence: 0.86,
      openingDate: '20200315',
      openingDateConfidence: 0.82,
    );
  }

  /// mock 서버 NTS 검증 — Phase 2 연동 전 placeholder.
  static Future<BusinessRegistrationValidation> mockValidateBusinessRegistration({
    required String businessNumber,
    String? ocrRequestId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const BusinessRegistrationValidation(
      isNumberFormatValid: true,
      requiresNtsCheck: false,
      ntsVerified: true,
      ntsStatusMessage: 'mock: 국세청 조회 일치 (운영 연동 시 서버 검증)',
      serverValidated: true,
    );
  }

  static Future<Job?> getMyJobById(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final index = _myJobsJson.indexWhere((j) => j['id'] == jobId);
    if (index < 0) return null;
    return Job.fromJson(Map<String, dynamic>.from(_myJobsJson[index]));
  }

  /// 근무일이 지난 published/closed 공고를 expired로 이동(스페어 목록에서 제거).
  static Future<void> expirePastJobs({DateTime? now}) async {
    for (var i = 0; i < _myJobsJson.length; i++) {
      final raw = Map<String, dynamic>.from(_myJobsJson[i]);
      final status = raw['status']?.toString() ?? 'published';
      if (status == 'draft' || status == 'expired') continue;

      final date = raw['date']?.toString() ?? '';
      if (!JobWorkDateUtils.isWorkDatePast(date, now: now)) continue;

      _myJobsJson[i] = {...raw, 'status': 'expired'};
      await MockSpareData.removePublicJob(raw['id']?.toString() ?? '');
    }
  }

  static Future<List<Job>> getMyJobs({
    String? status,
    String? search,
    int? limit,
    int? offset,
  }) async {
    await expirePastJobs();
    await _syncShopJobsToSpareListing();
    await Future.delayed(const Duration(milliseconds: 280));
    var jobs = _myJobsJson
        .map((j) => Job.fromJson(Map<String, dynamic>.from(j)))
        .toList();

    if (status == 'active') {
      jobs = jobs
          .where((j) => j.status == 'published' || j.status == 'closed')
          .toList();
    } else if (status != null && status.isNotEmpty) {
      jobs = jobs.where((j) => j.status == status).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      jobs = jobs
          .where(
            (j) =>
                j.title.toLowerCase().contains(q) ||
                j.shopName.toLowerCase().contains(q),
          )
          .toList();
    }

    jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final start = offset ?? 0;
    final end = limit != null ? start + limit : jobs.length;
    if (start >= jobs.length) return [];
    return jobs.sublist(start, end.clamp(0, jobs.length));
  }

  static int unilateralCancelCount30d = 0;
  static DateTime? jobPostingSuspendedUntil;
  static DateTime? chatBlockedUntil;
  static int contactViolationRoomCount = 0;

  static DateTime? _later(DateTime? a, DateTime b) {
    if (a == null) return b;
    return a.isAfter(b) ? a : b;
  }

  static ({int count, DateTime? suspendedUntil}) shopCancellationState() {
    return (
      count: unilateralCancelCount30d,
      suspendedUntil: jobPostingSuspendedUntil,
    );
  }

  static void assertCanChat() {
    final until = chatBlockedUntil;
    if (until != null && DateTime.now().isBefore(until)) {
      throw ValidationException(
        '연락처 공유 위반으로 ${ContactViolationPolicy.shopPenaltyDays}일간 '
        '모든 대화가 제한됩니다. '
        '${until.year}.${until.month}.${until.day} '
        '${until.hour.toString().padLeft(2, '0')}:'
        '${until.minute.toString().padLeft(2, '0')} 이후에 이용해 주세요.',
        code: 'CHAT_BLOCKED_CONTACT_VIOLATION',
      );
    }
  }

  static void assertCanPostJob() {
    assertCanChat();
    final until = jobPostingSuspendedUntil;
    if (until != null && DateTime.now().isBefore(until)) {
      throw ValidationException(
        '공고 등록이 제한된 상태입니다. '
        '${until.year}.${until.month}.${until.day} 이후에 다시 등록해 주세요.',
        code: 'JOB_POSTING_SUSPENDED',
      );
    }
  }

  /// 샵 대화방 3회 적발 시 1일 제재. 누적 3회 제재 시 계정 탈퇴·블랙리스트.
  static ContactViolationResult applyContactViolationPenalty(String shopId) {
    contactViolationRoomCount++;
    final now = DateTime.now();
    final penaltyEnd = now.add(
      const Duration(days: ContactViolationPolicy.shopPenaltyDays),
    );
    chatBlockedUntil = _later(chatBlockedUntil, penaltyEnd);
    jobPostingSuspendedUntil = _later(jobPostingSuspendedUntil, penaltyEnd);

    if (contactViolationRoomCount >=
        ContactViolationPolicy.maxShopRoomPenaltiesBeforeBan) {
      MockAuthData.terminateShopAccount(shopId);
      return const ContactViolationResult(
        attemptCount: ContactViolationPolicy.maxAttemptsPerChat,
        maxAttempts: ContactViolationPolicy.maxAttemptsPerChat,
        outcome: ContactViolationOutcome.shopAccountTerminated,
        userMessage:
            '연락처 공유 위반이 ${ContactViolationPolicy.maxShopRoomPenaltiesBeforeBan}회 '
            '누적되어 계정이 자동 탈퇴 처리되었습니다. '
            '해당 사업자는 재가입이 불가합니다.',
        chatDeleted: true,
        accountTerminated: true,
      );
    }

    return ContactViolationResult(
      attemptCount: ContactViolationPolicy.maxAttemptsPerChat,
      maxAttempts: ContactViolationPolicy.maxAttemptsPerChat,
      outcome: ContactViolationOutcome.shopDailyPenalty,
      userMessage:
          '연락처 전송 시도 ${ContactViolationPolicy.maxAttemptsPerChat}회가 누적되어 '
          '해당 대화방이 삭제되었습니다.\n'
          '${ContactViolationPolicy.shopPenaltyDays}일간 모든 대화와 공고 등록이 '
          '제한됩니다. '
          '(제재 $contactViolationRoomCount/'
          '${ContactViolationPolicy.maxShopRoomPenaltiesBeforeBan}회)',
      chatDeleted: true,
      shopChatBlockedUntil: chatBlockedUntil,
      shopJobPostingBlockedUntil: jobPostingSuspendedUntil,
    );
  }

  static void recordShopUnilateralCancel() {
    unilateralCancelCount30d++;
    if (unilateralCancelCount30d >=
        ScheduleCancellationPolicy.shopUnilateralCancelLimit30d) {
      jobPostingSuspendedUntil = DateTime.now().add(
        const Duration(
          days: ScheduleCancellationPolicy.shopJobPostingSuspensionDays,
        ),
      );
    }
  }

  static Future<Job> addMyJob(Job job) async {
    await Future.delayed(const Duration(milliseconds: 200));
    assertCanPostJob();
    final json = Map<String, dynamic>.from(job.toJson());
    _myJobsJson.insert(0, json);
    if (job.status == 'published' && !job.isHidden) {
      await MockSpareData.upsertPublicJob(json);
    }
    return job;
  }

  static Future<Job?> updateMyJob(String jobId, Map<String, dynamic> patch) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _myJobsJson.indexWhere((j) => j['id'] == jobId);
    if (index < 0) return null;
    _myJobsJson[index] = {..._myJobsJson[index], ...patch};
    final job = Job.fromJson(Map<String, dynamic>.from(_myJobsJson[index]));
    _syncEmbeddedApplicationJobs(jobId);
    await _syncPublicListing(job);
    return job;
  }

  static Future<bool> deleteMyJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final before = _myJobsJson.length;
    _myJobsJson.removeWhere((j) => j['id'] == jobId);
    if (_myJobsJson.length == before) return false;
    _shopApplicationsJson.removeWhere(
      (a) => (a['job'] as Map<String, dynamic>)['id'] == jobId,
    );
    await MockSpareData.removePublicJob(jobId);
    return true;
  }

  static Future<Job?> hideMyJob(String jobId) async {
    return updateMyJob(jobId, {'isHidden': true});
  }

  static Future<Job?> unhideMyJob(String jobId) async {
    return updateMyJob(jobId, {'isHidden': false});
  }

  static Future<void> _syncPublicListing(Job job) async {
    if (job.status == 'published' && !job.isHidden) {
      await MockSpareData.upsertPublicJob(job.toJson());
    } else {
      await MockSpareData.removePublicJob(job.id);
    }
  }

  static final Set<String> _thumbsUpGivenSpareIds = {};

  /// 샵 → 스페어 따봉 (mock, 중복 전송 방지).
  static Future<void> giveThumbsUpToSpare(String spareId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (_thumbsUpGivenSpareIds.contains(spareId)) return;
    _thumbsUpGivenSpareIds.add(spareId);
    final index = _sparesJson.indexWhere((s) => s['id'] == spareId);
    if (index < 0) return;
    final current = (_sparesJson[index]['thumbsUpCount'] as int?) ?? 0;
    _sparesJson[index]['thumbsUpCount'] = current + 1;
  }

}
