# 교육 가격 · 에너지 표기 정책 (MVP)

## 스페어 (신청·결제)

- 참가비는 **`energyCost` (정수, 개)** 로만 표시·결제한다.
- UI 예: 「에너지 5개」
- `price`(원화) 필드는 API 호환용으로 내려올 수 있으나 **스페어 화면에 노출하지 않는다**.

## 샵 (등록·관리)

- [`CreateEducationRequest.price`](../lib/models/create_education_request.dart) — **원화(₩)** 유지.
- 샵 교육 등록·목록 UI는 기존처럼 금액 표기.

## 추후 결정 (TBD)

| 항목 | 상태 |
|------|------|
| 원화 `price` ↔ `energyCost` 환산 공식 | 미정 (서버/운영 정책) |
| 에너지 1개당 원화 단가 | 미정 |
| 샵 등록 시 energyCost 직접 입력 여부 | 미정 |

MVP mock은 `energyCost`를 데이터에 **직접 부여**한다. 자동 환산 없음.

## 서버 검증 (실 API)

- `POST /api/educations/:id/enroll` — `{ "payWith": "energy" }`
- 서버가 `energyCost`·잔액·정원·마감 검증 후 차감·enrollment 발급 (클라만 신뢰 금지).
