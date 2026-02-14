import '../models/job.dart';
import '../models/schedule.dart';
import '../models/notification.dart';
import '../models/challenge_profile.dart';
import '../models/challenge_comment.dart';
import '../models/space_rental.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';
import '../services/payment_service.dart';
import '../services/review_service.dart';
import '../screens/spare/challenge_screen.dart';

/// 스페어 화면용 Mock 데이터
class MockSpareData {
  static final List<Map<String, dynamic>> _jobsJson = [
    {
      'id': 'job-mock-1',
      'title': '오후 스텝 급구',
      'shopName': '빌라드블랑 강남점',
      'date': '2026-02-15',
      'time': '14:00',
      'endTime': '22:00',
      'amount': 50000,
      'energy': 50,
      'requiredCount': 1,
      'regionId': 'region-1',
      'isUrgent': true,
      'isPremium': false,
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'job-mock-2',
      'title': '주말 디자이너 대타',
      'shopName': '헤어스튜디오 A',
      'date': '2026-02-16',
      'time': '10:00',
      'endTime': '18:00',
      'amount': 80000,
      'energy': 80,
      'requiredCount': 1,
      'regionId': 'region-2',
      'isUrgent': false,
      'isPremium': true,
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  static Future<List<Job>> getJobs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _jobsJson.map((j) => Job.fromJson(j)).toList();
  }

  static Future<Job> getJobById(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final found = _jobsJson.firstWhere(
      (j) => j['id'] == jobId,
      orElse: () => _jobsJson.first,
    );
    return Job.fromJson(Map<String, dynamic>.from(found));
  }

  static Future<List<Job>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [Job.fromJson(_jobsJson.first)];
  }

  static Future<List<Schedule>> getSchedules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return [
      Schedule.fromJson({
        'id': 'sched-mock-1',
        'jobId': 'job-mock-1',
        'spareId': 'mock-spare-1',
        'shopId': 'shop-1',
        'date': dateStr,
        'startTime': '14:00',
        'status': 'scheduled',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'job': _jobsJson.first,
      }),
    ];
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

  static Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      AppNotification.fromJson({
        'id': 'notif-1',
        'type': 'job',
        'title': '새 공고 알림',
        'message': '오후 스텝 급구 공고가 등록되었습니다',
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
        'relatedJobId': 'job-mock-1',
      }),
      AppNotification.fromJson({
        'id': 'notif-2',
        'type': 'schedule_reminder',
        'title': '스케줄 알림',
        'message': '내일 2시 헤어스튜디오 A 출근 예정입니다',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      }),
      AppNotification.fromJson({
        'id': 'notif-3',
        'type': 'message_received',
        'title': '새 메시지',
        'message': '빌라드블랑 강남점에서 메시지를 보냈습니다',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'relatedUserId': 'shop-1',
      }),
    ];
  }

  static final List<Map<String, dynamic>> _chatsJson = [
    {
      'id': 'chat-mock-1',
      'shopId': 'shop-1',
      'shopName': '빌라드블랑 강남점',
      'spareId': 'mock-spare-1',
      'spareName': '김디자이너',
      'jobId': 'job-mock-1',
      'jobTitle': '오후 스텝 급구',
      'lastMessage': {
        'content': '내일 2시에 오시면 됩니다',
        'createdAt': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
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
        'createdAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
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
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      },
      'unreadCount': 2,
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
        'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
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
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
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
        'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
      'unreadCount': 0,
    },
  ];

  static Future<List<Chat>> getChats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _chatsJson.map((j) => Chat.fromJson(Map<String, dynamic>.from(j))).toList();
  }

  static Future<Map<String, dynamic>> getWallet() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'balance': 1250,
      'transactions': [
        {
          'id': 'tx-1',
          'type': 'purchase',
          'amount': 100,
          'description': '에너지 100개 구매',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ],
    };
  }

  static Future<List<Payment>> getPayments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Payment.fromJson({
        'id': 'pay-1',
        'type': 'energy_purchase',
        'amount': 50000,
        'status': 'success',
        'createdAt': DateTime.now().toIso8601String(),
        'description': '에너지 100개 구매',
      }),
    ];
  }

  static Future<ChallengeProfile> getChallengeProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ChallengeProfile.fromJson({
      'userId': userId,
      'challengeNickname': '디자이너킴',
      'challengeBio': '헤어 스타일 챌린지',
      'isPublic': true,
      'videoCount': 5,
      'totalLikes': 120,
      'totalViews': 1500,
      'subscriberCount': 45,
    });
  }

  static Future<List<MyChallenge>> getMyChallenges() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }

  static Future<List<Challenge>> getSubscribedChallenges() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }

  static Future<List<ChallengeComment>> getChallengeComments(String challengeId) async {
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
      'identityVerified': false,
      'identityName': null,
      'identityPhone': null,
    };
  }

  static Future<Map<String, dynamic>> getPassVerificationStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {'verified': false};
  }

  static Future<Map<String, dynamic>> getLicenseVerificationStatus() async {
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
      {'id': 'msg-1-1', 'chatId': 'chat-mock-1', 'senderId': 'shop-1', 'senderName': '빌라드블랑 강남점', 'senderRole': 'shop', 'content': '안녕하세요, 지원해주셔서 감사합니다.', 'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()},
      {'id': 'msg-1-2', 'chatId': 'chat-mock-1', 'senderId': 'mock-spare-1', 'senderName': '김디자이너', 'senderRole': 'spare', 'content': '네, 감사합니다. 내일 2시 출근이 맞나요?', 'createdAt': DateTime.now().subtract(const Duration(hours: 1, minutes: 55)).toIso8601String()},
      {'id': 'msg-1-3', 'chatId': 'chat-mock-1', 'senderId': 'shop-1', 'senderName': '빌라드블랑 강남점', 'senderRole': 'shop', 'content': '네 맞습니다. 내일 2시에 오시면 됩니다', 'createdAt': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String()},
    ],
    'chat-mock-2': [
      {'id': 'msg-2-1', 'chatId': 'chat-mock-2', 'senderId': 'shop-2', 'senderName': '헤어스튜디오 A', 'senderRole': 'shop', 'content': '주말 디자이너 대타 지원해주셔서 감사해요', 'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()},
      {'id': 'msg-2-2', 'chatId': 'chat-mock-2', 'senderId': 'mock-spare-1', 'senderName': '김디자이너', 'senderRole': 'spare', 'content': '네, 주말 근무 가능합니다', 'createdAt': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)).toIso8601String()},
      {'id': 'msg-2-3', 'chatId': 'chat-mock-2', 'senderId': 'shop-2', 'senderName': '헤어스튜디오 A', 'senderRole': 'shop', 'content': '주말 근무 가능하시면 연락주세요', 'createdAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String()},
    ],
    'chat-mock-3': [
      {'id': 'msg-3-1', 'chatId': 'chat-mock-3', 'senderId': 'shop-3', 'senderName': '빌라드블랑 홍대점', 'senderRole': 'shop', 'content': '금요일 저녁 급구 공고에 지원해주셨네요', 'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String()},
      {'id': 'msg-3-2', 'chatId': 'chat-mock-3', 'senderId': 'mock-spare-1', 'senderName': '김디자이너', 'senderRole': 'spare', 'content': '6시부터 가능합니다', 'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()},
      {'id': 'msg-3-3', 'chatId': 'chat-mock-3', 'senderId': 'shop-3', 'senderName': '빌라드블랑 홍대점', 'senderRole': 'shop', 'content': '금요일 6시부터 가능하시다니 감사합니다!', 'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()},
    ],
    'chat-mock-4': [
      {'id': 'msg-4-1', 'chatId': 'chat-mock-4', 'senderId': 'shop-4', 'senderName': '헤어살롱 B', 'senderRole': 'shop', 'content': '오전 스텝 근무 잘 하셨어요', 'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String()},
      {'id': 'msg-4-2', 'chatId': 'chat-mock-4', 'senderId': 'mock-spare-1', 'senderName': '김디자이너', 'senderRole': 'spare', 'content': '감사합니다! 다음에도 기회 주시면 좋겠어요', 'createdAt': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String()},
      {'id': 'msg-4-3', 'chatId': 'chat-mock-4', 'senderId': 'shop-4', 'senderName': '헤어살롱 B', 'senderRole': 'shop', 'content': '확인했습니다. 수고하세요!', 'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String()},
    ],
    'chat-mock-5': [
      {'id': 'msg-5-1', 'chatId': 'chat-mock-5', 'senderId': 'shop-5', 'senderName': '스타일리스트 C', 'senderRole': 'shop', 'content': '주중 디자이너 공고 확인했습니다', 'createdAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String()},
      {'id': 'msg-5-2', 'chatId': 'chat-mock-5', 'senderId': 'mock-spare-1', 'senderName': '김디자이너', 'senderRole': 'spare', 'content': '화요일부터 가능합니다', 'createdAt': DateTime.now().subtract(const Duration(hours: 5, minutes: 30)).toIso8601String()},
      {'id': 'msg-5-3', 'chatId': 'chat-mock-5', 'senderId': 'shop-5', 'senderName': '스타일리스트 C', 'senderRole': 'shop', 'content': '이번 주 화요일부터 출근 가능하신가요?', 'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String()},
    ],
    'chat-mock-6': [
      {'id': 'msg-6-1', 'chatId': 'chat-mock-6', 'senderId': 'shop-6', 'senderName': '커트 전문샵', 'senderRole': 'shop', 'content': '오후 시간대 대타 감사합니다', 'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String()},
      {'id': 'msg-6-2', 'chatId': 'chat-mock-6', 'senderId': 'mock-spare-1', 'senderName': '김디자이너', 'senderRole': 'spare', 'content': '네, 협력 잘 부탁드려요', 'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()},
    ],
  };

  static Future<ChatWithMessages> getChatById(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final chatData = _chatsJson.firstWhere(
      (c) => c['id'] == chatId,
      orElse: () => _chatsJson.first,
    );
    final messages = _chatMessages[chatId] ?? _chatMessages['chat-mock-1'] ?? [];
    return ChatWithMessages.fromJson({
      'chat': chatData,
      'messages': messages,
    });
  }

  /// 공간대여 더미 데이터
  static Future<List<SpaceRental>> getSpaceRentals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _spaceRentalsJson.map((j) => SpaceRental.fromJson(Map<String, dynamic>.from(j))).toList();
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

  static List<Map<String, dynamic>> get _spaceRentalsJson {
    final now = DateTime.now();
    return [
      {
        'id': 'space-mock-1',
        'shopId': 'shop-1',
        'shopName': '빌라드블랑 강남점',
        'address': '서울 강남구 테헤란로 123',
        'detailAddress': '4층',
        'regionId': 'seoul-gangnam',
        'regionName': '강남구',
        'availableSlots': _makeSlots(now, 5),
        'pricePerHour': 30000,
        'facilities': ['의자', '세트', '샴푸대', '드라이어'],
        'imageUrls': ['https://picsum.photos/id/100/400/280'],
        'status': 'available',
        'description': '쾌적한 미용 공간을 시간 단위로 대여합니다. 자연광이 잘 드는 넓은 공간으로 촬영 및 실습에 최적화되어 있습니다.',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'contactPhone': '02-1234-5678',
        'subwayInfo': '강남역 3번 출구 도보 5분',
        'isPremium': true,
        'usageNotes': '• 최소 2시간 단위 예약\n• 사용 후 정리 정돈 부탁드립니다\n• 취소는 예약 24시간 전까지 가능',
        'averageRating': 4.7,
        'reviewCount': 3,
        'reviews': [
          {'userName': '박스타일', 'rating': 5, 'comment': '공간이 넓고 밝아서 작업하기 좋았어요. 다음에 또 이용할게요!', 'createdAt': now.subtract(Duration(days: 2)).toIso8601String()},
          {'userName': '김헤어', 'rating': 5, 'comment': '설비가 깔끔하고 관리가 잘 되어 있습니다.', 'createdAt': now.subtract(Duration(days: 5)).toIso8601String()},
          {'userName': '이디자인', 'rating': 4, 'comment': '가격 대비 만족도 높아요. 강추합니다.', 'createdAt': now.subtract(Duration(days: 10)).toIso8601String()},
        ],
        'minHours': 2,
      },
      {
        'id': 'space-mock-2',
        'shopId': 'shop-2',
        'shopName': '헤어스튜디오 A',
        'address': '서울 마포구 홍대로 456',
        'regionId': 'seoul-mapo',
        'regionName': '마포구',
        'availableSlots': _makeSlots(now, 3),
        'pricePerHour': 25000,
        'facilities': ['의자', '세트'],
        'imageUrls': ['https://picsum.photos/id/200/400/280'],
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
          {'userName': '최미용', 'rating': 4, 'comment': '홍대 근처라 접근성 좋아요.', 'createdAt': now.subtract(Duration(days: 3)).toIso8601String()},
          {'userName': '정스타일', 'rating': 5, 'comment': '가성비 최고!', 'createdAt': now.subtract(Duration(days: 7)).toIso8601String()},
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
        'availableSlots': _makeSlots(now, 4),
        'pricePerHour': 35000,
        'facilities': ['의자', '세트', '샴푸대', '드라이어', '촬영조명'],
        'imageUrls': ['https://picsum.photos/id/300/400/280'],
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
          {'userName': '한촬영', 'rating': 5, 'comment': '조명이 너무 좋아요. 전문가용으로 강추!', 'createdAt': now.subtract(Duration(days: 1)).toIso8601String()},
        ],
        'minHours': 2,
      },
    ];
  }

  static List<Map<String, dynamic>> _makeSlots(DateTime base, int count) {
    final slots = <Map<String, dynamic>>[];
    for (var i = 0; i < count; i++) {
      final start = base.add(Duration(days: i ~/ 3, hours: 9 + (i % 3) * 4));
      final end = start.add(const Duration(hours: 2));
      slots.add({
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'isAvailable': true,
      });
    }
    return slots;
  }

  /// 교육 더미 데이터 (공고목록용)
  static Future<List<Map<String, dynamic>>> getEducations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    return List.generate(5, (i) => {
      'id': 'edu-mock-$i',
      'title': '교육 프로그램 ${i + 1}',
      'price': (i + 1) * 10000,
      'deadline': now.add(Duration(days: i + 5)),
      'isOnline': i % 2 == 0,
      'isUrgent': i % 3 == 0,
      'province': '서울',
      'district': '강남구',
    });
  }
}
