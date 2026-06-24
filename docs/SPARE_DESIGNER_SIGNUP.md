# 스페어·디자이너 회원가입

HairSpare 앱에서 **스페어·디자이너**(미용 구직 전문가) 회원가입 흐름, 화면, 데이터, 라우팅을 정리한 문서입니다.

---

## 1. 개요

스페어·디자이너는 `UserRole.spare` + `SpareSubtype.professional` 계정입니다.  
모델(`SpareSubtype.model`)과 **같은 스페어 포털**에서 가입하지만, 폼·프로필 필드·가입 후 홈 경로가 다릅니다.

| 구분 | 스페어·디자이너 | 모델 |
|------|----------------|------|
| `spareSubtype` | `professional` | `model` |
| 가입 화면 | `SpareSignupProfessionalScreen` | `SpareSignupModelScreen` |
| 가입 후 홈 | `/spare/home` | `/model/home` |
| 핵심 기능 | 공고 지원 · 스케줄 · 에너지 결제 | 디자이너 매칭 · 채팅 |

---

## 2. 사용자 흐름

```
로그인 화면
  └─ [회원가입] → /spare/signup (유형 선택)
                    └─ [스페어·디자이너] → /spare/signup/professional (가입 폼)
                          └─ [회원가입] 성공 → /spare/signup/success
                                ├─ [본인인증 하기] → /spare/signup/success/verification
                                ├─ [홈으로 가기] → /spare/home
                                └─ [나중에 하기] → /spare/login
```

**진입점**

| 위치 | 동작 |
|------|------|
| `SpareLoginScreen` | `context.push(AppRoutes.spareSignup)` |
| `FindIdScreen` / `FindPasswordScreen` | `context.replace(AppRoutes.spareSignup)` |

---

## 3. 라우트

| 경로 | 상수 | 화면 | 공개(비로그인) |
|------|------|------|----------------|
| `/spare/signup` | `AppRoutes.spareSignup` | `SpareSignupTypeScreen` | ✅ |
| `/spare/signup/professional` | `AppRoutes.spareSignupProfessional` | `SpareSignupProfessionalScreen` | ✅ |
| `/spare/signup/model` | `AppRoutes.spareSignupModel` | `SpareSignupModelScreen` | ✅ |
| `/spare/signup/success` | `AppRoutes.spareSignupSuccess` | `SpareSignupSuccessScreen` | ❌ (로그인 필요) |
| `/spare/signup/success/verification` | `AppRoutes.spareSignupSuccessVerification` | `VerificationScreen` | ❌ |

라우터 정의: `lib/core/router/app_router.dart`  
공개 경로 화이트리스트: `lib/core/router/auth_redirect.dart` → `_isSparePublicPath()`

> **주의:** `/spare/signup/professional`, `/spare/signup/model`이 공개 경로에 없으면 비로그인 사용자가 폼으로 이동할 때 `/spare/login`으로 리다이렉트됩니다.

---

## 4. 화면별 상세

### 4.1 유형 선택 — `SpareSignupTypeScreen`

**파일:** `lib/screens/spare/spare_signup_type_screen.dart`

| UI | 내용 |
|----|------|
| AppBar | `회원가입` |
| 질문 | 어떤 활동을 하시나요? |
| 부제 | 가입 유형에 맞는 프로필을 설정해 드려요. |
| 카드 1 | **스페어·디자이너** — 미용 일자리를 찾고 있어요 / 공고 지원 · 스케줄 · 에너지 결제 |
| 카드 2 | **모델** — 헤어 시술 모델로 활동해요 |
| 하 footer | 이미 계정이 있으신가요? **로그인** (`Navigator.pop`) |

스페어·디자이너 카드 탭 → `context.push(AppRoutes.spareSignupProfessional)`

---

### 4.2 가입 폼 — `SpareSignupProfessionalScreen`

**파일:** `lib/screens/spare/spare_signup_professional_screen.dart`  
**AppBar:** `스페어·디자이너 가입`  
**부제:** 미용 일자리를 찾고 있어요

#### 계정 정보

| 필드 | 필수 | 클라이언트 검증 |
|------|------|-----------------|
| 아이디 | ✅ | 4자 이상 |
| 비밀번호 | ✅ | 6자 이상 |
| 비밀번호 확인 | ✅ | 비밀번호 일치 |
| 이름 | ✅ | 비어 있지 않음 |
| 휴대폰 | ✅ | 비어 있지 않음 |
| 이메일 | ❌ | — |
| 추천 코드 | ❌ | — |

#### 전문가 프로필

| 필드 | 필수 | 설명 |
|------|------|------|
| 활동 지역 | ✅ | 시/도 → 구/군 (`SpareSignupRegionPicker`) |
| 경력 | ✅ | 슬라이더 0~20년 (0 = 신입) |
| 전문 분야 | ✅ | 1개 이상 (`StitchFilterChip`) |
| 희망 시급 | ❌ | 숫자(원), 미입력 가능 |

**전문 분야 옵션** (`ProfessionalSpecialtyOptions.all`):

`커트` · `염색` · `펌` · `탈색` · `클리닉` · `드라이` · `스타일링`

#### 약관 동의 (전체 필수)

- 이용약관 동의
- 개인정보 처리방침 동의
- 개인정보 제공 및 이용 동의
- 만 14세 이상

위젯: `SpareSignupTermsAllRow`, `SpareSignupTermsSection`

#### 제출 전 추가 검증 (SnackBar)

1. 활동 지역 미선택 → `활동 지역을 선택해 주세요.`
2. 전문 분야 0개 → `전문 분야를 1개 이상 선택해 주세요.`
3. 약관 미동의 → `필수 약관에 동의해 주세요.`

#### 제출 (`_submit`)

```dart
auth.register(
  username: ...,
  password: ...,
  role: UserRole.spare,
  spareSubtype: SpareSubtype.professional,
  email: ...,        // optional
  name: ...,
  phone: ...,
  referralCode: ..., // optional
  profilePayload: ProfessionalSignupProfile(...).toJson(),
);
```

성공 시: `context.pushReplacement(AppRoutes.spareSignupSuccess)`  
실패 시: `AuthProvider.error` → 빨간 SnackBar

---

### 4.3 가입 완료 — `SpareSignupSuccessScreen`

**파일:** `lib/screens/spare/spare_signup_success_screen.dart`

| 버튼 | 동작 (디자이너) |
|------|-----------------|
| 본인인증 하기 | `/spare/signup/success/verification` |
| 홈으로 가기 | `AppNavigation.goSpareHome` → `/spare/home` |
| 나중에 하기 | `/spare/login` |

디자이너용 안내 문구:

> 본인인증을 완료하면 공고 지원·모델 매칭 등 모든 기능을 이용할 수 있어요.

---

### 4.4 본인인증 — `VerificationScreen`

**파일:** `lib/screens/spare/verification_screen.dart`  
`VerificationService`로 상태 조회 후 본인인증 진행.

---

## 5. 데이터 모델

### 5.1 `ProfessionalSignupProfile`

**파일:** `lib/models/spare_signup_data.dart`

```json
{
  "region": "서울특별시 강남구",
  "regionId": "<district 또는 province id>",
  "experienceYears": 3,
  "specialties": ["커트", "염색"],
  "hourlyRate": 25000
}
```

`hourlyRate`는 입력하지 않으면 JSON에서 생략됩니다.

### 5.2 API 요청 (프로덕션)

**엔드포인트:** `POST /api/auth/register`

**파일:** `lib/services/auth_service.dart`

```json
{
  "username": "string",
  "password": "string",
  "role": "spare",
  "spareSubtype": "professional",
  "email": "optional",
  "name": "string",
  "phone": "string",
  "referralCode": "optional",
  "profile": { /* ProfessionalSignupProfile */ }
}
```

응답: `data.user` → `User.fromJson`  
`User.spareSubtype == SpareSubtype.professional`, `isModelAccount == false`

### 5.3 Mock 모드

`ApiConfig.useMockData == true` 일 때:

- `MockAuthData.registerSpareUser()` 호출
- `mock_token` 저장 후 즉시 `User` 반환
- 프로필 payload는 `MockAuthData.registeredProfilePayload`에 보관

---

## 6. 인증·리다이렉트 규칙

**파일:** `lib/core/router/auth_redirect.dart`

| 상황 | 결과 |
|------|------|
| 비로그인 + 공개 가입 경로 | 허용 |
| 비로그인 + `/spare/signup/success` | → `/spare/login` |
| 로그인 + 공개 가입 경로 (success 제외) | → 역할별 홈 |
| 로그인 + 디자이너가 `/spare/*` | 허용 (스페어 홈 등) |
| 로그인 + 모델 계정이 `/model/*` 아닌 스페어 보호 경로 | → `/model/home` |

디자이너 가입 직후 `AuthProvider.isAuthenticated == true` (`_currentUser != null`) 이므로 success 화면 접근 가능.

---

## 7. 관련 파일 맵

```
lib/
├── screens/spare/
│   ├── spare_signup_type_screen.dart      # 1️⃣ 유형 선택
│   ├── spare_signup_professional_screen.dart  # 2️⃣ 디자이너 폼
│   ├── spare_signup_model_screen.dart     # (비교) 모델 폼
│   ├── spare_signup_success_screen.dart   # 3️⃣ 완료
│   └── verification_screen.dart           # 4️⃣ 본인인증
├── models/
│   ├── spare_signup_data.dart             # ProfessionalSignupProfile
│   ├── spare_subtype.dart                 # professional | model
│   └── user.dart                          # isModelAccount
├── widgets/spare_signup/
│   ├── spare_signup_text_field.dart
│   ├── spare_signup_region_picker.dart
│   └── spare_signup_terms_section.dart
├── providers/auth_provider.dart           # register()
├── services/auth_service.dart             # POST /api/auth/register
├── core/router/
│   ├── app_routes.dart
│   ├── app_router.dart
│   └── auth_redirect.dart
└── mocks/mock_auth_data.dart              # mock 가입
```

가입 폼 위젯은 프로필 편집에서도 재사용됩니다:

- `lib/widgets/spare_profile_edit/spare_profile_edit_basic_fields.dart`
- `lib/widgets/spare_profile_edit/spare_profile_edit_matching_fields.dart`

---

## 8. 서버·보안 체크리스트 (백엔드 연동 시)

클라이언트 검증은 UX용입니다. 서버에서 반드시 처리할 항목:

| 항목 | 권장 |
|------|------|
| `username` | 중복 검사, 길이·문자 규칙 |
| `password` | 최소 길이, 해시 저장 |
| `phone` | 형식 검증, 중복 정책 |
| `spareSubtype` | `professional` \| `model` enum |
| `profile.specialties` | allowlist (7종) |
| `profile.experienceYears` | 0~20 범위 |
| `profile.hourlyRate` | 양수 optional |
| `referralCode` | 유효 코드 검증 |
| JWT | register 응답에 `token`/`accessToken` 포함 권장 (세션 유지) |

---

## 9. 테스트·수동 확인

1. Hot Restart 후 `/spare/login` → 회원가입
2. **스페어·디자이너** 선택 → 가입 폼 표시 (로그인으로 튕기지 않음)
3. 필수 필드·약관 입력 → 회원가입 → success 화면
4. mock: 아무 아이디/비밀번호로 가입 가능 (`ApiConfig.useMockData`)

---

## 10. 알려진 이슈·개선 여지

| 항목 | 설명 |
|------|------|
| 유형 선택 화면 «로그인» | `Navigator.pop` 사용 — go_router 스택에 따라 동작이 달라질 수 있음. `context.pop()` 또는 `context.go(AppRoutes.spareLogin)` 검토 |
| 프로덕션 register 토큰 | mock은 `mock_token` 설정, API 모드는 User만 반환 — 앱 재시작 시 세션 복원 여부는 서버 토큰 응답에 의존 |
| success → login «나중에 하기» | 로그아웃 없이 login으로 이동 — 의도된 UX인지 확인 필요 |

---

*최종 갱신: 코드 기준 `lib/screens/spare/spare_signup_professional_screen.dart` 및 `auth_redirect.dart` public path 포함.*
