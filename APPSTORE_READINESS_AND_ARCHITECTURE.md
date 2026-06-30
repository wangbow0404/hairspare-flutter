# HairSpare 아키텍처 현황 & 앱스토어 출시 준비 문서

> **버전:** 1.2 (출시 스코프 확정)
> **작성 기준일:** 2026-06-30
> **목적:** (1) 현재 앱이 실제로 어떻게 구현·연결돼 있는지 정확히 파악하고, (2) Apple App Store / Google Play 정책에 맞춰 무엇을 고쳐야 하는지 로드맵을 세운다.
> **원칙:** 추측 금지. 모든 항목은 실제 코드/파일 경로 근거를 기반으로 작성했다. 확인되지 않은 것은 "확인 필요"로 명시한다.

---

## 문서 규약 (v1.1에서 추가)

이 문서는 **사실(Fact)과 의견(Opinion)을 구분**한다.

- **[사실]** — 코드/파일에서 직접 확인한 내용. 파일 경로 근거 있음.
- **[의견]** — Apple/Google 정책 해석, 심각도 판단, 출시 전략 등. **공식 문서와 최종 대조가 필요한 영역**이다.

정책 대비(§7) 항목은 아래 **표준 형식**으로 정리한다.

| 필드 | 의미 |
| :--- | :--- |
| **현재 상태** | 지금 코드/설정이 어떤지 (사실) |
| **근거** | 파일 경로 또는 공식 정책 링크 |
| **위험도** | Critical / High / Medium / Low (의견) |
| **권장 조치** | 실제 수정 방법 (의견) |
| **검증 여부** | ✅ 확인 완료 / ⬜ 확인 필요 |

**심각도 판단 기준 [의견]:** "기능이 존재하는가"가 아니라 **"심사관/사용자가 그 화면에 실제로 접근 가능한가"**를 기준으로 한다. 예: Store/Cart/Order를 출시 시 UI에서 숨기면, 백엔드가 비어 있어도 위험도는 Critical → Medium으로 낮아진다.

---

## 0. 출시 방향 (사용자 확정 사항)

| 항목 | 결정 |
| :--- | :--- |
| **출시 대상** | **Flutter 모바일 앱 우선 출시.** 웹(`~/hairspare`)은 나중에 **관리자 전용 콘솔**로 전환 예정 |
| **디지털 재화 결제** | 미정 → 본 문서에서 추천안 제시 (§7-6) |
| **출시 전략** | MVP 스코프 확정 후 출시 (§0-1 참고) |

### 0-1. 출시 스코프 확정 (v1.2에서 확정)

| 구분 | 기능 | 처리 |
| :--- | :--- | :--- |
| ✅ **그대로 출시** | 로그인/회원가입, 공고, 채팅, 스케줄/근무확인 | 백엔드 동작 중 |
| 🔨 **백엔드 새로 구현** | 모델매칭, 챌린지, 검색, 포트폴리오, 찜, 알림 | 이번 출시 포함 |
| ✏️ **수정** | 회원가입 본인인증 → 전화번호만 (인증 코드는 유지) / 소셜로그인에 Apple 추가(iOS만) | - |
| 🙈 **UI 숨김** (코드 유지) | 스토어, 공간대여, 에너지, 포인트, 교육 | 나중에 활성화 |
| ⚠️ **필수 (스코프 무관)** | 계정삭제 백엔드, iOS 권한문구, Bundle ID 변경, 신고/차단, 개인정보처리방침 | 안 하면 반려 |

**로그인 정책:**
- **iOS:** 카카오·네이버·구글 + **Apple 로그인 필수**(4.8). Apple Developer 계정($99/년) 필요.
- **Android:** 카카오·네이버·구글 (Apple 로그인 불필요). 별도로 `targetSdk` 최신화·Data Safety 양식·(신규 개인계정 시) 비공개 테스트 필요.

**챌린지 주의:** 챌린지는 UGC(사용자 생성 콘텐츠)이므로 신고/차단 기능이 더욱 필수가 된다(Apple 1.2).

---

## 1. 전체 구조 개요 — 3개의 독립 코드베이스

이 프로젝트는 서로 **분리된 3개의 코드베이스**로 구성된다. 한 곳을 고친다고 다른 곳에 자동 반영되지 않는다.

| 코드베이스 | 경로 | 역할 | 배포 |
| :--- | :--- | :--- | :--- |
| **모바일 앱** | `~/flutter` | Flutter로 만든 iOS/Android 앱 (출시 주력) | (미출시) |
| **백엔드** | `~/backend-new` | FastAPI 마이크로서비스(MSA) + API Gateway | Railway |
| **웹** | `~/hairspare` | Next.js 웹사이트 (Prisma + Neon 직접 연결) | Vercel (`hairspare.co.kr`) |

> **중요:** 웹(`~/hairspare`)과 앱(`~/flutter`)은 **완전히 다른 프로젝트**다. 디자인·기능·코드가 따로 있으며, 백엔드 연결 방식도 다르다(앱은 API Gateway 경유, 웹은 Prisma로 DB 직접 접근).

### 1-1. 용어 설명 (주니어 개발자용)
- **MSA (Microservice Architecture):** 기능별로 서버를 잘게 쪼갠 구조. 예: 로그인 서버, 공고 서버, 채팅 서버를 따로 둠.
- **API Gateway:** 앱이 여러 서버에 직접 붙지 않고, "단일 입구" 하나로만 요청을 보내면 게이트웨이가 알맞은 서버로 전달(프록시)해 주는 중계소.
- **프록시(proxy):** 요청을 대신 받아서 뒤쪽 진짜 서버로 넘겨주는 것.

---

## 2. 시스템 아키텍처 (데이터 흐름)

```
┌─────────────────┐
│  Flutter 앱     │  (~/flutter, 화면 119개)
│  (iOS/Android)  │
└────────┬────────┘
         │ HTTPS  (assets/env/app.env 의 API_BASE_URL)
         ▼
┌─────────────────────────────────────────────┐
│  API Gateway  (Railway: hairspare-backend)   │
│  https://hairspare-backend-production         │
│         .up.railway.app                       │
│  - 경로(/api/...)를 보고 알맞은 서비스로 프록시 │
│  - 일부 경로는 여기서 직접 mock 데이터 반환     │
└───┬───────┬───────┬───────┬───────┬──────────┘
    │       │       │       │       │
    ▼       ▼       ▼       ▼       ▼
 ┌──────┐┌──────┐┌──────┐┌──────┐┌────────┐
 │auth  ││job   ││chat  ││energy││schedule│   ← 실제 구현된 5개
 └──┬───┘└──┬───┘└──┬───┘└──┬───┘└───┬────┘
    └───────┴───────┴───────┴────────┘
                    │
                    ▼
         ┌────────────────────┐
         │  Neon PostgreSQL    │  (싱가포르 리전)
         │  - 메인 브랜치: 앱용  │
         │  - web-app 브랜치: 웹용│
         └────────────────────┘

 ┌──────────────────────────────────────┐
 │ payment / notification / store /      │  ← 빈 껍데기 5개
 │ cart / order  (main.py에 /health만)   │     (게이트웨이는 프록시하지만
 └──────────────────────────────────────┘      실제 기능 없음 → 호출 시 실패)
```

### 2-1. 별도: 웹(Next.js) 흐름
```
브라우저 → Vercel (hairspare.co.kr) → Prisma → Neon (web-app 브랜치)
```
웹은 API Gateway를 **거치지 않고** DB에 직접 붙는다.

---

## 3. 프론트엔드(Flutter 앱) 구조

**경로:** `~/flutter/lib/`

| 폴더 | 내용 | 수량 |
| :--- | :--- | :--- |
| `screens/spare/` | 스페어(구직자) 화면 | 56개 |
| `screens/shop/` | 미용실(구인) 화면 | 35개 |
| `screens/admin/` | 관리자 화면 | 26개 |
| `screens/common/` | 공통 화면 | 2개 |
| `services/` | 백엔드 API 호출 담당 클래스 | **27개** |
| `providers/` | 상태관리 (Provider 패턴) | 8개 |
| `core/network/` | Dio HTTP 클라이언트 + JWT 인터셉터 | - |

- **화면 총 119개** — 규모가 큰 앱이다.
- **API 진입점:** `lib/utils/api_config.dart`
  - 디버그: `localhost:8000`
  - 릴리스: `https://hairspare-backend-production.up.railway.app`
  - `assets/env/app.env`로 덮어쓰기 가능 (현재 `USE_MOCK_DATA=false`, 프로덕션 연결)
- **인증:** `lib/core/network/auth_interceptor.dart` — JWT Access Token을 모든 요청에 자동 첨부, 401 시 refresh 시도.

---

## 4. 백엔드(MSA) 구조 — 핵심 문제 구간

**경로:** `~/backend-new/services/`

### 4-1. 실제 구현된 서비스 (5개)

| 서비스 | 주요 엔드포인트 | 상태 |
| :--- | :--- | :--- |
| **auth-service** | register, login, refresh, me, logout, change-password, find-id, reset-password, send-verification-code, verify-code | ✅ 동작 |
| **job-service** | jobs(목록/상세/생성), jobs/{id}/apply, jobs/my, applications/my, applications/shop, applications/{id}/approve·reject | ✅ 동작 |
| **chat-service** | chats(목록/상세), chats/{id}/messages(조회/전송), chats/{id}/read, 삭제 | ✅ 동작 |
| **energy-service** | wallet, purchase, lock, return, forfeit | ✅ 동작 |
| **schedule-service** | schedules(CRUD), cancel, my, check-in, confirm, work-check/stats, work-check/shop-stats | ✅ 동작 |

### 4-2. 빈 껍데기 서비스 (5개) ⚠️

다음 서비스들은 `app/main.py`에 `/health` 응답만 있고 **실제 기능(routes/models)이 없다.**

| 서비스 | 현재 상태 | 근거 |
| :--- | :--- | :--- |
| **payment-service** | 빈 껍데기 | `main.py`에 health만, routes.py 없음 |
| **notification-service** | 빈 껍데기 | 〃 |
| **store-service** | 빈 껍데기 | 〃 |
| **cart-service** | 빈 껍데기 | 〃 |
| **order-service** | 빈 껍데기 | 〃 |

> **함정:** API Gateway(`proxy.py`, 총 41개 라우트)는 이 빈 서비스들로도 프록시 경로를 만들어 놨다. 예) `/api/payments` → payment-service. 하지만 대상 서비스에 기능이 없어 **실제 호출하면 실패**한다.

### 4-3. 게이트웨이가 직접 가짜 데이터(mock)를 반환하는 구간 ⚠️

`~/backend-new/api-gateway/app/routes/proxy.py` 안에서 **백엔드 서비스로 보내지 않고 게이트웨이가 직접 하드코딩된 데이터를 응답**하는 경로들:

| 경로 | 현재 동작 | 근거 |
| :--- | :--- | :--- |
| `/api/notifications` | 하드코딩된 mock 알림 반환 (`TODO: 실제 notification-service로 프록시`) | proxy.py 312~ |
| `/api/favorites`, `/api/favorites/check` | 빈 배열/false 반환 | proxy.py 225~242 |
| `/api/admin/stats` | 하드코딩된 통계 반환 | proxy.py 732~ |
| `/api/admin/users`, `/api/admin/activities` | 하드코딩된 mock 반환 | proxy.py 837~ |

> 앞서 관리자 대시보드 화면이 일부만 뜨고 "감사 로그 조회 실패"가 났던 이유가 이것이다. 일부는 게이트웨이 mock으로 보이고, 미구현 부분은 실패한다.

---

## 5. 프론트↔백엔드 연결 매트릭스 (가장 중요)

Flutter 서비스 클래스 27개가 실제로 백엔드와 연결돼 동작하는지 정리. **이 표가 "어디가 끊겨 있는지"의 핵심이다.**

| Flutter 서비스 | 호출 대상 API | 백엔드 실제 구현 | 동작 여부 |
| :--- | :--- | :--- | :---: |
| auth_service | /api/auth/* | auth-service | ✅ (단 delete-account 없음, §7-3) |
| job_service | /api/jobs/* | job-service | ✅ |
| application_service | /api/applications/* | job-service | ✅ |
| chat_service | /api/chats/* | chat-service | ✅ |
| energy_service | /api/energy/* | energy-service | ✅ |
| schedule_service | /api/schedules/* | schedule-service | ✅ |
| work_check_service | /api/work-check/* | schedule-service | ✅ |
| favorite_service | /api/favorites | 게이트웨이 mock(빈 배열) | ⚠️ 가짜 |
| notification_service | /api/notifications | 게이트웨이 mock | ⚠️ 가짜 |
| payment_service | /api/payments | payment-service (빈 껍데기) | ❌ 미동작 |
| report_service | /api/reports | 백엔드 없음 | ❌ 미동작 |
| contact_violation_service | /api/chats/{id}/contact-violations | chat-service에 해당 라우트 없음 | ❌ 확인필요 |
| verification_service | /api/shop/business-verification/* | 백엔드 없음 (코드에 `Phase 2` 주석) | ❌ 미동작 |
| admin_service | /api/admin/* | 일부 게이트웨이 mock, 대부분 미구현 | ⚠️ 부분 |
| review_service | /api/reviews | 백엔드 없음 | ❌ 미동작 |
| point_service | /api/points | 백엔드 없음 | ❌ 미동작 |
| subscription_service | /api/subscriptions | 백엔드 없음 | ❌ 미동작 |
| search_service | /api/search | 백엔드 없음 | ❌ 미동작 |
| space_rental_service | /api/space-rentals | 백엔드 없음(store 빈껍데기) | ❌ 미동작 |
| portfolio_service | /api/portfolios | 백엔드 없음 | ❌ 미동작 |
| challenge_service | /api/challenges | 백엔드 없음 | ❌ 미동작 |
| education_service | /api/educations | 백엔드 없음 | ❌ 미동작 |
| matching_service / model_match_service / model_designer_match_service | /api/matching 등 | 백엔드 없음 | ❌ 미동작 |
| spare_service / spare_designer_profile_service | /api/spares 등 | 백엔드 없음 | ❌ 미동작 |

> **요약:** Flutter 서비스 27개 중 **실제로 백엔드와 연결돼 동작하는 것은 약 7개**(auth, job, application, chat, energy, schedule, work-check). 나머지 약 20개는 **백엔드 미구현 또는 게이트웨이 mock 상태**다.
>
> *(주: 위 표의 "호출 대상 API" 경로 일부는 서비스 파일별로 더 정밀 검증이 필요할 수 있다. 동작 여부 ✅/❌ 판정은 백엔드 라우트 존재 여부에 근거했다.)*

---

## 6. 데이터베이스 (Neon PostgreSQL)

- **리전:** AWS 싱가포르 (한국에 서울 리전 없어 싱가포르 선택)
- **메인 브랜치:** 앱/백엔드용. 생성된 테이블 12개:
  `User, Account, Verification, Region, Job, Application, Chat, Message, EnergyWallet, EnergyTransaction, NoShowHistory, Schedule`
- **web-app 브랜치:** 웹(Next.js/Prisma)용 분리
- **주의 1 — 컬럼 네이밍 불일치:** 백엔드(SQLAlchemy)는 `snake_case`, 웹(Prisma)은 `camelCase`를 쓴다. 그래서 브랜치를 분리해 충돌을 피한 상태다. 추후 통합 시 반드시 정리 필요.
- **주의 2 — Neon 무료 플랜 scale-to-zero:** 일정 시간 미사용 시 DB가 절전 모드로 들어가, 첫 요청이 1~3초 느려진다. 실서비스 전 유료 플랜 검토 필요.

---

## 7. App Store / Play Store 정책 대비 현황

`Apple App Store Review Checklist.pdf` + `gemini-code` 가이드 15개 항목을 실제 코드와 대조.
아래는 **§문서 규약의 표준 형식**(현재 상태 / 근거 / 위험도 / 권장 조치 / 검증 여부)으로 정리한다.
**위험도·정책 해석은 [의견]이며 Apple 공식 가이드라인과 최종 대조가 필요하다.**

### 7-1. App Completeness (2.1)
- **현재 상태:** 빈 껍데기 서비스 5개 + 백엔드 미구현 서비스 다수. 해당 서비스에 연결된 화면 진입 시 데이터 로드 실패/빈 화면 가능.
- **근거:** §4-2, §5 연결 매트릭스. `~/backend-new/services/{payment,notification,store,cart,order}-service/app/main.py` (health만)
- **위험도:** Critical *(단, 미동작 화면을 출시 시 UI에서 숨기면 High로 하향 가능 — §8 기준 참고)*
- **권장 조치:** 출시 범위에 포함되는 화면만 남기고, 미동작 화면은 백엔드 구현 또는 UI 비활성화.
- **검증 여부:** ✅ 확인 완료 (코드)

### 7-2. Login / Demo 계정 (2.1a)
- **현재 상태:** 로그인 동작. admin 계정 자동 생성 로직 있음(`ADMIN_USERNAME`/`ADMIN_PASSWORD`).
- **근거:** auth-service `routes.py`, `~/backend-new/services/auth-service/app/main.py`(lifespan admin 생성)
- **위험도:** Critical
- **권장 조치:** 심사용 데모 계정(스페어/샵/관리자) 준비 + 리뷰 노트에 ID/PW 기재.
- **검증 여부:** ✅ 로그인 확인 / ⬜ 데모 계정 세팅 필요

### 7-3. 계정 삭제 (5.1.1v)
- **현재 상태:** Flutter에 삭제 화면 있으나, 호출하는 백엔드 API가 없음 → 실제 삭제 안 됨.
- **근거:** `~/flutter/lib/screens/spare/delete_account_screen.dart`, `auth_service.dart`가 `DELETE /api/auth/delete-account` 호출. auth-service에 해당 라우트 **없음**.
- **위험도:** Critical (Apple 명시적 반려 사유)
- **권장 조치:** auth-service에 계정 삭제 API + 개인정보 실제 파기 로직 + 법적 보존 안내 구현.
- **검증 여부:** ✅ 확인 완료 (UI 있음 / 백엔드 없음)

### 7-4. 개인정보 처리방침 (5.1)
- **현재 상태:** 회원가입에 약관 동의 섹션은 있음. 개인정보처리방침 **전용 페이지/URL 미확인**.
- **근거:** `~/flutter/lib/widgets/spare_signup/spare_signup_terms_section.dart` 등
- **위험도:** Medium
- **권장 조치:** 앱 내 처리방침 전문(웹뷰/페이지) + App Store Connect용 URL 확보.
- **검증 여부:** ⬜ 확인 필요

### 7-5. 권한 요청 (5.1.1)
- **현재 상태:** iOS `Info.plist`에 권한 설명 문구가 **하나도 없음**. 앱은 사진/카메라(`image_picker`) 사용.
- **근거:** `~/flutter/ios/Runner/Info.plist` (UsageDescription 키 0개), `pubspec.yaml` image_picker
- **위험도:** Critical (배포 차단급 — 설명 없이 권한 요청 시 iOS 크래시)
- **권장 조치:** `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` 등 추가. 권한은 **필요한 시점에만** 요청.
- **검증 여부:** ✅ 확인 완료 (없음)

### 7-6. 결제 (3.1) — 최대 반려 요인
- **현재 상태:** 에너지(디지털 재화)를 `/api/energy/purchase`에 `paymentMethod='CARD'`로 결제. `in_app_purchase` 패키지 **없음**. payment-service 빈 껍데기.
- **근거:** `~/flutter/lib/services/energy_service.dart`, `pubspec.yaml`(IAP 패키지 부재)
- **에너지 메커니즘 [사실]:** wallet → purchase(충전) → lock(지원 시 잠금) → return(근무 완료 반환) → forfeit(노쇼 몰수). 보증금+매칭 이용권 성격.
- **위험도:** Critical
- **정책 해석 [의견, 공식 대조 필요]:** 앱 내 가상 재화 충전은 원칙적으로 IAP 강제(3.1). 외부 카드결제 충전은 반려 위험 큼.
- **권장 조치 (2단계 전략):**
  1. *(1순위, 가장 안전)* 에너지 충전을 Apple IAP / Google Billing으로 전환. 수수료 15~30% 발생하나 반려 위험 제거.
  2. *(차선, 리스크)* 에너지를 "오프라인 인력 매칭 이용권/수수료"로 재정의 후 외부 PG(토스) 유지 시도. 단 애플이 가상재화로 판단 시 반려.
  - 실물 시술비·예약금은 외부 PG 허용. **디지털(에너지)과 실물(시술비)을 결제 수단부터 분리**가 핵심.
- **검증 여부:** ✅ 코드 확인 / ⬜ 결제 방향 최종 결정 필요

### 7-7. 본인인증 (PASS/사업자)
- **현재 상태:** 사업자 인증/OCR 호출 코드 있으나 백엔드 미구현(`Phase 2` 주석).
- **근거:** `~/flutter/lib/services/verification_service.dart` (`/api/shop/business-verification` 호출, 백엔드 라우트 없음)
- **위험도:** High
- **권장 조치:** 백엔드 인증 API 구현 + 심사관용 데모 계정은 PASS/사업자 인증 우회 처리.
- **검증 여부:** ✅ 확인 완료 (미구현)

### 7-8. 서버 권한 검증 (Authorization)
- **현재 상태:** JWT 토큰은 인터셉터로 첨부됨. 서버단 role/소유권 검증은 **전수 미확인** (admin API 다수가 mock/미구현).
- **근거:** `~/flutter/lib/core/network/auth_interceptor.dart`, §4-3 게이트웨이 mock
- **위험도:** High *(실서비스 데이터 연결 시 Critical)*
- **권장 조치:** 관리자 API·리소스 소유권을 서버에서 role 검증. "Flutter 라우팅은 보안이 아니다."
- **검증 여부:** ⬜ 확인 필요 (전수 점검)

### 7-9. UGC 신고/차단 (1.2)
- **현재 상태:** 신고(`report_service`) 호출 코드 있으나 백엔드 `/api/reports` 미구현. 사용자 간 "차단(block)" 기능 **미확인/미구현** (현재 "차단"은 연락처 공유 위반 시 채팅 제한뿐).
- **근거:** `~/flutter/lib/services/report_service.dart`, `contact_violation_service.dart`
- **위험도:** High (채팅/포트폴리오/챌린지 등 UGC 존재)
- **권장 조치:** 신고 백엔드 + 사용자 차단 기능 + 제재 약관(EULA) + 고객 문의 채널.
- **검증 여부:** ✅ 신고 확인 / ❌ 차단 미확인

### 7-10. 파일 업로드 검증
- **현재 상태:** 프로필/사업자등록증 업로드의 서버측 검증(MIME/용량/악성코드) 미확인.
- **근거:** 백엔드 업로드 처리 라우트 미확인
- **위험도:** High
- **권장 조치:** 서버에서 MIME·용량·악성코드·소유권 검증. 클라이언트 검증만으로 불충분.
- **검증 여부:** ⬜ 확인 필요

### 7-11. Mock 데이터 (13)
- **현재 상태:** 앱은 `USE_MOCK_DATA=false`, 프로덕션 연결. 단 **백엔드 게이트웨이가 직접 mock 반환하는 구간** 존재.
- **근거:** `~/flutter/assets/env/app.env`, `~/backend-new/api-gateway/app/routes/proxy.py` (notifications/favorites/admin)
- **위험도:** Medium (앱) / High (게이트웨이 mock)
- **권장 조치:** 게이트웨이 mock 구간을 실제 서비스로 교체.
- **검증 여부:** ✅ 확인 완료

### 7-12. 소셜 로그인 / Apple 로그인 (4.8)
- **현재 상태:** 카카오/네이버/구글만 있음. 'Apple로 로그인' **없음**.
- **근거:** `~/flutter/pubspec.yaml` (`kakao_flutter_sdk_user`, `flutter_naver_login`, `google_sign_in` / `sign_in_with_apple` 부재)
- **위험도:** Critical (타 소셜 로그인 존재 시 Apple 로그인 강제)
- **권장 조치:** `sign_in_with_apple` 도입 + Apple Developer 계정($99/년) + 로그인 화면 동일 크기 버튼.
- **검증 여부:** ✅ 확인 완료 (없음)

### 7-13. 빌드 설정 (배포 차단급)
- **현재 상태:** iOS Bundle ID가 `com.example.hairspare` (기본 플레이스홀더).
- **근거:** `~/flutter/ios/Runner.xcodeproj/project.pbxproj`
- **위험도:** Critical (Apple은 `com.example` ID 등록 거부)
- **권장 조치:** 실제 도메인 기반 ID로 변경(예: `kr.co.hairspare.app`). Android `targetSdkVersion` 최신화. 아이콘/스플래시/버전 점검.
- **검증 여부:** ✅ Bundle ID 확인 / ⬜ Android·아이콘 점검 필요

---

## 8. 문제점 우선순위 요약

> **심각도 판단 기준 [의견]:** "기능 존재 여부"가 아니라 **"심사관/사용자가 실제로 접근 가능한가"**로 판단한다.
> 따라서 **출시 범위(스코프)를 먼저 확정**하면 일부 항목의 위험도가 내려간다.
> 아래는 "전체 기능 완성 후 출시" 전략 기준이며, MVP 범위 축소 시 괄호의 하향 위험도를 적용한다.

### 🔴 Critical (이거 안 되면 출시/심사 불가)
1. iOS Info.plist 권한 설명 문구 없음 → **카메라 사용 시 크래시** (5.1.1) — *스코프 무관, 무조건 Critical*
2. Bundle ID `com.example` → **앱 등록 자체 불가** — *스코프 무관*
3. Apple 로그인 없음 (4.8) — *스코프 무관*
4. 계정 삭제 백엔드 미구현 (5.1.1v) — *스코프 무관*
5. 에너지 디지털 재화 결제 정책 미정 (3.1) — *에너지 기능을 출시에 포함할 경우 Critical*
6. 빈 껍데기/미동작 서비스에 연결된 화면 (2.1) — *해당 화면을 출시에 노출할 경우 Critical / **UI에서 숨기면 → Medium***

### 🟠 High
7. 신고/차단 기능 백엔드 미구현 (UGC) — *채팅·챌린지 등 UGC를 노출할 경우 High*
8. PASS/사업자 인증 백엔드 미구현 + 심사 우회 처리
9. 서버 권한(role) 검증 전수 점검 — *실데이터 연결 시 Critical*
10. 파일 업로드 서버 검증
11. 게이트웨이 mock 데이터 실제 서비스로 교체

### 🟡 Medium
12. 개인정보처리방침 앱 내 페이지 + URL
13. 권한 요청 타이밍(필요 시점에만)
14. 데모 계정 + 리뷰 노트 작성
15. 메타데이터(스크린샷/설명) 준비

> **선행 결정 사항:** 위 6·7번 위험도를 확정하려면 **"이번 출시에 어떤 화면을 노출할지"** 스코프를 먼저 정해야 한다. (§10 크로스체크 대상)

---

## 9. 작업 로드맵 (전체 기능 완성 후 출시 전략 기준)

### Phase 1 — 배포 가능 상태 만들기 (빌드 차단 요소 제거)
- [ ] Bundle ID 변경 (`com.example` → 실제 도메인)
- [ ] iOS Info.plist 권한 설명 문구 추가
- [ ] Apple Developer 계정 등록 + `sign_in_with_apple` 도입

### Phase 2 — 핵심 기능 백엔드 완성 (미동작 서비스 구현)
- [ ] 계정 삭제 API (auth-service)
- [ ] 신고/차단 API + 차단 기능 UI
- [ ] 알림(notification-service) 실제 구현 (게이트웨이 mock 제거)
- [ ] favorite/review/point 등 핵심 서비스 백엔드 구현
- [ ] PASS/사업자 인증 백엔드 + 심사 데모 우회

### Phase 3 — 결제 정책 정리
- [ ] 에너지 결제 방식 확정 (IAP 전환 vs 실물 서비스 재정의)
- [ ] 실물 시술비/예약금 PG(토스)와 명확히 분리
- [ ] payment-service 구현

### Phase 4 — 커머스 영역 (store/cart/order)
- [ ] store/cart/order-service 구현 (스토어 기능 출시 범위면)

### Phase 5 — 보안 & 검증
- [ ] 서버 권한(role/소유권) 전수 검증
- [ ] 파일 업로드 MIME/용량/악성코드 검증

### Phase 6 — 출시 준비
- [ ] 개인정보처리방침 앱 내 페이지 + URL
- [ ] 권한 요청 타이밍 조정
- [ ] 데모 계정 + 리뷰 노트
- [ ] 스크린샷/메타데이터/아이콘

### (출시 후) Phase 7 — 웹 관리자 콘솔
- [ ] `~/hairspare`를 관리자 전용 웹으로 정리

---

## 10. 다음 액션 (크로스체크 대상)

이 문서는 **사실 파악본**이다. 사용자와 함께 아래를 크로스체크한 뒤 확정한다.

### 10-1. 코드로 확인 끝났지만 운영 환경 확인이 필요한 것
코드만으로는 알 수 없고, 실제 콘솔/설정을 봐야 하는 항목 (검증 여부 ⬜):

| 항목 | 확인 위치 | 이유 |
| :--- | :--- | :--- |
| Railway 실제 배포 서비스 목록 | Railway 대시보드 | auth/job/chat/energy/schedule이 모두 떠 있는가 |
| Neon 운영 DB 상태 | Neon 콘솔 | scale-to-zero, 브랜치 구성 |
| Apple Developer 계정/설정 | developer.apple.com | Apple 로그인·Push 전제 조건 |
| Bundle Identifier 등록 | App Store Connect | `com.example` → 실제 ID |
| Push Notification 설정 | Apple/FCM | 알림 기능 전제 |
| Associated Domains | Xcode/Apple | 딥링크·Apple 로그인 |
| Sign in with Apple 설정 | Xcode Capabilities | 4.8 대응 |

### 10-2. 방향 결정이 필요한 것
1. **출시 스코프 확정** — §5 매트릭스의 미동작 화면 중 이번 출시에 **노출할 화면 vs 숨길 화면** 선별 (→ §8 위험도 확정)
2. **§7-6 결제 방향** 최종 결정 (IAP 전환 vs 실물 서비스 재정의)
3. **웹 관리자 콘솔** 기능 범위

---

## 11. 향후 추가하면 좋은 문서 세트 [의견]

본 문서는 **기술 감사(Technical Audit)** 성격이다. 아래 문서를 추가하면 *개발 → 심사 → 출시 → 운영* 전 과정을 문서로 관리할 수 있다.

| # | 문서 | 목적 |
| :--- | :--- | :--- |
| 1 | Apple App Store Compliance Audit | Apple 가이드라인 항목별 충족 증빙 |
| 2 | Google Play Compliance Audit | Play 정책(타겟 SDK, 테스터 등) 대응 |
| 3 | Security Audit | JWT/권한/소유권/업로드 검증 |
| 4 | Privacy Audit | 수집 데이터·목적·보존·파기·제3자 |
| 5 | Release Checklist | 빌드/서명/버전/메타데이터 |
| 6 | Launch Checklist | 심사 제출·데모 계정·리뷰 노트 |
| 7 | Post-Launch Checklist | 모니터링·장애 대응·업데이트 |

---

## 변경 이력

- **v1.2 (2026-06-30):** 출시 스코프 확정(§0-1). 구현 대상(모델매칭·챌린지·검색·포트폴리오·찜·알림), 숨김 대상(스토어·공간대여·에너지·포인트·교육), 로그인 정책(iOS Apple 로그인 추가, Android 불필요), 본인인증 전화번호만으로 변경 결정.
- **v1.1 (2026-06-28):** ChatGPT 리뷰 반영. ① 사실/의견 분리 규약 추가, ② §7을 표준 형식(현재상태/근거/위험도/권장조치/검증여부)으로 재작성, ③ §8 심각도를 "접근 가능 여부" 기준으로 재조정(스코프 연동), ④ §10 운영환경 검증 목록 보강, ⑤ §11 향후 문서 세트 추가.
- **v1.0 (2026-06-28):** 최초 작성 (아키텍처 현황 + 앱스토어 정책 대비 1차본).
