# HairSpare Source Control Policy v2 (Team-Ready)

> 범위: Flutter 앱 저장소 기준. 팀이 바로 적용 가능한 운영 규칙만 남긴다.

---

## 1) 브랜치 모델 (Trunk-Based)

- 기본 모델: **`main` + 짧은 수명 브랜치**
- `develop`는 사용하지 않는다 (현재 팀 규모/속도 기준)
- 허용 브랜치
  - `feature/<scope>`
  - `fix/<scope>`
  - `refactor/<scope>`
  - `docs/<scope>`
  - `hotfix/<scope>`

### 규칙
- 브랜치 수명: 1~3일 권장
- 1 PR = 1 목적(기능/리팩터링/문서 혼합 최소화)
- `main` 직접 push 금지

---

## 2) 커밋 규칙

형식:
- `<type>: <summary>`

권장 type:
- `feat`, `fix`, `refactor`, `docs`, `chore`, `test`

예시:
- `fix: gate work check by end time`
- `feat: add local challenge mock videos`
- `docs: define deployment pipeline v2`

---

## 3) PR 운영 규칙

## 3.1 머지 조건 (필수)
- [ ] `dart analyze` 통과
- [ ] 변경 범위 수동 QA 완료
- [ ] 리뷰 승인 1회 이상
- [ ] 롤백 포인트 기재

## 3.2 PR 본문 템플릿 (실사용)

```md
## Summary
- 변경 요약 1~3개

## Why
- 문제/목적

## Scope
- 포함: ...
- 제외: ...

## Test
- [ ] dart analyze
- [ ] flutter test (해당 시)
- [ ] 수동 QA (시나리오 기재)

## Risk
- 잠재 리스크

## Rollback
- 되돌릴 커밋/파일/플래그
```

---

## 4) 릴리즈 태깅 정책

- 태그: `vMAJOR.MINOR.PATCH`
- 기준:
  - `PATCH`: 버그 수정
  - `MINOR`: 하위호환 기능 추가
  - `MAJOR`: 비호환 변경
- 태깅 위치: `main` 머지 완료 커밋

릴리즈 노트 필수 항목:
- 사용자 영향 변경점
- 주요 수정사항
- Known Issues

---

## 5) 핫픽스 규칙

1. `main`에서 `hotfix/<scope>` 분기
2. 최소 수정 원칙으로 패치
3. 검증: `dart analyze` + 핵심 스모크 테스트
4. PR 승인 후 `main` 머지
5. 즉시 태깅 (`vX.Y.Z+1` 개념의 다음 patch)

---

## 6) 금지 사항

- `main` 직접 수정
- 검증 누락 PR 머지
- 대규모 리팩터링과 기능 변경 동시 투입
- 시크릿/키를 코드/문서에 하드코딩

---

## 7) 주간 운영 루틴 (권장)

- 월: 이번 주 PR 목표 3개 정의
- 수: 중간 품질 점검 (`analyze`, 회귀 체크)
- 금: 태그 후보 선정 + 릴리즈 노트 초안

---

## 8) 적용 시작 체크리스트

- [x] PR 템플릿 적용 (`.github/pull_request_template.md`)
- [x] 브랜치 네이밍 팀 공지 문안 (`docs/yoram/STEP2_SOURCE_CONTROL_KICKOFF.md`)
- [x] 핫픽스 절차 팀 공유 (동 문서 + §5)
- [x] 릴리즈 태그 규칙 공유 (동 문서 + §4)
- [ ] 팀 채널 공지 게시 (수동)
- [ ] GitHub `main` branch protection 설정 (repo admin)
