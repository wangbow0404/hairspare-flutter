# 관리자 페이지 기능 플랜 (ADMIN PANEL FEATURE PLAN)

> **갈래 1 / 2** — 기능·데이터·API 명세. 디자인은 `STITCH_ADMIN_PANEL_BRIEF.md` (갈래 2) 참고.
> **모듈 ID(M0~M18)** 는 두 문서가 공유 — 크로스체크용.
> **작성 기준:** 코드 전수 점검 (`lib/screens/**`, `lib/services/**`, `lib/models/**`, `lib/mocks/**`, `lib/core/router/**`).
> **상태 표기:** 🟢 기존 read 존재 → write 디벨롭 / 🆕 완전 신규

---

## 0. 현황 진단 (코드 점검 결과)

### 0.1 이미 존재하는 것 (재사용·확장 대상)

| 자산 | 위치 | 현재 상태 |
|------|------|-----------|
| `AdminLayout` (사이드바+헤더, 모바일 drawer) | `lib/widgets/admin_layout.dart` | 사이드바 7항목 평면 구조, 768px 반응형 |
| `AdminService` | `lib/services/admin_service.dart` | **전부 `GET`** — mutation 0건, `if (ApiConfig.useMockData)` 폴백 |
| `MockAdminData` | `lib/mocks/mock_admin_data.dart` | 대시보드/회원/공고/결제/에너지/스케줄/노쇼 시드 |
| 기존 화면 10종 | `lib/screens/admin/*.dart` | 대시보드·회원(목록+상세)·공고(목록+상세)·결제(목록+상세)·에너지·노쇼·체크인 |
| 라우트 | `lib/core/router/app_routes.dart` (L130~141) | `/admin`, `/admin/users(/:id)`, `/admin/jobs(/:id)`, `/admin/payments(/:id)`, `/admin/energy`, `/admin/noshow`, `/admin/checkin` |
| 권한 게이트 | `lib/core/router/auth_redirect.dart` | `/admin/*` → `UserRole.admin` 외 홈 리다이렉트 |
| 색상 토큰 | `lib/theme/app_theme.dart` (L102~130) | `adminPurple50/100/200`, `adminPink50`, `adminBackgroundGradient` |

### 0.2 결정적 한계

- **모든 admin 기능이 조회 전용.** 제재·환불·수동지급·승인/반려·설정변경 등 **mutation API가 0건.**
- 대시보드 활동피드 "전체보기" 버튼은 `onPressed: () {}` (미연결).
- 노쇼/체크인은 목록만 있고 **제재 실행·개입 불가.**

### 0.3 admin이 전혀 다루지 못하는 사용자 도메인 (신규 필요)

교육(Education), 공간대여(SpaceRental/Booking), 모델매칭(HairModel/MatchLike/quota), 챌린지·콘텐츠(Challenge/Comment), 채팅·연락처제재(Chat/ContactViolation), 포인트·미션(Point/Mission), 구독(Subscription), 인증심사(Verification queue), 알림발송(Notification broadcast), 레퍼런스데이터(Region/ShopTier/필터태그/미션정의), 신고/제재 케이스.

### 0.4 하드코딩된 비즈니스 상수 (M15 설정화면 대상 → §M15 표 참조)

가격(에너지 패키지·급구 수수료·구독·보증금), 쿼터(모델 매칭 3회·샵 등급별 공고수), 제재정책(연락처 3스트라이크·취소 30일3회→7일정지), 랭킹(공고 인기 top10·가중치) 등.

---

## 1. 모듈 분류 (크로스체크 기준 ID)

### 🟢 기존 read 존재 → write 디벨롭

- **M0** 대시보드 확장
- **M1** 회원관리 + 쓰기
- **M3** 공고관리 + 쓰기
- **M4** 스케줄·체크인 + 개입
- **M8** 결제관리 + 쓰기
- **M9** 에너지관리 + 쓰기

### 🆕 완전 신규

- **M2** 인증 심사 큐
- **M5** 모델매칭 관리
- **M6** 공간대여 관리
- **M7** 교육관리
- **M10** 포인트/미션 관리
- **M11** 구독관리
- **M12** 신고/제재 케이스 통합
- **M13** 연락처위반·노쇼 제재 정책 실행
- **M14** 콘텐츠 모더레이션
- **M15** 비즈니스 설정
- **M16** 알림 발송/템플릿
- **M17** 레퍼런스 데이터
- **M18** 감사로그 (admin action audit)

---

## 2. 우선순위 (위험도·빈도 기준)

| 단계 | 모듈 | 근거 |
|------|------|------|
| **P0** 운영 필수 | M18, M1, M12, M13, M8, M9, M0 | 제재·환불·감사 없이는 운영 불가 |
| **P1** 도메인 공백 | M2, M3(write), M4(개입), M6, M7, M14 | 사용자 기능 있으나 admin 부재 |
| **P2** 설정·고도화 | M15, M5, M10, M11, M16, M17 | 설정화·고도화 |

> **M18 감사로그는 최우선.** 모든 mutation 모듈(M1/M8/M9/M12/M13/M14/M15…)이 M18에 기록을 남기는 것을 전제로 하므로 P0 선두에서 스키마 확정.

---

## 3. 표준 8-체크리스트 (모든 모듈 공통 — 빈틈 방지)

각 모듈은 아래 8항목을 **모두** 채워야 완료로 간주:

1. **라우트** — `AppRoutes` 상수 + `app_router.dart`/`shell` 등록 + `auth_redirect` admin 게이트 확인
2. **서비스 메서드** — `AdminService`에 GET + mutation, 각 메서드 `if (ApiConfig.useMockData)` 폴백 + `try/catch` `ErrorHandler`
3. **Mock 시드** — `MockAdminData` 확장 (목록·상세·mutation 시뮬레이션)
4. **목록 화면** — 필터바 + 테이블/카드 (`admin_*_screen.dart` 패턴, `LayoutBuilder` 768px 반응형)
5. **상세 화면** — 세그먼트 정보 + 액션 버튼 영역
6. **액션/다이얼로그** — 제재·환불·승인·설정 확인 모달 (사유 입력 필수)
7. **사이드바 등록** — `AdminLayout._navItems` (그룹 §5 기준)
8. **서버 API 계약 + 권한가드 + 감사로그** — 서버 엔드포인트 정의, JWT+admin role 가드, M18 기록

---

## 4. 모듈 상세 명세

> 표기: `GET` = 조회, `MUT` = mutation(서버 권위 필수). 모든 MUT은 M18 감사로그 기록.

### M0 — 대시보드 확장 🟢

- **현재:** `admin_dashboard_screen.dart` — KPI 6카드(회원/공고/결제/체크인/에너지/노쇼), 역할별 회원, 활동피드(5초 폴링).
- **추가 데이터:** 신규 도메인 KPI — 대기 인증건수(M2), 미처리 신고건수(M12), 대기 공간예약(M6), 대기 교육승인(M7), 오늘 모델매칭수(M5).
- **서비스:** `getDashboardStats` 확장(신규 카운트 필드), `getRecentActivities` "전체보기" → M18 감사로그 또는 활동 전체 화면 연결.
- **라우트:** `/admin` (기존).
- **액션:** KPI 카드 탭 → 해당 모듈 목록 이동(기존 패턴), 대기성 KPI는 빨강 강조.
- **8-체크리스트:** 라우트✔(기존)/서비스(stats 필드 추가)/mock(카운트 추가)/목록(대시보드)/상세N·A/액션(카드 탭)/사이드바✔/API(`GET /api/admin/stats` 확장).

### M1 — 회원관리 + 쓰기 🟢

- **현재:** `admin_users_screen.dart`+`admin_user_detail_screen.dart`, `getUsers`/`getUserDetail`.
- **엔티티:** `User`(role/spareSubtype/OAuth accounts/`_count`/energyWallet), 참조 `SpareProfile`·`ShopSignupProfile`.
- **추가 MUT:**
  - `suspendUser(userId, reason, untilDate?)` / `unsuspendUser`
  - `changeUserRole(userId, role)` (신중 — 확인 2단계)
  - `forceDeleteUser(userId, reason)`
  - `adjustEnergy(userId, delta, reason)` → M9 연동
  - `adjustPoints(userId, delta, reason)` → M10 연동
  - `resetPassword(userId)` (임시발급)
- **API:** `PATCH /api/admin/users/:id/suspend|role`, `DELETE /api/admin/users/:id`, `POST /api/admin/users/:id/energy|points`.
- **상세 탭:** 기본정보 / 활동(공고·지원·스케줄) / 지갑(에너지·포인트) / 제재이력(M18 연동) / 인증상태(M2 연동).

### M2 — 인증 심사 큐 🆕

- **엔티티:** `ShopBusinessVerificationSnapshot`(status: not_started/pending/approved/rejected), `BusinessRegistrationOcrResult`, `BusinessRegistrationValidation`, 신원/대리인 인증.
- **서비스(신규):** `getVerificationQueue({type, status})`, `getVerificationDetail(id)`, `approveVerification(id)`, `rejectVerification(id, reason)`.
- **API:** `GET /api/admin/verifications`, `GET .../:id`, `POST .../:id/approve|reject`.
- **라우트:** `/admin/verifications(/:id)`.
- **목록:** 사업자/신원/대리인 탭 + 상태 필터(대기 우선). **상세:** OCR 원본·NTS 결과·첨부 이미지 뷰 + 승인/반려(사유) 버튼.
- **연동:** 승인 시 해당 User 인증플래그 갱신(M1), 반려사유는 사용자에게 알림(M16).

### M3 — 공고관리 + 쓰기 🟢

- **현재:** `admin_jobs_screen.dart`+`admin_job_detail_screen.dart`, `getJobs`/`getJobDetail`.
- **엔티티:** `Job`(status: published/closed/draft/scheduled, isHidden/isUrgent/isPremium/energy/ownerId).
- **추가 MUT:** `hideJob`/`unhideJob`, `forceCloseJob(reason)`, `deleteJob(reason)`, `toggleUrgent`/`togglePremium`(부정 사용 교정), `transferOrFlag`(분쟁표시).
- **API:** `PATCH /api/admin/jobs/:id/hide|close|urgent|premium`, `DELETE /api/admin/jobs/:id`.
- **상세:** 공고 원본 + 지원자 수/조회수(`JobPopularityMetrics`) + 소유 샵 링크(M1) + 액션.

### M4 — 스케줄·체크인 + 개입 🟢

- **현재:** `admin_checkin_screen.dart`, `getSchedules`(404→빈목록).
- **엔티티:** `Schedule`(status: scheduled/proposed/completed/cancelled, checkIn/Out).
- **추가 MUT:** `forceCompleteSchedule`, `forceCancelSchedule(reason)`, `markNoShow(scheduleId, party)` → M13 제재 연동, `adjustCheckTime`.
- **API:** `GET /api/admin/schedules`(서버 미구현 상태 — 정식화), `POST /api/admin/schedules/:id/complete|cancel|noshow`.
- **연동:** 노쇼 처리 → M13 정책 적용 + `SpareProfile.noShowCount` 증가 + 에너지 forfeit(M9).

### M5 — 모델매칭 관리 🆕

- **엔티티:** `HairModel`, `MatchLike`(pending/matched/declined), `ModelDesignerMatch`, `ModelMatchPreference`, 일일쿼터(`dailyMatchLimit=3`).
- **서비스(신규):** `getMatchLikes({status})`, `getHairModels`, `getMatchDetail(id)`, `forceCancelMatch(chatId, reason)`, `setDailyQuota(value)`(→M15), `flagModelProfile(id)`.
- **API:** `GET /api/admin/matches`, `GET /api/admin/hair-models`, `POST /api/admin/matches/:id/cancel`.
- **목록:** 좋아요/매칭 상태별 + 모델 프로필 목록. **상세:** 매칭 양측·생성된 채팅·취소이력.

### M6 — 공간대여 관리 🆕

- **엔티티:** `SpaceRental`(status: available/booked/unavailable, isHidden, operatingSchedule), `SpaceBooking`(pending/confirmed/inProgress/completed/cancelled).
- **서비스(신규):** `getSpaceRentals({status})`, `getSpaceBookings({status})`, `getSpaceDetail(id)`, `hideSpace`/`unhideSpace`, `forceCancelBooking(reason)`, `resolveBookingDispute(id, decision)`.
- **API:** `GET /api/admin/spaces`, `GET /api/admin/space-bookings`, `PATCH /api/admin/spaces/:id/hide`, `POST /api/admin/space-bookings/:id/cancel`.
- **목록:** 공간 목록 + 예약 큐(대기 강조). **상세:** 공간정보·예약내역·리뷰·분쟁처리.

### M7 — 교육관리 🆕

- **엔티티:** `Education`(category/deadline/maxApplicants/energyCost/isOnline), `EducationEnrollment`(energyPaid).
- **서비스(신규):** `getEducations({status})`, `getEnrollments({educationId})`, `getEducationDetail(id)`, `hideEducation`, `deleteEducation(reason)`, `refundEnrollment(id, reason)`(에너지 환원→M9).
- **API:** `GET /api/admin/educations`, `GET /api/admin/enrollments`, `PATCH /api/admin/educations/:id/hide`, `POST /api/admin/enrollments/:id/refund`.
- **상세:** 교육 원본·커리큘럼·수강자 목록·환불 액션.

### M8 — 결제관리 + 쓰기 🟢

- **현재:** `admin_payments_screen.dart`+`admin_payment_detail_screen.dart`, `getPayments`/`getPaymentDetail`.
- **엔티티:** `Payment`(type: energy_purchase/subscription/urgent_job/premium_job/chat, status: success/completed).
- **추가 MUT:** `refundPayment(id, amount, reason)`(전액/부분), `changePaymentStatus(id, status)`, `issueReceipt(id)`.
- **API:** `POST /api/admin/payments/:id/refund`, `PATCH /api/admin/payments/:id/status`.
- **연동:** 환불 시 연결 자원 회수(에너지 차감 M9 / 급구노출 해제 M3).

### M9 — 에너지관리 + 쓰기 🟢

- **현재:** `admin_energy_screen.dart`, `getEnergyTransactions`.
- **엔티티:** `EnergyTransaction`(type: purchase/spend/lock/forfeit), 지갑 잔액.
- **추가 MUT:** `grantEnergy(userId, amount, reason)`(수동지급), `deductEnergy`, `releaseLock(txId)`/`forceForfeit(txId)`(분쟁 해소).
- **API:** `POST /api/admin/energy/grant|deduct`, `PATCH /api/admin/energy/:txId/release|forfeit`.
- **연동:** M1/M4/M7/M8에서 호출되는 공용 에너지 조정 진입점.

### M10 — 포인트/미션 관리 🆕

- **엔티티:** `PointTransaction`(earn/spend), 미션 정의(`MISSIONS_AND_REWARDS_V1.md`: daily/simple/participation/purchase/rewarded_ad).
- **서비스(신규):** `getPointTransactions({userId,type})`, `grantPoints`/`deductPoints`, `getMissions`/`upsertMission`/`toggleMission`(→M17), `detectPointAbuse`(어뷰징 룰).
- **API:** `GET /api/admin/points`, `POST /api/admin/points/grant|deduct`, `GET/POST/PATCH /api/admin/missions`.

### M11 — 구독관리 🆕

- **엔티티:** `Subscription`(userId/creatorId/isActive), `Creator`(subscriberCount/videoCount).
- **서비스(신규):** `getSubscriptions({creatorId})`, `getCreators`, `cancelSubscription(reason)`, `verifyCreator(id)`(크리에이터 인증).
- **API:** `GET /api/admin/subscriptions`, `GET /api/admin/creators`, `POST /api/admin/creators/:id/verify`.

### M12 — 신고/제재 케이스 통합 🆕 (P0)

- **엔티티:** `ContactViolationResult`/`ContactViolationOutcome`(attemptRecorded/chatDeleted/applicationCancelled/shopDailyPenalty/shopAccountTerminated), 신고(현재 "준비중" 플레이스홀더 — 신규 정의), `Chat`/`Message` 감사.
- **서비스(신규):** `getReports({status})`, `getCaseDetail(id)`, `assignCase`, `resolveCase(id, action, reason)`, `getChatTranscript(chatId)`(감사용).
- **API:** `GET /api/admin/reports`, `GET .../:id`, `POST .../:id/resolve`, `GET /api/admin/chats/:id/transcript`.
- **워크플로:** 접수 → 검토(채팅 로그·증거) → 조치(경고/정지/탈퇴 → M1·M13) → 종결. 모든 조치 M18 기록.
- **신고 진입점 신설 필요:** 현재 앱은 `challenge_more_options_sheet.dart` "신고하기"가 "준비중" — 사용자측 신고 API와 함께 정의.

### M13 — 연락처위반·노쇼 제재 정책 실행 🆕 (P0)

- **정책 상수(현재 하드코딩):**
  - `ContactViolationPolicy`: `maxAttemptsPerChat=3`, `shopPenaltyDays=1`, `maxShopRoomPenaltiesBeforeBan=3`
  - `ScheduleCancellationPolicy`: `shopUnilateralCancelLimit30d=3`, `shopJobPostingSuspensionDays=7`, 스페어 취소 시 에너지 forfeit
  - 노쇼: `SpareProfile.noShowCount` (자동 페널티 상수 미정 — 신규)
- **서비스(신규):** `getSanctionCases`, `applySanction(userId, type, reason, duration)`, `liftSanction(id, reason)`, `getViolationHistory(userId)`.
- **API:** `GET /api/admin/sanctions`, `POST /api/admin/sanctions`, `DELETE /api/admin/sanctions/:id`.
- **정책값은 M15에서 설정** — 본 모듈은 실행/이력. 블랙리스트(`MockAuthData.blacklistedBusinessIdentifiers`) 관리 포함.

### M14 — 콘텐츠 모더레이션 🆕

- **엔티티:** `Challenge`(video feed), `MyChallenge`, `ChallengeComment`(threaded), `ChallengeProfile`, `UserBehavior`.
- **서비스(신규):** `getChallenges({flagged})`, `getComments({challengeId})`, `hideChallenge`/`deleteChallenge(reason)`, `hideComment`/`deleteComment`, `setFeatured(id, bool)`.
- **API:** `GET /api/admin/challenges|comments`, `PATCH .../hide|feature`, `DELETE .../:id`.
- **목록:** 신고/플래그 우선 + 피처드 관리. **상세:** 영상·댓글 트리·작성자(M1).

### M15 — 비즈니스 설정 🆕 (config화)

설정 항목 일람 (현재 하드코딩 → 서버 config 이전 권장, MVP는 mock):

| 그룹 | 항목 | 현재값 | 출처 파일 |
|------|------|--------|-----------|
| 경제·가격 | 에너지 단가(P) | `kEnergyPointCostPerUnit=1000` | `energy_purchase_pricing.dart` |
| | 에너지 패키지 | 1/3/5, ₩9900/27000/39000 | `energy_purchase_pricing.dart` |
| | 급구 수수료 | `kShopUrgentJobListingFee=5000` | `job_urgent_payment_screen.dart` |
| | 구독료 | ₩99,000/월 | `shop/payment_screen.dart` |
| | 프리미엄 공고 | ₩5,000 | `shop/payment_screen.dart` |
| | 채팅 애드온 | ₩2,000 | `shop/payment_screen.dart` |
| | 모델 보증금 | ₩30,000 | `mock_model_home_data.dart` |
| | 공고 에너지 공식 | `amount ~/ 1000` | `job_service.dart` |
| | 교육 energyCost↔KRW | TBD | `education_service.dart` |
| 쿼터·한도 | 모델 일일 매칭 | 3 | `mock_model_match_data.dart` |
| | 샵 등급별 공고수 | 5/10/20/999 | `shop_tier.dart` |
| | 등급 임계값 | schedules·thumbs-up | `shop_tier.dart` |
| 제재정책 | 연락처 스트라이크 | 3 | `contact_violation_policy.dart` |
| | 샵 1일 정지 / 3룸→탈퇴 | 1 / 3 | `contact_violation_policy.dart` |
| | 취소 30일3회→7일정지 | 3 / 7 | `schedule_cancellation_policy.dart` |
| 랭킹·노출 | 공고 인기 top N | 10 | `job_popularity.dart` |
| | 신규 보너스 윈도우 | 72h | `job_popularity.dart` |
| 공간 | 최소 예약시간 / 예약창 | 1h / 30일 | `space_booking_rules.dart` |

- **서비스(신규):** `getConfig(group)`, `updateConfig(group, payload)`.
- **API:** `GET /api/admin/config/:group`, `PUT /api/admin/config/:group`.
- **상세는 §config-inventory(별도 절) 참조.**

### M16 — 알림 발송/템플릿 🆕

- **엔티티:** `AppNotification`(type별), `NotificationSettings`.
- **서비스(신규):** `broadcastNotification({audience, title, body, deeplink})`, `getTemplates`/`upsertTemplate`, `getSendHistory`.
- **API:** `POST /api/admin/notifications/broadcast`, `GET/POST /api/admin/notification-templates`.
- **audience:** 전체/역할별(shop·spare·model)/세그먼트(미인증·휴면 등). 발송 M18 기록.

### M17 — 레퍼런스 데이터 🆕

- **엔티티:** `Region`(province/city/district 계층), `ShopTier` 임계값, 매칭필터 태그(`ModelMatchOptions`·`ProfessionalSpecialtyOptions`), 미션정의(M10), 교육 카테고리.
- **서비스(신규):** CRUD `getRegions`/`upsertRegion`, `getTiers`/`updateTier`, `getMatchTags`/`upsertMatchTag`, 카테고리 CRUD.
- **API:** `GET/POST/PATCH/DELETE /api/admin/regions|tiers|match-tags|categories`.

### M18 — 감사로그 (admin action audit) 🆕 (P0 선두)

- **목적:** 모든 mutation의 누가·언제·무엇을·사유 추적. M1/M4/M8/M9/M12/M13/M14/M15/M16 등 전 MUT의 전제.
- **스키마(신규 `AdminAuditLog`):**
  - `id`, `adminId`, `adminName`, `action`(enum: suspend_user/refund_payment/grant_energy/approve_verification/resolve_case/apply_sanction/update_config/broadcast/...), `targetType`(user/job/payment/...), `targetId`, `reason`, `beforeValue?`, `afterValue?`, `createdAt`, `ip?`.
- **서비스(신규):** `getAuditLogs({admin,action,target,dateRange})`, (서버측 기록은 각 MUT 처리 시 자동).
- **API:** `GET /api/admin/audit-logs`. (기록은 서버가 각 mutation 트랜잭션 내에서 생성)
- **기록지점:** 각 MUT 메서드 성공 직후 서버가 자동 append. 클라는 조회만.

---

## 5. 사이드바 정보구조 재설계 (그룹화) → `sidebar-ir` 절 상세

7항목 평면 → 7그룹. `AdminLayout._navItems` 를 그룹 헤더 + 하위 항목 구조로 확장 (상세는 §6).

| 그룹 | 모듈 | 라우트 |
|------|------|--------|
| 대시보드 | M0 | `/admin` |
| 회원·인증 | M1, M2 | `/admin/users`, `/admin/verifications` |
| 거래·매칭 | M3, M4, M5, M6, M7 | `/admin/jobs`, `/admin/checkin`, `/admin/matches`, `/admin/spaces`, `/admin/educations` |
| 경제·포인트 | M8, M9, M10, M11 | `/admin/payments`, `/admin/energy`, `/admin/points`, `/admin/subscriptions` |
| 신뢰·안전 | M12, M13, M14 | `/admin/reports`, `/admin/sanctions`, `/admin/content` |
| 운영설정 | M15, M16, M17 | `/admin/config`, `/admin/notifications`, `/admin/reference` |
| 감사 | M18 | `/admin/audit-logs` |

> 노쇼(`/admin/noshow`)는 M4/M13으로 흡수(스케줄 개입 + 제재 이력)하거나 신뢰·안전 그룹 하위 유지.

---

## 6. 아키텍처·보안 원칙

- **패턴 100% 계승:** `AdminLayout` + `AdminService`(mock 폴백) + 목록→상세 2단계 + `AppTheme.admin*` 토큰 + `LayoutBuilder` 768px 반응형 + `ErrorHandler`.
- **MVVM:** 화면→ViewModel(Provider/ChangeNotifier)→`AdminService`. `BuildContext`는 VM/Service에 전달 금지. 네비는 `appRouter`/`context.go`.
- **보안룰(`security-auth-and-secrets.mdc`) 준수:**
  - 모든 mutation은 **서버 권위**(JWT + admin role 검증). 클라 검증은 UX용.
  - 가격·제재정책 변경(M15)은 서버 config로. 클라 상수는 MVP 시뮬레이션·문서일 뿐.
  - 비밀키·운영 URL 커밋 금지.
- **MVP 동작:** `if (ApiConfig.useMockData)` → `MockAdminData` 시뮬레이션 + 서버 API 계약 병행 표기. 릴리스에서 mock 강제 off.
- **감사(M18):** 모든 MUT 성공 시 서버 자동 기록. 사유(reason) 입력 필수.

---

## 7. 구현 순서 (승인 후)

1. **M18 스키마 확정** (감사로그 — 모든 MUT 전제)
2. **P0:** M1(write) → M8(환불) → M9(에너지조정) → M12(신고/케이스) → M13(제재실행) → M0(대시보드 KPI)
3. **P1:** M2(인증심사) → M3(write) → M4(개입) → M6 → M7 → M14
4. **P2:** M15(설정) → M5 → M10 → M11 → M16 → M17

각 모듈은 §3 8-체크리스트 완수로 "완료" 판정.

---

## 8. 신규 추가 산출물 요약 (코드 작업 시)

- 라우트 상수(`AppRoutes`): `adminVerifications`, `adminMatches`, `adminSpaces`, `adminEducations`, `adminPoints`, `adminSubscriptions`, `adminReports`, `adminSanctions`, `adminContent`, `adminConfig`, `adminNotifications`, `adminReference`, `adminAuditLogs` (+ detail variants).
- 화면 파일: `lib/screens/admin/admin_{verifications|matches|spaces|educations|points|subscriptions|reports|sanctions|content|config|notifications|reference|audit_logs}_screen.dart` (+ detail).
- 서비스: `AdminService` 메서드 대폭 확장 (각 모듈 GET+MUT).
- Mock: `MockAdminData` 시드 확장.
- 모델: `AdminAuditLog`, `AdminSanction`, `AdminReport`, `AdminConfig` (신규).
- 위젯: 공통 `AdminActionDialog`(사유입력), `AdminFilterBar`, `AdminDataTable`(반응형).
