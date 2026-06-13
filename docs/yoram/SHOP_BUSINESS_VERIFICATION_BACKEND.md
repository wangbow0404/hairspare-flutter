# 샵 사업자 인증 — 백엔드 일괄 연동 체크리스트

> **용도:** Flutter Phase 1(mock·UI·클라이언트 검증) 완료 후, 백엔드를 **한 번에** 연결할 때 따라갈 목록.  
> **원칙:** OCR·국세청 API 키는 **서버 env only** — 앱/커밋 금지 ([security-auth-and-secrets](../../.cursor/rules/security-auth-and-secrets.mdc)).

---

## 1. 외부 서비스·키 (서버/CI)

- [ ] **국세청 OpenAPI** serviceKey 발급 — [사업자등록정보 진위확인 및 상태조회](https://www.data.go.kr/data/15081808/openapi.do)
- [ ] OCR 벤더 선택 (택1)
  - [ ] NHN CLOVA OCR `/v1.1/appkeys/{appKey}/business`
  - [ ] SELVAS OCR for Business Registration
  - [ ] NCP Financial eKYC `BIZ_LICENSE` (OCR+진위 일괄)
- [ ] (선택) Object storage — 원본 사업자등록증·신분증 보관 (S3/GCS 등)
- [ ] Admin 심사 UI — `pending` → `approved` / `rejected`

---

## 2. 백엔드 API (Flutter `VerificationService` 연동)

| API | 메서드 | Flutter 연동 위치 |
|-----|--------|-------------------|
| `/api/shop/business-verification/ocr` | POST multipart `file` | `scanBusinessRegistration()` |
| `/api/shop/business-verification/validate` | POST JSON | `validateBusinessRegistration()` |
| `/api/shop/business-verification` | POST multipart | `submitShopBusinessVerification()` |
| `/api/shop/business-verification` | GET | `getShopBusinessVerification()` (기존) |
| `/api/shop/proxy-verification` | POST | `submitShopProxyVerification()` (기존) |
| `/api/auth/send-verification-code` | POST | `sendVerificationCode()` |
| `/api/auth/verify-code` | POST | `verifyCode()` |

### 2-1. OCR 응답 스키마 (Flutter `BusinessRegistrationOcrResult`)

```json
{
  "requestId": "ocr-req-uuid",
  "businessNumber": "124-81-00998",
  "businessNumberConfidence": 0.96,
  "businessName": "헤어스페어 강남점",
  "businessNameConfidence": 0.94,
  "representativeName": "김원장",
  "representativeNameConfidence": 0.91,
  "businessType": "서비스업",
  "businessTypeConfidence": 0.88,
  "businessCategory": "미용업",
  "businessCategoryConfidence": 0.87,
  "address": "서울특별시 ...",
  "addressConfidence": 0.86,
  "openingDate": "20200315",
  "openingDateConfidence": 0.82
}
```

### 2-2. Validate 응답 스키마 (Flutter `BusinessRegistrationValidation`)

```json
{
  "isNumberFormatValid": true,
  "ocrMismatches": [],
  "requiresNtsCheck": false,
  "ntsVerified": true,
  "ntsStatusMessage": "부가가치세 일반과세자",
  "serverValidated": true
}
```

**NTS statusCode 참고 (상태조회):** `05` 휴업, `06` 폐업 → 제출 거부.

### 2-3. Submit multipart (Phase 2 — `FormData`)

필드 예시 (license 업로드 패턴):

- `businessNumber`, `businessName`, `representativeName`, `businessType`, `businessCategory`, `address`
- `ocrRequestId` (OCR 호출 correlation)
- `businessRegistration` — file
- `idCard` — file (optional)

---

## 3. 서버 검증 규칙 (필수)

- [ ] 모든 텍스트 필드 schema limit·sanitize·ownership (shopId)
- [ ] OCR confidence &lt; 0.85 → `manualReviewRequired` 플래그
- [ ] OCR 등록번호 ≠ 제출 등록번호 → 400 또는 재확인 요구
- [ ] NTS 진위확인: 번호 + 대표자명 + (개업일) 교차
- [ ] NTS 상태: 휴업/폐업 차단
- [ ] 이미지 MIME `image/jpeg`/`image/png`, max 5MB
- [ ] OCR/NTS rate limit
- [ ] 감사 로그: `ocrRequestId`, NTS 응답 코드, 제출 shopId

---

## 4. Flutter 연동 스위치 (`ApiConfig.useMockData == false`)

파일: [`lib/services/verification_service.dart`](../../lib/services/verification_service.dart)

1. [ ] `scanBusinessRegistration` — mock → real OCR endpoint (이미 분기 구현)
2. [ ] `validateBusinessRegistration` — mock → real validate endpoint
3. [ ] `submitShopBusinessVerification` — JSON → **FormData multipart** (주석 TODO 해제)
4. [ ] `getShopBusinessVerification` mock — 다양한 status 시뮬 (`pending`/`approved`/`rejected`) 선택

---

## 5. 보안·운영

- [ ] OCR/NTS 키: 서버 환경변수만
- [ ] PII(대표자명·주소·이미지) retention·암호화 정책
- [ ] 위조·편집 이미지: 수동 심사 + (선택) eKYC/위변조 탐지
- [ ] **auto-approve 금지** — MVP는 관리자 `pending` → `approved`

---

## 6. QA (백엔드 연동 후)

- [ ] 실 OCR → 폼 자동입력 → 사용자 수정 → 제출
- [ ] 잘못된 사업자번호 → 클라+서버 거부
- [ ] 휴업/폐업 번호 → validate 거부
- [ ] multipart 이미지 서버 저장 확인
- [ ] Admin 승인 후 앱 snapshot `approved` 반영

---

## 7. 관련 Flutter 파일

| 파일 | 역할 |
|------|------|
| `lib/view_models/shop_verification_view_model.dart` | OCR 플로우·제출 |
| `lib/utils/business_registration_validator.dart` | 클라이언트 체크섬 |
| `lib/models/business_registration_ocr_result.dart` | OCR DTO |
| `lib/models/business_registration_validation.dart` | 검증 DTO |
| `lib/mocks/mock_shop_data.dart` | mock OCR/validate |
| `lib/widgets/shop_verification/*` | UI |
