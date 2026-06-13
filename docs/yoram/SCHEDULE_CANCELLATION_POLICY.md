# 스케줄 취소 정책

> **현재 버전:** `v2_unilateral`  
> **코드:** [`lib/utils/schedule_cancellation_policy.dart`](../lib/utils/schedule_cancellation_policy.dart)  
> **공통 플로우:** [`lib/utils/schedule_cancel_flow.dart`](../lib/utils/schedule_cancel_flow.dart)

---

## v2_unilateral (현재)

| 규칙 | 내용 |
|------|------|
| 취소 대상 | `scheduled` (확정) 상태, **근무 시작 시각 전** |
| `proposed` | 수락/거절 플로우 — 일반 취소 아님 |
| 스페어 패널티 | **예약 에너지 미환불** |
| 샵 패널티 | 공고 에너지·수수료 미환급 가능 + **30일 일방 취소 3회 → 7일 공고 등록 제한** |
| 알림 | 취소 시 상대 **채팅방 시스템 메시지** 자동 전송 |
| 집행 | **서버** 최종 검증·차감; mock·클라이언트는 동일 규칙 |

### API (연동 시)

- `POST /api/schedules/{id}/cancel`
- Body: `{ actor, cancelReason?, cancellationPolicyVersion: "v2Unilateral" }`
- `POST /api/schedules/{id}/cancel-notice` — 채팅 알림 (또는 cancel 응답에 포함)

---

## v1_strict_d1 (레거시)

- 근무 시작 **24시간 전**까지만 앷 취소 허용
- enum `ScheduleCancellationPolicyVersion.v1StrictD1` — `_evaluateV1` 분기 유지

---

## 변경 체크리스트

1. `ScheduleCancellationPolicy.activeVersion` / `evaluate`
2. `ScheduleCancelFlow` + UI 시트
3. `mock_spare_data.cancelSchedule` / `mock_shop_data` 패널티
4. 이 문서 + QA
