/// 에너지 구매 가격 정책 (MVP mock — **운영 확정 전 예시**).
///
/// 상세: docs/yoram/ENERGY_PURCHASE_PRICING.md

/// 1회 구매·패키지당 에너지 상한 (개).
const int kMaxEnergyPurchaseAmount = 5;

/// 판매 패키지 구성 (개). 1·3·5만 제공, 그 외 수량 없음.
const List<int> kEnergyPurchasePackageAmounts = [1, 3, 5];

/// `true`이면 구매·결제 화면에 「예시 금액」 안내를 노출한다.
/// 정식 가격 확정 후 `false`로 전환.
const bool kEnergyPurchasePricingIsProvisional = true;

/// UI에 노출하는 예시 금액 안내 문구.
const String kEnergyPurchaseProvisionalNotice =
    '표시된 카드·포인트 금액은 예시이며, 정식 서비스 전에 확정·변경될 수 있습니다.';

/// 포인트 환율 (TBD) — 1에너지당 차감 포인트. **예시값.**
const int kEnergyPointCostPerUnit = 1000;

int energyPointCostForPackage(int energyAmount) =>
    energyAmount * kEnergyPointCostPerUnit;

/// 구매 수량이 허용 패키지(1·3·5, 최대 5)인지 검증. 위반 시 [ArgumentError].
void assertValidEnergyPurchaseAmount(int energyAmount) {
  if (energyAmount < 1 || energyAmount > kMaxEnergyPurchaseAmount) {
    throw ArgumentError(
      '에너지는 1~$kMaxEnergyPurchaseAmount개까지만 구매할 수 있습니다. (요청: $energyAmount개)',
    );
  }
  if (!kEnergyPurchasePackageAmounts.contains(energyAmount)) {
    throw ArgumentError(
      '에너지 패키지는 ${kEnergyPurchasePackageAmounts.join('·')}개만 제공합니다. (요청: $energyAmount개)',
    );
  }
}

/// 카드 결제 패키지 (TBD) — 원화 가격은 **mock 예시**.
class EnergyPurchasePackage {
  const EnergyPurchasePackage({
    required this.id,
    required this.energyAmount,
    required this.cashPriceKrw,
    this.popular = false,
  });

  final String id;
  final int energyAmount;

  /// 원화 결제 예시 가격 (₩). 운영 확정 전.
  final int cashPriceKrw;
  final bool popular;

  int get pointCost => energyPointCostForPackage(energyAmount);
}

/// 에너지 패키지 mock 목록 (TBD — 패키지 구성·단가 모두 예시).
const List<EnergyPurchasePackage> kEnergyPurchasePackagesExample = [
  EnergyPurchasePackage(id: '1', energyAmount: 1, cashPriceKrw: 9900),
  EnergyPurchasePackage(
    id: '3',
    energyAmount: 3,
    cashPriceKrw: 27000,
    popular: true,
  ),
  EnergyPurchasePackage(id: '5', energyAmount: 5, cashPriceKrw: 39000),
];
