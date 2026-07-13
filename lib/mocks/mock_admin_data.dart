import '../utils/admin_member_role.dart';
/// ApiConfig.useMockData == true 일 때 AdminService에서 사용
class MockAdminData {
  static Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'users': {
        'total': 1247,
        'today': 12,
        'weekGrowthPct': 12.5,
        'byRole': {'spare_designer': 892, 'shop': 312, 'model': 43},
      },
      'jobs': {'total': 523, 'active': 89, 'todayGrowthPct': 5.2},
      'payments': {'total': 45800000, 'today': 1250000, 'avgGrowthPct': 8.1},
      'schedules': {'total': 3421, 'today': 23},
      'energy': {'wallets': 1105, 'transactions': 8934},
      'noShow': {'total': 18},
      'pendingVerifications': 7,
      'openReports': 4,
      'pendingBookings': 2,
      'pendingEducations': 3,
      'todayMatches': 12,
    };
  }

  static Future<Map<String, dynamic>> getRecentActivities() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'activities': [
        {
          'type': 'signup',
          'label': '온보딩',
          'entity': '글래머',
          'description': '미용실 "글래머" 온보딩 완료',
          'ago': '2분 전',
          'source': '시스템 자동',
          'color': 'purple',
        },
        {
          'type': 'job',
          'label': '공고등록',
          'entity': '이미용실',
          'description': '이미용실 공고 등록',
          'ago': '12분 전',
          'source': '사용자',
          'color': 'purple',
        },
        {
          'type': 'payment',
          'label': '결제완료',
          'entity': '박스텝',
          'description': '412개 계정 일괄 결제 처리 완료',
          'ago': '1시간 전',
          'source': '시스템 배치',
          'color': 'green',
        },
        {
          'type': 'noshow',
          'label': '신고접수',
          'entity': '스페어 #8492',
          'description': '스페어 #8492 신고 접수',
          'ago': '15분 전',
          'source': '사용자 제출',
          'color': 'red',
        },
        {'type': 'energy', 'label': '에너지충전', 'entity': '정디자이너', 'ago': '2시간 전', 'color': 'yellow'},
        {'type': 'schedule', 'label': '체크인', 'entity': '이스텝', 'ago': '3시간 전', 'color': 'purple'},
      ],
    };
  }

  static final Set<String> _suspendedUserIds = {'usr-9'};

  // ── 인증 상태 오버라이드 (approve/reject 호출 시 갱신)
  static final Map<String, String> _verificationStatuses = {};

  static Future<void> setVerificationStatus(String id, String status) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _verificationStatuses[id] = status;
  }

  // ── 신고 상태 오버라이드 (resolve 호출 시 갱신)
  static final Map<String, String> _reportStatuses = {};

  static Future<void> setReportStatus(String id, String status) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _reportStatuses[id] = status;
  }

  // ── 공고 상태 오버라이드 (hide/close 호출 시 갱신)
  static final Set<String> _hiddenJobIds = {};
  static final Set<String> _closedJobIds = {};

  static Future<void> setJobHidden(String id, {required bool hide}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (hide) { _hiddenJobIds.add(id); } else { _hiddenJobIds.remove(id); }
  }

  static Future<void> setJobClosed(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _closedJobIds.add(id);
  }

  // ── 스케줄 상태 오버라이드 (complete/cancel/noshow 호출 시 갱신)
  static final Map<String, String> _scheduleStates = {};

  static Future<void> setScheduleState(String id, String state) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _scheduleStates[id] = state;
  }

  static List<Map<String, dynamic>> _userSeedList() {
    return [
      {
        'id': 'usr-1',
        'name': '김디자이너',
        'email': 'kim@example.com',
        'phone': '010-1234-5678',
        'role': 'spare',
        'spareSubtype': 'professional',
        'spareRole': 'designer',
        'createdAt': '2025-01-15T10:00:00Z',
        'accounts': [
          {'provider': 'email'},
        ],
        '_count': {'jobs': 0, 'applications': 3, 'schedules': 12},
      },
      {
        'id': 'usr-2',
        'name': '이미용실',
        'email': 'lee@salon.co.kr',
        'phone': '02-1234-5678',
        'role': 'shop',
        'createdAt': '2025-01-10T14:30:00Z',
        'accounts': [
          {'provider': 'kakao'},
        ],
        '_count': {'jobs': 8, 'applications': 0, 'schedules': 45},
      },
      {
        'id': 'usr-3',
        'name': '박스텝',
        'email': 'park@example.com',
        'phone': '010-9876-5432',
        'role': 'spare',
        'spareSubtype': 'professional',
        'spareRole': 'step',
        'createdAt': '2025-02-01T09:00:00Z',
        'accounts': [
          {'provider': 'naver'},
        ],
        '_count': {'jobs': 0, 'applications': 5, 'schedules': 8},
      },
      {
        'id': 'usr-4',
        'name': '최모델',
        'email': 'choi.model@example.com',
        'phone': '010-5555-1111',
        'role': 'spare',
        'spareSubtype': 'model',
        'createdAt': '2025-01-20T11:00:00Z',
        'accounts': [
          {'provider': 'kakao'},
        ],
        '_count': {'jobs': 0, 'applications': 0, 'schedules': 0},
      },
      {
        'id': 'usr-5',
        'name': '정헤어살롱',
        'email': 'jung@hair.co.kr',
        'phone': '02-9876-5432',
        'role': 'shop',
        'createdAt': '2025-02-10T16:00:00Z',
        'accounts': [
          {'provider': 'email'},
        ],
        '_count': {'jobs': 5, 'applications': 0, 'schedules': 22},
      },
      {
        'id': 'usr-6',
        'name': '한스페어',
        'email': 'han.spare@example.com',
        'phone': '010-2222-3333',
        'role': 'spare',
        'spareSubtype': 'professional',
        'spareRole': 'step',
        'createdAt': '2025-03-05T08:30:00Z',
        'accounts': [
          {'provider': 'google'},
        ],
        '_count': {'jobs': 0, 'applications': 2, 'schedules': 4},
      },
      {
        'id': 'usr-7',
        'name': '윤뷰티',
        'email': 'yoon@beauty.co.kr',
        'phone': '02-3333-4444',
        'role': 'shop',
        'createdAt': '2025-03-12T13:00:00Z',
        'accounts': [
          {'provider': 'kakao'},
        ],
        '_count': {'jobs': 3, 'applications': 0, 'schedules': 15},
      },
      {
        'id': 'usr-8',
        'name': '강디자이너',
        'email': 'kang.design@example.com',
        'phone': '010-7777-8888',
        'role': 'spare',
        'spareSubtype': 'professional',
        'spareRole': 'designer',
        'createdAt': '2025-03-18T10:00:00Z',
        'accounts': [
          {'provider': 'naver'},
        ],
        '_count': {'jobs': 0, 'applications': 0, 'schedules': 0},
      },
      {
        'id': 'usr-9',
        'name': '조인턴',
        'email': 'jo.intern@example.com',
        'phone': '010-4444-5555',
        'role': 'spare',
        'spareSubtype': 'professional',
        'spareRole': 'step',
        'createdAt': '2025-04-01T09:00:00Z',
        'accounts': [
          {'provider': 'email'},
        ],
        '_count': {'jobs': 0, 'applications': 1, 'schedules': 0},
      },
      {
        'id': 'usr-10',
        'name': '서미용실',
        'email': 'seo.salon@example.com',
        'phone': '02-5555-6666',
        'role': 'shop',
        'createdAt': '2025-04-08T15:30:00Z',
        'accounts': [
          {'provider': 'email'},
        ],
        '_count': {'jobs': 6, 'applications': 0, 'schedules': 30},
      },
      {
        'id': 'usr-11',
        'name': '임스텝',
        'email': 'lim.step@example.com',
        'phone': '010-6666-7777',
        'role': 'spare',
        'spareSubtype': 'professional',
        'spareRole': 'step',
        'createdAt': '2025-04-15T12:00:00Z',
        'accounts': [
          {'provider': 'kakao'},
        ],
        '_count': {'jobs': 0, 'applications': 4, 'schedules': 6},
      },
      {
        'id': 'usr-12',
        'name': '오모델',
        'email': 'oh.model@example.com',
        'phone': '010-8888-9999',
        'role': 'spare',
        'spareSubtype': 'model',
        'createdAt': '2025-04-20T17:00:00Z',
        'accounts': [
          {'provider': 'google'},
        ],
        '_count': {'jobs': 0, 'applications': 0, 'schedules': 0},
      },
    ];
  }

  static Map<String, dynamic> _withAccountStatus(Map<String, dynamic> user) {
    final copy = Map<String, dynamic>.from(user);
    final id = copy['id']?.toString() ?? '';
    final suspended = _suspendedUserIds.contains(id);
    copy['status'] = suspended ? 'suspended' : 'active';
    copy['accountStatus'] = suspended ? 'suspended' : 'active';
    copy['accountStatusLabel'] = suspended ? '정지' : '정상';
    return copy;
  }

  static Future<void> setUserSuspended(String userId, {required bool suspended}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (suspended) {
      _suspendedUserIds.add(userId);
    } else {
      _suspendedUserIds.remove(userId);
    }
  }

  static Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? memberCategory,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var users = _userSeedList().map(_withAccountStatus).toList();

    if (memberCategory != null && memberCategory.isNotEmpty) {
      users = users
          .where((u) => AdminMemberRole.matchesFilter(u, memberCategory))
          .toList();
    } else if (role != null && role.isNotEmpty) {
      users = users.where((u) => u['role'] == role).toList();
    }

    final query = search?.trim().toLowerCase() ?? '';
    if (query.isNotEmpty) {
      users = users.where((u) {
        final name = u['name']?.toString().toLowerCase() ?? '';
        final email = u['email']?.toString().toLowerCase() ?? '';
        final phone = u['phone']?.toString().toLowerCase() ?? '';
        return name.contains(query) ||
            email.contains(query) ||
            phone.contains(query);
      }).toList();
    }

    final total = users.length;
    final totalPages = total == 0 ? 1 : (total / limit).ceil();
    final safePage = page.clamp(1, totalPages);
    final start = (safePage - 1) * limit;
    final end = (start + limit).clamp(0, total);
    final pageUsers = start < total ? users.sublist(start, end) : <Map<String, dynamic>>[];

    return {
      'users': pageUsers,
      'pagination': {
        'page': safePage,
        'limit': limit,
        'total': total,
        'totalPages': totalPages,
      },
    };
  }

  static Future<Map<String, dynamic>> getUserDetail(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    Map<String, dynamic>? seed;
    for (final user in _userSeedList()) {
      if (user['id'] == userId) {
        seed = user;
        break;
      }
    }
    final base = seed ??
        {
          'id': userId,
          'name': '김디자이너',
          'email': 'kim@example.com',
          'phone': '010-1234-5678',
          'role': 'spare',
          'createdAt': '2025-01-15T10:00:00Z',
        };
    final withStatus = _withAccountStatus(base);
    return {
      ...withStatus,
      'profileImage': null,
      'energyWallet': {'balance': 1250},
      'pointWallet': {'balance': 340},
      '_count': withStatus['_count'] ??
          {'jobs': 0, 'applications': 3, 'schedules': 12},
      'accounts': withStatus['accounts'] ?? [
        {'provider': 'email'},
      ],
      'recentActivity': [
        {
          'label': '공고 지원',
          'detail': '오후 스텝 급구',
          'at': '2025-06-22T09:00:00Z',
        },
        {
          'label': '체크인',
          'detail': '빌라드블랑 강남점',
          'at': '2025-06-21T14:05:00Z',
        },
      ],
      'sanctionHistory': _suspendedUserIds.contains(userId)
          ? [
              {
                'typeLabel': '정지',
                'reason': '관리자 조치',
                'at': '2025-06-20T00:00:00Z',
                'active': true,
              },
            ]
          : [
              {
                'typeLabel': '경고',
                'reason': '지각',
                'at': '2025-05-01T00:00:00Z',
                'active': false,
              },
            ],
      'verification': {
        'status': 'approved',
        'statusLabel': '승인',
        'typeLabel': '본인인증',
        'verifiedAt': '2025-01-20T10:00:00Z',
      },
    };
  }

  static Future<List<Map<String, dynamic>>> getUserActivities(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      {
        'type': 'application',
        'label': '공고 지원',
        'detail': '오후 스텝 급구 · 대기중',
        'at': '2025-06-22T09:00:00Z',
      },
      {
        'type': 'schedule',
        'label': '근무 스케줄',
        'detail': '2025-06-21 14:00 · 완료',
        'at': '2025-06-21T14:05:00Z',
      },
    ];
  }

  static Future<void> deleteUser(String userId, {bool permanent = false}) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  static Future<Map<String, dynamic>> getJobs({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final jobs = [
      {
        'id': 'job-1',
        'title': '오후 스텝 급구',
        'shop': {'name': '빌라드블랑 강남점'},
        'region': {'name': '서울 강남구'},
        'amount': 50000,
        'isUrgent': true,
        'isPremium': false,
        '_count': {'applications': 5, 'schedules': 2},
      },
      {
        'id': 'job-2',
        'title': '주말 디자이너 대타',
        'shop': {'name': '헤어스튜디오 A'},
        'region': {'name': '서울 홍대'},
        'amount': 80000,
        'isUrgent': false,
        'isPremium': true,
        '_count': {'applications': 3, 'schedules': 0},
      },
    ];
    return {
      'jobs': jobs,
      'pagination': {'page': page, 'limit': limit, 'total': 523, 'totalPages': 27},
    };
  }

  static Future<Map<String, dynamic>> getJobDetail(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    String status = 'published';
    if (_closedJobIds.contains(jobId)) {
      status = 'closed';
    } else if (_hiddenJobIds.contains(jobId)) {
      status = 'hidden';
    }
    return {
      'id': jobId,
      'title': '오후 스텝 급구',
      'description': '경력 1년 이상 스텝 구합니다.',
      'shop': {'name': '빌라드블랑 강남점'},
      'region': {'name': '서울 강남구'},
      'amount': 50000,
      'date': '2025-02-15',
      'time': '14:00',
      'isUrgent': true,
      'status': status,
      'isHidden': _hiddenJobIds.contains(jobId),
    };
  }

  static Future<Map<String, dynamic>> getPayments({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final payments = [
      {
        'id': 'pay-1',
        'orderId': 'ORD-20250209-001',
        'paymentMethod': '카드',
        'user': {'email': 'kim@example.com'},
        'type': 'energy_purchase',
        'amount': 50000,
        'status': 'success',
        'createdAt': '2025-02-09T10:30:00Z',
      },
      {
        'id': 'pay-2',
        'orderId': 'ORD-20250209-002',
        'paymentMethod': '카카오페이',
        'user': {'email': 'lee@salon.co.kr'},
        'type': 'subscription',
        'amount': 99000,
        'status': 'success',
        'createdAt': '2025-02-09T09:15:00Z',
      },
    ];
    return {
      'payments': payments,
      'pagination': {'page': page, 'limit': limit, 'total': 458, 'totalPages': 23},
    };
  }

  static Future<Map<String, dynamic>> getPaymentDetail(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'id': paymentId,
      'orderId': 'ORD-20250209-001',
      'paymentMethod': '카드',
      'user': {'email': 'kim@example.com', 'name': '김디자이너'},
      'type': 'energy_purchase',
      'amount': 50000,
      'status': 'success',
      'createdAt': '2025-02-09T10:30:00Z',
    };
  }

  static Future<Map<String, dynamic>> getEnergyTransactions({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final transactions = [
      {
        'id': 'tx-1',
        'energyWallet': {'user': {'email': 'kim@example.com'}},
        'type': 'purchase',
        'amount': 100,
        'job': {'title': '오후 스텝 급구'},
        'state': 'completed',
        'createdAt': '2025-02-09T10:30:00Z',
      },
      {
        'id': 'tx-2',
        'energyWallet': {'user': {'email': 'park@example.com'}},
        'type': 'lock',
        'amount': -50,
        'job': {'title': '주말 디자이너 대타'},
        'state': 'completed',
        'createdAt': '2025-02-09T09:00:00Z',
      },
    ];
    return {
      'transactions': transactions,
      'pagination': {'page': page, 'limit': limit, 'total': 8934, 'totalPages': 447},
    };
  }

  static Future<Map<String, dynamic>> getApplications({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = [
      {
        'id': 'app-1',
        'status': 'pending',
        'statusLabel': '검토 대기',
        'spare': {'name': '김디자이너', 'email': 'kim@example.com'},
        'shop': {'name': '빌라드블랑 강남점'},
        'job': {'id': 'job-1', 'title': '오후 스텝 급구', 'startTime': '2025-07-10T14:00:00Z', 'amount': 80000},
        'createdAt': '2025-07-08T09:30:00Z',
      },
      {
        'id': 'app-2',
        'status': 'approved',
        'statusLabel': '승인됨',
        'spare': {'name': '박스타일리스트', 'email': 'park@example.com'},
        'shop': {'name': '헤어스튜디오 강북'},
        'job': {'id': 'job-2', 'title': '주말 디자이너 대타', 'startTime': '2025-07-12T10:00:00Z', 'amount': 100000},
        'createdAt': '2025-07-07T16:20:00Z',
      },
      {
        'id': 'app-3',
        'status': 'rejected',
        'statusLabel': '거절됨',
        'spare': {'name': '이헤어', 'email': 'lee@example.com'},
        'shop': {'name': '살롱드파리 홍대'},
        'job': {'id': 'job-3', 'title': '평일 어시스턴트', 'startTime': '2025-07-09T11:00:00Z', 'amount': 60000},
        'createdAt': '2025-07-06T11:00:00Z',
      },
      {
        'id': 'app-4',
        'status': 'cancelled_contact_violation',
        'statusLabel': '연락처 위반 취소',
        'spare': {'name': '최스텝', 'email': 'choi@example.com'},
        'shop': {'name': '모던헤어 신촌'},
        'job': {'id': 'job-4', 'title': '금요일 디자이너', 'startTime': '2025-07-11T13:00:00Z', 'amount': 90000},
        'createdAt': '2025-07-05T14:45:00Z',
      },
      {
        'id': 'app-5',
        'status': 'pending',
        'statusLabel': '검토 대기',
        'spare': {'name': '정컬러리스트', 'email': 'jeong@example.com'},
        'shop': {'name': '아뜰리에 헤어 압구정'},
        'job': {'id': 'job-5', 'title': '컬러 전문 스페어 모집', 'startTime': '2025-07-15T09:00:00Z', 'amount': 120000},
        'createdAt': '2025-07-08T18:00:00Z',
      },
    ];

    var filtered = all.where((a) {
      if (status != null && status.isNotEmpty && a['status'] != status) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final spareName = (a['spare'] as Map)['name']?.toString().toLowerCase() ?? '';
        final shopName = (a['shop'] as Map)['name']?.toString().toLowerCase() ?? '';
        final jobTitle = (a['job'] as Map)['title']?.toString().toLowerCase() ?? '';
        if (!spareName.contains(q) && !shopName.contains(q) && !jobTitle.contains(q)) return false;
      }
      return true;
    }).toList();

    final total = filtered.length;
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, total);
    filtered = filtered.sublist(start.clamp(0, total), end);

    return {
      'applications': filtered,
      'pagination': {
        'page': page,
        'limit': limit,
        'total': total,
        'totalPages': (total / limit).ceil().clamp(1, 9999),
      },
    };
  }

  static Future<Map<String, dynamic>> getSchedules({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final seed = [
      {
        'id': 'sched-1',
        'spare': {'name': '김디자이너', 'email': 'kim@example.com'},
        'shop': {'name': '빌라드블랑 강남점'},
        'job': {'title': '오후 스텝 급구'},
        'checkInTime': '2025-02-09T14:05:00Z',
        'state': 'checked_in',
      },
      {
        'id': 'sched-2',
        'energyWallet': {'user': {'email': 'park@example.com'}},
        'job': {'shop': {'name': '헤어스튜디오 A'}, 'title': '주말 디자이너 대타'},
        'checkIn': '2025-02-09T10:00:00Z',
        'state': 'completed',
      },
    ];
    final schedules = seed.map((s) {
      final override = _scheduleStates[s['id']];
      if (override == null) return s;
      final copy = Map<String, dynamic>.from(s);
      copy['state'] = override;
      return copy;
    }).toList();
    return {
      'schedules': schedules,
      'pagination': {'page': page, 'limit': limit, 'total': 3421, 'totalPages': 172},
    };
  }

  static Future<Map<String, dynamic>> getNoShowHistory({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final history = [
      {
        'id': 'noshow-1',
        'energyWallet': {
          'user': {'name': '최스텝', 'role': 'spare'},
        },
        'job': {'title': '금요일 디자이너', 'shop': {'name': '미용실 B'}},
        'noshowDate': '2025-02-07T14:00:00Z',
        'createdAt': '2025-02-07T16:00:00Z',
      },
    ];
    return {
      'history': history,
      'pagination': {'page': page, 'limit': limit, 'total': 18, 'totalPages': 1},
    };
  }

  static Future<Map<String, dynamic>> getVerifications({
    String? status,
    String? type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = [
      {
        'id': 'ver-1',
        'userId': 'usr-1',
        'userName': '김디자이너',
        'userEmail': 'kim@example.com',
        'userRole': 'spare',
        'type': 'identity',
        'typeLabel': '본인인증',
        'status': 'pending',
        'submittedAt': '2025-06-20T09:30:00Z',
        'documentUrl': null,
      },
      {
        'id': 'ver-2',
        'userId': 'usr-2',
        'userName': '이미용실',
        'userEmail': 'lee@salon.co.kr',
        'userRole': 'shop',
        'type': 'business',
        'typeLabel': '사업자등록',
        'status': 'pending',
        'submittedAt': '2025-06-21T14:00:00Z',
        'documentUrl': null,
      },
      {
        'id': 'ver-3',
        'userId': 'usr-4',
        'userName': '정디자이너',
        'userEmail': 'jung@example.com',
        'userRole': 'seller',
        'type': 'portfolio',
        'typeLabel': '포트폴리오',
        'status': 'approved',
        'submittedAt': '2025-06-18T11:00:00Z',
        'documentUrl': null,
      },
      {
        'id': 'ver-4',
        'userId': 'usr-5',
        'userName': '최스텝',
        'userEmail': 'choi@example.com',
        'userRole': 'spare',
        'type': 'identity',
        'typeLabel': '본인인증',
        'status': 'rejected',
        'submittedAt': '2025-06-19T16:20:00Z',
        'rejectReason': '서류 불명확',
        'documentUrl': null,
      },
    ];
    // 오버라이드 적용
    final withOverrides = all.map((v) {
      final override = _verificationStatuses[v['id']];
      if (override == null) return v;
      final copy = Map<String, dynamic>.from(v);
      copy['status'] = override;
      copy['statusLabel'] = _verificationStatusLabel(override);
      return copy;
    }).toList();

    var filtered = withOverrides;
    if (status != null && status.isNotEmpty && status != 'all') {
      filtered = filtered.where((v) => v['status'] == status).toList();
    }
    if (type != null && type.isNotEmpty && type != 'all') {
      filtered = filtered.where((v) => v['type'] == type).toList();
    }
    return {
      'verifications': filtered,
      'pagination': {
        'page': 1,
        'limit': 20,
        'total': filtered.length,
        'totalPages': 1,
      },
    };
  }

  static Future<Map<String, dynamic>> getVerificationDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final statusOverride = _verificationStatuses[id];
    final base = {
      'id': id,
      'userId': 'usr-2',
      'userName': '이미용실',
      'userEmail': 'lee@salon.co.kr',
      'userRole': 'shop',
      'type': 'business',
      'typeLabel': '사업자등록',
      'status': statusOverride ?? 'pending',
      'statusLabel': _verificationStatusLabel(statusOverride ?? 'pending'),
      'submittedAt': '2025-06-21T14:00:00Z',
    };
    return {
      ...base,
      'submitted': {
        'businessNumber': '123-45-67890',
        'businessName': '헤어스페어 강남점',
        'representative': '이사장',
        'address': '서울특별시 강남구 테헤란로 123',
      },
      'ocr': {
        'businessNumber': '123-45-67890',
        'businessName': '헤어스페어 강남점',
        'representative': '이사장',
        'address': '서울특별시 강남구 테헤란로 123',
        'confidence': 0.94,
      },
      'ntsValidation': {
        'match': true,
        'statusLabel': '일치',
        'checkedAt': '2025-06-21T14:05:00Z',
        'mismatches': <String>[],
      },
      'documentImageUrl': null,
    };
  }

  static Future<Map<String, dynamic>> getReportDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'id': id,
      'reporterName': '김디자이너',
      'reporterId': 'usr-1',
      'reportedName': '헤어스튜디오 A',
      'reportedId': 'usr-shop-a',
      'reportedRole': 'shop',
      'category': 'contact',
      'categoryLabel': '연락처 유출',
      'status': 'open',
      'statusLabel': '미처리',
      'priority': 'high',
      'priorityLabel': '긴급',
      'summary': '채팅 외 연락처 요구 반복',
      'description': '채팅방에서 전화번호와 카카오톡 ID를 반복 요구했습니다.',
      'createdAt': '2025-06-21T15:30:00Z',
      'chatId': 'chat-rep-$id',
      'assignedTo': null,
      'evidenceUrls': <String>[],
    };
  }

  static Future<Map<String, dynamic>> getChatTranscript(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'chatId': chatId,
      'messages': [
        {
          'id': 'msg-1',
          'senderName': '김디자이너',
          'senderRole': 'spare',
          'body': '안녕하세요, 내일 스케줄 확인 부탁드립니다.',
          'createdAt': '2025-06-21T15:00:00Z',
          'contactViolation': false,
        },
        {
          'id': 'msg-2',
          'senderName': '헤어스튜디오 A',
          'senderRole': 'shop',
          'body': '010-9876-5432로 연락 주시거나 카톡 ID hairshop_a 로 추가해주세요.',
          'createdAt': '2025-06-21T15:02:00Z',
          'contactViolation': true,
        },
        {
          'id': 'msg-3',
          'senderName': '김디자이너',
          'senderRole': 'spare',
          'body': '앱 내 채팅으로만 연락 가능합니다.',
          'createdAt': '2025-06-21T15:05:00Z',
          'contactViolation': false,
        },
        {
          'id': 'msg-4',
          'senderName': '헤어스튜디오 A',
          'senderRole': 'shop',
          'body': '급해서 번호 알려드린 거예요. 꼭 연락 주세요.',
          'createdAt': '2025-06-21T15:08:00Z',
          'contactViolation': true,
        },
      ],
    };
  }

  static Future<Map<String, dynamic>> getReports({
    String? status,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = [
      {
        'id': 'rep-1',
        'reporterName': '이미용실',
        'reportedName': '박스텝',
        'reportedRole': 'spare',
        'category': 'noshow',
        'categoryLabel': '노쇼',
        'status': 'open',
        'priority': 'high',
        'summary': '약속 시간 30분 경과 후 미도착',
        'createdAt': '2025-06-22T08:00:00Z',
      },
      {
        'id': 'rep-2',
        'reporterName': '김디자이너',
        'reportedName': '헤어스튜디오 A',
        'reportedRole': 'shop',
        'category': 'contact',
        'categoryLabel': '연락처 유출',
        'status': 'open',
        'priority': 'high',
        'summary': '채팅 외 연락처 요구 반복',
        'createdAt': '2025-06-21T15:30:00Z',
      },
      {
        'id': 'rep-3',
        'reporterName': '정디자이너',
        'reportedName': '최스텝',
        'reportedRole': 'spare',
        'category': 'abuse',
        'categoryLabel': '욕설/비방',
        'status': 'in_review',
        'priority': 'medium',
        'summary': '채팅방 내 부적절 언행',
        'createdAt': '2025-06-20T10:00:00Z',
      },
      {
        'id': 'rep-4',
        'reporterName': '박스텝',
        'reportedName': '미용실 B',
        'reportedRole': 'shop',
        'category': 'payment',
        'categoryLabel': '결제 분쟁',
        'status': 'resolved',
        'priority': 'low',
        'summary': '에너지 환불 요청',
        'createdAt': '2025-06-15T12:00:00Z',
        'resolution': 'warn',
      },
    ];
    // 사용자가 제출한 신고 포함
    final combined = [...all, ..._submittedReports];

    // 오버라이드 적용
    final withOverrides = combined.map((r) {
      final override = _reportStatuses[r['id']];
      if (override == null) return r;
      final copy = Map<String, dynamic>.from(r);
      copy['status'] = override;
      copy['statusLabel'] = _reportStatusLabel(override);
      return copy;
    }).toList();

    var filtered = withOverrides;
    if (status != null && status.isNotEmpty && status != 'all') {
      filtered = filtered.where((r) => r['status'] == status).toList();
    }
    if (category != null && category.isNotEmpty && category != 'all') {
      filtered = filtered.where((r) => r['category'] == category).toList();
    }
    return {
      'reports': filtered,
      'pagination': {
        'page': 1,
        'limit': 20,
        'total': filtered.length,
        'totalPages': 1,
      },
    };
  }

  static Future<Map<String, dynamic>> getBusinessSettings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'groups': [
        {
          'id': 'pricing',
          'title': '경제·가격',
          'description': '에너지·구독·급구·하이패스 수수료',
          'settings': [
            {'key': 'energyPointCostPerUnit', 'label': '에너지 1개당 가격 (원)', 'type': 'int', 'value': 1000, 'min': 1},
            {'key': 'urgentJobListingFee', 'label': '급구 공고 수수료 (원)', 'type': 'int', 'value': 5000, 'min': 0},
            {'key': 'hipassListingFee', 'label': '하이패스 노출 수수료 (원)', 'type': 'int', 'value': 5000, 'min': 0},
            {'key': 'subscriptionMonthlyFee', 'label': '월 구독료 (원)', 'type': 'int', 'value': 99000, 'min': 0},
            {'key': 'premiumJobFee', 'label': '프리미엄 공고 수수료 (원)', 'type': 'int', 'value': 5000, 'min': 0},
            {'key': 'chatAddonFee', 'label': '채팅 애드온 수수료 (원)', 'type': 'int', 'value': 2000, 'min': 0},
            {'key': 'modelDepositAmount', 'label': '모델 보증금 (원)', 'type': 'int', 'value': 30000, 'min': 0},
            {'key': 'jobEnergyFormulaDivisor', 'label': '공고 에너지 환산 (원÷N=에너지)', 'type': 'int', 'value': 1000, 'min': 1},
          ],
        },
        {
          'id': 'quota',
          'title': '쿼터·한도',
          'description': '매칭·에너지·등급별 공고 한도',
          'settings': [
            {'key': 'modelDailyMatchLimit', 'label': '모델 일일 매칭 한도', 'type': 'int', 'value': 3, 'min': 1},
            {'key': 'maxEnergyPurchaseAmount', 'label': '에너지 최대 구매 단위 (개)', 'type': 'int', 'value': 5, 'min': 1},
            {'key': 'shopTierBronzeMaxJobs', 'label': '브론즈 등급 최대 공고 수', 'type': 'int', 'value': 5, 'min': 1},
            {'key': 'shopTierSilverMaxJobs', 'label': '실버 등급 최대 공고 수', 'type': 'int', 'value': 10, 'min': 1},
            {'key': 'shopTierGoldMaxJobs', 'label': '골드 등급 최대 공고 수', 'type': 'int', 'value': 20, 'min': 1},
            {'key': 'shopTierPlatinumMaxJobs', 'label': '플래티넘/VIP 무제한 기준값', 'type': 'int', 'value': 999, 'min': 1},
          ],
        },
        {
          'id': 'sanction',
          'title': '제재정책',
          'description': '연락처·취소·노쇼 제재 규칙',
          'settings': [
            {'key': 'contactMaxAttemptsPerChat', 'label': '채팅당 연락처 시도 최대 횟수', 'type': 'int', 'value': 3, 'min': 1},
            {'key': 'shopContactPenaltyDays', 'label': '미용실 연락처 위반 정지 (일)', 'type': 'int', 'value': 1, 'min': 0},
            {'key': 'maxShopRoomPenaltiesBeforeBan', 'label': '샵 누적 제재 시 탈퇴 기준 (회)', 'type': 'int', 'value': 3, 'min': 1},
            {'key': 'shopUnilateralCancelLimit30d', 'label': '30일 내 일방 취소 허용 횟수', 'type': 'int', 'value': 3, 'min': 0},
            {'key': 'shopJobPostingSuspensionDays', 'label': '공고 등록 정지 기간 (일)', 'type': 'int', 'value': 7, 'min': 0},
            {'key': 'lateCancelCutoffHours', 'label': '늦은 취소·노쇼 기준 (시간)', 'type': 'int', 'value': 48, 'min': 1},
          ],
        },
        {
          'id': 'ranking',
          'title': '랭킹·노출',
          'description': '공고 인기도·노출 가중치',
          'settings': [
            {'key': 'jobPopularityTopN', 'label': '인기 공고 상위 N개', 'type': 'int', 'value': 10, 'min': 1},
            {'key': 'newJobBonusWindowHours', 'label': '신규 공고 보너스 시간 (시간)', 'type': 'int', 'value': 72, 'min': 1},
            {'key': 'jobPopularityAppWeight', 'label': '인기도 — 지원 수 가중치', 'type': 'int', 'value': 10, 'min': 0},
            {'key': 'jobPopularityViewWeight', 'label': '인기도 — 조회 수 가중치', 'type': 'int', 'value': 1, 'min': 0},
            {'key': 'jobPopularityPremiumBonus', 'label': '인기도 — 프리미엄 보너스', 'type': 'int', 'value': 5, 'min': 0},
            {'key': 'jobPopularityLowEnergyBonus', 'label': '인기도 — 저에너지 보너스', 'type': 'int', 'value': 2, 'min': 0},
          ],
        },
        {
          'id': 'space',
          'title': '공간대여',
          'description': '공간 예약 시간·기간 규칙',
          'settings': [
            {'key': 'spaceMinBookingHours', 'label': '공간 최소 예약 시간 (시간)', 'type': 'int', 'value': 1, 'min': 1},
            {'key': 'spaceBookingWindowDays', 'label': '예약 가능 기간 (일)', 'type': 'int', 'value': 30, 'min': 1},
            {'key': 'spaceDefaultOpenHour', 'label': '기본 운영 시작 (시)', 'type': 'int', 'value': 9, 'min': 0},
            {'key': 'spaceDefaultCloseHour', 'label': '기본 운영 종료 (시)', 'type': 'int', 'value': 21, 'min': 1},
          ],
        },
      ],
    };
  }

  static Future<Map<String, dynamic>> getAuditLogs({
    String? action,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = [
      {
        'id': 'audit-1',
        'adminId': 'admin-1',
        'adminName': '운영관리자',
        'action': 'approve_verification',
        'actionLabel': '인증 승인',
        'targetType': 'verification',
        'targetId': 'ver-3',
        'reason': '서류 확인 완료',
        'beforeValue': {'status': 'pending'},
        'afterValue': {'status': 'approved'},
        'createdAt': '2025-06-22T10:15:00Z',
      },
      {
        'id': 'audit-2',
        'adminId': 'admin-1',
        'adminName': '운영관리자',
        'action': 'resolve_case',
        'actionLabel': '신고 처리',
        'targetType': 'report',
        'targetId': 'rep-4',
        'reason': '경고 조치 및 환불 안내',
        'beforeValue': {'status': 'open'},
        'afterValue': {'status': 'resolved', 'action': 'warn'},
        'createdAt': '2025-06-21T16:40:00Z',
      },
      {
        'id': 'audit-3',
        'adminId': 'admin-2',
        'adminName': 'CS팀',
        'action': 'update_config',
        'actionLabel': '설정 변경',
        'targetType': 'config',
        'targetId': 'modelDailyMatchLimit',
        'reason': '매칭 한도 조정',
        'beforeValue': {'value': 5},
        'afterValue': {'value': 3},
        'createdAt': '2025-06-20T09:00:00Z',
      },
      {
        'id': 'audit-4',
        'adminId': 'admin-1',
        'adminName': '운영관리자',
        'action': 'reject_verification',
        'actionLabel': '인증 반려',
        'targetType': 'verification',
        'targetId': 'ver-4',
        'reason': '서류 불명확 — 재제출 요청',
        'beforeValue': {'status': 'pending'},
        'afterValue': {'status': 'rejected'},
        'createdAt': '2025-06-19T17:00:00Z',
      },
      {
        'id': 'audit-5',
        'adminId': 'admin-2',
        'adminName': 'CS팀',
        'action': 'grant_energy',
        'actionLabel': '에너지 지급',
        'targetType': 'user',
        'targetId': 'usr-1',
        'reason': 'CS 보상 지급',
        'beforeValue': {'balance': 1000},
        'afterValue': {'balance': 1100},
        'createdAt': '2025-06-18T14:30:00Z',
      },
    ];
    var filtered = all;
    if (action != null && action.isNotEmpty && action != 'all') {
      filtered = filtered.where((l) => l['action'] == action).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      filtered = filtered.where((l) {
        final name = (l['adminName'] ?? '').toString().toLowerCase();
        final reason = (l['reason'] ?? '').toString().toLowerCase();
        final targetId = (l['targetId'] ?? '').toString().toLowerCase();
        return name.contains(q) || reason.contains(q) || targetId.contains(q);
      }).toList();
    }
    return {
      'logs': filtered,
      'pagination': {
        'page': 1,
        'limit': 20,
        'total': filtered.length,
        'totalPages': 1,
      },
    };
  }

  static Future<Map<String, dynamic>> getMatches({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = [
      {
        'id': 'match-1',
        'designerName': '김디자이너',
        'modelName': '이모델',
        'region': '서울 강남',
        'status': 'matched',
        'statusLabel': '매칭됨',
        'createdAt': '2025-06-22T11:00:00Z',
        'chatId': 'chat-101',
      },
      {
        'id': 'match-2',
        'designerName': '박디자이너',
        'modelName': '최모델',
        'region': '서울 홍대',
        'status': 'pending',
        'statusLabel': '대기',
        'createdAt': '2025-06-21T09:30:00Z',
        'chatId': null,
      },
    ];
    var filtered = all;
    if (status != null && status.isNotEmpty && status != 'all') {
      filtered = filtered.where((m) => m['status'] == status).toList();
    }
    return {'matches': filtered, 'pagination': {'page': 1, 'limit': 20, 'total': filtered.length, 'totalPages': 1}};
  }

  static Future<Map<String, dynamic>> getSpaces({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final spaces = [
      {'id': 'space-1', 'name': '강남 스튜디오 A', 'shopName': '빌라드블랑', 'status': 'available', 'statusLabel': '이용 가능', 'isHidden': false, 'hourlyRate': 15000},
      {'id': 'space-2', 'name': '홍대 공유석', 'shopName': '헤어스튜디오 A', 'status': 'booked', 'statusLabel': '예약 중', 'isHidden': false, 'hourlyRate': 12000},
    ];
    return {'spaces': spaces, 'pagination': {'page': 1, 'limit': 20, 'total': spaces.length, 'totalPages': 1}};
  }

  static Future<Map<String, dynamic>> getSpaceBookings({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final bookings = [
      {'id': 'bk-1', 'spaceName': '강남 스튜디오 A', 'userName': '김디자이너', 'startAt': '2025-06-23T10:00:00Z', 'amount': 45000, 'status': 'pending', 'statusLabel': '대기'},
      {'id': 'bk-2', 'spaceName': '홍대 공유석', 'userName': '박스텝', 'startAt': '2025-06-22T14:00:00Z', 'amount': 36000, 'status': 'confirmed', 'statusLabel': '확정'},
    ];
    var filtered = bookings;
    if (status != null && status.isNotEmpty && status != 'all') {
      filtered = bookings.where((b) => b['status'] == status).toList();
    }
    return {'bookings': filtered, 'pagination': {'page': 1, 'limit': 20, 'total': filtered.length, 'totalPages': 1}};
  }

  static Future<Map<String, dynamic>> getEducations({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final educations = [
      {'id': 'edu-1', 'title': '컷트 기초 마스터', 'instructor': '이강사', 'category': '컷트', 'maxApplicants': 20, 'applicantCount': 14, 'energyCost': 50, 'deadline': '2025-07-01', 'status': 'published', 'statusLabel': '모집중', 'isOnline': false},
      {'id': 'edu-2', 'title': '염색 실무 온라인', 'instructor': '정강사', 'category': '염색', 'maxApplicants': 50, 'applicantCount': 8, 'energyCost': 30, 'deadline': '2025-07-15', 'status': 'pending', 'statusLabel': '승인 대기', 'isOnline': true},
    ];
    return {'educations': educations, 'pagination': {'page': 1, 'limit': 20, 'total': educations.length, 'totalPages': 1}};
  }

  static Future<Map<String, dynamic>> getPointTransactions({String? type}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final txs = [
      {'id': 'pt-1', 'userName': '김디자이너', 'type': 'earn', 'typeLabel': '적립', 'amount': 10, 'description': '일일 미션', 'createdAt': '2025-06-22T08:00:00Z', 'suspicious': false},
      {'id': 'pt-2', 'userName': '박스텝', 'type': 'earn', 'typeLabel': '적립', 'amount': 500, 'description': '광고 시청', 'createdAt': '2025-06-21T20:00:00Z', 'suspicious': true},
    ];
    return {'transactions': txs, 'pagination': {'page': 1, 'limit': 20, 'total': txs.length, 'totalPages': 1}};
  }

  static Future<Map<String, dynamic>> getMissions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'missions': [
        {'id': 'mission-daily', 'type': 'daily', 'label': '일일 출석', 'reward': 10, 'dailyCap': 1, 'active': true},
        {'id': 'mission-ad', 'type': 'rewarded_ad', 'label': '광고 시청', 'reward': 5, 'dailyCap': 10, 'active': true},
      ],
    };
  }

  static Future<Map<String, dynamic>> getSubscriptions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'subscriptions': [
        {
          'id': 'sub-1',
          'userId': 'shop-1',
          'creatorId': 'creator-1',
          'userName': '이미용실',
          'creatorName': '정크리에이터',
          'isActive': true,
          'startedAt': '2025-05-01T00:00:00Z',
          'amount': 99000,
        },
        {
          'id': 'sub-2',
          'userId': 'shop-2',
          'creatorId': 'creator-1',
          'userName': '미용실 B',
          'creatorName': '정크리에이터',
          'isActive': false,
          'startedAt': '2025-03-01T00:00:00Z',
          'amount': 99000,
        },
      ],
      'counts': {'all': 2, 'active': 1, 'inactive': 1},
      'pagination': {'page': 1, 'limit': 20, 'total': 2, 'totalPages': 1},
    };
  }

  static Future<Map<String, dynamic>> getCreators() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'creators': [
        {
          'id': 'creator-1',
          'userId': 'user-1',
          'name': '정크리에이터',
          'email': 'creator1@test.com',
          'subscriberCount': 128,
          'videoCount': 24,
          'likeCount': 540,
          'verified': true,
          'createdAt': '2025-05-01T00:00:00Z',
        },
        {
          'id': 'creator-2',
          'userId': 'user-2',
          'name': '한크리에이터',
          'email': 'creator2@test.com',
          'subscriberCount': 45,
          'videoCount': 8,
          'likeCount': 120,
          'verified': false,
          'createdAt': '2025-06-01T00:00:00Z',
        },
      ],
      'counts': {'all': 2, 'verified': 1, 'unverified': 1},
      'pagination': {'page': 1, 'limit': 20, 'total': 2, 'totalPages': 1},
    };
  }

  static Future<Map<String, dynamic>> getSanctions({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sanctions = [
      {'id': 'san-1', 'userName': '최스텝', 'type': 'suspend', 'typeLabel': '정지', 'durationDays': 7, 'reason': '노쇼 누적', 'active': true, 'createdAt': '2025-06-20T00:00:00Z'},
      {'id': 'san-2', 'userName': '미용실 B', 'type': 'warn', 'typeLabel': '경고', 'durationDays': null, 'reason': '연락처 유출', 'active': false, 'createdAt': '2025-06-15T00:00:00Z'},
    ];
    return {'sanctions': sanctions, 'pagination': {'page': 1, 'limit': 20, 'total': sanctions.length, 'totalPages': 1}};
  }

  static Future<Map<String, dynamic>> getContentItems({String? type, String? flagged}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final items = [
      {'id': 'ch-1', 'type': 'challenge', 'typeLabel': '영상', 'title': '여름 컬러 챌린지', 'authorName': '김디자이너', 'flagged': true, 'featured': false, 'createdAt': '2025-06-21T12:00:00Z'},
      {'id': 'cm-1', 'type': 'comment', 'typeLabel': '댓글', 'title': '부적절한 댓글', 'authorName': '익명', 'flagged': true, 'featured': false, 'createdAt': '2025-06-20T18:00:00Z'},
    ];
    var filtered = items;
    if (type != null && type.isNotEmpty && type != 'all') {
      filtered = filtered.where((i) => i['type'] == type).toList();
    }
    return {'items': filtered, 'pagination': {'page': 1, 'limit': 20, 'total': filtered.length, 'totalPages': 1}, 'flaggedContent': 2};
  }

  static final List<Map<String, dynamic>> _notificationTemplates = [
    {'id': 'tpl-1', 'name': '인증 승인', 'title': '인증이 승인되었습니다', 'body': 'HairSpare 인증 심사가 완료되었습니다.'},
    {'id': 'tpl-2', 'name': '제재 안내', 'title': '계정 제재 안내', 'body': '커뮤니티 가이드 위반으로 제재가 적용되었습니다.'},
    {'id': 'tpl-3', 'name': '점검 안내', 'title': '서비스 점검 안내', 'body': '더 나은 서비스를 위해 점검이 진행됩니다. 이용에 참고해 주세요.'},
  ];
  static int _templateIdSeq = 10;

  static Future<Map<String, dynamic>> getNotificationData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'templates': _notificationTemplates
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      'history': [
        {'id': 'send-1', 'audience': '전체', 'title': '서비스 점검 안내', 'body': '더 나은 서비스를 위해 점검이 진행됩니다. 이용에 참고해 주세요.', 'sentAt': '2025-06-20T09:00:00Z', 'recipientCount': 1247},
      ],
    };
  }

  static Future<Map<String, dynamic>> createNotificationTemplate({
    required String name,
    required String title,
    required String body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final row = {
      'id': 'tpl-${_templateIdSeq++}',
      'name': name,
      'title': title,
      'body': body,
    };
    _notificationTemplates.add(row);
    return Map<String, dynamic>.from(row);
  }

  static Future<Map<String, dynamic>> updateNotificationTemplate({
    required String templateId,
    required String name,
    required String title,
    required String body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notificationTemplates.indexWhere((e) => e['id'] == templateId);
    if (index < 0) throw Exception('템플릿을 찾을 수 없습니다');
    _notificationTemplates[index] = {
      'id': templateId,
      'name': name,
      'title': title,
      'body': body,
    };
    return Map<String, dynamic>.from(_notificationTemplates[index]);
  }

  static Future<void> deleteNotificationTemplate(String templateId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notificationTemplates.removeWhere((e) => e['id'] == templateId);
  }

  static Future<Map<String, dynamic>> getReferenceData({String? tab}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'regions': [
        {'id': 'r-1', 'province': '서울', 'city': '강남구', 'district': '역삼동'},
        {'id': 'r-2', 'province': '서울', 'city': '마포구', 'district': '홍대'},
      ],
      'tiers': [
        {'id': 'bronze', 'label': '브론즈', 'maxJobs': 5},
        {'id': 'silver', 'label': '실버', 'maxJobs': 10},
        {'id': 'gold', 'label': '골드', 'maxJobs': 20},
      ],
      'matchTags': [
        {'id': 'tag-1', 'label': '단발', 'category': 'hair_length'},
        {'id': 'tag-2', 'label': '염색', 'category': 'style'},
      ],
      'categories': [
        {'id': 'cat-1', 'label': '컷트'},
        {'id': 'cat-2', 'label': '염색'},
      ],
    };
  }

  // ── 사용자가 제출한 신고 목록 (mock에서 누적)
  static final List<Map<String, dynamic>> _submittedReports = [];
  static int _reportIdSeq = 100;

  static Future<void> addReport({
    required String category,
    required String summary,
    String? reportedUserId,
    String? referenceId,
    String? referenceType,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _submittedReports.add({
      'id': 'rep-${_reportIdSeq++}',
      'reporterName': '나',
      'reportedName': reportedUserId ?? '알 수 없음',
      'reportedRole': 'unknown',
      'category': category,
      'categoryLabel': _reportCategoryLabel(category),
      'status': 'open',
      'priority': 'medium',
      'summary': summary,
      if (referenceId != null) 'referenceId': referenceId,
      if (referenceType != null) 'referenceType': referenceType,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  static String _reportCategoryLabel(String category) {
    switch (category) {
      case 'noshow': return '노쇼';
      case 'contact': return '연락처 유출';
      case 'abuse': return '욕설/비방';
      case 'payment': return '결제 분쟁';
      default: return '기타';
    }
  }

  // ── 상태 레이블 헬퍼 ──

  static String _verificationStatusLabel(String status) {
    switch (status) {
      case 'approved': return '승인';
      case 'rejected': return '반려';
      default: return '대기중';
    }
  }

  static String _reportStatusLabel(String status) {
    switch (status) {
      case 'resolved': return '처리완료';
      case 'in_review': return '검토중';
      default: return '미처리';
    }
  }
}
