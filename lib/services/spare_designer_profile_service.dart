import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/spare_designer_profile.dart';
import '../utils/api_config.dart';
import '../utils/api_client.dart';

/// 스페어·디자이너 공개 프로필 조회·저장.
class SpareDesignerProfileService {
  SpareDesignerProfileService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  static String _storageKey(String userId) => 'spare_designer_profile_$userId';

  Future<SpareDesignerProfile> getProfile(String userId) async {
    if (ApiConfig.useMockData) {
      return _loadMock(userId);
    }

    try {
      final response = await _apiClient.dio.get('/api/spares/me/profile');
      final data = response.data;
      final map = data is Map<String, dynamic>
          ? (data['data'] ?? data) as Map<String, dynamic>
          : <String, dynamic>{};
      final profile = SpareDesignerProfile.fromJson(map);
      await _saveMock(userId, profile);
      return profile;
    } catch (_) {
      return _loadMock(userId);
    }
  }

  Future<SpareDesignerProfile> saveProfile(
    String userId,
    SpareDesignerProfile profile,
  ) async {
    if (ApiConfig.useMockData) {
      await _saveMock(userId, profile);
      return profile;
    }

    final response = await _apiClient.dio.put(
      '/api/spares/me/profile',
      data: profile.toJson(),
    );
    final data = response.data;
    final map = data is Map<String, dynamic>
        ? (data['data'] ?? data) as Map<String, dynamic>
        : profile.toJson();
    final saved = SpareDesignerProfile.fromJson(map);
    await _saveMock(userId, saved);
    return saved;
  }

  Future<SpareDesignerProfile> _loadMock(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(userId));
    if (raw != null) {
      try {
        return SpareDesignerProfile.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return const SpareDesignerProfile(
      matchingIntro: '내추럴 염색·탈색 전문. 모델 촬영 경험 풍부합니다.',
      specialties: ['염색', '탈색'],
      experienceYears: 5,
      regionLabel: '강남구',
      role: 'designer',
    );
  }

  Future<void> _saveMock(String userId, SpareDesignerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(userId), jsonEncode(profile.toJson()));
  }
}
