import '../models/spare_profile.dart';
import '../models/application.dart';

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

  static final Map<String, dynamic> _jobJson = {
    'id': 'job-mock-1',
    'title': '오후 스텝 급구',
    'shopName': '빌라드블랑 강남점',
    'date': '2025-02-15',
    'time': '14:00',
    'amount': 50000,
    'energy': 50,
    'requiredCount': 1,
    'regionId': 'region-1',
    'isUrgent': true,
    'isPremium': false,
    'createdAt': DateTime.now().toIso8601String(),
  };

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

  static Future<List<Application>> getShopApplications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Application.fromJson({
        'id': 'app-mock-1',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'job': _jobJson,
        'spare': {
          'id': 'spare-mock-1',
          'username': 'kim_designer',
          'name': '김디자이너',
          'email': 'kim@example.com',
          'role': 'spare',
          'createdAt': DateTime.now().toIso8601String(),
        },
      }),
    ];
  }

  static Future<List<Application>> getMyApplications() async {
    return getShopApplications();
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
}
