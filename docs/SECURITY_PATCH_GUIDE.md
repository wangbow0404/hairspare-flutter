# HairSpare 종합 보안 및 운영 패치 가이드

**문서 목적:** 런칭 전(MAU 1,000명 목표) 반드시 해결해야 할 보안 취약점과 운영 리스크를 정의하고, 프론트엔드 및 백엔드의 구체적인 코드 수정 가이드를 제공합니다.

## Phase 1. 즉시 수정이 필요한 크리티컬 취약점 (P0)

### 1. 관리자 API 인가(Authorization) 누락 및 인증 우회

현재 API Gateway 구조에서 프론트엔드의 `flutter_secure_storage`에만 의존하고 있으며, 백엔드 라우트 보호가 해제되어 있습니다.

* **취약점:** 누구나 Postman이나 브라우저를 통해 `http://api-url/api/admin/users`를 호출하면 회원 및 결제 정보를 탈취할 수 있습니다.
* **조치 방안 (Backend - FastAPI API Gateway):**
  1. `backend-new/api-gateway/app/middleware.py`에 주석 처리된 JWT 인증 미들웨어를 **즉시 활성화**합니다.
  2. 공개 API(로그인, 회원가입, 공고 조회 등)를 제외한 모든 경로는 Token 검증을 필수로 적용합니다.
  3. **Role 기반 접근 제어(RBAC):** `/api/admin/*` 경로는 토큰 디코딩 후 `role == 'admin'`이 아닌 경우 무조건 `HTTP 403 Forbidden`을 반환하도록 강제해야 합니다.

### 2. 결제 및 에너지(포인트) 조작 방지 (Server-to-Server 검증)

클라이언트에서 결제 성공 후 `/api/payments/complete`와 같은 API를 단순히 호출하는 방식이라면, 해커가 이 API를 직접 호출해 에너지를 무한 충전할 수 있습니다.

* **조치 방안 (Backend - Payment Service):**
  * Flutter 앱은 PG사(토스페이먼츠 등) 결제 성공 후, 백엔드에 `paymentKey`, `orderId`, `amount`만 전달합니다.
  * 백엔드는 해당 키를 가지고 **PG사 서버로 직접 API를 요청(Server-to-Server)**하여 실제 결제된 금액과 승인 상태를 대조합니다.
  * 검증이 일치할 때만 DB에 Payment 내역을 기록하고 Energy를 충전합니다.

---

## Phase 2. 비즈니스 로직 클라이언트 의존성 탈피 (P1)

Flutter 모바일/웹 코드는 디컴파일이 가능하므로, **"클라이언트의 검증 로직은 UX용일 뿐, 진짜 보안은 백엔드에서 한다"**는 원칙을 지켜야 합니다.

### 1. 연락처 교환 (직거래) 차단 백엔드 이관

* **현황:** `lib/utils/contact_blocker.dart`에서 정규식을 통해 전화번호 전송을 막고 있으나, 클라이언트 변조 시 우회가 가능합니다.
* **조치 방안 (Backend - Chat Service):**
  * 메시지 전송 API (`POST /api/messages`)에 프론트엔드와 **동일한 정규식 필터링**을 추가합니다.
  * 매칭되면 `HTTP 400 Bad Request`와 함께 "연락처 공유는 제한됩니다" 라는 에러를 반환해야 합니다.

### 2. 출근 체크인(Work Check) 시간/위치 조작 방지

* **현황:** 기기 시간(`DateTime.now()`)에 의존할 가능성이 있습니다. 사용자가 폰의 시간을 조작하면 언제든 체크인이 가능합니다.
* **조치 방안:**
  * **시간 검증 (Backend):** 체크인 API 호출 시, 서버의 시간(`UTC/KST`)을 기준으로 스케줄의 `startTime` / `endTime`을 검증해야 합니다.
  * **위치 검증 (Flutter & Backend):** GPS 조작까지는 막기 어렵더라도, 최소한의 허들을 위해 Flutter에서 `geolocator`로 위도/경도를 얻어 체크인 API 파라미터로 넘깁니다. 백엔드는 미용실 좌표와 비교하여 반경 500m 이내일 때만 체크인을 허용하도록 고도화해야 합니다.

---

## Phase 3. 데이터 오염 방지 및 에러 핸들링 (P2)

### 1. XSS 방어 및 문자열 살균 (Sanitization)

* **현황:** 공고 설명, 스페어 닉네임, 후기(`comment`) 등에 스크립트 태그 `<script>`가 포함될 수 있습니다. 특히 Flutter Web 환경에서는 렌더링 시 XSS 공격에 노출될 수 있습니다.
* **조치 방안 (Backend):**
  * 모든 텍스트 입력(POST/PUT) 시 HTML 태그를 이스케이프(`&lt;` 등) 처리하거나, 허용된 텍스트만 저장하도록 백엔드 모델 유효성 검사(Pydantic/Zod 등)를 강화합니다.

### 2. 서버 에러(Stacktrace) 노출 차단

* **현황:** `lib/utils/error_handler.dart`에서 `error.response?.data`를 그대로 파싱합니다. 만약 백엔드가 500 에러 시 DB 쿼리나 스택 트레이스를 반환한다면 심각한 정보 누출입니다.
* **조치 방안 (Backend):**
  * 프로덕션(`USE_MOCK_DATA=false`) 환경의 백엔드에서는 500 에러 발생 시 로그에만 상세 내역을 남기고, 프론트엔드에는 `{"error": {"message": "서버 오류가 발생했습니다."}}` 형태의 정형화된 JSON만 반환하도록 전역 Exception Handler를 설정해야 합니다.
* **조치 방안 (Flutter 클라이언트):**
  * HTTP 5xx 응답 본문을 사용자 메시지로 파싱하지 않고, 항상 일반화된 문구만 표시합니다. (본 저장소 `ErrorHandler`에 반영됨)

---

## Phase 4. 인프라 및 운영 보안 자문 (MAU 1,000+ 기준)

`docs/ADVISOR_BRIEF_SECURITY_AND_OPERATIONS.md`에서 요청하신 내용에 대한 실무적 아키텍처 가이드입니다.

### 1. 런칭 전 필수 인프라 조치 ("이것만은 반드시")

* **HTTPS (SSL/TLS) 강제 적용:**
  * API Gateway 포트(8000)를 직접 열지 마세요.
  * 앞단에 **Nginx** 또는 **AWS ALB(Application Load Balancer)**를 두고 SSL 인증서를 부착하여 `https://api.hairspare.co.kr` 형태로 라우팅하세요. HTTP 통신 시 JWT 토큰이 스니핑 당합니다.
* **CORS 정책 강화:**
  * `docs/CORS_FIX.md`에서 `Access-Control-Allow-Origin: *`로 설정된 것을 확인했습니다.
  * 프로덕션 배포 시에는 **반드시 Flutter Web 도메인(`https://www.hairspare.co.kr`)만 허용**하도록 변경해야 합니다. 타 사이트에서 API를 도용하는 것을 막습니다.

### 2. 트래픽 스파이크 및 DDoS 대응 방향 (역할 분담)

단일 Gateway 구조는 트래픽에 취약합니다. 팀 내부에서 직접 하기보다는 **클라우드 서비스의 기본 기능을 적극 활용**하는 것이 비용/시간 면에서 압도적으로 유리합니다.

* **팀 내에서 할 일 (애플리케이션 계층 방어):**
  * **Rate Limiting (속도 제한) 적용:** FastAPI에 `slowapi` 등의 패키지를 달아, 특정 IP가 1초에 10회 이상 API를 찌르면 차단(`HTTP 429`)하세요.
  * 특히 `/api/auth/send-verification-code` (문자 인증) API는 비용 공격(SMS Bombing)의 주 타겟입니다. "IP당 5분에 3회" 등 극도로 엄격한 제한을 걸어야 합니다.
* **외부/전문 플랫폼에 맡길 일 (네트워크 계층 방어):**
  * **Cloudflare (Pro 플랜 추천):** 한 달 $20 수준으로 DDoS 방어, 웹 방화벽(WAF), 악성 봇 차단을 자동 수행합니다. 서버 앞단에 Cloudflare를 씌우면 MAU 1만 명 수준까지 인프라 보안 걱정 없이 서비스에만 집중할 수 있습니다.

### 3. 현재 구조의 배포 시 리스크 (단일 Gateway + Next.js 프록시 혼재)

* **문제점:** 관리자 API의 일부는 DB를 직접 보고, 일부는 Next.js(3000포트)를 프록시합니다. 이렇게 로직이 파편화되면 WAF나 인증 미들웨어를 일관되게 적용하기 어렵습니다.
* **권장 사항:** 런칭 전, Phase 5 플랜에 명시된 대로 **Next.js 의존성을 완전히 제거**하고 모든 관리자 API를 FastAPI 기반으로 통합하세요. 그래야 하나의 API Gateway에서 모든 트래픽의 로그 감사와 보안 제어가 가능합니다.

---

## 최종 체크리스트 (배포 전 확인)

- [ ] (BE) API Gateway JWT 인증 미들웨어 활성화 완료
- [ ] (BE) `/api/admin/*` 경로에 대한 권한 검증(Admin Role) 적용 완료
- [ ] (BE) 메시지 전송 API에 연락처 공유 정규식 필터링 적용 완료
- [ ] (BE) 결제 완료 처리 시 PG사 Server-to-Server 교차 검증 로직 적용 완료
- [ ] (BE/FE) SMS 인증번호 발송 API에 Rate Limit(속도 제한) 적용 완료
- [ ] (BE) 프로덕션 환경에서 서버 에러(Stacktrace) 노출 숨김 처리 완료
- [ ] (Infra) API 도메인에 HTTPS(SSL) 적용 완료
- [ ] (Infra) CORS 정책에서 `*` 제거 후 실제 도메인만 허용 완료
- [ ] (FE) `app.env` 및 `--dart-define`에 배포용 URL 정상 세팅 완료
- [ ] (FE) HTTP 5xx 시 응답 본문을 사용자에게 노출하지 않음 (`ErrorHandler` 확인)

**이 가이드를 기반으로 백엔드 개발자와 인프라 담당자가 조치를 완료한 후, 클라이언트 앱을 최종 릴리즈하시기 바랍니다.**

---

## 부록: 본 저장소(Flutter 클라이언트)와의 대응

| 가이드 항목 | 본 레포 상태 / 비고 |
|-------------|---------------------|
| P0 관리자 클라이언트 우회 | 일반 로그인 화면의 하드코딩 관리자 분기 제거됨. 관리자는 **서버 JWT + role** 로만 허용할 것. |
| P0 백엔드 JWT/RBAC | API Gateway **백엔드 레포**에서 구현 필요 (본 레포에 `backend-new` 없음). |
| P0 결제 S2S 검증 | **Payment 서비스(백엔드)** 구현. |
| P1 연락처 차단 | `lib/utils/contact_blocker.dart`는 UX·선제 차단용. **Chat API 서버 검증 필수.** |
| P1 체크인 시간/GPS | **백엔드 서버 시간 검증 + 좌표 반경 검증**; Flutter는 향후 `geolocator` 등으로 좌표 전달 권장. |
| P2 XSS 살균 | 저장·표시 전 **백엔드** 살균이 주 방어선. |
| P2 스택 트레이스 | 백엔드 프로덕션 응답 정형화 + **클라이언트 5xx 메시지 일반화** (아래 구현 참고). |
| P3 인프라 | HTTPS, CORS, Rate limit, Cloudflare는 **인프라/백엔드** 작업. |
| 시크릿 / API URL | `assets/env/app.env`, `.env.example`, `--dart-define`; `.gitignore`에 로컬 시크릿 제외. |

Cursor 에이전트용 보안 규칙: `.cursor/rules/security-auth-and-secrets.mdc`
