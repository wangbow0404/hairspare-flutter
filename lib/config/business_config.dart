import 'package:dio/dio.dart';

import '../utils/api_config.dart';

/// 서버 비즈니스 설정 (M15) — 앱 전역 단일 진실 원천.
///
/// 기동 시 [load]로 `/api/config`를 받아 오며, 실패 시 [defaults]를 사용합니다.
abstract final class BusinessConfig {
  BusinessConfig._();

  static const Map<String, int> defaults = {
    'energyPointCostPerUnit': 1000,
    'urgentJobListingFee': 5000,
    'hipassListingFee': 5000,
    'subscriptionMonthlyFee': 99000,
    'premiumJobFee': 5000,
    'chatAddonFee': 2000,
    'modelDepositAmount': 30000,
    'jobEnergyFormulaDivisor': 1000,
    'modelDailyMatchLimit': 3,
    'maxEnergyPurchaseAmount': 5,
    'shopTierBronzeMaxJobs': 5,
    'shopTierSilverMaxJobs': 10,
    'shopTierGoldMaxJobs': 20,
    'shopTierPlatinumMaxJobs': 999,
    'contactMaxAttemptsPerChat': 3,
    'shopContactPenaltyDays': 1,
    'maxShopRoomPenaltiesBeforeBan': 3,
    'shopUnilateralCancelLimit30d': 3,
    'shopJobPostingSuspensionDays': 7,
    'lateCancelCutoffHours': 48,
    'jobPopularityTopN': 10,
    'newJobBonusWindowHours': 72,
    'jobPopularityAppWeight': 10,
    'jobPopularityViewWeight': 1,
    'jobPopularityPremiumBonus': 5,
    'jobPopularityLowEnergyBonus': 2,
    'spaceMinBookingHours': 1,
    'spaceBookingWindowDays': 30,
    'spaceDefaultOpenHour': 9,
    'spaceDefaultCloseHour': 21,
    // 2026년 고용노동부 고시 최저임금(시급). 매년 갱신 필요.
    'minimumHourlyWage': 10320,
  };

  static Map<String, int> _values = Map<String, int>.from(defaults);
  static bool _loaded = false;

  static bool get isLoaded => _loaded;

  static int _v(String key) => _values[key] ?? defaults[key] ?? 0;

  // pricing
  static int get energyPointCostPerUnit => _v('energyPointCostPerUnit');
  static int get urgentJobListingFee => _v('urgentJobListingFee');
  static int get hipassListingFee => _v('hipassListingFee');
  static int get subscriptionMonthlyFee => _v('subscriptionMonthlyFee');
  static int get premiumJobFee => _v('premiumJobFee');
  static int get chatAddonFee => _v('chatAddonFee');
  static int get modelDepositAmount => _v('modelDepositAmount');
  static int get jobEnergyFormulaDivisor => _v('jobEnergyFormulaDivisor');
  static int get minimumHourlyWage => _v('minimumHourlyWage');

  // quota
  static int get modelDailyMatchLimit => _v('modelDailyMatchLimit');
  static int get maxEnergyPurchaseAmount => _v('maxEnergyPurchaseAmount');
  static int get shopTierBronzeMaxJobs => _v('shopTierBronzeMaxJobs');
  static int get shopTierSilverMaxJobs => _v('shopTierSilverMaxJobs');
  static int get shopTierGoldMaxJobs => _v('shopTierGoldMaxJobs');
  static int get shopTierPlatinumMaxJobs => _v('shopTierPlatinumMaxJobs');

  // sanction
  static int get contactMaxAttemptsPerChat => _v('contactMaxAttemptsPerChat');
  static int get shopContactPenaltyDays => _v('shopContactPenaltyDays');
  static int get maxShopRoomPenaltiesBeforeBan =>
      _v('maxShopRoomPenaltiesBeforeBan');
  static int get shopUnilateralCancelLimit30d =>
      _v('shopUnilateralCancelLimit30d');
  static int get shopJobPostingSuspensionDays =>
      _v('shopJobPostingSuspensionDays');
  static int get lateCancelCutoffHours => _v('lateCancelCutoffHours');

  // ranking
  static int get jobPopularityTopN => _v('jobPopularityTopN');
  static int get newJobBonusWindowHours => _v('newJobBonusWindowHours');
  static int get jobPopularityAppWeight => _v('jobPopularityAppWeight');
  static int get jobPopularityViewWeight => _v('jobPopularityViewWeight');
  static int get jobPopularityPremiumBonus => _v('jobPopularityPremiumBonus');
  static int get jobPopularityLowEnergyBonus =>
      _v('jobPopularityLowEnergyBonus');

  // space
  static int get spaceMinBookingHours => _v('spaceMinBookingHours');
  static int get spaceBookingWindowDays => _v('spaceBookingWindowDays');
  static int get spaceDefaultOpenHour => _v('spaceDefaultOpenHour');
  static int get spaceDefaultCloseHour => _v('spaceDefaultCloseHour');

  static int maxJobPostsForTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'silver':
        return shopTierSilverMaxJobs;
      case 'gold':
        return shopTierGoldMaxJobs;
      case 'platinum':
      case 'vip':
        return shopTierPlatinumMaxJobs;
      case 'bronze':
      default:
        return shopTierBronzeMaxJobs;
    }
  }

  static int jobEnergyFromAmount(int amount) {
    final divisor = jobEnergyFormulaDivisor;
    return divisor > 0 ? amount ~/ divisor : amount ~/ 1000;
  }

  /// 앱 기동 시 호출. mock 모드에서는 defaults 유지.
  static Future<void> load(Dio dio) async {
    if (ApiConfig.useMockData) {
      _values = Map<String, int>.from(defaults);
      _loaded = true;
      return;
    }
    try {
      final response = await dio.get('/api/config');
      final raw = response.data['data'] ?? response.data;
      if (raw is Map) {
        final merged = Map<String, int>.from(defaults);
        for (final entry in raw.entries) {
          final key = entry.key.toString();
          final parsed = _parseInt(entry.value);
          if (parsed != null) merged[key] = parsed;
        }
        _values = merged;
      }
    } catch (_) {
      _values = Map<String, int>.from(defaults);
    }
    _loaded = true;
  }

  /// 관리자 설정 저장 후 등 — 최신 서버 값 재조회.
  static Future<void> reload(Dio dio) => load(dio);

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
