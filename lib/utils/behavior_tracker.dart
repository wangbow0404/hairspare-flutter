import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_behavior.dart';

/// 챌린지 사용자 행동 추적 유틸리티
class BehaviorTracker {
  static const String _storageKey = 'challenge_behaviors';

  /// 사용자 행동 데이터를 SharedPreferences에 저장
  static Future<void> saveBehavior(UserBehavior behavior) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getUserBehaviors();
      
      // 기존 데이터에서 같은 challengeId 찾기
      final index = existing.indexWhere((b) => b.challengeId == behavior.challengeId);
      
      if (index >= 0) {
        // 기존 데이터 업데이트
        existing[index] = behavior;
      } else {
        // 새 데이터 추가
        existing.add(behavior);
      }
      
      // JSON으로 변환하여 저장
      final jsonList = existing.map((b) => b.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (error) {
      debugPrint('Failed to save behavior: $error');
    }
  }

  /// 저장된 사용자 행동 데이터 조회
  static Future<List<UserBehavior>> getUserBehaviors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      
      if (data == null || data.isEmpty) return [];
      
      final jsonList = jsonDecode(data) as List<dynamic>;
      return jsonList.map((json) => UserBehavior.fromJson(json as Map<String, dynamic>)).toList();
    } catch (error) {
      debugPrint('Failed to get behaviors: $error');
      return [];
    }
  }

  /// 특정 챌린지의 행동 데이터 조회
  static Future<UserBehavior?> getBehaviorByChallengeId(String challengeId) async {
    final behaviors = await getUserBehaviors();
    try {
      return behaviors.firstWhere((b) => b.challengeId == challengeId);
    } catch (e) {
      return null;
    }
  }

  /// 시청 시간 추적 (비디오 timeupdate 이벤트에서 호출)
  static Future<void> trackWatchTime(
    String challengeId,
    double currentTime,
    double duration,
  ) async {
    final watchPercentage = duration > 0 ? (currentTime / duration) * 100.0 : 0.0;
    
    final existing = await getBehaviorByChallengeId(challengeId);
    final behavior = UserBehavior(
      challengeId: challengeId,
      watchTime: currentTime,
      watchPercentage: watchPercentage,
      isLiked: existing?.isLiked ?? false,
      isCommented: existing?.isCommented ?? false,
      isShared: existing?.isShared ?? false,
      watchedAt: existing?.watchedAt ?? DateTime.now(),
    );
    
    await saveBehavior(behavior);
  }

  /// 상호작용 추적 (좋아요, 댓글, 공유)
  static Future<void> trackInteraction(
    String challengeId,
    String type, // 'like', 'comment', 'share'
    bool value,
  ) async {
    final existing = await getBehaviorByChallengeId(challengeId);
    final behavior = UserBehavior(
      challengeId: challengeId,
      watchTime: existing?.watchTime ?? 0,
      watchPercentage: existing?.watchPercentage ?? 0,
      isLiked: type == 'like' ? value : (existing?.isLiked ?? false),
      isCommented: type == 'comment' ? value : (existing?.isCommented ?? false),
      isShared: type == 'share' ? value : (existing?.isShared ?? false),
      watchedAt: existing?.watchedAt ?? DateTime.now(),
    );
    
    await saveBehavior(behavior);
  }

  /// 행동 데이터 초기화
  static Future<void> clearBehaviors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (error) {
      debugPrint('Failed to clear behaviors: $error');
    }
  }
}
