import '../models/job.dart';
import '../models/schedule.dart';
import '../models/notification.dart';
import '../models/point_transaction.dart';
import '../models/challenge_profile.dart';
import '../models/challenge_comment.dart';
import '../models/space_operating_schedule.dart';
import '../models/space_rental.dart';
import '../utils/space_slot_builder.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';
import 'mock_model_messaging_data.dart';
import '../services/payment_service.dart';
import '../services/review_service.dart';
import '../models/challenge_feed.dart';
import '../models/education_enrollment.dart';
import '../models/education_material.dart';
import '../screens/spare/education_screen.dart';
import '../utils/region_helper.dart';
import '../utils/schedule_conflict.dart';
import '../utils/contact_violation_policy.dart';
import '../utils/schedule_cancellation_policy.dart';
import '../utils/schedule_work_session.dart';
import '../utils/app_exception.dart';
import '../utils/energy_purchase_pricing.dart';
import '../utils/schedule_space_rental.dart';
import '../utils/job_work_date_utils.dart';
import '../models/region.dart';
import 'mock_shop_data.dart';

/// 스페어·미용실(공고 목록) Mock 데이터
class MockSpareData {
  static String _mockImage(String key) => 'mock://$key';

  static String _mockJobImage(String jobId) => _mockImage('job/$jobId');
  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 겹침 모달 QA용 — [overlapDemoDateYmd] 10:00~18:00 확정 근무와 15:00~21:00 공고.
  static const String overlapDemoJobId = 'job-mock-overlap-demo';
  static const String overlapDemoBlockerScheduleId = 'sched-mock-overlap-blocker';

  static String get overlapDemoDateYmd =>
      _ymd(DateTime.now().add(const Duration(days: 1)));

  static Map<String, dynamic> _overlapDemoJobJson(String dateYmd) => {
        'id': overlapDemoJobId,
        'images': [_mockJobImage(overlapDemoJobId)],
        'title': '[겹침테스트] 저녁 스텝 모집',
        'shopName': '홍대 트렌디 헤어',
        'date': dateYmd,
        'time': '15:00',
        'endTime': '21:00',
        'amount': 55000,
        'energy': 3,
        'requiredCount': 1,
        'regionId': 'seoul-mapo',
        'isUrgent': true,
        'isPremium': false,
        'status': 'published',
        'createdAt': DateTime.now().toIso8601String(),
      };

  static Job _overlapDemoJob() =>
      Job.fromJson(_overlapDemoJobJson(overlapDemoDateYmd));

  static Map<String, dynamic> _overlapDemoBlockerScheduleJson(String dateYmd) => {
        'id': overlapDemoBlockerScheduleId,
        'jobId': 'job-mock-overlap-blocker-ref',
        'spareId': 'spare-mock-1',
        'shopId': 'mock-shop-1',
        'date': dateYmd,
        'startTime': '10:00',
        'endTime': '18:00',
        'status': 'scheduled',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'job': {
          'id': 'job-mock-overlap-blocker-ref',
          'title': '오전~오후 스텝',
          'shopName': '청담 하이엔드 살롱',
          'date': dateYmd,
          'time': '10:00',
          'endTime': '18:00',
          'amount': 70000,
          'energy': 5,
          'requiredCount': 1,
          'regionId': 'seoul-gangnam',
          'isUrgent': false,
          'isPremium': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
        'spare': {'id': 'spare-mock-1', 'name': '김디자이너'},
      };

  /// 세션 내 찜 ID (mock 전용).
  static final Set<String> _favoriteJobIds = {'job-mock-1'};

  /// 시드 공고 근무일 — 오늘 기준 N일 후 (0=오늘, 1=내일).
  static const Map<String, int> _seedJobDayOffsets = {
    'job-mock-1': 4,
    'job-mock-2': 3,
    'job-mock-3': 1,
    'job-mock-4': 2,
    'job-mock-5': 5,
    'job-mock-6': 4,
    'job-mock-7': 3,
    'job-mock-8': 6,
    'job-mock-9': 7,
    'job-mock-10': 1,
  };

  static void _refreshSeedJobWorkDates() {
    final today = DateTime.now();
    for (var i = 0; i < _jobsJson.length; i++) {
      final id = _jobsJson[i]['id']?.toString();
      final offset = _seedJobDayOffsets[id];
      if (offset == null) continue;
      _jobsJson[i] = {
        ...Map<String, dynamic>.from(_jobsJson[i]),
        'date': _ymd(today.add(Duration(days: offset))),
      };
    }
  }

  static final List<Map<String, dynamic>> _jobsJson = [
    {
      'id': 'job-mock-1',
      'images': [_mockJobImage('job-mock-1')],
      'title': '오후 스텝 급구',
      'shopName': '빌라드블랑 강남점',
      'date': '2026-06-01',
      'time': '14:00',
      'endTime': '22:00',
      'amount': 50000,
      'energy': 5,
      'requiredCount': 1,
      'regionId': 'seoul-gangnam',
      'isUrgent': true,
      'isPremium': false,
      'status': 'published',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-2',
      'images': [_mockJobImage('job-mock-2')],
      'title': '주말 디자이너 대타',
      'shopName': '헤어스튜디오 A',
      'date': '2026-06-02',
      'time': '10:00',
      'endTime': '18:00',
      'amount': 80000,
      'energy': 4,
      'requiredCount': 1,
      'regionId': 'seoul-mapo',
      'isUrgent': false,
      'isPremium': true,
      'status': 'closed',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-3',
      'images': [_mockJobImage('job-mock-3')],
      'title': '평일 오전 스텝 (초보 가능)',
      'shopName': '이미용실',
      'date': '2026-06-03',
      'time': '09:00',
      'endTime': '15:00',
      'amount': 45000,
      'energy': 2,
      'requiredCount': 2,
      'regionId': 'seoul-gangnam',
      'isUrgent': false,
      'isPremium': false,
      'status': 'published',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-4',
      'images': [_mockJobImage('job-mock-4')],
      'title': '금요 야간 디자이너',
      'shopName': '이미용실',
      'date': '2026-06-04',
      'time': '18:00',
      'endTime': '23:00',
      'amount': 95000,
      'energy': 5,
      'requiredCount': 1,
      'regionId': 'seoul-gangnam',
      'isUrgent': true,
      'isPremium': true,
      'status': 'published',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-5',
      'images': [_mockJobImage('job-mock-5')],
      'title': '토요일 샴푸담당 스텝',
      'shopName': '이미용실',
      'date': '2026-06-07',
      'time': '11:00',
      'endTime': '19:00',
      'amount': 52000,
      'energy': 3,
      'requiredCount': 1,
      'regionId': 'seoul-seocho',
      'isUrgent': false,
      'isPremium': false,
      'status': 'published',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-6',
      'images': [_mockJobImage('job-mock-6')],
      'title': '[급구] 내일 오전 컷 모델',
      'shopName': '빌라드블랑 강남점',
      'date': '2026-06-08',
      'time': '10:00',
      'endTime': '14:00',
      'amount': 60000,
      'energy': 5,
      'requiredCount': 1,
      'regionId': 'seoul-gangnam',
      'isUrgent': true,
      'isPremium': false,
      'status': 'published',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-7',
      'images': [_mockJobImage('job-mock-7')],
      'title': '일요일 휴무 대체 디자이너',
      'shopName': '헤어살롱 B',
      'date': '2026-06-09',
      'time': '12:00',
      'endTime': '20:00',
      'amount': 88000,
      'energy': 4,
      'requiredCount': 1,
      'regionId': 'seoul-mapo',
      'isUrgent': false,
      'isPremium': false,
      'status': 'published',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-8',
      'images': [_mockJobImage('job-mock-8')],
      'title': '드라이·스타일링 보조',
      'shopName': '이미용실',
      'date': '2026-06-10',
      'time': '13:00',
      'endTime': '21:00',
      'amount': 48000,
      'energy': 1,
      'requiredCount': 1,
      'regionId': 'seoul-gangnam',
      'isUrgent': false,
      'isPremium': false,
      'status': 'closed',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-9',
      'images': [_mockJobImage('job-mock-9')],
      'title': '(임시저장) 봄 시즌 이벤트 스텝',
      'shopName': '이미용실',
      'date': '2026-06-15',
      'time': '10:00',
      'endTime': '18:00',
      'amount': 55000,
      'energy': 3,
      'requiredCount': 2,
      'regionId': 'seoul-gangnam',
      'isUrgent': false,
      'isPremium': false,
      'status': 'draft',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-10',
      'images': [_mockJobImage('job-mock-10')],
      'title': '저녁 타임 스텝 (월수금)',
      'shopName': '이미용실',
      'date': '2026-06-11',
      'time': '17:00',
      'endTime': '22:00',
      'amount': 62000,
      'energy': 2,
      'requiredCount': 1,
      'regionId': 'seoul-gangnam',
      'isUrgent': false,
      'isPremium': true,
      'status': 'published',
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  static Future<void> upsertPublicJob(Map<String, dynamic> json) async {
    final id = json['id']?.toString();
    if (id == null || id.isEmpty) return;
    final index = _jobsJson.indexWhere((j) => j['id'] == id);
    final entry = Map<String, dynamic>.from(json)..remove('ownerId');
    if (index >= 0) {
      _jobsJson[index] = entry;
    } else {
      _jobsJson.insert(0, entry);
    }
  }

  static Future<void> removePublicJob(String jobId) async {
    _jobsJson.removeWhere((j) => j['id'] == jobId);
  }

  static Future<List<Job>> getJobs({String? searchQuery}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _refreshSeedJobWorkDates();
    var jobs = [
      _overlapDemoJob(),
      ..._jobsJson.map((j) => Job.fromJson(j)),
    ].where((j) {
      if (j.isHidden || j.status != 'published') return false;
      return !JobWorkDateUtils.isWorkDatePast(j.date);
    }).toList();
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      jobs = jobs.where((j) {
        final title = (j.title).toLowerCase();
        final shopName = (j.shopName).toLowerCase();
        return title.contains(q) || shopName.contains(q);
      }).toList();
    }
    return jobs;
  }

  static Future<Job> getJobById(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _refreshSeedJobWorkDates();
    if (jobId == overlapDemoJobId) {
      return _overlapDemoJob();
    }
    final found = _jobsJson.firstWhere(
      (j) => j['id'] == jobId,
      orElse: () => _jobsJson.first,
    );
    return Job.fromJson(Map<String, dynamic>.from(found));
  }

  /// 샵 지원 mock 등 sync 스냅샷용 — [getJobById]와 동일 소스.
  static Map<String, dynamic>? jobJsonSnapshot(String jobId) {
    _refreshSeedJobWorkDates();
    if (jobId == overlapDemoJobId) {
      return Map<String, dynamic>.from(
        _overlapDemoJobJson(overlapDemoDateYmd),
      );
    }
    for (final raw in _jobsJson) {
      if (raw['id'] == jobId) {
        return Map<String, dynamic>.from(raw);
      }
    }
    return null;
  }

  static Future<List<Job>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _refreshSeedJobWorkDates();
    final jobs = <Job>[];
    for (final id in _favoriteJobIds) {
      for (final json in _jobsJson) {
        if (json['id'] == id) {
          jobs.add(Job.fromJson(Map<String, dynamic>.from(json)));
          break;
        }
      }
    }
    return jobs;
  }

  static Future<void> addFavorite(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _favoriteJobIds.add(jobId);
  }

  static Future<void> removeFavorite(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _favoriteJobIds.remove(jobId);
  }

  static bool isFavorite(String jobId) => _favoriteJobIds.contains(jobId);

  /// mock 조회수 — 지원·찜·일급 기반 추정 (인기도 보조 지표).
  static int mockViewCountForJob(String jobId) {
    var views = 12;
    if (_favoriteJobIds.contains(jobId)) views += 18;
    if (jobId.hashCode.abs() % 17 != 0) {
      views += jobId.hashCode.abs() % 40;
    }
    return views;
  }

  static final Set<String> _rejectedScheduleIds = {};
  static final Map<String, String> _scheduleStatusOverrides = {};
  static final List<Map<String, dynamic>> _addedSchedulesJson = [];
  static final Set<String> _dismissedNotificationIds = {};
  static final Set<String> _readNotificationIds = {};

  static List<Schedule> _applyScheduleMutations(List<Schedule> list) {
    return list
        .where((s) => !_rejectedScheduleIds.contains(s.id))
        .map((s) {
          final override = _scheduleStatusOverrides[s.id];
          if (override == null) return s;
          final json = s.toJson();
          json['status'] = override;
          json['updatedAt'] = DateTime.now().toIso8601String();
          return Schedule.fromJson(json);
        })
        .toList();
  }

  static Future<Schedule> acceptWorkProposal(String scheduleId) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final list = await getSchedules();
    final match = list.where((s) => s.id == scheduleId).toList();
    if (match.isEmpty) {
      throw StateError('스케줄을 찾을 수 없습니다: $scheduleId');
    }
    final target = match.first;
    final window = ScheduleConflict.windowFromSchedule(target);
    if (window != null) {
      final conflicts = ScheduleConflict.findBlockingSchedules(
        all: list,
        candidate: window,
        ignoreScheduleId: scheduleId,
      );
      if (conflicts.isNotEmpty) {
        throw ValidationException(
          ScheduleConflict.overlapUserMessage(
            actionLabel: '제안 수락',
            conflicts: conflicts,
          ),
          code: ScheduleConflict.overlapCode,
        );
      }
    }
    _scheduleStatusOverrides[scheduleId] = 'scheduled';
    final updated = await getSchedules();
    return updated.firstWhere((s) => s.id == scheduleId);
  }

  static Future<void> cancelSchedule(
    String scheduleId, {
    CancellationActor actor = CancellationActor.spare,
    String? cancelReason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final list = await getSchedules();
    final match = list.where((s) => s.id == scheduleId).toList();
    if (match.isEmpty) {
      throw StateError('스케줄을 찾을 수 없습니다: $scheduleId');
    }
    final schedule = match.first;
    final shopState = MockShopData.shopCancellationState();
    final eligibility = ScheduleCancellationPolicy.evaluate(
      schedule,
      actor: actor,
      shopUnilateralCancelCount30d: shopState.count,
      shopJobPostingSuspendedUntil: shopState.suspendedUntil,
    );
    if (!eligibility.canCancelInApp) {
      throw ValidationException(
        eligibility.blockedMessage ??
            ScheduleCancellationPolicy.blockedOverlapMessage(),
        code: ScheduleCancellationPolicy.cancelBlockedCode,
      );
    }
    _scheduleStatusOverrides[scheduleId] = 'cancelled';
    if (actor == CancellationActor.shop) {
      MockShopData.recordShopUnilateralCancel();
    }
    await sendScheduleCancellationNotice(
      schedule: schedule,
      actor: actor,
      cancelReason: cancelReason,
    );
  }

  static String? _findChatIdForSchedule(Schedule schedule) {
    for (final chat in _chatsJson) {
      final jobId = chat['jobId']?.toString();
      if (jobId != null && jobId == schedule.jobId) {
        return chat['id']?.toString();
      }
      if (chat['shopId']?.toString() == schedule.shopId &&
          chat['spareId']?.toString() == schedule.spareId) {
        return chat['id']?.toString();
      }
    }
    return null;
  }

  static Future<void> sendScheduleCancellationNotice({
    required Schedule schedule,
    required CancellationActor actor,
    String? cancelReason,
  }) async {
    final chatId = _findChatIdForSchedule(schedule);
    if (chatId == null) return;

    final shop = schedule.job?.shopName ?? '매장';
    final reasonSuffix = cancelReason != null && cancelReason.trim().isNotEmpty
        ? ' (사유: ${cancelReason.trim()})'
        : '';
    final content = actor == CancellationActor.shop
        ? '[시스템] $shop의 ${schedule.date} ${schedule.startTime} 근무가 '
            '매장 사정으로 취소되었습니다.$reasonSuffix'
        : '[시스템] ${schedule.date} ${schedule.startTime} $shop 근무가 '
            '스페어 사정으로 취소되었습니다.$reasonSuffix';

    await sendMessage(
      chatId,
      content,
      senderId: 'system',
      senderName: '시스템',
      senderRole: 'system',
    );
  }

  /// 샵 근무 확인·정산 (mock).
  static Future<Map<String, dynamic>> confirmWork({
    required String scheduleId,
    required bool thumbsUp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final list = await getSchedules();
    final match = list.where((s) => s.id == scheduleId).toList();
    if (match.isEmpty) {
      throw ValidationException('스케줄을 찾을 수 없습니다.');
    }
    final schedule = match.first;
    final blocked = ScheduleWorkSession.settlementBlockedMessage(schedule);
    if (blocked != null) {
      throw ValidationException(blocked);
    }
    _scheduleStatusOverrides[scheduleId] = 'completed';
    return {
      'amount': schedule.job?.amount ?? 0,
      'returnedEnergy': schedule.job?.energy ?? 0,
      'thumbsUp': thumbsUp,
    };
  }

  static Future<void> applyToJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final job = await getJobById(jobId);
    final window = ScheduleConflict.windowFromJob(job);
    if (window == null) return;
    final schedules = await getSchedules();
    final conflicts = ScheduleConflict.findBlockingSchedules(
      all: schedules,
      candidate: window,
    );
    if (conflicts.isNotEmpty) {
      throw ValidationException(
        ScheduleConflict.overlapUserMessage(
          actionLabel: '지원',
          conflicts: conflicts,
        ),
        code: ScheduleConflict.overlapCode,
      );
    }
  }

  static String? findChatIdForJob(String jobId) {
    for (final c in _chatsJson) {
      if (c['jobId']?.toString() == jobId) {
        return c['id']?.toString();
      }
    }
    return null;
  }

  /// 공고 지원 후 스페어·매장 1:1 채팅방 (없으면 생성).
  static String ensureChatForJobApplication({
    required String jobId,
    required String jobTitle,
    required String shopName,
    required String spareId,
    required String spareName,
    String shopId = 'mock-shop-1',
  }) {
    if (isContactBannedForJob(jobId: jobId, spareId: spareId)) {
      throw ValidationException(
        '연락처 위반으로 이 공고 지원이 취소되어 연락할 수 없습니다.',
      );
    }

    final existing = findChatIdForJob(jobId);
    if (existing != null) return existing;

    final chatId = 'chat-job-$jobId';
    final now = DateTime.now();
    const welcome =
        '지원이 접수되었습니다. 근무 관련 문의는 이 채팅으로 남겨 주세요.';
    _chatsJson.insert(0, {
      'id': chatId,
      'shopId': shopId,
      'shopName': shopName,
      'spareId': spareId,
      'spareName': spareName,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'lastMessage': {
        'content': welcome,
        'createdAt': now.toIso8601String(),
      },
      'unreadCount': 0,
    });
    _chatMessages[chatId] = [
      {
        'id': 'msg-$chatId-welcome',
        'chatId': chatId,
        'senderId': shopId,
        'senderRole': 'shop',
        'senderName': shopName,
        'content': welcome,
        'createdAt': now.toIso8601String(),
        'isRead': false,
      },
    ];
    return chatId;
  }

  /// 모델 매칭 성공 시 모델과 1:1 채팅방 생성 (없으면).
  static String ensureChatForModel({
    required String modelId,
    required String modelName,
    required String spareId,
    required String spareName,
  }) {
    final chatId = 'chat-model-$modelId';
    final existing = _chatsJson.firstWhere(
      (c) => c['id']?.toString() == chatId,
      orElse: () => <String, dynamic>{},
    );
    if (existing.isNotEmpty) return chatId;

    final now = DateTime.now();
    const welcome = '모델 매칭이 성사되었어요! 촬영·시술 일정을 편하게 나눠 보세요.';
    _chatsJson.insert(0, {
      'id': chatId,
      'shopId': modelId,
      'shopName': modelName,
      'spareId': spareId,
      'spareName': spareName,
      'jobId': null,
      'jobTitle': '모델 매칭',
      'lastMessage': {
        'content': welcome,
        'createdAt': now.toIso8601String(),
      },
      'unreadCount': 0,
    });
    _chatMessages[chatId] = [
      {
        'id': 'msg-$chatId-welcome',
        'chatId': chatId,
        'senderId': modelId,
        'senderRole': 'shop',
        'senderName': modelName,
        'content': welcome,
        'createdAt': now.toIso8601String(),
        'isRead': false,
      },
    ];
    return chatId;
  }

  static Future<void> rejectWorkProposal(String scheduleId) async {
    await Future.delayed(const Duration(milliseconds: 220));
    _rejectedScheduleIds.add(scheduleId);
    _scheduleStatusOverrides.remove(scheduleId);
  }

  /// 공간 대여 승인 시 스케줄 현황에 표시 (선결제·확인용).
  static void addScheduleFromConfirmedSpaceBooking(SpaceBooking booking) {
    final scheduleId = 'sched-space-${booking.id}';
    if (_addedSchedulesJson.any((s) => s['id'] == scheduleId)) return;

    final dateStr = _ymd(booking.startTime);
    final startTime =
        '${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')}';
    final endTime =
        '${booking.endTime.hour.toString().padLeft(2, '0')}:${booking.endTime.minute.toString().padLeft(2, '0')}';
    final spaceLabel = booking.spaceRental?.shopName ?? '공간';
    final now = DateTime.now().toIso8601String();

    _addedSchedulesJson.add({
      'id': scheduleId,
      'jobId': ScheduleSpaceRental.jobIdMarker,
      'spareId': booking.spareId,
      'shopId': 'mock-shop-1',
      'date': dateStr,
      'startTime': startTime,
      'endTime': endTime,
      'status': 'scheduled',
      'createdAt': now,
      'updatedAt': now,
      'job': {
        'id': ScheduleSpaceRental.jobIdMarker,
        'title': '공간 대여 · $spaceLabel',
        'shopName': booking.spaceRental?.shopName ?? '미용실',
        'date': dateStr,
        'time': startTime,
        'endTime': endTime,
        'amount': booking.totalPrice,
        'energy': 0,
        'requiredCount': 1,
        'regionId': booking.spaceRental?.regionId ?? '',
        'isUrgent': false,
        'isPremium': false,
        'status': 'published',
        'ownerId': 'me',
        'createdAt': now,
      },
      'spare': {'id': booking.spareId, 'name': booking.spareName},
    });
  }

  /// 공간 대여 승인 시 채팅방 생성.
  static String ensureChatForSpaceBooking(SpaceBooking booking) {
    final markerJobId = 'space-${booking.spaceRentalId}';
    for (final c in _chatsJson) {
      if (c['spareId'] == booking.spareId &&
          c['jobId'] == markerJobId &&
          c['shopId'] == 'mock-shop-1') {
        return c['id'] as String;
      }
    }

    final chatId = 'chat-space-${booking.id}';
    final now = DateTime.now();
    const welcome =
        '공간 예약이 확정되었습니다. 이용 시간과 준비물은 이 채팅으로 문의해 주세요.';
    _chatsJson.insert(0, {
      'id': chatId,
      'shopId': 'mock-shop-1',
      'shopName': booking.spaceRental?.shopName ?? '빌라드블랑 강남점',
      'spareId': booking.spareId,
      'spareName': booking.spareName,
      'jobId': markerJobId,
      'jobTitle': '공간 대여',
      'lastMessage': {
        'content': welcome,
        'createdAt': now.toIso8601String(),
      },
      'unreadCount': 0,
    });
    _chatMessages[chatId] = [
      {
        'id': 'msg-$chatId-welcome',
        'chatId': chatId,
        'senderId': 'mock-shop-1',
        'senderRole': 'shop',
        'senderName': booking.spaceRental?.shopName ?? '빌라드블랑 강남점',
        'content': welcome,
        'createdAt': now.toIso8601String(),
        'isRead': false,
      },
    ];
    return chatId;
  }

  /// 공간 대여 스케줄에 연결된 채팅방 id (없으면 null).
  static String? findChatIdForSpaceSchedule(Schedule schedule) {
    final derived = ScheduleSpaceRental.chatIdFromSchedule(schedule);
    if (derived != null &&
        _chatsJson.any((c) => c['id']?.toString() == derived)) {
      return derived;
    }
    for (final chat in _chatsJson) {
      if (chat['shopId']?.toString() != schedule.shopId) continue;
      if (chat['spareId']?.toString() != schedule.spareId) continue;
      final jobId = chat['jobId']?.toString() ?? '';
      if (jobId.startsWith('space-')) {
        return chat['id']?.toString();
      }
    }
    return null;
  }

  /// 샵 지원 승인 시 근무 스케줄 생성 (mock).
  static void addScheduleFromApprovedApplication({
    required String applicationId,
    required Job job,
    required String spareId,
    required String spareName,
  }) {
    final scheduleId = 'sched-app-$applicationId';
    if (_addedSchedulesJson.any((s) => s['id'] == scheduleId)) return;
    final duplicate = _addedSchedulesJson.any(
      (s) =>
          s['jobId'] == job.id &&
          s['spareId'] == spareId &&
          s['status'] == 'scheduled',
    );
    if (duplicate) return;

    final now = DateTime.now().toIso8601String();
    _addedSchedulesJson.add({
      'id': scheduleId,
      'jobId': job.id,
      'spareId': spareId,
      'shopId': 'mock-shop-1',
      'date': job.date,
      'startTime': job.time,
      if (job.endTime != null && job.endTime!.isNotEmpty) 'endTime': job.endTime,
      'status': 'scheduled',
      'createdAt': now,
      'updatedAt': now,
      'job': job.toJson(),
      'spare': {'id': spareId, 'name': spareName},
    });
  }

  static Future<List<Schedule>> getSchedules({
    String? dateFrom,
    String? dateTo,
    String? status,
    String? ownerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _refreshSeedJobWorkDates();
    final today = DateTime.now();
    final todayStr = _ymd(today);
    final tomorrowStr = _ymd(today.add(const Duration(days: 1)));
    final plus2Str = _ymd(today.add(const Duration(days: 2)));
    final plus3Str = _ymd(today.add(const Duration(days: 3)));
    final pastStr = _ymd(today.subtract(const Duration(days: 5)));
    final overlapDay = overlapDemoDateYmd;

    final base = [
      Schedule.fromJson(_overlapDemoBlockerScheduleJson(overlapDay)),
      Schedule.fromJson({
        'id': 'sched-mock-1',
        'jobId': 'job-mock-1',
        'spareId': 'spare-mock-1',
        'shopId': 'mock-shop-1',
        'date': todayStr,
        'startTime': '14:00',
        'endTime': '18:00',
        'status': 'scheduled',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'job': _jobsJson[0],
        'spare': {'id': 'spare-mock-1', 'name': '김디자이너'},
      }),
      Schedule.fromJson({
        'id': 'sched-mock-2',
        'jobId': 'job-mock-2',
        'spareId': 'spare-mock-2',
        'shopId': 'mock-shop-1',
        'date': tomorrowStr,
        'startTime': '10:00',
        'endTime': '14:00',
        'status': 'scheduled',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'job': _jobsJson[1],
        'spare': {'id': 'spare-mock-2', 'name': '이스텝'},
      }),
      Schedule.fromJson({
        'id': 'sched-mock-proposal',
        'jobId': 'job-mock-1',
        'spareId': 'spare-mock-1',
        'shopId': 'mock-shop-1',
        'date': plus2Str,
        'startTime': '14:00',
        'endTime': '18:00',
        'status': 'proposed',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'job': _jobsJson[0],
        'spare': {'id': 'spare-mock-1', 'name': '김디자이너'},
      }),
      Schedule.fromJson({
        'id': 'sched-mock-3',
        'jobId': 'job-mock-3',
        'spareId': 'spare-mock-1',
        'shopId': 'mock-shop-1',
        'date': plus3Str,
        'startTime': '09:00',
        'endTime': '17:00',
        'status': 'proposed',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'job': _jobsJson[2],
        'spare': {'id': 'spare-mock-1', 'name': '김디자이너'},
      }),
      Schedule.fromJson({
        'id': 'sched-mock-4',
        'jobId': 'job-mock-4',
        'spareId': 'spare-mock-2',
        'shopId': 'mock-shop-1',
        'date': pastStr,
        'startTime': '18:00',
        'status': 'completed',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'job': _jobsJson[3],
        'spare': {'id': 'spare-mock-2', 'name': '이스텝'},
      }),
    ];
    final dynamicSchedules = _addedSchedulesJson
        .map((j) => Schedule.fromJson(Map<String, dynamic>.from(j)))
        .toList();
    var list = _applyScheduleMutations([...base, ...dynamicSchedules])
        .where((s) => s.status != 'cancelled')
        .toList();

    if (ownerId == 'model') {
      final modelJobs = [
        {
          'id': 'job-model-treatment-1',
          'title': '전체염색 모델',
          'shopName': '빌라드블랑 강남점',
          'date': todayStr,
          'time': '14:00',
          'endTime': '18:00',
          'amount': 0,
          'energy': 0,
          'requiredCount': 1,
          'regionId': 'seoul-gangnam',
          'status': 'published',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'job-model-treatment-2',
          'title': '레이어드 컷 모델',
          'shopName': '빌라드블랑 홍대점',
          'date': tomorrowStr,
          'time': '11:00',
          'endTime': '15:00',
          'amount': 0,
          'energy': 0,
          'requiredCount': 1,
          'regionId': 'seoul-mapo',
          'status': 'published',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ];
      list = [
        Schedule.fromJson({
          'id': 'sched-model-1',
          'jobId': 'job-model-treatment-1',
          'spareId': 'mock-model-dev',
          'shopId': 'mock-shop-1',
          'date': todayStr,
          'startTime': '14:00',
          'endTime': '18:00',
          'status': 'scheduled',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'job': modelJobs[0],
          'spare': {'id': 'mock-model-dev', 'name': '모델테스트'},
        }),
        Schedule.fromJson({
          'id': 'sched-model-2',
          'jobId': 'job-model-treatment-2',
          'spareId': 'mock-model-dev',
          'shopId': 'mock-shop-1',
          'date': tomorrowStr,
          'startTime': '11:00',
          'endTime': '15:00',
          'status': 'scheduled',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'job': modelJobs[1],
          'spare': {'id': 'mock-model-dev', 'name': '모델테스트'},
        }),
        Schedule.fromJson({
          'id': 'sched-model-3',
          'jobId': 'job-model-treatment-1',
          'spareId': 'mock-model-dev',
          'shopId': 'mock-shop-1',
          'date': plus2Str,
          'startTime': '14:00',
          'endTime': '18:00',
          'status': 'scheduled',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'job': modelJobs[0],
          'spare': {'id': 'mock-model-dev', 'name': '모델테스트'},
        }),
        Schedule.fromJson({
          'id': 'sched-model-completed',
          'jobId': 'job-model-treatment-2',
          'spareId': 'mock-model-dev',
          'shopId': 'mock-shop-1',
          'date': pastStr,
          'startTime': '13:00',
          'endTime': '17:00',
          'status': 'completed',
          'checkInTime': DateTime.now()
              .subtract(const Duration(days: 5, hours: 2))
              .toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'job': modelJobs[1],
          'spare': {'id': 'mock-model-dev', 'name': '모델테스트'},
        }),
      ];
    } else if (ownerId == 'me') {
      list = list
          .where(
            (s) =>
                s.spareId == 'spare-mock-1' || s.spareId == 'mock-spare-1',
          )
          .toList();
    }
    if (dateFrom != null) {
      list = list.where((s) => s.date.compareTo(dateFrom) >= 0).toList();
    }
    if (dateTo != null) {
      list = list.where((s) => s.date.compareTo(dateTo) <= 0).toList();
    }
    if (status != null) {
      list = list.where((s) => s.status == status).toList();
    }
    return list;
  }

  static Future<Map<String, dynamic>> getWorkCheckStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {'consecutiveDays': 5, 'energyFromWork': 5};
  }

  static Future<NotificationSettings> getNotificationSettings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return NotificationSettings.fromJson({
      'pushEnabled': true,
      'emailEnabled': true,
      'jobAlerts': true,
      'messages': true,
      'scheduleReminders': true,
      'energyUpdates': true,
      'verificationStatus': true,
      'challengeNotifications': true,
    });
  }

  /// 알림 확인(탭) — 자세히 보기 목록에는 읽음으로 유지.
  static Future<void> markNotificationRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (notificationId.startsWith('notif-model-')) {
      await MockModelMessagingData.markNotificationRead(notificationId);
      return;
    }
    _readNotificationIds.add(notificationId);
  }

  /// 알림 삭제·벨에서 완전 제거.
  static Future<void> dismissNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (notificationId.startsWith('notif-model-')) {
      await MockModelMessagingData.dismissNotification(notificationId);
      return;
    }
    _dismissedNotificationIds.add(notificationId);
  }

  static bool _notificationIsRead(AppNotification n) =>
      n.isRead || _readNotificationIds.contains(n.id);

  /// 스페어 홈·알림 벨용 — 미용실→스페어 알림만 (근무 제안·확정·스케줄·메시지).
  static Future<List<AppNotification>> getSpareNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final today = DateTime.now();
    final todayStr = _ymd(today);
    final tomorrowStr = _ymd(today.add(const Duration(days: 1)));
    final plus2Str = _ymd(today.add(const Duration(days: 2)));
    final all = [
      AppNotification.fromJson({
        'id': 'notif-spare-1',
        'type': 'work_proposal',
        'title': '근무 제안',
        'message': '빌라드블랑 강남점에서 「오후 스텝 급구」 근무 제안을 보냈습니다',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        'relatedJobId': 'job-mock-1',
        'relatedScheduleId': 'sched-mock-proposal',
        'scheduleDate': plus2Str,
        'relatedUserId': 'mock-shop-1',
      }),
      AppNotification.fromJson({
        'id': 'notif-spare-2',
        'type': 'work_proposal',
        'title': '근무 제안',
        'message': '헤어스튜디오 A에서 「평일 오전 스텝」 근무 제안을 보냈습니다',
        'isRead': false,
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 18))
            .toIso8601String(),
        'relatedJobId': 'job-mock-3',
        'relatedScheduleId': 'sched-mock-3',
        'scheduleDate': plus2Str,
        'relatedUserId': 'mock-shop-1',
      }),
      AppNotification.fromJson({
        'id': 'notif-spare-3',
        'type': 'application_accepted',
        'title': '지원 확정',
        'message': '「주말 디자이너 대타」 지원이 확정되었습니다',
        'isRead': false,
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'relatedJobId': 'job-mock-2',
        'relatedScheduleId': 'sched-mock-2',
        'scheduleDate': tomorrowStr,
      }),
      AppNotification.fromJson({
        'id': 'notif-spare-4',
        'type': 'schedule_reminder',
        'title': '출근 알림',
        'message': '내일 14:00 빌라드블랑 강남점 출근 예정입니다',
        'isRead': false,
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
        'relatedJobId': 'job-mock-1',
        'relatedScheduleId': 'sched-mock-1',
        'scheduleDate': todayStr,
      }),
      AppNotification.fromJson({
        'id': 'notif-spare-5',
        'type': 'message_received',
        'title': '새 메시지',
        'message': '빌라드블랑 강남점에서 메시지를 보냈습니다',
        'isRead': true,
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 8))
            .toIso8601String(),
        'relatedUserId': 'mock-shop-1',
      }),
    ];
    return all
        .where((n) => !_dismissedNotificationIds.contains(n.id))
        .map(
          (n) => n.copyWith(isRead: _notificationIsRead(n)),
        )
        .toList();
  }

  /// 모델 홈·알림 벨용 — 매칭·예약·메시지 알림.
  static Future<List<AppNotification>> getModelNotifications() async {
    return MockModelMessagingData.getNotifications();
  }

  static final List<Map<String, dynamic>> _chatsJson = [
    {
      'id': 'chat-mock-1',
      'shopId': 'mock-shop-1',
      'shopName': '빌라드블랑 강남점',
      'spareId': 'mock-spare-1',
      'spareName': '김디자이너',
      'jobId': 'job-mock-1',
      'jobTitle': '오후 스텝 급구',
      'lastMessage': {
        'content': '내일 2시에 오시면 됩니다',
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 2))
            .toIso8601String(),
      },
      'unreadCount': 1,
    },
    {
      'id': 'chat-mock-2',
      'shopId': 'shop-2',
      'shopName': '헤어스튜디오 A',
      'spareId': 'mock-spare-1',
      'spareName': '김디자이너',
      'jobId': 'job-mock-2',
      'jobTitle': '주말 디자이너 대타',
      'lastMessage': {
        'content': '주말 근무 가능하시면 연락주세요',
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
      },
      'unreadCount': 0,
    },
    {
      'id': 'chat-mock-3',
      'shopId': 'shop-3',
      'shopName': '빌라드블랑 홍대점',
      'spareId': 'mock-spare-1',
      'spareName': '김디자이너',
      'jobId': 'job-mock-3',
      'jobTitle': '금요일 저녁 급구',
      'lastMessage': {
        'content': '금요일 6시부터 가능하시다니 감사합니다!',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
      },
      'unreadCount': 1,
    },
    {
      'id': 'chat-mock-4',
      'shopId': 'shop-4',
      'shopName': '헤어살롱 B',
      'spareId': 'mock-spare-1',
      'spareName': '김디자이너',
      'jobId': 'job-mock-4',
      'jobTitle': '오전 스텝',
      'lastMessage': {
        'content': '확인했습니다. 수고하세요!',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 3))
            .toIso8601String(),
      },
      'unreadCount': 0,
    },
    {
      'id': 'chat-mock-5',
      'shopId': 'shop-5',
      'shopName': '스타일리스트 C',
      'spareId': 'mock-spare-1',
      'spareName': '김디자이너',
      'jobId': 'job-mock-5',
      'jobTitle': '주중 디자이너',
      'lastMessage': {
        'content': '이번 주 화요일부터 출근 가능하신가요?',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
      },
      'unreadCount': 1,
    },
    {
      'id': 'chat-mock-6',
      'shopId': 'shop-6',
      'shopName': '커트 전문샵',
      'spareId': 'mock-spare-1',
      'spareName': '김디자이너',
      'jobId': 'job-mock-6',
      'jobTitle': '오후 시간대 대타',
      'lastMessage': {
        'content': '네, 협력 잘 부탁드려요',
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
      'unreadCount': 0,
    },
  ];

  static bool _chatReadStateInitialized = false;

  /// 스페어 기준: 상대(shop) 메시지 중 [isRead] != true 만 미읽음.
  /// 샵 기준: 상대(spare) 메시지 중 [isRead] != true 만 미읽음.
  static void _ensureChatReadState() {
    if (_chatReadStateInitialized) return;
    _chatReadStateInitialized = true;
    const unreadShopMessageIds = <String>{
      'msg-1-3',
      'msg-3-3',
      'msg-5-3',
    };
    const unreadSpareMessageIds = <String>{
      'msg-1-2',
      'msg-3-2',
      'msg-5-2',
    };
    for (final messages in _chatMessages.values) {
      for (final message in messages) {
        if (message['isRead'] != null) continue;
        final id = message['id'] as String;
        if (message['senderRole'] == 'shop') {
          message['isRead'] = !unreadShopMessageIds.contains(id);
        } else {
          message['isRead'] = !unreadSpareMessageIds.contains(id);
        }
      }
    }
  }

  static String _opponentRole(String viewerRole) =>
      viewerRole == 'shop' ? 'spare' : 'shop';

  static int _countUnread(String chatId, String viewerRole) {
    final messages = _chatMessages[chatId];
    if (messages == null) return 0;
    final opponentRole = _opponentRole(viewerRole);
    return messages
        .where(
          (m) => m['senderRole'] == opponentRole && m['isRead'] != true,
        )
        .length;
  }

  static void _syncChatUnreadInList(String chatId, String viewerRole) {
    final index = _chatsJson.indexWhere((c) => c['id'] == chatId);
    if (index >= 0) {
      _chatsJson[index]['unreadCount'] = _countUnread(chatId, viewerRole);
    }
  }

  static void _syncAllChatUnreadCounts(String viewerRole) {
    for (final chat in _chatsJson) {
      _syncChatUnreadInList(chat['id'] as String, viewerRole);
    }
  }

  static String? findChatIdByShopId(String? shopId) {
    if (shopId == null || shopId.isEmpty) return null;
    for (final chat in _chatsJson) {
      if (chat['shopId']?.toString() == shopId) {
        return chat['id']?.toString();
      }
    }
    return null;
  }

  static String? findChatIdBySpareId(String? spareId) {
    if (spareId == null || spareId.isEmpty) return null;
    for (final chat in _chatsJson) {
      if (chat['spareId']?.toString() == spareId) {
        return chat['id']?.toString();
      }
    }
    return null;
  }

  static Future<List<Chat>> getChats({String viewerRole = 'spare'}) async {
    if (viewerRole == 'model') {
      return MockModelMessagingData.getChats(viewerRole: viewerRole);
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _ensureChatReadState();
    _syncAllChatUnreadCounts(viewerRole);
    return _chatsJson
        .map((j) => Chat.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  /// 채팅방 진입 시 상대방 메시지 전부 읽음 처리.
  static Future<void> markChatAsRead(
    String chatId, {
    String viewerRole = 'spare',
  }) async {
    if (viewerRole == 'model' || MockModelMessagingData.isModelChatId(chatId)) {
      return MockModelMessagingData.markChatAsRead(
        chatId,
        viewerRole: 'model',
      );
    }
    await Future.delayed(const Duration(milliseconds: 80));
    _ensureChatReadState();
    final messages = _chatMessages[chatId];
    if (messages != null) {
      final opponentRole = _opponentRole(viewerRole);
      for (final message in messages) {
        if (message['senderRole'] == opponentRole) {
          message['isRead'] = true;
        }
      }
    }
    _syncChatUnreadInList(chatId, viewerRole);
  }

  static Future<Message> sendMessage(
    String chatId,
    String content, {
    String? senderId,
    String? senderName,
    String? senderRole,
  }) async {
    if (MockModelMessagingData.isModelChatId(chatId)) {
      return MockModelMessagingData.sendMessage(
        chatId,
        content,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
      );
    }
    await Future.delayed(const Duration(milliseconds: 150));
    final now = DateTime.now();
    final chatIndex = _chatsJson.indexWhere((c) => c['id'] == chatId);
    final Map<String, dynamic>? chat =
        chatIndex >= 0 ? _chatsJson[chatIndex] : null;

    final String resolvedRole;
    if (senderRole != null) {
      resolvedRole = senderRole;
    } else if (senderId != null &&
        chat != null &&
        senderId == chat['shopId']?.toString()) {
      resolvedRole = 'shop';
    } else {
      resolvedRole = 'spare';
    }

    final String resolvedId;
    if (senderId != null) {
      resolvedId = senderId;
    } else if (resolvedRole == 'shop') {
      resolvedId = chat?['shopId']?.toString() ?? _mockShopOwnerId;
    } else {
      resolvedId = chat?['spareId']?.toString() ?? 'mock-spare-1';
    }

    final String resolvedName;
    if (senderName != null) {
      resolvedName = senderName;
    } else if (resolvedRole == 'shop') {
      resolvedName = chat?['shopName']?.toString() ?? '미용실';
    } else {
      resolvedName = chat?['spareName']?.toString() ?? '스페어';
    }

    final messageJson = <String, dynamic>{
      'id': 'msg-$chatId-${now.millisecondsSinceEpoch}',
      'chatId': chatId,
      'senderId': resolvedId,
      'senderName': resolvedName,
      'senderRole': resolvedRole,
      'content': content,
      'createdAt': now.toIso8601String(),
    };
    (_chatMessages[chatId] ??= []).add(messageJson);
    if (chatIndex >= 0) {
      _chatsJson[chatIndex]['lastMessage'] = {
        'content': content,
        'createdAt': now.toIso8601String(),
      };
      _chatsJson[chatIndex]['unreadCount'] = 0;
    }
    return Message.fromJson(messageJson);
  }

  static Future<void> deleteChat(String chatId) async {
    if (MockModelMessagingData.isModelChatId(chatId)) {
      return MockModelMessagingData.deleteChat(chatId);
    }
    await Future.delayed(const Duration(milliseconds: 100));
    _chatsJson.removeWhere((c) => c['id'] == chatId);
    _chatMessages.remove(chatId);
  }

  static final Map<String, int> _contactAttemptCounts = {};
  static final Set<String> _contactBannedJobKeys = {};

  static String _jobSpareKey(String jobId, String spareId) =>
      '$jobId:${MockShopData.normalizeSpareId(spareId)}';

  static bool isContactBannedForJob({
    required String jobId,
    required String spareId,
  }) {
    return _contactBannedJobKeys.contains(_jobSpareKey(jobId, spareId));
  }

  static void _markContactBannedForJob({
    required String jobId,
    required String spareId,
  }) {
    _contactBannedJobKeys.add(_jobSpareKey(jobId, spareId));
  }

  static Map<String, dynamic>? _chatRecord(String chatId) {
    for (final c in _chatsJson) {
      if (c['id']?.toString() == chatId) {
        return c;
      }
    }
    return null;
  }

  static void resetContactViolationEnforcementState() {
    _contactAttemptCounts.clear();
    _contactBannedJobKeys.clear();
  }

  /// 테스트용 채팅방 등록 (jobId 없으면 지원 취소 집행 제외).
  static void registerTestChat({
    required String chatId,
    String? jobId,
    String spareId = 'mock-spare-1',
    String shopId = 'mock-shop-1',
    String shopName = '테스트 샵',
  }) {
    if (_chatsJson.any((c) => c['id']?.toString() == chatId)) return;
    _chatsJson.add({
      'id': chatId,
      'shopId': shopId,
      'shopName': shopName,
      'spareId': spareId,
      'spareName': '테스트 스페어',
      if (jobId != null) 'jobId': jobId,
      'lastMessage': {
        'content': 'test',
        'createdAt': DateTime.now().toIso8601String(),
      },
      'unreadCount': 0,
    });
    _chatMessages.putIfAbsent(chatId, () => []);
  }

  static String? _jobIdFromChat(String chatId) =>
      _chatRecord(chatId)?['jobId']?.toString();

  static String? _spareIdFromChat(String chatId) =>
      _chatRecord(chatId)?['spareId']?.toString();

  /// 지원 시 잠금 에너지 (몰수·환불 추적용).
  static void recordLockedEnergyForJobApplication({
    required String jobId,
    required String spareId,
    required int amount,
  }) {
    if (amount <= 0) return;
    _lockedEnergyByJobSpare[_jobSpareKey(jobId, spareId)] = amount;
  }

  static final Map<String, int> _lockedEnergyByJobSpare = {};

  /// 잠금 에너지 몰수 — 잔액 환불·매장 이전 없음.
  static int forfeitLockedEnergyForJobApplication({
    required String jobId,
    required String spareId,
    String? jobTitle,
  }) {
    final amount =
        _lockedEnergyByJobSpare.remove(_jobSpareKey(jobId, spareId)) ?? 0;
    if (amount <= 0) return 0;
    _energyTransactions.insert(
      0,
      {
        'id': 'tx-forfeit-${DateTime.now().millisecondsSinceEpoch}',
        'type': 'forfeit',
        'amount': -amount,
        'description': jobTitle != null && jobTitle.isNotEmpty
            ? '연락처 위반 · $jobTitle 지원 취소 (에너지 몰수)'
            : '연락처 위반 · 지원 취소 (에너지 몰수)',
        'referenceId': jobId,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
    return amount;
  }

  /// 연락처 전송 시도 1회 기록. 3회 시 대화방 삭제·(샵) 패널티·(스페어) 지원 취소.
  static Future<ContactViolationResult> recordContactViolationAttempt({
    required String chatId,
    required String senderId,
    required String senderRole,
    required String shopId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final max = ContactViolationPolicy.maxAttemptsPerChat;
    final jobId = _jobIdFromChat(chatId);
    final countKey = jobId != null && jobId.isNotEmpty
        ? 'job:$jobId:$senderId'
        : '$chatId:$senderId';
    final count = (_contactAttemptCounts[countKey] ?? 0) + 1;
    _contactAttemptCounts[countKey] = count;

    if (count < max) {
      return ContactViolationResult(
        attemptCount: count,
        maxAttempts: max,
        outcome: ContactViolationOutcome.attemptRecorded,
        userMessage: ContactViolationPolicy.attemptMessage(
          attemptCount: count,
          maxAttempts: max,
          chatDeleted: false,
          isShop: senderRole == 'shop',
        ),
      );
    }

    final spareId = _spareIdFromChat(chatId);
    var applicationCancelled = false;
    var energyForfeited = 0;

    if (senderRole == 'spare' && jobId != null && jobId.isNotEmpty) {
      final locked = await MockShopData.cancelApplicationForContactViolation(
        jobId: jobId,
        spareId: spareId ?? senderId,
      );
      final job = await getJobById(jobId);
      energyForfeited = forfeitLockedEnergyForJobApplication(
        jobId: jobId,
        spareId: spareId ?? senderId,
        jobTitle: job.title,
      );
      if (energyForfeited <= 0 && locked > 0) {
        energyForfeited = locked;
      }
      _markContactBannedForJob(
        jobId: jobId,
        spareId: spareId ?? senderId,
      );
      applicationCancelled = true;
    }

    await deleteChat(chatId);

    if (senderRole == 'shop') {
      final penalty = MockShopData.applyContactViolationPenalty(shopId);
      return penalty;
    }

    return ContactViolationResult(
      attemptCount: count,
      maxAttempts: max,
      outcome: applicationCancelled
          ? ContactViolationOutcome.applicationCancelled
          : ContactViolationOutcome.chatDeleted,
      userMessage: ContactViolationPolicy.attemptMessage(
        attemptCount: count,
        maxAttempts: max,
        chatDeleted: true,
        isShop: false,
      ),
      chatDeleted: true,
      applicationCancelled: applicationCancelled,
      energyForfeited: energyForfeited,
    );
  }

  static Future<Map<String, dynamic>> getWallet() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'balance': mockEnergyBalance,
      'transactions': List<Map<String, dynamic>>.from(_energyTransactions),
    };
  }

  /// mock 에너지 잔액 (교육 결제 등 차감).
  static int mockEnergyBalance = 8;
  static final List<Map<String, dynamic>> _energyTransactions = [
    {
      'id': 'tx-1',
      'type': 'purchase',
      'amount': 3,
      'description': '에너지 3개 충전',
      'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
  ];

  static Future<void> mockSpendEnergy(
    int amount, {
    required String description,
    required String referenceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (mockEnergyBalance < amount) {
      throw ValidationException('에너지가 부족합니다. (필요: $amount개, 보유: $mockEnergyBalance개)');
    }
    mockEnergyBalance -= amount;
    _energyTransactions.insert(
      0,
      {
        'id': 'tx-spend-${DateTime.now().millisecondsSinceEpoch}',
        'type': 'spend',
        'amount': -amount,
        'description': description,
        'referenceId': referenceId,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  static final List<EducationEnrollment> _educationEnrollments = [];

  static Future<List<EducationEnrollment>> getMyEducationEnrollments() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List<EducationEnrollment>.from(_educationEnrollments);
  }

  static Future<EducationEnrollment?> getEducationEnrollmentById(
    String enrollmentId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (final e in _educationEnrollments) {
      if (e.id == enrollmentId) return e;
    }
    return null;
  }

  static Future<EducationEnrollment?> getEnrollmentByEducationId(
    String educationId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (final e in _educationEnrollments) {
      if (e.educationId == educationId) return e;
    }
    return null;
  }

  static Future<Education?> getEducationById(String educationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final list = _buildEducationCatalog();
    for (final e in list) {
      if (e.id == educationId) return e;
    }
    return null;
  }

  static List<Education> _buildEducationCatalog() {
    return _generateEducationCatalogList();
  }

  static Future<EducationEnrollment> mockEnrollInEducation(
    String educationId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final existing = await getEnrollmentByEducationId(educationId);
    if (existing != null) return existing;

    final education = await getEducationById(educationId);
    if (education == null) {
      throw NotFoundException('교육을 찾을 수 없습니다.');
    }
    if (education.applicants >= education.maxApplicants) {
      throw ValidationException('정원이 마감되었습니다.');
    }
    if (DateTime.now().isAfter(education.deadline)) {
      throw ValidationException('신청 마감된 교육입니다.');
    }

    await mockSpendEnergy(
      education.energyCost,
      description: '교육 신청 · ${education.title}',
      referenceId: educationId,
    );

    final enrollment = EducationEnrollment(
      id: 'enroll-${DateTime.now().millisecondsSinceEpoch}',
      educationId: education.id,
      title: education.title,
      energyPaid: education.energyCost,
      isOnline: education.isOnline,
      enrolledAt: DateTime.now(),
      startDate: education.startDate,
      endDate: education.endDate,
      materials: education.materials,
      venueAddress: education.venueAddress,
      venueLat: education.venueLat,
      venueLng: education.venueLng,
      meetingUrl: education.meetingUrl,
      province: education.province,
      district: education.district,
    );
    _educationEnrollments.add(enrollment);
    return enrollment;
  }

  static List<Education> _generateEducationCatalogList() {
    final provinces = RegionHelper.getAllRegions()
        .where((r) => r.type == RegionType.province)
        .toList();
    final categories = [
      Category(id: 'cut', name: '컷트', subCategories: ['여성컷트', '남성컷트']),
      Category(id: 'perm', name: '펌', subCategories: ['디지털펌', '볼륨펌']),
      Category(id: 'color', name: '염색', subCategories: ['탈색', '브릿지']),
      Category(id: 'styling', name: '스타일링', subCategories: ['웨딩스타일링']),
    ];
    final now = DateTime.now();
    final educations = <Education>[];
    for (var i = 0; i < 20; i++) {
      final province = provinces[i % provinces.length];
      final district = RegionHelper.getDistrictsByProvince(province.id);
      final dist = district.isNotEmpty ? district[i % district.length] : null;
      final cat = categories[i % categories.length];
      final deadline = now.add(Duration(days: i + 5));
      final startDate = deadline.add(const Duration(days: 1));
      final endDate = startDate.add(const Duration(days: 1));
      final isOnline = i % 2 == 0;
      final hasRich = i < 3;
      educations.add(
        Education(
          id: 'edu_$i',
          title: '교육 프로그램 ${i + 1}',
          description:
              '교육 ${i + 1} 설명. ${cat.name} ${cat.subCategories[0]} 과정.',
          category: cat.name,
          subCategory: cat.subCategories[0],
          province: province.name,
          district: dist?.name,
          regionId: dist?.id ?? province.id,
          price: (i + 1) * 10000,
          energyCost: 2 + (i % 4),
          isUrgent: i % 3 == 0,
          isOnline: isOnline,
          isLive: i % 4 == 0 && isOnline,
          deadline: deadline,
          startDate: startDate,
          endDate: endDate,
          applicants: 5 + i,
          maxApplicants: 20,
          createdAt: now,
          materials: hasRich
              ? [
                  const EducationMaterial(
                    title: '사전 학습 PDF',
                    url:
                        'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
                  ),
                ]
              : null,
          venueAddress: !isOnline
              ? '${province.name} ${dist?.name ?? ''} 미용교육센터 2층'
              : null,
          venueLat: !isOnline ? 37.5012 + i * 0.001 : null,
          venueLng: !isOnline ? 127.0396 + i * 0.001 : null,
          meetingUrl: isOnline ? 'https://example.com/edu/live/$i' : null,
        ),
      );
    }
    return educations;
  }

  static Future<List<Payment>> getPayments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Payment.fromJson({
        'id': 'pay-1',
        'type': 'energy_purchase',
        'amount': 39000,
        'status': 'success',
        'createdAt': DateTime.now().toIso8601String(),
        'description': '에너지 5개 구매',
      }),
    ];
  }

  /// 프로필·피드 구독 상태 (목).
  static final Set<String> mockSubscribedCreatorIds = {'sub_creator_0'};

  static Future<ChallengeProfile> getChallengeProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final mock = _mockChallengeProfileForUserId(userId);
    mock['isSubscribed'] = mockSubscribedCreatorIds.contains(userId);
    return ChallengeProfile.fromJson(mock);
  }

  static Future<bool> mockCheckSubscriptionStatus(String creatorId) async {
    await Future.delayed(const Duration(milliseconds: 80));
    return mockSubscribedCreatorIds.contains(creatorId);
  }

  static Future<void> mockSubscribe(String creatorId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    mockSubscribedCreatorIds.add(creatorId);
  }

  static Future<void> mockUnsubscribe(String creatorId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    mockSubscribedCreatorIds.remove(creatorId);
  }

  /// 챌린지 피드 [creatorId] / [sub_creatorId] 와 맞는 목 프로필.
  static Map<String, dynamic> _mockChallengeProfileForUserId(String userId) {
    if (userId.startsWith('creator_')) {
      final index = int.tryParse(userId.replaceFirst('creator_', '')) ?? 0;
      final n = index + 1;
      return {
        'userId': userId,
        'challengeNickname': '크리에이터 $n',
        'challengeBio':
            '헤어·뷰티 챌린지 크리에이터 $n입니다.\n스타일링·염색·케어 영상을 올리고 있어요. 구독 부탁해요!',
        'isPublic': true,
        'videoCount': 12 + index,
        'totalLikes': 800 + index * 47,
        'totalViews': 12000 + index * 900,
        'subscriberCount': 320 + index * 28,
        'specialtyTags': ['헤어', '염색', '스타일링'],
        'joinedAt': DateTime(2024, 3, 1 + (index % 20)).toIso8601String(),
        'externalLinks': _mockExternalLinksForCreator(n),
      };
    }
    if (userId.startsWith('sub_creator_')) {
      final index = int.tryParse(userId.replaceFirst('sub_creator_', '')) ?? 0;
      final n = index + 1;
      return {
        'userId': userId,
        'challengeNickname': '구독 크리에이터 $n',
        'challengeBio': '구독 중인 크리에이터 $n 채널입니다.\n매주 새 챌린지를 업로드합니다.',
        'isPublic': true,
        'videoCount': 6 + index,
        'totalLikes': 400 + index * 30,
        'totalViews': 6000 + index * 500,
        'subscriberCount': 900 + index * 40,
        'specialtyTags': ['구독', '미용', '챌린지'],
        'joinedAt': DateTime(2023, 8, 10 + index).toIso8601String(),
        'externalLinks': _mockExternalLinksForCreator(n),
      };
    }
    return {
      'userId': userId,
      'challengeNickname': '디자이너킴',
      'challengeBio': '헤어 스타일 챌린지',
      'isPublic': true,
      'videoCount': 5,
      'totalLikes': 120,
      'totalViews': 1500,
      'subscriberCount': 45,
      'specialtyTags': ['헤어'],
      'joinedAt': DateTime(2025, 1, 15).toIso8601String(),
      'externalLinks': [
        {
          'type': 'instagram',
          'url': 'https://www.instagram.com/',
          'label': '@designer_kim',
        },
        {
          'type': 'youtube',
          'url': 'https://www.youtube.com/',
          'label': 'HairSpare 채널',
        },
      ],
    };
  }

  static List<Map<String, dynamic>> _mockExternalLinksForCreator(int n) {
    return [
      {
        'type': 'instagram',
        'url': 'https://www.instagram.com/',
        'label': '@creator_$n',
      },
      {
        'type': 'youtube',
        'url': 'https://www.youtube.com/',
        'label': '크리에이터 $n',
      },
      if (n.isEven)
        {
          'type': 'tiktok',
          'url': 'https://www.tiktok.com/',
          'label': '@creator_$n',
        },
    ];
  }

  static List<MyChallenge> _mockVideosForCreator(String userId) {
    const videoPool = <String>[
      'assets/videos/mock_challenge_1.mp4',
      'assets/videos/mock_challenge_2.mp4',
    ];
    final index = _creatorIndexFromUserId(userId);
    final count = 8 + (index % 5);
    return List.generate(count, (i) {
      final likes = 80 + i * 37 + index * 11;
      return MyChallenge(
        id: '${userId}_video_$i',
        title: '챌린지 영상 ${i + 1}',
        description: '영상 ${i + 1}',
        videoUrl: videoPool[i % videoPool.length],
        likes: likes,
        comments: 5 + i * 2,
        views: 900 + i * 210 + index * 50,
        isPublic: i % 4 != 3,
        createdAt: DateTime.now().subtract(Duration(days: i * 3)),
        tags: ['미용', '챌린지'],
      );
    });
  }

  static int _creatorIndexFromUserId(String userId) {
    if (userId.startsWith('creator_')) {
      return int.tryParse(userId.replaceFirst('creator_', '')) ?? 0;
    }
    if (userId.startsWith('sub_creator_')) {
      return int.tryParse(userId.replaceFirst('sub_creator_', '')) ?? 0;
    }
    return 0;
  }

  static Future<List<MyChallenge>> getMyChallenges({
    String? filter,
    String? sortBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sortedFilteredVideos(
      _mockVideosForCreator('me'),
      filter: filter,
      sortBy: sortBy,
    );
  }

  static Future<List<MyChallenge>> getCreatorPublicVideos(
    String creatorId, {
    String? filter,
    String? sortBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sortedFilteredVideos(
      _mockVideosForCreator(creatorId),
      filter: filter,
      sortBy: sortBy,
      publicOnly: true,
    );
  }

  static Future<List<MyChallenge>> getCreatorFeaturedVideos(
    String creatorId,
  ) async {
    final all = await getCreatorPublicVideos(creatorId, sortBy: 'popular');
    return all.take(5).toList();
  }

  /// 프로필에서 재생할 크리에이터 전용 피드 (Challenge 피드 모델).
  static Future<List<Challenge>> getCreatorChallengeFeed(
    String creatorId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final profile = await getChallengeProfile(creatorId);
    final videos = await getCreatorPublicVideos(creatorId, sortBy: 'latest');
    return videos
        .map((v) => _myChallengeToChallenge(v, profile))
        .toList();
  }

  /// 크리에이터 영상 소진 후 — 태그 유사도 기반 추천 (해당 크리에이터 제외).
  static Future<List<Challenge>> getSimilarChallenges({
    required String excludeCreatorId,
    List<String>? referenceTags,
    List<String> excludeIds = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final tags = referenceTags ?? const ['미용', '챌린지'];
    final excluded = excludeIds.toSet();

    int tagScore(Challenge c) {
      final ct = c.tags ?? const [];
      return ct.where(tags.contains).length;
    }

    final pool = _generateMockChallengesForSearch()
        .where(
          (c) =>
              c.creatorId != excludeCreatorId && !excluded.contains(c.id),
        )
        .toList()
      ..sort((a, b) {
        final scoreDiff = tagScore(b).compareTo(tagScore(a));
        if (scoreDiff != 0) return scoreDiff;
        return b.views.compareTo(a.views);
      });

    return pool;
  }

  static Challenge _myChallengeToChallenge(
    MyChallenge video,
    ChallengeProfile profile,
  ) {
    final index = _creatorIndexFromUserId(profile.userId);
    final hasProduct = video.likes.isEven;
    final hasEducation = !hasProduct && video.likes % 3 == 0;
    return Challenge(
      id: video.id,
      title: video.title,
      description: video.description ?? video.title,
      creatorName: profile.challengeNickname ?? '크리에이터',
      creatorId: profile.userId,
      creatorAvatar: profile.challengeProfileImage,
      videoUrl: video.videoUrl,
      thumbnailUrl: video.thumbnailUrl,
      likes: video.likes,
      comments: video.comments,
      views: video.views,
      isSubscribed: profile.isSubscribed,
      subscriberCount: profile.subscriberCount,
      tags: video.tags ?? profile.specialtyTags,
      productUrl: hasProduct ? 'https://example.com/product/${video.id}' : null,
      productName: hasProduct ? video.title : null,
      educationId: hasEducation ? 'edu_${video.id}' : null,
      educationName: hasEducation ? '교육 ${index + 1}' : null,
      educationUrl: hasEducation ? 'https://example.com/edu/${video.id}' : null,
      taggedType: hasProduct
          ? 'product'
          : (hasEducation ? 'education' : null),
      musicName: '음악',
      musicArtist: profile.challengeNickname ?? '아티스트',
      createdAt: video.createdAt,
    );
  }

  static List<MyChallenge> _sortedFilteredVideos(
    List<MyChallenge> videos, {
    String? filter,
    String? sortBy,
    bool publicOnly = false,
  }) {
    var list = List<MyChallenge>.from(videos);
    if (publicOnly) {
      list = list.where((v) => v.isPublic).toList();
    }
    if (filter == 'public') {
      list = list.where((v) => v.isPublic).toList();
    } else if (filter == 'private') {
      list = list.where((v) => !v.isPublic).toList();
    }
    switch (sortBy) {
      case 'popular':
        list.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case 'views':
        list.sort((a, b) => b.views.compareTo(a.views));
        break;
      case 'latest':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return list;
  }

  static Future<List<Challenge>> getSubscribedChallenges() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // 구독 탭도 화면 구성을 확인할 수 있도록 목데이터를 제공합니다.
    const videoPool = <String>[
      'assets/videos/mock_challenge_1.mp4',
      'assets/videos/mock_challenge_2.mp4',
    ];

    return List.generate(8, (i) {
      final hasProduct = i % 2 == 0;
      return Challenge(
        id: 'sub_challenge_$i',
        title: '구독 챌린지 ${i + 1}',
        description: '구독 피드 ${i + 1} 설명입니다',
        creatorName: '구독 크리에이터 ${i + 1}',
        creatorId: 'sub_creator_$i',
        creatorAvatar: null,
        videoUrl: videoPool[i % videoPool.length],
        thumbnailUrl: null,
        likes: 120 + i * 9,
        comments: 12 + i,
        shares: 4 + i,
        views: 1400 + i * 180,
        isLiked: false,
        isDisliked: false,
        isSubscribed: true,
        subscriberCount: 1800 + i * 120,
        tags: ['구독', '미용'],
        productUrl: hasProduct ? 'https://example.com/product/$i' : null,
        productName: hasProduct ? '제품 ${i + 1}' : null,
        productThumbnailUrl: null,
        educationId: !hasProduct ? 'edu_$i' : null,
        educationName: !hasProduct ? '교육 ${i + 1}' : null,
        educationUrl: !hasProduct ? 'https://example.com/edu/$i' : null,
        educationThumbnailUrl: null,
        taggedType: hasProduct ? 'product' : 'education',
        musicName: '음악 ${i + 1}',
        musicArtist: '아티스트 ${i + 1}',
        createdAt: DateTime.now().subtract(Duration(days: i)),
      );
    });
  }

  static Future<List<ChallengeComment>> getChallengeComments(
    String challengeId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      ChallengeComment.fromJson({
        'id': 'comment-1',
        'userId': 'usr-1',
        'userName': '김디자이너',
        'content': '멋진 스타일이에요!',
        'likes': 3,
        'createdAt': DateTime.now().toIso8601String(),
      }),
    ];
  }

  static Future<Map<String, dynamic>> getVerificationStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      'identityVerified': true,
      'identityName': '김디자이너',
      'identityPhone': '01012345678',
    };
  }

  static Future<Map<String, dynamic>> getPassVerificationStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {'verified': false};
  }

  static Future<List<Review>> getReviews() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      Review.fromJson({
        'id': 'review-1',
        'shopName': '빌라드블랑 강남점',
        'shopId': 'shop-1',
        'rating': 5,
        'comment': '친절하고 좋았어요!',
        'createdAt': DateTime.now().toIso8601String(),
      }),
    ];
  }

  static final Map<String, List<Map<String, dynamic>>> _chatMessages = {
    'chat-mock-1': [
      {
        'id': 'msg-1-1',
        'chatId': 'chat-mock-1',
        'senderId': 'mock-shop-1',
        'senderName': '빌라드블랑 강남점',
        'senderRole': 'shop',
        'content': '안녕하세요, 지원해주셔서 감사합니다.',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      },
      {
        'id': 'msg-1-2',
        'chatId': 'chat-mock-1',
        'senderId': 'mock-spare-1',
        'senderName': '김디자이너',
        'senderRole': 'spare',
        'content': '네, 감사합니다. 내일 2시 출근이 맞나요?',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 1, minutes: 55))
            .toIso8601String(),
      },
      {
        'id': 'msg-1-3',
        'chatId': 'chat-mock-1',
        'senderId': 'mock-shop-1',
        'senderName': '빌라드블랑 강남점',
        'senderRole': 'shop',
        'content': '네 맞습니다. 내일 2시에 오시면 됩니다',
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 2))
            .toIso8601String(),
      },
    ],
    'chat-mock-2': [
      {
        'id': 'msg-2-1',
        'chatId': 'chat-mock-2',
        'senderId': 'shop-2',
        'senderName': '헤어스튜디오 A',
        'senderRole': 'shop',
        'content': '주말 디자이너 대타 지원해주셔서 감사해요',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      },
      {
        'id': 'msg-2-2',
        'chatId': 'chat-mock-2',
        'senderId': 'mock-spare-1',
        'senderName': '김디자이너',
        'senderRole': 'spare',
        'content': '네, 주말 근무 가능합니다',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 1, minutes: 30))
            .toIso8601String(),
      },
      {
        'id': 'msg-2-3',
        'chatId': 'chat-mock-2',
        'senderId': 'shop-2',
        'senderName': '헤어스튜디오 A',
        'senderRole': 'shop',
        'content': '주말 근무 가능하시면 연락주세요',
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
      },
    ],
    'chat-mock-3': [
      {
        'id': 'msg-3-1',
        'chatId': 'chat-mock-3',
        'senderId': 'shop-3',
        'senderName': '빌라드블랑 홍대점',
        'senderRole': 'shop',
        'content': '금요일 저녁 급구 공고에 지원해주셨네요',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 3))
            .toIso8601String(),
      },
      {
        'id': 'msg-3-2',
        'chatId': 'chat-mock-3',
        'senderId': 'mock-spare-1',
        'senderName': '김디자이너',
        'senderRole': 'spare',
        'content': '6시부터 가능합니다',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      },
      {
        'id': 'msg-3-3',
        'chatId': 'chat-mock-3',
        'senderId': 'shop-3',
        'senderName': '빌라드블랑 홍대점',
        'senderRole': 'shop',
        'content': '금요일 6시부터 가능하시다니 감사합니다!',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 1))
            .toIso8601String(),
      },
    ],
    'chat-mock-4': [
      {
        'id': 'msg-4-1',
        'chatId': 'chat-mock-4',
        'senderId': 'shop-4',
        'senderName': '헤어살롱 B',
        'senderRole': 'shop',
        'content': '오전 스텝 근무 잘 하셨어요',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
      },
      {
        'id': 'msg-4-2',
        'chatId': 'chat-mock-4',
        'senderId': 'mock-spare-1',
        'senderName': '김디자이너',
        'senderRole': 'spare',
        'content': '감사합니다! 다음에도 기회 주시면 좋겠어요',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 4))
            .toIso8601String(),
      },
      {
        'id': 'msg-4-3',
        'chatId': 'chat-mock-4',
        'senderId': 'shop-4',
        'senderName': '헤어살롱 B',
        'senderRole': 'shop',
        'content': '확인했습니다. 수고하세요!',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 3))
            .toIso8601String(),
      },
    ],
    'chat-mock-5': [
      {
        'id': 'msg-5-1',
        'chatId': 'chat-mock-5',
        'senderId': 'shop-5',
        'senderName': '스타일리스트 C',
        'senderRole': 'shop',
        'content': '주중 디자이너 공고 확인했습니다',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 6))
            .toIso8601String(),
      },
      {
        'id': 'msg-5-2',
        'chatId': 'chat-mock-5',
        'senderId': 'mock-spare-1',
        'senderName': '김디자이너',
        'senderRole': 'spare',
        'content': '화요일부터 가능합니다',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 5, minutes: 30))
            .toIso8601String(),
      },
      {
        'id': 'msg-5-3',
        'chatId': 'chat-mock-5',
        'senderId': 'shop-5',
        'senderName': '스타일리스트 C',
        'senderRole': 'shop',
        'content': '이번 주 화요일부터 출근 가능하신가요?',
        'createdAt': DateTime.now()
            .subtract(const Duration(hours: 5))
            .toIso8601String(),
      },
    ],
    'chat-mock-6': [
      {
        'id': 'msg-6-1',
        'chatId': 'chat-mock-6',
        'senderId': 'shop-6',
        'senderName': '커트 전문샵',
        'senderRole': 'shop',
        'content': '오후 시간대 대타 감사합니다',
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
      },
      {
        'id': 'msg-6-2',
        'chatId': 'chat-mock-6',
        'senderId': 'mock-spare-1',
        'senderName': '김디자이너',
        'senderRole': 'spare',
        'content': '네, 협력 잘 부탁드려요',
        'createdAt': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      },
    ],
  };

  static Future<ChatWithMessages> getChatById(String chatId) async {
    if (MockModelMessagingData.isModelChatId(chatId)) {
      return MockModelMessagingData.getChatById(chatId);
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _ensureChatReadState();
    final chatData = Map<String, dynamic>.from(
      _chatsJson.firstWhere(
        (c) => c['id'] == chatId,
        orElse: () => _chatsJson.first,
      ),
    );
    final messages =
        _chatMessages[chatId] ?? _chatMessages['chat-mock-1'] ?? [];
    return ChatWithMessages.fromJson({'chat': chatData, 'messages': messages});
  }

  /// 공간대여 더미 데이터
  static Future<List<SpaceRental>> getSpaceRentals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _publicSpaceRentalMaps()
        .map((j) => SpaceRental.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  static List<Map<String, dynamic>> _publicSpaceRentalMaps() {
    final maps = <Map<String, dynamic>>[];
    for (final raw in _spaceRentalsJson) {
      final id = raw['id'] as String;
      if (_deletedShopSpaceIds.contains(id)) continue;
      maps.add(_applyShopSpacePatch(Map<String, dynamic>.from(raw)));
    }
    for (final raw in _shopCreatedSpaces) {
      final id = raw['id'] as String;
      if (_deletedShopSpaceIds.contains(id)) continue;
      maps.add(_applyShopSpacePatch(Map<String, dynamic>.from(raw)));
    }
    return maps.where((m) => m['isHidden'] != true).toList();
  }

  static Future<SpaceRental> getSpaceRentalById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final found = _spaceRentalsJson.firstWhere(
      (s) => s['id'] == id,
      orElse: () => _spaceRentalsJson.first,
    );
    return SpaceRental.fromJson(Map<String, dynamic>.from(found));
  }

  static final List<SpaceBooking> _myBookings = [];

  static Future<List<SpaceBooking>> getMySpaceBookings() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.from(_myBookings);
  }

  static void addMockBooking(SpaceBooking booking) {
    _myBookings.add(booking);
  }

  static final List<AppNotification> _shopSpaceNotifications = [];

  static List<AppNotification> get shopSpaceNotifications {
    _ensureShopSpaceBookings();
    return List.unmodifiable(_shopSpaceNotifications);
  }

  /// 스페어 선결제 후 샵 승인 대기 예약.
  static SpaceBooking submitSpaceBookingRequest(SpaceBooking booking) {
    _myBookings.add(booking);
    _ensureShopSpaceBookings();
    final idx = _shopSpaceBookings.indexWhere((b) => b.id == booking.id);
    if (idx < 0) {
      _shopSpaceBookings.add(booking);
    }
    _pushShopSpaceBookingNotification(booking);
    return booking;
  }

  static void _pushShopSpaceBookingNotification(SpaceBooking booking) {
    if (booking.status != BookingStatus.pending) return;
    final spaceLabel =
        booking.spaceRental?.shopName ??
        booking.spaceRental?.address ??
        booking.spaceRentalId;
    final fmt = '${booking.startTime.month}/${booking.startTime.day} '
        '${booking.startTime.hour.toString().padLeft(2, '0')}:'
        '${booking.startTime.minute.toString().padLeft(2, '0')}~'
        '${booking.endTime.hour.toString().padLeft(2, '0')}:'
        '${booking.endTime.minute.toString().padLeft(2, '0')}';
    _shopSpaceNotifications.removeWhere(
      (n) => n.relatedBookingId == booking.id,
    );
    _shopSpaceNotifications.insert(
      0,
      AppNotification(
        id: 'notif-space-${booking.id}',
        type: 'space_booking_request',
        title: '공간 대여 신청',
        message:
            '${booking.spareName}님이 「$spaceLabel」 $fmt 예약을 신청했습니다 (선결제 완료)',
        isRead: false,
        createdAt: DateTime.now(),
        relatedJobId: booking.spaceRentalId,
        relatedUserId: booking.spareId,
        relatedBookingId: booking.id,
        scheduleDate: _ymd(booking.startTime),
      ),
    );
  }

  static void _removeShopSpaceBookingNotification(String bookingId) {
    _shopSpaceNotifications.removeWhere(
      (n) => n.relatedBookingId == bookingId,
    );
  }

  // ——— Shop 공간관리 mock ———

  static const String _mockShopOwnerId = 'mock-shop-1';

  static final List<Map<String, dynamic>> _shopCreatedSpaces = [];

  static final Set<String> _deletedShopSpaceIds = {};

  static final Map<String, Map<String, dynamic>> _shopSpacePatches = {};

  static final List<SpaceBooking> _shopSpaceBookings = [];

  static bool _shopSpaceBookingsSeeded = false;

  static void _ensureShopSpaceBookings() {
    if (_shopSpaceBookingsSeeded) return;
    _shopSpaceBookingsSeeded = true;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 14);
    final space = _spaceRentalsJson.firstWhere((s) => s['id'] == 'space-mock-1');
    _shopSpaceBookings.addAll([
      SpaceBooking(
        id: 'shop-booking-mock-1',
        spaceRentalId: 'space-mock-1',
        spareId: 'spare-mock-1',
        spareName: '김디자이너',
        startTime: tomorrow,
        endTime: tomorrow.add(const Duration(hours: 3)),
        totalPrice: 90000,
        status: BookingStatus.pending,
        createdAt: now,
        spaceRental: SpaceRental.fromJson(
          Map<String, dynamic>.from(space),
        ),
      ),
      SpaceBooking(
        id: 'shop-booking-mock-2',
        spaceRentalId: 'space-mock-1',
        spareId: 'spare-mock-2',
        spareName: '이스텝',
        startTime: tomorrow.add(const Duration(days: 2)),
        endTime: tomorrow.add(const Duration(days: 2, hours: 2)),
        totalPrice: 60000,
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
        spaceRental: SpaceRental.fromJson(
          Map<String, dynamic>.from(space),
        ),
      ),
    ]);
    _pushShopSpaceBookingNotification(_shopSpaceBookings.first);
    _pushShopSpaceBookingNotification(_shopSpaceBookings[1]);
  }

  static List<Map<String, dynamic>> _resolvedShopSpaceMaps() {
    final maps = <Map<String, dynamic>>[];
    for (final raw in _spaceRentalsJson) {
      if (raw['shopId'] != _mockShopOwnerId) continue;
      final id = raw['id'] as String;
      if (_deletedShopSpaceIds.contains(id)) continue;
      maps.add(_applyShopSpacePatch(Map<String, dynamic>.from(raw)));
    }
    for (final raw in _shopCreatedSpaces) {
      final id = raw['id'] as String;
      if (_deletedShopSpaceIds.contains(id)) continue;
      maps.add(_applyShopSpacePatch(Map<String, dynamic>.from(raw)));
    }
    return maps;
  }

  static Map<String, dynamic> _applyShopSpacePatch(Map<String, dynamic> base) {
    final id = base['id'] as String;
    final patch = _shopSpacePatches[id];
    if (patch == null) return base;
    return {...base, ...patch};
  }

  static Future<List<SpaceRental>> getMySpaceRentals({
    SpaceStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var maps = _resolvedShopSpaceMaps();
    if (status != null) {
      maps = maps.where((m) => m['status'] == status.name).toList();
    }
    return maps
        .map((j) => SpaceRental.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  static Future<SpaceRental> createShopSpaceRental({
    required String address,
    String? detailAddress,
    required String regionId,
    required int pricePerHour,
    required List<String> facilities,
    List<String>? imageUrls,
    String? description,
    required SpaceOperatingSchedule operatingSchedule,
    required int minHours,
    String? usageNotes,
    String? contactPhone,
    String? subwayInfo,
    List<TimeSlot>? availableSlots,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));
    final now = DateTime.now();
    final id = 'space-shop-${now.millisecondsSinceEpoch}';
    final slots = availableSlots ??
        SpaceSlotBuilder.build(schedule: operatingSchedule, fromDate: now);
    final json = <String, dynamic>{
      'id': id,
      'shopId': _mockShopOwnerId,
      'shopName': '빌라드블랑 강남점',
      'address': address,
      if (detailAddress != null) 'detailAddress': detailAddress,
      'regionId': regionId,
      'regionName': regionId,
      'operatingSchedule': operatingSchedule.toJson(),
      'availableSlots': slots.map((s) => s.toJson()).toList(),
      'pricePerHour': pricePerHour,
      'facilities': facilities,
      'imageUrls': imageUrls ?? <String>[],
      'status': SpaceStatus.available.name,
      'description': description ?? '',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'minHours': minHours,
      if (usageNotes != null) 'usageNotes': usageNotes,
      if (contactPhone != null) 'contactPhone': contactPhone,
      if (subwayInfo != null) 'subwayInfo': subwayInfo,
    };
    _shopCreatedSpaces.add(json);
    return SpaceRental.fromJson(json);
  }

  static Future<SpaceRental> hideShopSpaceRental(String spaceId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _shopSpacePatches[spaceId] = {
      ...(_shopSpacePatches[spaceId] ?? {}),
      'isHidden': true,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    final maps = _resolvedShopSpaceMaps();
    Map<String, dynamic>? existing;
    for (final m in maps) {
      if (m['id'] == spaceId) {
        existing = m;
        break;
      }
    }
    if (existing == null) {
      throw ValidationException('공간을 찾을 수 없습니다.');
    }
    return SpaceRental.fromJson(_applyShopSpacePatch(existing));
  }

  static Future<SpaceRental> unhideShopSpaceRental(String spaceId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _shopSpacePatches[spaceId] = {
      ...(_shopSpacePatches[spaceId] ?? {}),
      'isHidden': false,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    final maps = _resolvedShopSpaceMaps();
    Map<String, dynamic>? existing;
    for (final m in maps) {
      if (m['id'] == spaceId) {
        existing = m;
        break;
      }
    }
    if (existing == null) {
      throw ValidationException('공간을 찾을 수 없습니다.');
    }
    return SpaceRental.fromJson(_applyShopSpacePatch(existing));
  }

  static Future<SpaceRental> updateShopSpaceRental({
    required String spaceId,
    String? address,
    String? detailAddress,
    String? regionId,
    int? pricePerHour,
    List<String>? facilities,
    List<String>? imageUrls,
    String? description,
    List<TimeSlot>? availableSlots,
    SpaceOperatingSchedule? operatingSchedule,
    int? minHours,
    String? usageNotes,
    String? contactPhone,
    String? subwayInfo,
    SpaceStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final maps = _resolvedShopSpaceMaps();
    Map<String, dynamic>? existing;
    for (final m in maps) {
      if (m['id'] == spaceId) {
        existing = m;
        break;
      }
    }
    if (existing == null) {
      throw ValidationException('공간을 찾을 수 없습니다.');
    }
    final patch = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (address != null) patch['address'] = address;
    if (detailAddress != null) patch['detailAddress'] = detailAddress;
    if (regionId != null) {
      patch['regionId'] = regionId;
      patch['regionName'] = regionId;
    }
    if (pricePerHour != null) patch['pricePerHour'] = pricePerHour;
    if (facilities != null) patch['facilities'] = facilities;
    if (imageUrls != null) patch['imageUrls'] = imageUrls;
    if (description != null) patch['description'] = description;
    if (operatingSchedule != null) {
      patch['operatingSchedule'] = operatingSchedule.toJson();
    }
    if (availableSlots != null) {
      patch['availableSlots'] = availableSlots.map((s) => s.toJson()).toList();
    }
    if (minHours != null) patch['minHours'] = minHours;
    if (usageNotes != null) patch['usageNotes'] = usageNotes;
    if (contactPhone != null) patch['contactPhone'] = contactPhone;
    if (subwayInfo != null) patch['subwayInfo'] = subwayInfo;
    if (status != null) patch['status'] = status.name;
    _shopSpacePatches[spaceId] = {
      ...(_shopSpacePatches[spaceId] ?? {}),
      ...patch,
    };
    final updated = _applyShopSpacePatch(Map<String, dynamic>.from(existing));
    return SpaceRental.fromJson(updated);
  }

  static Future<void> deleteShopSpaceRental(String spaceId) async {
    await Future.delayed(const Duration(milliseconds: 180));
    _deletedShopSpaceIds.add(spaceId);
    _shopSpacePatches.remove(spaceId);
    _shopCreatedSpaces.removeWhere((s) => s['id'] == spaceId);
  }

  static Future<List<SpaceBooking>> getShopSpaceBookings({
    String? spaceId,
    BookingStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _ensureShopSpaceBookings();
    final ownedIds =
        _resolvedShopSpaceMaps().map((m) => m['id'] as String).toSet();
    var list = _shopSpaceBookings
        .where((b) => ownedIds.contains(b.spaceRentalId))
        .toList();
    if (spaceId != null) {
      list = list.where((b) => b.spaceRentalId == spaceId).toList();
    }
    if (status != null) {
      list = list.where((b) => b.status == status).toList();
    }
    return list;
  }

  static Future<void> approveShopBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _ensureShopSpaceBookings();
    final idx = _shopSpaceBookings.indexWhere((b) => b.id == bookingId);
    if (idx < 0) return;
    final b = _shopSpaceBookings[idx];
    if (b.status != BookingStatus.pending) {
      throw ValidationException('이미 처리된 예약입니다');
    }
    final confirmed = SpaceBooking(
      id: b.id,
      spaceRentalId: b.spaceRentalId,
      spareId: b.spareId,
      spareName: b.spareName,
      startTime: b.startTime,
      endTime: b.endTime,
      totalPrice: b.totalPrice,
      status: BookingStatus.confirmed,
      createdAt: b.createdAt,
      spaceRental: b.spaceRental,
    );
    _shopSpaceBookings[idx] = confirmed;
    final spareIdx = _myBookings.indexWhere((x) => x.id == bookingId);
    if (spareIdx >= 0) {
      _myBookings[spareIdx] = confirmed;
    }
    _removeShopSpaceBookingNotification(bookingId);
    addScheduleFromConfirmedSpaceBooking(confirmed);
    ensureChatForSpaceBooking(confirmed);
  }

  static Future<void> cancelSpaceBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _myBookings.removeWhere((b) => b.id == bookingId);
    _ensureShopSpaceBookings();
    final idx = _shopSpaceBookings.indexWhere((b) => b.id == bookingId);
    if (idx < 0) return;
    final b = _shopSpaceBookings[idx];
    _shopSpaceBookings[idx] = SpaceBooking(
      id: b.id,
      spaceRentalId: b.spaceRentalId,
      spareId: b.spareId,
      spareName: b.spareName,
      startTime: b.startTime,
      endTime: b.endTime,
      totalPrice: b.totalPrice,
      status: BookingStatus.cancelled,
      createdAt: b.createdAt,
      spaceRental: b.spaceRental,
    );
  }

  static Future<void> rejectShopBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _ensureShopSpaceBookings();
    final idx = _shopSpaceBookings.indexWhere((b) => b.id == bookingId);
    if (idx < 0) return;
    final b = _shopSpaceBookings[idx];
    _shopSpaceBookings[idx] = SpaceBooking(
      id: b.id,
      spaceRentalId: b.spaceRentalId,
      spareId: b.spareId,
      spareName: b.spareName,
      startTime: b.startTime,
      endTime: b.endTime,
      totalPrice: b.totalPrice,
      status: BookingStatus.cancelled,
      createdAt: b.createdAt,
      spaceRental: b.spaceRental,
    );
    _myBookings.removeWhere((x) => x.id == bookingId);
    _removeShopSpaceBookingNotification(bookingId);
  }

  static List<Map<String, dynamic>> get _spaceRentalsJson {
    final now = DateTime.now();
    final defaultSchedule = SpaceOperatingSchedule.defaultEveryDay();
    final weekdayWeekendSchedule = SpaceOperatingSchedule(
      mode: SpaceOperatingMode.weekdayWeekend,
      weekday: DayWindow.open(start: '10:00', end: '20:00'),
      weekend: DayWindow.open(start: '11:00', end: '18:00'),
    );
    return [
      {
        'id': 'space-mock-1',
        'shopId': 'mock-shop-1',
        'shopName': '빌라드블랑 강남점',
        'address': '서울 강남구 테헤란로 123',
        'detailAddress': '4층',
        'regionId': 'seoul-gangnam',
        'regionName': '강남구',
        'operatingSchedule': defaultSchedule.toJson(),
        'availableSlots': _makeSlots(now, defaultSchedule, applyMockUnavailable: true),
        'pricePerHour': 30000,
        'facilities': ['의자', '세트', '샴푸대', '드라이어'],
        'imageUrls': [_mockImage('space/space-mock-1')],
        'status': 'available',
        'description':
            '쾌적한 미용 공간을 시간 단위로 대여합니다. 자연광이 잘 드는 넓은 공간으로 촬영 및 실습에 최적화되어 있습니다.',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'contactPhone': '02-1234-5678',
        'subwayInfo': '강남역 3번 출구 도보 5분',
        'isPremium': true,
        'usageNotes':
            '• 최소 2시간 단위 예약\n• 사용 후 정리 정돈 부탁드립니다\n• 취소는 예약 24시간 전까지 가능',
        'averageRating': 4.7,
        'reviewCount': 3,
        'reviews': [
          {
            'userName': '박스타일',
            'rating': 5,
            'comment': '공간이 넓고 밝아서 작업하기 좋았어요. 다음에 또 이용할게요!',
            'createdAt': now
                .subtract(const Duration(days: 2))
                .toIso8601String(),
          },
          {
            'userName': '김헤어',
            'rating': 5,
            'comment': '설비가 깔끔하고 관리가 잘 되어 있습니다.',
            'createdAt': now
                .subtract(const Duration(days: 5))
                .toIso8601String(),
          },
          {
            'userName': '이디자인',
            'rating': 4,
            'comment': '가격 대비 만족도 높아요. 강추합니다.',
            'createdAt': now
                .subtract(const Duration(days: 10))
                .toIso8601String(),
          },
        ],
        'minHours': 2,
      },
      {
        'id': 'space-shop-mock-2',
        'shopId': 'mock-shop-1',
        'shopName': '청담 하이엔드 살롱 (공간)',
        'address': '서울 강남구 청담동 88-12',
        'detailAddress': '2층',
        'regionId': 'seoul-gangnam',
        'regionName': '강남구',
        'operatingSchedule': weekdayWeekendSchedule.toJson(),
        'availableSlots': _makeSlots(now, weekdayWeekendSchedule),
        'pricePerHour': 45000,
        'facilities': ['의자', '세트'],
        'imageUrls': [
          'https://picsum.photos/seed/hairspare-space-shop-2/400/400',
        ],
        'status': 'available',
        'description': '청담 고급 살롱 공간. 미니멀 인테리어와 자연광이 특징입니다.',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'contactPhone': '02-5678-9012',
        'subwayInfo': '압구정로데오역 5번 출구 도보 8분',
        'isPremium': false,
        'isHidden': true,
        'usageNotes': '• 최소 2시간 단위 예약',
        'averageRating': 4.5,
        'reviewCount': 0,
        'reviews': <Map<String, dynamic>>[],
        'minHours': 2,
      },
      {
        'id': 'space-mock-2',
        'shopId': 'shop-2',
        'shopName': '헤어스튜디오 A',
        'address': '서울 마포구 홍대로 456',
        'regionId': 'seoul-mapo',
        'regionName': '마포구',
        'operatingSchedule': weekdayWeekendSchedule.toJson(),
        'availableSlots': _makeSlots(now, weekdayWeekendSchedule),
        'pricePerHour': 25000,
        'facilities': ['의자', '세트'],
        'imageUrls': [_mockImage('space/space-mock-2')],
        'status': 'available',
        'description': '홍대 인근 스튜디오 대여. 트렌디한 분위기의 작업 공간입니다.',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'contactPhone': '02-2345-6789',
        'subwayInfo': '홍대입구역 1번 출구 도보 7분',
        'isPremium': false,
        'usageNotes': '• 최소 1시간 단위 예약',
        'averageRating': 4.3,
        'reviewCount': 2,
        'reviews': [
          {
            'userName': '최미용',
            'rating': 4,
            'comment': '홍대 근처라 접근성 좋아요.',
            'createdAt': now
                .subtract(const Duration(days: 3))
                .toIso8601String(),
          },
          {
            'userName': '정스타일',
            'rating': 5,
            'comment': '가성비 최고!',
            'createdAt': now
                .subtract(const Duration(days: 7))
                .toIso8601String(),
          },
        ],
        'minHours': 1,
      },
      {
        'id': 'space-mock-3',
        'shopId': 'shop-3',
        'shopName': '헤어살롱 B',
        'address': '서울 서초구 서초대로 789',
        'regionId': 'seoul-seocho',
        'regionName': '서초구',
        'operatingSchedule': defaultSchedule.toJson(),
        'availableSlots': _makeSlots(now, defaultSchedule),
        'pricePerHour': 35000,
        'facilities': ['의자', '세트', '샴푸대', '드라이어', '촬영조명'],
        'imageUrls': [_mockImage('space/space-mock-3')],
        'status': 'available',
        'description': '촬영용 조명이 갖춰진 전문 스튜디오. 광고 촬영에 최적화된 환경을 제공합니다.',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'contactPhone': '02-3456-7890',
        'subwayInfo': '서초역 2번 출구 도보 3분',
        'isPremium': true,
        'usageNotes': '• 촬영조명 사용법 별도 안내\n• 최소 2시간 단위 예약',
        'averageRating': 4.9,
        'reviewCount': 1,
        'reviews': [
          {
            'userName': '한촬영',
            'rating': 5,
            'comment': '조명이 너무 좋아요. 전문가용으로 강추!',
            'createdAt': now
                .subtract(const Duration(days: 1))
                .toIso8601String(),
          },
        ],
        'minHours': 2,
      },
    ];
  }

  /// [schedule] 기준 30일 1시간 슬롯. mock-1 등 일부는 예약 불가 슬롯 혼합.
  static List<Map<String, dynamic>> _makeSlots(
    DateTime base,
    SpaceOperatingSchedule schedule, {
    bool applyMockUnavailable = false,
  }) {
    var slots = SpaceSlotBuilder.build(schedule: schedule, fromDate: base);
    if (applyMockUnavailable) {
      slots = [
        for (final s in slots)
          TimeSlot(
            startTime: s.startTime,
            endTime: s.endTime,
            isAvailable: !(s.startTime.hour == 12 ||
                (s.startTime.day + s.startTime.hour) % 7 == 0),
            bookedBy: s.bookedBy,
            bookingId: s.bookingId,
          ),
      ];
    }
    return slots.map((s) => s.toJson()).toList();
  }

  /// 교육 더미 데이터 (공고목록용)
  static Future<List<Map<String, dynamic>>> getEducations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    return List.generate(
      5,
      (i) => {
        'id': 'edu-mock-$i',
        'title': '교육 프로그램 ${i + 1}',
        'price': (i + 1) * 10000,
        'deadline': now.add(Duration(days: i + 5)),
        'isOnline': i % 2 == 0,
        'isUrgent': i % 3 == 0,
        'province': '서울',
        'district': '강남구',
      },
    );
  }

  static Future<int> getPointBalance() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return mockPointBalance;
  }

  /// mock 포인트 잔액 (에너지 포인트 결제 등 차감).
  static int mockPointBalance = 1250;

  static Future<void> mockPurchaseEnergy({
    required int energyAmount,
    required String paymentMethod,
    int? cashPrice,
    int? pointCost,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    assertValidEnergyPurchaseAmount(energyAmount);
    if (paymentMethod == 'POINTS') {
      final cost = pointCost ?? 0;
      if (mockPointBalance < cost) {
        throw ValidationException(
          '포인트가 부족합니다. (필요: ${cost}P, 보유: ${mockPointBalance}P)',
        );
      }
      mockPointBalance -= cost;
    }

    mockEnergyBalance += energyAmount;
    _energyTransactions.insert(
      0,
      {
        'id': 'tx-purchase-${DateTime.now().millisecondsSinceEpoch}',
        'type': 'purchase',
        'amount': energyAmount,
        'description': paymentMethod == 'POINTS'
            ? '포인트로 에너지 $energyAmount개 충전'
            : '에너지 $energyAmount개 충전 (₩${cashPrice ?? 0})',
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<List<PointTransaction>> getPointHistory({
    int limit = 50,
    int offset = 0,
    String? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final items = [
      {
        'id': 'pt-1',
        'type': 'earn',
        'amount': 10,
        'description': '출석체크',
        'createdAt': now.toIso8601String(),
        'relatedId': 'daily-1',
      },
      {
        'id': 'pt-2',
        'type': 'earn',
        'amount': 94,
        'description': '채널추가 미션',
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'relatedId': 'simple-1',
      },
      {
        'id': 'pt-3',
        'type': 'spend',
        'amount': -50,
        'description': '상품 구매',
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'relatedId': 'purchase-1',
      },
      {
        'id': 'pt-4',
        'type': 'earn',
        'amount': 3,
        'description': '참여 미션',
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'relatedId': 'participation-1',
      },
    ];
    var list = items
        .map((j) => PointTransaction.fromJson(Map<String, dynamic>.from(j)))
        .toList();
    if (type != null) {
      list = list.where((t) => t.type == type).toList();
    }
    return list.skip(offset).take(limit).toList();
  }

  static Future<bool> completePointMission(String missionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  static Future<List<Education>> getEducationsForSearch(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final educations = _generateEducationCatalogList();
    if (query.trim().isEmpty) return educations;
    final q = query.trim().toLowerCase();
    return educations.where((e) {
      return e.title.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q);
    }).toList();
  }

  static Future<List<Challenge>> getChallengesForSearch(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final challenges = _generateMockChallengesForSearch();
    if (query.trim().isEmpty) return challenges;
    final q = query.trim().toLowerCase();
    return challenges.where((c) {
      return c.title.toLowerCase().contains(q) ||
          (c.creatorName.toLowerCase().contains(q)) ||
          (c.tags?.any((t) => t.toLowerCase().contains(q)) ?? false);
    }).toList();
  }

  static List<Challenge> _generateMockChallengesForSearch() {
    const videoPool = <String>[
      'assets/videos/mock_challenge_1.mp4',
      'assets/videos/mock_challenge_2.mp4',
    ];
    return List.generate(15, (i) {
      final hasProduct = i % 3 == 0;
      final hasEducation = i % 5 == 0 && !hasProduct;
      return Challenge(
        id: 'challenge_$i',
        title: '챌린지 ${i + 1}',
        description: '챌린지 ${i + 1} 설명입니다',
        creatorName: '크리에이터 ${i + 1}',
        creatorId: 'creator_$i',
        creatorAvatar: null,
        videoUrl: videoPool[i % videoPool.length],
        thumbnailUrl: null,
        likes: 100 + i * 10,
        comments: 10 + i,
        shares: 5 + i,
        views: 1000 + i * 100,
        isLiked: false,
        isDisliked: false,
        isSubscribed: false,
        subscriberCount: 500 + i * 10,
        tags: ['태그${i + 1}', '미용'],
        productUrl: hasProduct ? 'https://example.com/product/$i' : null,
        productName: hasProduct ? '제품 ${i + 1}' : null,
        productThumbnailUrl: null,
        educationId: hasEducation ? 'edu_$i' : null,
        educationName: hasEducation ? '교육 ${i + 1}' : null,
        educationUrl: hasEducation ? 'https://example.com/edu/$i' : null,
        educationThumbnailUrl: null,
        taggedType: hasProduct
            ? 'product'
            : (hasEducation ? 'education' : null),
        musicName: '음악 ${i + 1}',
        musicArtist: '아티스트 ${i + 1}',
        createdAt: DateTime.now(),
      );
    });
  }
}
