/// 모델 홈 — 받은 관심 카드.
class ModelHomeInterest {
  const ModelHomeInterest({
    required this.id,
    required this.designerName,
    required this.treatment,
    required this.region,
    this.avatarUrl,
    this.isPrimaryCta = true,
  });

  final String id;
  final String designerName;
  final String treatment;
  final String region;
  final String? avatarUrl;
  final bool isPrimaryCta;
}

/// 모델 시술 결제 유형.
enum ModelTreatmentPayment {
  /// 무료 시술 (디자이너·스텝·샵이 무료 제공).
  free,

  /// 부분유료 시술 — 예약금이 걸리는 방식.
  deposit,
}

/// 모델 홈 — 다가오는 시술 일정.
class ModelHomeUpcomingSchedule {
  const ModelHomeUpcomingSchedule({
    required this.id,
    required this.shopName,
    required this.dateTime,
    required this.treatment,
    this.paymentType = ModelTreatmentPayment.free,
    this.depositAmount = 0,
    this.depositPaid = false,
  });

  final String id;
  final String shopName;
  final DateTime dateTime;
  final String treatment;
  final ModelTreatmentPayment paymentType;
  final int depositAmount;
  final bool depositPaid;

  bool get isFree => paymentType == ModelTreatmentPayment.free;

  /// 부분유료인데 아직 예약금을 안 낸 상태.
  bool get needsDepositPayment =>
      paymentType == ModelTreatmentPayment.deposit && !depositPaid;

  ModelHomeUpcomingSchedule copyWith({bool? depositPaid}) =>
      ModelHomeUpcomingSchedule(
        id: id,
        shopName: shopName,
        dateTime: dateTime,
        treatment: treatment,
        paymentType: paymentType,
        depositAmount: depositAmount,
        depositPaid: depositPaid ?? this.depositPaid,
      );
}

/// 모델 홈 프로필 요약.
class ModelHomeProfileSummary {
  const ModelHomeProfileSummary({
    required this.name,
    required this.regionLabel,
    required this.hairLength,
    required this.intro,
    required this.completionPercent,
    required this.isIdentityVerified,
    required this.todayInterestCount,
    this.photoUrl,
    this.matchingVisible = true,
  });

  final String name;
  final String regionLabel;
  final String hairLength;
  final String intro;
  final double completionPercent;
  final bool isIdentityVerified;
  final int todayInterestCount;
  final String? photoUrl;
  final bool matchingVisible;
}
