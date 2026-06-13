# Step 2 — 소스관리 규칙 적용 (킥오프)

> 적용 시작일: 2026-05-15  
> 정책 본문: [SOURCE_CONTROL_POLICY.md](../SOURCE_CONTROL_POLICY.md)

---

## 완료된 저장소 설정

- [x] `.github/pull_request_template.md` 추가 (다음 PR부터 자동 적용)
- [x] 브랜치·커밋·PR·릴리즈·핫픽스 규칙 문서화 (`SOURCE_CONTROL_POLICY.md`)

## 팀 공지 (복사해서 Slack/노션에 붙여넣기)

```
[HairSpare] 소스관리 규칙 적용 (2026-05-15~)

1) 브랜치
- main 직접 push 금지
- feature/ fix/ refactor/ docs/ hotfix/ + scope
- 1 PR = 1 목적, 수명 1~3일 권장

2) 커밋
- 형식: <type>: <summary>  (feat, fix, refactor, docs, chore, test)

3) PR (필수)
- dart analyze 통과
- 변경 범위 수동 QA
- 리뷰 1회 이상
- Rollback 포인트 기재
- GitHub PR 템플릿 자동 채우기

4) 릴리즈
- 태그: vMAJOR.MINOR.PATCH (main 머지 후)
- 핫픷: main → hotfix/<scope> → 검증 → main 머지 → patch 태그

문서: docs/SOURCE_CONTROL_POLICY.md
MVP 범위: docs/yoram/MVP_SCOPE_V1.md
```

## 저장소 관리자 1회 설정 (GitHub)

GitHub **Settings → Branches → Branch protection rules** (`main`):

- [ ] Require a pull request before merging
- [ ] Require approvals: 1 (팀 2명 이상일 때)
- [ ] Do not allow bypassing the above settings (권장)
- [ ] (선택) Require status checks — CI 추가 후 `dart analyze` 연동

## 다음 PR 체크리스트 (작성자)

1. `main`에서 `feature/<scope>` 또는 `fix/<scope>` 분기
2. PR 생성 시 템플릿 항목 전부 작성
3. `dart analyze` 로컬 통과 후 PR 오픈
4. 리뷰어 1명 지정

## Step 2 완료 기준

- [x] 정책 문서 공유용 메시지 준비 (위 블록)
- [x] PR 템플릿 저장소 반영
- [ ] 팀 채널에 공지 게시 (Yoram)
- [ ] `main` 브랜치 protection 설정 (repo admin)

> 위 두 항목(공지 게시, branch protection)만 하면 Step 2 DoD 충족.
