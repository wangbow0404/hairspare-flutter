# Step 3 — Staging 배포 리허설

> **상태: ON HOLD** (백엔드 API 연동 전 — 2026-05-15)  
> 체크리스트는 작성 완료. 실제 리허설·`USE_MOCK_DATA=false` 빌드는 **백엔드 연동 후** 재개.

> 기준 문서: [DEPLOYMENT_PIPELINE_V1.md](../DEPLOYMENT_PIPELINE_V1.md) · [GO_LIVE_CHECKLIST.md](../GO_LIVE_CHECKLIST.md)  
> MVP 범위: [MVP_SCOPE_V1.md](MVP_SCOPE_V1.md)

---

## 홀드 사유

- 현재 시점에서는 staging `API_BASE_URL` + **`USE_MOCK_DATA=false`** 로 release 빌드 후 Must 플로우 스모크 QA를 **실행할 수 없음**.
- 문서·체크리스트만 준비해 두고, **날짜·담당·실행**은 백엔드 연동이 가능해진 뒤 확정.

### 재개 조건 (백엔드 연동 후)

- [ ] staging API 엔드포인트 확정 (`API_BASE_URL`)
- [ ] 인증·공고·스케줄/근무체크·Shop Must 동선이 mock 없이 동작
- [ ] `USE_MOCK_DATA=false` release 빌드 1회 성공

---

## 리허설 일정 (확정 시 기입)

| 항목 | 값 |
|------|-----|
| **날짜** | TBD (백엔드 연동 후 확정) |
| **시간** | TBD (백엔드 연동 후 확정) |
| **목표** | staging 채널에 release 빌드 1회 올리고 MVP Must 플로우 스모크 QA |

---

## 담당 (임시 배정)

| 역할 | 담당 | 할 일 |
|------|------|--------|
| **Release** | Yoram | 빌드·`--dart-define`·버전 번호·TestFlight/Internal 업로드 |
| **QA** | TBD (백엔드 연동 후 확정) | 아래 체크리스트 수동 실행·이슈 기록 |
| **Dev** | TBD (백엔드 연동 후 확정) | analyze/test 통과 확인·핫픽스 대응 가능 여부 |

---

## 리허설 전 (T-2 ~ T-1) — *실행 시 체크*

### 빌드·환경
- [ ] `flutter pub get`
- [ ] `dart analyze` 통과
- [ ] `flutter test` (도입된 Unit Test 범위) 통과
- [ ] staging `API_BASE_URL` / **`USE_MOCK_DATA=false`** 확인 *(백엔드 연동 후)*
- [ ] 버전·빌드번호 증가 기록

### 빌드 명령 (참고 — *백엔드 연동 후 사용*)

```bash
flutter pub get
dart analyze
flutter test

# Android Internal
flutter build appbundle --release \
  --dart-define=API_BASE_URL=<staging-url> \
  --dart-define=USE_MOCK_DATA=false

# iOS TestFlight (로컬/Xcode 또는 CI)
flutter build ipa --release \
  --dart-define=API_BASE_URL=<staging-url> \
  --dart-define=USE_MOCK_DATA=false
```

> **지금 단계:** 로컬 개발은 `USE_MOCK_DATA=true`(또는 debug mock)로 UI·로직 고도화 진행.

---

## 리허설 당일 — Staging 스모크 QA — *실행 시 체크*

MVP Must 기준 ([MVP_SCOPE_V1.md](MVP_SCOPE_V1.md)):

### Spare
- [ ] 역할 선택 → 로그인 → 세션 복원 → Spare 홈
- [ ] 공고 목록 / 상세 / 지원
- [ ] 스케줄 조회
- [ ] 근무체크: 종료 **전** 안내 / 종료 **후** 리뷰 모달
- [ ] 채팅·알림 AppBar 진입 (라우팅 오류 없음)
- [ ] 챌린지 피드 스크롤 + mock 영상 또는 fallback UI

### Shop
- [ ] 샵 인증 플로우
- [ ] 공고 등록
- [ ] 지원자 확인

### 공통
- [ ] 크래시 없이 15분 이상 사용
- [ ] 발견 이슈 Severity 표기 (Sev1/2/3)

---

## 리허설 후 (당일) — *실행 시 체크*

- [ ] 이슈 목록 정리 (Must 차단 vs Should)
- [ ] 롤백 필요 여부 판단 (이전 태그/빌드 번호 기록)
- [ ] `EXECUTION_ORDER.md` Step 3 실행 항목 체크 완료
- [ ] 다음 prod 후보일 또는 2차 리허설 일정

---

## Step 3 단계 정리 (2026-05-15)

| 항목 | 상태 |
|------|------|
| 체크리스트 문서 작성 | ✅ 완료 |
| 날짜·담당·실행 | ⏸ ON HOLD — 백엔드 연동 후 |

> Phase 1 문서 작업은 여기서 마무리. **현재 주력: 프론트엔드 UI·로직 고도화** (`MVP_SCOPE_V1.md` Must/Should).
