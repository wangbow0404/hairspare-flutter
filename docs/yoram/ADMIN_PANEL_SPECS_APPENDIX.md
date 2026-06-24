# 관리자 페이지 구현 부록 (SPECS APPENDIX)

> 구현 레벨 상세 — `ADMIN_PANEL_FEATURE_PLAN.md`(기능)·`STITCH_ADMIN_PANEL_BRIEF.md`(디자인) 보조.
> 3개 횡단 명세: **A. 사이드바 정보구조** / **B. 비즈니스 설정 인벤토리(M15)** / **C. 감사로그(M18)**.

---

## A. 사이드바 정보구조 7그룹 재설계 (sidebar-ir)

### A.1 현황

`lib/widgets/admin_layout.dart` `_navItems`는 `AdminNavItem(route,label,icon)` 7개 **평면 리스트**. 모듈이 19개로 늘면 평면 구조는 관리 불가 → **그룹 헤더 + 하위 항목** 아코디언으로 확장.

### A.2 데이터 구조 확장안

```dart
class AdminNavGroup {
  final String title;          // 그룹 헤더 (null이면 단독 항목)
  final List<AdminNavItem> items;
  const AdminNavGroup({required this.title, required this.items});
}

class AdminNavItem {
  final String route;
  final String label;
  final IconData icon;
  final String? badgeKey;      // 대기건수 매핑 키 (e.g. 'pendingVerifications')
  const AdminNavItem({required this.route, required this.label, required this.icon, this.badgeKey});
}
```

### A.3 그룹 정의 (구현 시 그대로 사용)

| 그룹 | 항목 (label · route · icon · badgeKey) |
|------|------|
| (단독) | 대시보드 · `/admin` · `dashboard` |
| 회원·인증 | 회원 관리 · `/admin/users` · `people` / 인증 심사 · `/admin/verifications` · `verified_user` · `pendingVerifications` |
| 거래·매칭 | 공고 관리 · `/admin/jobs` · `work` / 스케줄·체크인 · `/admin/checkin` · `calendar_today` / 모델 매칭 · `/admin/matches` · `favorite` / 공간 대여 · `/admin/spaces` · `meeting_room` · `pendingBookings` / 교육 관리 · `/admin/educations` · `school` · `pendingEducations` |
| 경제·포인트 | 결제 관리 · `/admin/payments` · `payment` / 에너지 관리 · `/admin/energy` · `bolt` / 포인트·미션 · `/admin/points` · `stars` / 구독 관리 · `/admin/subscriptions` · `subscriptions` |
| 신뢰·안전 | 신고/제재 케이스 · `/admin/reports` · `report` · `openReports` / 제재 실행·이력 · `/admin/sanctions` · `gavel` / 콘텐츠 모더레이션 · `/admin/content` · `video_library` · `flaggedContent` |
| 운영설정 | 비즈니스 설정 · `/admin/config` · `tune` / 알림 발송 · `/admin/notifications` · `campaign` / 레퍼런스 데이터 · `/admin/reference` · `dataset` |
| 감사 | 감사 로그 · `/admin/audit-logs` · `history` |

> 노쇼(`/admin/noshow`)는 신뢰·안전 그룹 하위로 유지하거나 M4(체크인)·M13(제재이력)에 흡수. 기존 라우트는 호환 위해 보존 권장.

### A.4 UI 동작 규칙

- 그룹 헤더: 12px `textTertiary` 캡션, 비클릭(또는 접기/펴기). 항목: 14px.
- 활성 항목: `primaryPurple500 → primaryPink` 그라데 배경 + white (기존 `_buildSidebar` 로직 재사용).
- `isActive`: `/admin`은 정확히 일치, 그 외 `startsWith(route)` (기존 규칙 유지).
- `badgeKey`: 대시보드 `getDashboardStats` 응답의 대기 카운트와 동일 키로 red pill 표시. 0이면 숨김.
- 모바일(<768): drawer 내 동일 그룹 구조, 항목 탭 시 `Navigator.pop` 후 `context.go` (기존 `_onNavItemTap`).

### A.5 라우트 등록 체크 (app_router.dart / auth_redirect.dart)

- 신규 13개 경로를 `/admin/*` 하위에 `AdminLayout` 래핑하여 등록.
- `auth_redirect.dart`의 `/admin` prefix 가드가 신규 경로 자동 커버하는지 확인(현재 prefix 기반이면 OK).

---

## B. 비즈니스 설정 인벤토리 (M15 / config-inventory)

> 현재 하드코딩 → 서버 config 이전 대상. MVP는 `MockAdminData` 시뮬레이션. 각 항목: 키 · 타입 · 현재값 · 검증 · 출처.

### B.1 경제·가격 (group: `pricing`)

| 키 | 타입 | 현재값 | 검증 | 출처 |
|----|------|--------|------|------|
| `energyPointCostPerUnit` | int(P) | 1000 | >0 | `energy_purchase_pricing.dart` |
| `energyPackages` | list<{amount,krw,points}> | [{1,9900,1000},{3,27000,3000},{5,39000,5000}] | amount>0, krw≥0 | `energy_purchase_pricing.dart` |
| `maxEnergyPurchaseAmount` | int | 5 | ≥1 | `energy_purchase_pricing.dart` |
| `urgentJobListingFee` | int(KRW) | 5000 | ≥0 | `job_urgent_payment_screen.dart` |
| `subscriptionMonthlyFee` | int(KRW) | 99000 | ≥0 | `shop/payment_screen.dart` |
| `premiumJobFee` | int(KRW) | 5000 | ≥0 | `shop/payment_screen.dart` |
| `chatAddonFee` | int(KRW) | 2000 | ≥0 | `shop/payment_screen.dart` |
| `modelDepositAmount` | int(KRW) | 30000 | ≥0 | `mock_model_home_data.dart` |
| `jobEnergyFormulaDivisor` | int | 1000 (`amount~/divisor`) | >0 | `job_service.dart` |
| `educationEnergyToKrw` | map/공식 | TBD | — | `education_service.dart` |

### B.2 쿼터·한도 (group: `quota`)

| 키 | 타입 | 현재값 | 출처 |
|----|------|--------|------|
| `modelDailyMatchLimit` | int | 3 | `mock_model_match_data.dart` |
| `shopTierMaxJobPosts` | map<tier,int> | bronze5/silver10/gold20/platinum999/vip999 | `shop_tier.dart` |
| `shopTierThresholds` | map<tier,{schedules,thumbsUp}> | (등급별 임계값) | `shop_tier.dart` |

### B.3 제재정책 (group: `sanction`)

| 키 | 타입 | 현재값 | 출처 |
|----|------|--------|------|
| `contactMaxAttemptsPerChat` | int | 3 | `contact_violation_policy.dart` |
| `shopContactPenaltyDays` | int | 1 | `contact_violation_policy.dart` |
| `maxShopRoomPenaltiesBeforeBan` | int | 3 | `contact_violation_policy.dart` |
| `shopUnilateralCancelLimit30d` | int | 3 | `schedule_cancellation_policy.dart` |
| `shopJobPostingSuspensionDays` | int | 7 | `schedule_cancellation_policy.dart` |
| `spareCancelEnergyForfeit` | bool/공식 | job.energy 몰수 | `schedule_cancellation_policy.dart` |
| `noShowPenalty` | 미정(신규) | — | (신규 정의 필요) |

### B.4 랭킹·노출 (group: `ranking`)

| 키 | 타입 | 현재값 | 출처 |
|----|------|--------|------|
| `jobPopularityTopN` | int | 10 | `job_popularity.dart` |
| `jobPopularityWeights` | map | apps×10/view×1/amount÷10000/premium+5/energy≤3+2 | `job_popularity.dart` |
| `newJobBonusWindowHours` | int | 72 | `job_popularity.dart` |

### B.5 공간 (group: `space`)

| 키 | 타입 | 현재값 | 출처 |
|----|------|--------|------|
| `spaceMinBookingHours` | int | 1 | `space_booking_rules.dart` |
| `spaceDefaultOpenClose` | {open,close} | 9~21 | `space_hourly_slot_grid.dart` |
| `spaceBookingWindowDays` | int | 30 | `space_slot_builder.dart` |

### B.6 미션 (group: `mission`, M10/M17 연계)

| 키 | 타입 | 현재값 | 출처 |
|----|------|--------|------|
| `missions` | list<{type,reward,dailyCap,active}> | daily 10P / simple 77~94P / rewarded_ad TBD | `points_screen.dart`, `MISSIONS_AND_REWARDS_V1.md` |
| `dailyAdCap` | int | 10(문서) | `MISSIONS_AND_REWARDS_V1.md` |

### B.7 서비스/저장 형태

- `AdminService.getConfig(String group)` / `updateConfig(String group, Map payload)`.
- API: `GET /api/admin/config/:group`, `PUT /api/admin/config/:group`.
- 변경 시 M18 감사로그(`update_config`, before/after) 자동 기록.

---

## C. 감사로그 (M18 / audit-log)

### C.1 목적

모든 mutation(제재·환불·지급·승인·설정변경·발송)의 **누가·언제·무엇을·왜** 추적. 운영 책임·분쟁대응의 전제.

### C.2 모델 스키마 (신규 `lib/models/admin_audit_log.dart`)

```dart
class AdminAuditLog {
  final String id;
  final String adminId;
  final String adminName;
  final String action;        // enum 문자열 (C.4)
  final String targetType;    // user|job|payment|energy|schedule|verification|
                              // match|space|booking|education|enrollment|
                              // point|subscription|report|sanction|challenge|
                              // comment|config|notification|region|tier
  final String targetId;
  final String reason;        // 필수
  final Map<String, dynamic>? beforeValue;
  final Map<String, dynamic>? afterValue;
  final DateTime createdAt;
  final String? ip;
}
```

### C.3 서비스 / API

- 조회: `AdminService.getAuditLogs({adminId, action, targetType, dateRange, page, limit})` → `GET /api/admin/audit-logs`.
- 기록: **클라가 직접 생성하지 않음.** 서버가 각 mutation 트랜잭션 내에서 자동 append (단일 진실 원천 보장).

### C.4 action enum (모듈 ↔ 기록지점 매핑)

| action | 모듈 | 기록 트리거 (MUT 성공 직후) |
|--------|------|------------------------------|
| `suspend_user` / `unsuspend_user` | M1 | 회원 정지/해제 |
| `change_user_role` | M1 | 역할 변경 |
| `delete_user` | M1 | 강제 탈퇴 |
| `grant_energy` / `deduct_energy` | M1·M9 | 에너지 수동 조정 |
| `grant_points` / `deduct_points` | M1·M10 | 포인트 조정 |
| `approve_verification` / `reject_verification` | M2 | 인증 승인/반려 |
| `hide_job` / `close_job` / `delete_job` / `toggle_job_flag` | M3 | 공고 개입 |
| `force_complete_schedule` / `force_cancel_schedule` / `mark_noshow` | M4 | 스케줄 개입 |
| `cancel_match` | M5 | 매칭 강제취소 |
| `hide_space` / `cancel_booking` / `resolve_dispute` | M6 | 공간/예약 개입 |
| `hide_education` / `delete_education` / `refund_enrollment` | M7 | 교육/수강 개입 |
| `refund_payment` / `change_payment_status` | M8 | 결제 환불/상태 |
| `release_energy_lock` / `force_forfeit` | M9 | 에너지 lock 조정 |
| `cancel_subscription` / `verify_creator` | M11 | 구독/크리에이터 |
| `resolve_case` / `assign_case` | M12 | 신고 케이스 처리 |
| `apply_sanction` / `lift_sanction` / `blacklist_add` / `blacklist_remove` | M13 | 제재 실행 |
| `hide_content` / `delete_content` / `set_featured` | M14 | 콘텐츠 모더레이션 |
| `update_config` | M15 | 설정 변경 (before/after 필수) |
| `broadcast_notification` / `upsert_template` | M16 | 알림 발송 |
| `upsert_region` / `update_tier` / `upsert_match_tag` / `upsert_mission` | M17·M10 | 레퍼런스 변경 |

### C.5 UI (감사로그 화면)

- 타임라인/테이블: 일시 · 관리자 · action 칩(색상=위험도) · 대상(type+id 링크) · 사유 · before/after 펼침.
- 필터: 관리자·action·targetType·기간. CSV 내보내기(선택). **읽기 전용.**

### C.6 불변 규칙

- 감사로그는 **수정/삭제 불가**(append-only).
- reason 미입력 mutation은 서버에서 거부 → 클라 액션 모달에서 사유 필수 검증.
