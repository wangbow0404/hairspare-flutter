/// 샵 운영 유형 — 대표 직접 vs 대리인.
enum ShopOperatorType {
  owner,
  proxy,
}

ShopOperatorType shopOperatorTypeFromJson(Object? json) {
  if (json == null) return ShopOperatorType.owner;
  final value = json.toString();
  for (final type in ShopOperatorType.values) {
    if (type.name == value) return type;
  }
  return ShopOperatorType.owner;
}

Object shopOperatorTypeToJson(ShopOperatorType type) => type.name;

extension ShopOperatorTypeX on ShopOperatorType {
  String get label => switch (this) {
        ShopOperatorType.owner => '대표 직접 운영',
        ShopOperatorType.proxy => '대리인 운영',
      };

  String get description => switch (this) {
        ShopOperatorType.owner => '사업자등록증 대표자 본인이 가입합니다',
        ShopOperatorType.proxy => '점장·매니저 등 대리인이 운영합니다',
      };
}

/// 샵 가입 시 프로필 payload.
class ShopSignupProfile {
  const ShopSignupProfile({
    required this.salonName,
    required this.representativeName,
    required this.region,
    this.regionId,
    required this.operatorType,
    this.proxyName,
    this.proxyRelation,
    this.proxyPhone,
  });

  final String salonName;
  final String representativeName;
  final String region;
  final String? regionId;
  final ShopOperatorType operatorType;
  final String? proxyName;
  final String? proxyRelation;
  final String? proxyPhone;

  Map<String, dynamic> toJson() => {
        'salonName': salonName,
        'representativeName': representativeName,
        'region': region,
        if (regionId != null) 'regionId': regionId,
        'operatorType': operatorType.name,
        if (operatorType == ShopOperatorType.proxy) ...{
          if (proxyName != null) 'proxyName': proxyName,
          if (proxyRelation != null) 'proxyRelation': proxyRelation,
          if (proxyPhone != null) 'proxyPhone': proxyPhone,
        },
      };
}
