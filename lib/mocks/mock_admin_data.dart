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
      'energyWallet': {'balance': 1250},
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
}
