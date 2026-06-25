# HairSpare 보안 구현 현황 요약

> 이 문서는 Flutter 클라이언트 레포에 **실제 구현된** 보안 항목을 정리한다.  
> 배포 전 전체 체크리스트는 `docs/SECURITY_PATCH_GUIDE.md`를 기준으로 한다.

---

## 1. 인증 (Authentication)

### JWT + HttpOnly Refresh Cookie
- **파일:** `lib/core/network/auth_interceptor.dart`
- Access Token은 `flutter_secure_storage`에 암호화 저장 (기기 Keychain / Keystore 위임)
- 모든 API 요청에 `Authorization: Bearer <token>` 자동 주입
- 401 응답 시 `/auth/refresh` 단일 플로우 실행 — 동시성 제어로 중복 refresh 방지 (`_isRefreshing` 플래그 + `Completer`)
- Refresh 실패 또는 재시도 401 → Access Token 삭제 후 세션 만료 처리

### 역할 기반 라우트 가드 (RBAC — 클라이언트)
- **파일:** `lib/core/router/auth_redirect.dart`
- `/admin/*` 경로: 미로그인 → 로그인 화면, `role != admin` → 각 역할 홈으로 강제 이동
- `/spare/*`, `/shop/*`, `/model/*`: 역할 불일치 시 해당 역할 홈으로 리다이렉트
- 모델 계정은 `/model` 전용 셸 사용 — `/spare` 접근 차단

> ⚠️ 클라이언트 가드는 UX용. **백엔드 API Gateway에서 JWT + role 검증이 반드시 필요하다** (SECURITY_PATCH_GUIDE P0).

---

## 2. 연락처 직거래 차단

### 실시간 메시지 필터링
- **파일:** `lib/utils/contact_blocker.dart`
- 전송 직전 메시지에서 전화번호 패턴 탐지:
  - 숫자 연속 8자리 이상, `010-XXXX-XXXX` 패턴
  - 한글 숫자(일이삼…) 3자 이상 연속 → 숫자로 변환 후 재검사
  - 이메일 주소 패턴 (`@` 포함)
  - 여러 메시지에 나눠 보낸 번호 분할 우회 탐지 (`containsBlockedPatternInRecent`)
- `shouldBlockSend()` — 단일/분할/레거시 규칙 통합 검사

### 연락처 위반 누적 제재 정책
- **파일:** `lib/utils/contact_violation_policy.dart`
- 대화방 내 3회 적발 → 해당 대화방 자동 삭제
- 스페어 3회 적발 → 지원 취소 + 잠금 에너지 **몰수** (환불·매장 이전 없음)
- 샵 1회 적발 → 1일 대화·공고 등록 제한
- 샵 누적 3회 → 계정 자동 탈퇴 + 블랙리스트

> ⚠️ 클라이언트 탐지는 UX 선제 차단용. **Chat API 서버에서 동일 정규식 적용이 필수** (SECURITY_PATCH_GUIDE P1).

---

## 3. 에너지 시스템 보호

### 에너지 차감 원자성 (Mock)
- **파일:** `lib/services/job_service.dart`
- 지원 신청 Mock 플로우에서 에너지 차감(`mockSpendEnergy`)을 상태 변경(`addApplication`)보다 **먼저** 실행
- 에너지 부족 시 throw → 이후 상태 변경 코드 전체 차단 (부분 실패 방지)

### 에너지 부족 UX 처리
- **파일:** `lib/view_models/job_detail_view_model.dart`
- 지원 신청 API 실패 시 메시지에 "에너지" 포함 여부 판단
- 에너지 부족이면 에러 텍스트 대신 **충전 유도 바텀시트** (`showLowEnergySheet`) 트리거
- 일반 에러는 기존대로 스낵바

### 잠금 에너지 추적
- **파일:** `lib/mocks/mock_spare_data.dart`
- `recordLockedEnergyForJobApplication()` — 지원 시 잠금 금액 기록
- `forfeitLockedEnergyForJobApplication()` — 연락처 위반 제재 시 몰수 처리

> ⚠️ 실제 결제 에너지 충전은 **PG사 Server-to-Server 교차 검증** 필요 (SECURITY_PATCH_GUIDE P0).

---

## 4. 서버 에러 정보 노출 방지

- **파일:** `lib/utils/error_handler.dart`
- HTTP 5xx 응답 → 응답 본문 파싱 없이 일반 문구 반환 ("서버 오류가 발생했습니다.")
- `_looksLikeInternalErrorDetail()` — Stacktrace·SQL·Django 패턴 감지 시 사용자 노출 차단
- 400 ValidationException만 서버 메시지 그대로 표시 (단, 내부 디버그 문자열이면 일반 문구로 대체)

---

## 5. 사업자 인증 검증

- **파일:** `lib/utils/business_registration_validator.dart`
- 사업자등록번호 국세청 표준 **체크섬 검증** (클라이언트 UX용 사전 필터)
- OCR 추출값 vs 사용자 입력 교차 비교 — 불일치 필드 목록 반환
- 국세청 진위 확인은 **서버 제출 후 백엔드**에서 처리 (클라이언트는 결과만 수신)

---

## 6. 신고 시스템

- **파일:** `lib/services/report_service.dart`, `lib/widgets/common/report_sheet.dart`
- 스페어/샵이 신고 제출 가능: 카테고리 선택 (노쇼·연락처 유출·욕설·결제 분쟁·기타) + 사유 입력
- `POST /api/reports` — Mock 모드에서는 `MockAdminData._submittedReports`에 누적
- 제출된 신고는 관리자 신고 목록(`/admin/reports`)에 실시간 반영

---

## 7. 관리자 패널 보안

### Mock 상태 일관성
- **파일:** `lib/mocks/mock_admin_data.dart`
- 인증 승인/반려 → `_verificationStatuses` Map에 기록 → 다음 조회 시 반영
- 신고 처리 → `_reportStatuses` Map 반영
- 공고 숨김/마감 → `_hiddenJobIds` / `_closedJobIds` Set 반영
- 유저 정지/해제 → `_suspendedUserIds` Set 반영 (기존)
- 스케줄 강제 완료/취소/노쇼 → `_scheduleStates` Map 반영

### 감사 로그 (Audit Log)
- **파일:** `lib/screens/admin/admin_audit_logs_screen.dart`
- 관리자 조치 이력 조회 (Mock 포함) — 이전 상태·새 상태·조치자·시각 기록
- 관리자 화면에서 승인/반려/제재 등 주요 조치 시 감사 로그 기록 명시

---

## 8. 아직 백엔드 구현이 필요한 항목

| 항목 | 우선순위 | 파일/근거 |
|------|----------|-----------|
| API Gateway JWT 인증 미들웨어 활성화 | **P0 (즉시)** | SECURITY_PATCH_GUIDE §1.1 |
| `/api/admin/*` 경로 role=admin 강제 검증 | **P0 (즉시)** | SECURITY_PATCH_GUIDE §1.1 |
| 결제 완료 PG사 Server-to-Server 교차 검증 | **P0 (즉시)** | SECURITY_PATCH_GUIDE §1.2 |
| Chat API 서버의 연락처 정규식 필터링 | P1 | `contact_blocker.dart` 주석 |
| 체크인 서버 시간 검증 + GPS 반경 검증 | P1 | SECURITY_PATCH_GUIDE §2.2 |
| 모든 텍스트 입력 XSS 살균 (백엔드) | P2 | SECURITY_PATCH_GUIDE §3.1 |
| SMS 인증 Rate Limit (IP당 5분 3회) | P1 | SECURITY_PATCH_GUIDE §4.2 |
| HTTPS/SSL 강제 적용 | P0 (배포 전) | SECURITY_PATCH_GUIDE §4.1 |
| CORS `*` 제거 → 실서비스 도메인만 허용 | P0 (배포 전) | SECURITY_PATCH_GUIDE §4.1 |

---

*최종 배포 전 전체 체크리스트: `docs/SECURITY_PATCH_GUIDE.md` 말미 참조*
