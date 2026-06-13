# HairSpare Deployment Pipeline v2 (Team-Ready)

> 목표: "로컬 성공"이 아니라 "재현 가능한 배포"를 만든다.

---

## 1) 환경/채널 매핑

| 환경 | Flutter 빌드 | 배포 채널 | 목적 |
|---|---|---|---|
| `dev` | debug/profile | 로컬 디바이스/에뮬레이터 | 기능 개발 |
| `staging` | release-like | TestFlight / Play Internal | 통합 검증 |
| `prod` | release | App Store / Play Production | 실제 사용자 |

---

## 2) 환경변수 표준

필수 키(예시):
- `API_BASE_URL`
- `KAKAO_NATIVE_APP_KEY`
- `USE_MOCK_DATA` (release에서는 false 강제)

원칙:
- 시크릿은 CI Secret / `--dart-define`로만 주입
- `assets/env/app.env`에는 비시크릿 기본값만 유지

---

## 3) CI 기본 파이프라인

1. Checkout
2. Flutter SDK setup
3. `flutter pub get`
4. `dart analyze`
5. `flutter test` (테스트 존재 범위부터)
6. Build
   - Android: `flutter build appbundle --release`
   - iOS: `flutter build ipa --release`
7. Artifacts 업로드

---

## 4) CD 운영 규칙

## 4.1 Staging
- 트리거: `main`에서 릴리즈 후보 선택
- 배포: TestFlight / Internal track
- 승인: QA 체크리스트 통과 시 production 승격

## 4.2 Production
- 조건:
  - staging 검증 완료
  - Go-live checklist 통과
  - 릴리즈 노트 준비 완료
- 배포 후 24시간 모니터링 윈도우 운영

---

## 5) 배포 게이트 (필수)

- [ ] `dart analyze` 통과
- [ ] 핵심 플로우 수동 QA 통과
- [ ] 버전/빌드번호 증가
- [ ] `--dart-define` 값 검증
- [ ] 릴리즈 노트 작성
- [ ] 롤백 계획 명시

---

## 6) 롤백 전략

## 6.1 앱 롤백
- 이전 안정 태그 커밋으로 재빌드/재배포

## 6.2 서버/API 롤백
- 하위호환 API 유지
- 치명 이슈 시 문제 기능 임시 비활성(플래그 도입 시)

## 6.3 실행 조건
- Sev1 장애
- 크래시율 급증
- 핵심 퍼널(로그인/지원/근무체크) 붕괴

---

## 7) 이번 달 적용 순서

1. CI에 `dart analyze` 강제
2. staging 배포 루틴 문서화
3. release 태그 + 릴리즈 노트 자동/반자동화
4. 배포 후 모니터링 항목 고정

---

## 8) 최소 실행 명령 (로컬 검증)

```bash
flutter pub get
dart analyze
flutter test
flutter build appbundle --release
```
