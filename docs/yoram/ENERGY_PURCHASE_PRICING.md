# 에너지 구매 · 포인트 결제 가격 (TBD)

> **상태: 미확정** — 아래 금액·패키지·환율은 MVP mock **예시**입니다.  
> 정식 런칭 전 운영·사업팀과 별도 확정 예정.

## 코드 위치

| 항목 | 파일 |
|------|------|
| 예시 플래그 `kEnergyPurchasePricingIsProvisional` | `lib/utils/energy_purchase_pricing.dart` |
| 카드 패키지 (원화) | `kEnergyPurchasePackagesExample` |
| 포인트 환율 | `kEnergyPointCostPerUnit` (현재 예시: 1에너지 = 1,000P) |
| 구매 UI | `lib/screens/spare/energy_purchase_screen.dart` |
| 결제 UI | `lib/screens/spare/energy_purchase_checkout_screen.dart` |

## 패키지 정책

- **판매 단위:** 1개 · 3개 · 5개 패키지만 제공 (`kEnergyPurchasePackageAmounts`)
- **1회 구매 상한:** 최대 **5개** (`kMaxEnergyPurchaseAmount`)
- 10개·50개 등 대량 패키지는 **제공하지 않음**

## 현재 예시값 (변경 가능)

| 패키지 | 에너지 | 카드 (₩) | 포인트 (P) |
|--------|--------|----------|------------|
| 1 | 1개 | 9,900 | 1,000 |
| 2 | 3개 | 27,000 | 3,000 |
| 3 | 5개 | 39,000 | 5,000 |

- 포인트 환율과 카드 가격의 **상호 관계는 아직 정하지 않음** (각각 독립 예시).
- 실 API 연동 시 **서버가 최종 금액·환율을 내려주고 검증**해야 함 (클라 mock만 신뢰 금지).

## 추후 결정 (체크리스트)

- [ ] 에너지 1개당 원화 단가 (또는 패키지별 고정가)
- [ ] 포인트 ↔ 에너지 환산율
- [ ] 패키지 구성 (1/3/5개 유지 여부, 인기 배지 기준)
- [ ] PG 수수료·부가세 반영 방식
- [ ] `kEnergyPurchasePricingIsProvisional` → `false` 및 UI 안내 제거

## 관련 문서

- 교육 `energyCost` 정책: [EDUCATION_ENERGY_PRICING.md](./EDUCATION_ENERGY_PRICING.md)
