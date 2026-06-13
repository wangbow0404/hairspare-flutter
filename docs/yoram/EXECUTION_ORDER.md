# Yoram 실행 순서 (순서대로만 진행)

> 원칙: 동시에 다 하지 말고, 아래 순서대로 완료 체크하면서 진행.

## Phase 1 — 기준선 고정 (이번 주)

### Step 1. MVP 범위 고정
- [x] `MVP_REPLAN_ARCHITECTURE_DASHBOARD.md`에서 Must/Should/Won't 초안 정리
- [x] `MVP_SCOPE_V1.md` 리뷰 후 최종 확정
- [x] 미정 항목 5개 이내로 축소 (Decisions 3건 확정)
- [x] 결과를 한 문장으로 정의: "이번 스프린트에서 반드시 끝낼 것" → `MVP_SCOPE_V1.md` 상단 참조

### Step 2. 소스관리 규칙 적용
- [x] `SOURCE_CONTROL_POLICY.md` 팀 공유 (킥오프: `STEP2_SOURCE_CONTROL_KICKOFF.md`)
- [x] 브랜치 네이밍/PR 템플릿 규칙 공지 (`.github/pull_request_template.md`)
- [x] 다음 PR부터 규칙 적용 시작
- [ ] 팀 채널에 공지 붙여넣기 (Yoram 수동)
- [ ] GitHub `main` branch protection (repo admin)

### Step 3. 배포 리허설 계획 — ⏸ ON HOLD (백엔드 연동 후 재개)
- [x] `DEPLOYMENT_PIPELINE_V1.md` 기준으로 staging 리허설 체크리스트 작성 (`STEP3_STAGING_REHEARSAL.md`)
- [x] 문서 홀드: 날짜·QA/Dev → TBD (백엔드 연동 후 확정)
- [ ] 담당자(Release/QA/Dev) 확정 *(백엔드 연동 후)*
- [ ] 리허설 날짜 확정 *(백엔드 연동 후)*
- [ ] 리허설 실행 + 스모크 QA 완료 (`USE_MOCK_DATA=false` 빌드) *(백엔드 연동 후)*

## Phase 2 — 품질/신뢰성 (다음 2주)

### Step 4. 테스트 최소선 확보
- [ ] WorkCheck ViewModel 테스트 1차
- [ ] Challenge ViewModel 테스트 1차
- [ ] 릴리즈 전에 최소 smoke test 스크립트 작성

### Step 5. Go-Live 체크리스트 운영
- [ ] `GO_LIVE_CHECKLIST.md`를 다음 릴리즈에 실제 사용
- [ ] T-7 / T0 / T+1 항목 실제 체크
- [ ] 누락 항목 회고 반영

## Phase 3 — 운영 체계화 (그 다음)

### Step 6. 모니터링/장애 대응
- [ ] 크래시율/API 실패율/로그인 실패율 지표 수집 포인트 확정
- [ ] Sev1/2/3 분류 기준 문서화
- [ ] hotfix 대응 루틴 리허설

### Step 7. 수익화 실험 착수
- [ ] 수익화 가설 3개 정의
- [ ] 측정 지표(전환율/ARPU) 정의
- [ ] 실험 1건 착수

---

## 이번 주에 "무조건" 끝낼 것

- [x] Step 1 완료
- [x] Step 2 완료 (저장소 반영 완료 — 공지·branch protection 2건 수동 남음)
- [x] Step 3 문서·홀드 마무리 (실행은 백엔드 연동 후)

완료 기준(DoD):
- Step 1~2: 문서·저장소 반영 (Step 2 수동 2건은 여유 시)
- Step 3: 체크리스트 준비 완료 → **실행은 백엔드 연동 후**

---

## 현재 주력 (Phase 1 이후)

프론트엔드 **UI·로직 고도화** — [MVP_SCOPE_V1.md](MVP_SCOPE_V1.md) Must/Should 기준.

