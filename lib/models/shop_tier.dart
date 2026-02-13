/// Shop 등급 시스템 모델
enum ShopTier {
  bronze,    // 브론즈
  silver,    // 실버
  gold,      // 골드
  platinum,  // 플레티넘
  vip,       // VIP
}

extension ShopTierExtension on ShopTier {
  /// 백엔드 tier 문자열(bronze, silver 등)을 ShopTier로 파싱
  static ShopTier parse(String? value) {
    if (value == null || value.isEmpty) return ShopTier.bronze;
    final lower = value.toLowerCase();
    switch (lower) {
      case 'bronze':
      case '브론즈':
        return ShopTier.bronze;
      case 'silver':
      case '실버':
        return ShopTier.silver;
      case 'gold':
      case '골드':
        return ShopTier.gold;
      case 'platinum':
      case '플레티넘':
      case '플래티넘':
        return ShopTier.platinum;
      case 'vip':
        return ShopTier.vip;
      default:
        return ShopTier.bronze;
    }
  }

  String get name {
    switch (this) {
      case ShopTier.bronze:
        return '브론즈';
      case ShopTier.silver:
        return '실버';
      case ShopTier.gold:
        return '골드';
      case ShopTier.platinum:
        return '플레티넘';
      case ShopTier.vip:
        return 'VIP';
    }
  }

  String get emoji {
    switch (this) {
      case ShopTier.bronze:
        return '🥉';
      case ShopTier.silver:
        return '🥈';
      case ShopTier.gold:
        return '🥇';
      case ShopTier.platinum:
        return '💎';
      case ShopTier.vip:
        return '👑';
    }
  }

  /// 등급 색상
  int get colorValue {
    switch (this) {
      case ShopTier.bronze:
        return 0xFFCD7F32; // 브론즈 색상
      case ShopTier.silver:
        return 0xFFC0C0C0; // 실버 색상
      case ShopTier.gold:
        return 0xFFFFD700; // 골드 색상
      case ShopTier.platinum:
        return 0xFFE5E4E2; // 플레티넘 색상
      case ShopTier.vip:
        return 0xFFFF1493; // VIP 핑크
    }
  }

  /// 등급별 최소 완료 스케줄 수
  int get minCompletedSchedules {
    switch (this) {
      case ShopTier.bronze:
        return 0;
      case ShopTier.silver:
        return 10;
      case ShopTier.gold:
        return 50;
      case ShopTier.platinum:
        return 200;
      case ShopTier.vip:
        return 500;
    }
  }

  /// 등급별 최소 따봉 수
  int get minThumbsUp {
    switch (this) {
      case ShopTier.bronze:
        return 0;
      case ShopTier.silver:
        return 20;
      case ShopTier.gold:
        return 100;
      case ShopTier.platinum:
        return 500;
      case ShopTier.vip:
        return 1000;
    }
  }

  /// 등급별 혜택 설명
  List<String> get benefits {
    switch (this) {
      case ShopTier.bronze:
        return [
          '기본 공고 등록 (최대 5개)',
          '기본 프로필 표시',
        ];
      case ShopTier.silver:
        return [
          '공고 상단 노출 시간 연장 (1일)',
          '공고 등록 수 증가 (10개)',
          '실버 배지 표시',
          '프로필 우선 노출',
        ];
      case ShopTier.gold:
        return [
          '공고 우선 노출',
          '공고 등록 수 증가 (20개)',
          '골드 배지 표시',
          '프로필 최우선 노출',
          '고객 지원 우선권',
        ];
      case ShopTier.platinum:
        return [
          '공고 최우선 노출',
          '무제한 공고 등록',
          '플레티넘 배지 표시',
          '프로필 최상단 노출',
          '전담 고객 지원',
          '특별 프로모션 혜택',
        ];
      case ShopTier.vip:
        return [
          '공고 최상단 고정 노출',
          '무제한 공고 등록',
          'VIP 배지 표시',
          '프로필 최상단 고정 노출',
          '24/7 전담 고객 지원',
          '독점 프로모션 혜택',
          '우선 기능 베타 테스트',
        ];
    }
  }

  /// 다음 등급까지 필요한 완료 스케줄 수
  int? getNextTierRequiredSchedules(int currentCompleted) {
    final nextTier = getNextTier();
    if (nextTier == null) return null;
    return (nextTier.minCompletedSchedules - currentCompleted).clamp(0, double.infinity).toInt();
  }

  /// 다음 등급까지 필요한 따봉 수
  int? getNextTierRequiredThumbsUp(int currentThumbsUp) {
    final nextTier = getNextTier();
    if (nextTier == null) return null;
    return (nextTier.minThumbsUp - currentThumbsUp).clamp(0, double.infinity).toInt();
  }

  /// 다음 등급 반환
  ShopTier? getNextTier() {
    switch (this) {
      case ShopTier.bronze:
        return ShopTier.silver;
      case ShopTier.silver:
        return ShopTier.gold;
      case ShopTier.gold:
        return ShopTier.platinum;
      case ShopTier.platinum:
        return ShopTier.vip;
      case ShopTier.vip:
        return null; // 최고 등급
    }
  }

  /// 등급 진행률 (0.0 ~ 1.0)
  double getProgress(int completedSchedules, int thumbsUp) {
    final nextTier = getNextTier();
    if (nextTier == null) return 1.0; // 최고 등급

    // 완료 스케줄과 따봉 중 더 빠르게 달성 가능한 기준으로 진행률 계산
    final scheduleProgress = (completedSchedules - minCompletedSchedules) /
        (nextTier.minCompletedSchedules - minCompletedSchedules);
    final thumbsUpProgress = (thumbsUp - minThumbsUp) /
        (nextTier.minThumbsUp - minThumbsUp);

    // 두 기준 중 더 높은 진행률 사용
    return (scheduleProgress > thumbsUpProgress ? scheduleProgress : thumbsUpProgress)
        .clamp(0.0, 1.0);
  }
}

/// Shop 등급 정보
class ShopTierInfo {
  final ShopTier currentTier;
  final int completedSchedules;
  final int thumbsUpReceived;
  final int maxJobPosts; // 최대 공고 등록 수
  final DateTime? tierUpdatedAt;

  ShopTierInfo({
    required this.currentTier,
    required this.completedSchedules,
    required this.thumbsUpReceived,
    required this.maxJobPosts,
    this.tierUpdatedAt,
  });

  /// 현재 등급에 맞는 최대 공고 등록 수 계산
  static int calculateMaxJobPosts(ShopTier tier) {
    switch (tier) {
      case ShopTier.bronze:
        return 5;
      case ShopTier.silver:
        return 10;
      case ShopTier.gold:
        return 20;
      case ShopTier.platinum:
      case ShopTier.vip:
        return 999; // 무제한
    }
  }

  /// 등급 계산
  static ShopTier calculateTier(int completedSchedules, int thumbsUpReceived) {
    // VIP 체크
    if (completedSchedules >= ShopTier.vip.minCompletedSchedules ||
        thumbsUpReceived >= ShopTier.vip.minThumbsUp) {
      return ShopTier.vip;
    }
    // 플레티넘 체크
    if (completedSchedules >= ShopTier.platinum.minCompletedSchedules ||
        thumbsUpReceived >= ShopTier.platinum.minThumbsUp) {
      return ShopTier.platinum;
    }
    // 골드 체크
    if (completedSchedules >= ShopTier.gold.minCompletedSchedules ||
        thumbsUpReceived >= ShopTier.gold.minThumbsUp) {
      return ShopTier.gold;
    }
    // 실버 체크
    if (completedSchedules >= ShopTier.silver.minCompletedSchedules ||
        thumbsUpReceived >= ShopTier.silver.minThumbsUp) {
      return ShopTier.silver;
    }
    // 브론즈
    return ShopTier.bronze;
  }

  factory ShopTierInfo.fromJson(Map<String, dynamic> json) {
    final completedSchedules = json['completedSchedules'] as int? ?? 0;
    final thumbsUpReceived = json['thumbsUpReceived'] as int? ?? 0;
    final tierStr = json['tier']?.toString() ?? 'bronze';
    
    ShopTier tier;
    try {
      tier = ShopTier.values.firstWhere(
        (t) => t.name == tierStr,
        orElse: () => ShopTier.bronze,
      );
    } catch (e) {
      tier = ShopTier.bronze;
    }

    // 등급 재계산 (서버 데이터가 오래된 경우)
    tier = calculateTier(completedSchedules, thumbsUpReceived);

    return ShopTierInfo(
      currentTier: tier,
      completedSchedules: completedSchedules,
      thumbsUpReceived: thumbsUpReceived,
      maxJobPosts: calculateMaxJobPosts(tier),
      tierUpdatedAt: json['tierUpdatedAt'] != null
          ? DateTime.parse(json['tierUpdatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': currentTier.name,
      'completedSchedules': completedSchedules,
      'thumbsUpReceived': thumbsUpReceived,
      'maxJobPosts': maxJobPosts,
      'tierUpdatedAt': tierUpdatedAt?.toIso8601String(),
    };
  }

  /// 다음 등급까지 진행률
  double get progressToNextTier {
    return currentTier.getProgress(completedSchedules, thumbsUpReceived);
  }

  /// 다음 등급까지 필요한 완료 스케줄 수
  int? get requiredSchedulesForNextTier {
    return currentTier.getNextTierRequiredSchedules(completedSchedules);
  }

  /// 다음 등급까지 필요한 따봉 수
  int? get requiredThumbsUpForNextTier {
    return currentTier.getNextTierRequiredThumbsUp(thumbsUpReceived);
  }
}
