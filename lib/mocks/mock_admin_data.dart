/// 관리자 화면용 Mock 데이터
/// ApiConfig.useMockData == true 일 때 AdminService에서 사용
class MockAdminData {
  static Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'users': {'total': 1247, 'today': 12, 'byRole': {'spare': 892, 'shop': 312, 'seller': 43}},
      'jobs': {'total': 523, 'active': 89},
      'payments': {'total': 45800000, 'today': 1250000},
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
        {'type': 'signup', 'label': '회원가입', 'entity': '김디자이너', 'ago': '5분 전', 'color': 'blue'},
        {'type': 'job', 'label': '공고등록', 'entity': '이미용실', 'ago': '12분 전', 'color': 'purple'},
        {'type': 'payment', 'label': '결제완료', 'entity': '박스텝', 'ago': '23분 전', 'color': 'green'},
        {'type': 'noshow', 'label': '노쇼신고', 'entity': '최사장', 'ago': '1시간 전', 'color': 'red'},
        {'type': 'energy', 'label': '에너지충전', 'entity': '정디자이너', 'ago': '2시간 전', 'color': 'yellow'},
        {'type': 'schedule', 'label': '체크인', 'entity': '이스텝', 'ago': '3시간 전', 'color': 'purple'},
      ],
    };
  }

  static Future<Map<String, dynamic>> getUsers({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = [
      {
        'id': 'usr-1',
        'name': '김디자이너',
        'email': 'kim@example.com',
        'phone': '010-1234-5678',
        'role': 'spare',
        'createdAt': '2025-01-15T10:00:00Z',
        'accounts': [{'provider': 'email'}],
        '_count': {'jobs': 0, 'applications': 3, 'schedules': 12},
      },
      {
        'id': 'usr-2',
        'name': '이미용실',
        'email': 'lee@salon.co.kr',
        'phone': '02-1234-5678',
        'role': 'shop',
        'createdAt': '2025-01-10T14:30:00Z',
        'accounts': [{'provider': 'kakao'}],
        '_count': {'jobs': 8, 'applications': 0, 'schedules': 45},
      },
      {
        'id': 'usr-3',
        'name': '박스텝',
        'email': 'park@example.com',
        'phone': '010-9876-5432',
        'role': 'spare',
        'createdAt': '2025-02-01T09:00:00Z',
        'accounts': [{'provider': 'naver'}],
        '_count': {'jobs': 0, 'applications': 5, 'schedules': 8},
      },
    ];
    return {
      'users': users,
      'pagination': {'page': page, 'limit': limit, 'total': 1247, 'totalPages': 63},
    };
  }

  static Future<Map<String, dynamic>> getUserDetail(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'id': userId,
      'name': '김디자이너',
      'email': 'kim@example.com',
      'phone': '010-1234-5678',
      'role': 'spare',
      'createdAt': '2025-01-15T10:00:00Z',
      'profileImage': null,
      'accountStatus': 'active',
      'accountStatusLabel': '정상',
      'energyWallet': {'balance': 1250},
      'pointWallet': {'balance': 340},
      '_count': {'jobs': 0, 'applications': 3, 'schedules': 12},
      'accounts': [{'provider': 'email'}],
      'recentActivity': [
        {'label': '공고 지원', 'detail': '오후 스텝 급구', 'at': '2025-06-22T09:00:00Z'},
        {'label': '체크인', 'detail': '빌라드블랑 강남점', 'at': '2025-06-21T14:05:00Z'},
      ],
      'sanctionHistory': [
        {'typeLabel': '경고', 'reason': '지각', 'at': '2025-05-01T00:00:00Z', 'active': false},
      ],
      'verification': {
        'status': 'approved',
        'statusLabel': '승인',
        'typeLabel': '본인인증',
        'verifiedAt': '2025-01-20T10:00:00Z',
      },
    };
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
      'status': 'published',
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

  static Future<Map<String, dynamic>> getSchedules({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final schedules = [
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
    var filtered = all;
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
    final base = {
      'id': id,
      'userId': 'usr-2',
      'userName': '이미용실',
      'userEmail': 'lee@salon.co.kr',
      'userRole': 'shop',
      'type': 'business',
      'typeLabel': '사업자등록',
      'status': 'pending',
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
    var filtered = all;
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
          'description': '에너지·구독·수수료 관련 설정',
          'settings': [
            {
              'key': 'energyPointCostPerUnit',
              'label': '에너지 1개당 가격 (원)',
              'type': 'int',
              'value': 1000,
              'min': 1,
            },
            {
              'key': 'urgentJobListingFee',
              'label': '급구 공고 수수료 (원)',
              'type': 'int',
              'value': 5000,
              'min': 0,
            },
            {
              'key': 'subscriptionMonthlyFee',
              'label': '월 구독료 (원)',
              'type': 'int',
              'value': 99000,
              'min': 0,
            },
            {
              'key': 'modelDepositAmount',
              'label': '모델 보증금 (원)',
              'type': 'int',
              'value': 30000,
              'min': 0,
            },
          ],
        },
        {
          'id': 'quota',
          'title': '쿼터·한도',
          'description': '매칭·공고 등록 한도',
          'settings': [
            {
              'key': 'modelDailyMatchLimit',
              'label': '모델 일일 매칭 한도',
              'type': 'int',
              'value': 3,
              'min': 1,
            },
            {
              'key': 'maxEnergyPurchaseAmount',
              'label': '에너지 최대 구매 단위',
              'type': 'int',
              'value': 5,
              'min': 1,
            },
          ],
        },
        {
          'id': 'sanction',
          'title': '제재정책',
          'description': '연락처·취소·노쇼 제재 규칙',
          'settings': [
            {
              'key': 'contactMaxAttemptsPerChat',
              'label': '채팅당 연락처 시도 최대 횟수',
              'type': 'int',
              'value': 3,
              'min': 1,
            },
            {
              'key': 'shopContactPenaltyDays',
              'label': '미용실 연락처 위반 정지 (일)',
              'type': 'int',
              'value': 1,
              'min': 0,
            },
            {
              'key': 'shopUnilateralCancelLimit30d',
              'label': '30일 내 일방 취소 허용 횟수',
              'type': 'int',
              'value': 3,
              'min': 0,
            },
            {
              'key': 'shopJobPostingSuspensionDays',
              'label': '공고 등록 정지 기간 (일)',
              'type': 'int',
              'value': 7,
              'min': 0,
            },
          ],
        },
        {
          'id': 'ranking',
          'title': '랭킹·노출',
          'description': '공고 인기도·노출 가중치',
          'settings': [
            {
              'key': 'jobPopularityTopN',
              'label': '인기 공고 상위 N개',
              'type': 'int',
              'value': 10,
              'min': 1,
            },
            {
              'key': 'newJobBonusWindowHours',
              'label': '신규 공고 보너스 시간 (시간)',
              'type': 'int',
              'value': 72,
              'min': 1,
            },
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
        {'id': 'sub-1', 'userName': '이미용실', 'creatorName': '정크리에이터', 'isActive': true, 'startedAt': '2025-05-01T00:00:00Z', 'amount': 99000},
        {'id': 'sub-2', 'userName': '미용실 B', 'creatorName': '정크리에이터', 'isActive': false, 'startedAt': '2025-03-01T00:00:00Z', 'amount': 99000},
      ],
      'pagination': {'page': 1, 'limit': 20, 'total': 2, 'totalPages': 1},
    };
  }

  static Future<Map<String, dynamic>> getCreators() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'creators': [
        {'id': 'creator-1', 'name': '정크리에이터', 'subscriberCount': 128, 'videoCount': 24, 'verified': true},
        {'id': 'creator-2', 'name': '한크리에이터', 'subscriberCount': 45, 'videoCount': 8, 'verified': false},
      ],
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

  static Future<Map<String, dynamic>> getNotificationData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'templates': [
        {'id': 'tpl-1', 'name': '인증 승인', 'title': '인증이 승인되었습니다', 'body': 'HairSpare 인증 심사가 완료되었습니다.'},
        {'id': 'tpl-2', 'name': '제재 안내', 'title': '계정 제재 안내', 'body': '커뮤니티 가이드 위반으로 제재가 적용되었습니다.'},
      ],
      'history': [
        {'id': 'send-1', 'audience': '전체', 'title': '서비스 점검 안내', 'sentAt': '2025-06-20T09:00:00Z', 'recipientCount': 1247},
      ],
    };
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
}
