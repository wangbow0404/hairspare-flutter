# HairSpare 개발 브리핑 — 외부 개발자 미팅용

> **목적:** 진행 중인 Flutter 앱의 맥락·아키텍처·로드맵을 공유하고, 기술적 조언과 우선순위 검토를 받기 위한 문서입니다.  
> **참고:** 상세 리팩터링 타임라인은 [`ARCHITECTURE_REFACTOR.md`](./ARCHITECTURE_REFACTOR.md)와 병행해 읽으면 좋습니다.

---

## Sequential Thinking 요약 (사고 과정)

1. **문제 정의:** 외부 개발자가 빠르게 온보딩하려면 *제품 맥락*, *스택·폴더 구조*, *이미 한 일 / 남은 일*, *리스크*, *구체적 질문*이 한 번에 보여야 한다.
2. **정합성:** 내부 문서(`ARCHITECTURE_REFACTOR.md`)는 PoC 시점의 스낵바 콜백(`*SnackKind`) 등을 언급하지만, **현재 코드 기준**으로는 ViewModel이 `GlobalMessengerService`(get_it)로 전역 스낵을 띄우는 방향으로 정리된 상태다. 브리핑에서는 **코드 기준 현재 상태**를 우선한다.
3. **산출:** 아래 섹션은 위 두 가지를 반영해, 미팅에서 바로 읽고 질문으로 이어갈 수 있게 구성했다.

---

## 1. 한 줄 요약

**HairSpare**는 미용 분야에서 **스페어(구직자)**와 **샵(미용실)**을 연결하는 크로스플랫폼 앱(Flutter)으로, 구인·스케줄·에너지(포인트)·챌린지·공간 대여 등 MVP 기능을 포함하고 있다. 백엔드는 API 연동과 **목업 분기**가 공존하는 단계다.

---

## 2. 제품·비즈니스 맥락 (개발자에게 꼭 알려줄 것)

| 구분 | 설명 |
|------|------|
| **역할** | 스페어 / 샵(및 일부 관리자·교육 등) — 앱 내 **역할별 화면·탭**이 갈린다. |
| **핵심 플로우** | 로그인 → 홈 → 구인/스케줄/메시지/에너지 등 — 도메인이 나뉘어 있어 **기능별 서비스 클래스**가 많다. |
| **현 단계** | MVP 이후 **유지보수·확장 가능한 구조**로 리팩터링 중 (DI, 라우팅, 모델, ViewModel, 린트 정리 등). |

---

## 3. 기술 스택 & 실행

| 영역 | 선택 |
|------|------|
| **프레임워크** | Flutter (Material 3) |
| **상태 관리** | `provider` — 인증·알림·채팅 등 `ChangeNotifier` Provider + 화면별 ViewModel(`ChangeNotifier`) |
| **DI** | `get_it` — `lib/core/di/service_locator.dart`에서 `configureDependencies()`, `sl<T>()` |
| **라우팅** | `go_router` — `AppRoutes` / `AppNavigation`, 스페어·샵 **StatefulShellRoute** 탭 |
| **모델** | `json_serializable` + `*.g.dart`, 공통 파싱은 `json_converters.dart` 등 |
| **환경** | `assets/env/app.env` 등 (실제 키·엔드포인트는 배포 정책에 맞게 관리) |

**로컬 개발:** 의존성 설치 후 `flutter pub get`, 모델 생성 시 `dart run build_runner build --delete-conflicting-outputs`.  
품질 게이트로 **`dart analyze`를 이슈 0**에 맞춰 둔 상태(정책 변경 시 `analysis_options.yaml`와 함께 조정).

---

## 4. 아키텍처 개요 (레이어)

```
lib/
├── main.dart                 # 진입, DI 설정, MaterialApp.router + 전역 ScaffoldMessenger 키
├── core/
│   ├── di/                   # get_it 등록
│   ├── router/               # go_router, 네비게이션 헬퍼
│   ├── shell/              # 탭 셸 (indexedStack)
│   └── services/             # 예: global_messenger_service.dart (전역 스낵)
├── models/                   # JSON 직렬화 모델
├── services/                 # API·목업 분기가 있는 도메인 서비스
├── providers/                # 앱 전역 Provider (Auth, Chat, …)
├── view_models/              # 화면별 ChangeNotifier (스케줄, 구인 상세, 챌린지 등)
├── screens/                  # 스페어 / 샵 / 공통 / 관리자
└── widgets/                  # 기능별 분리 위젯 (job_detail, shop_schedule, challenge, …)
```

**의존성 방향(목표):**  
`UI (Screen/Widget)` → `ViewModel` / `Provider` → `Service` → `ApiClient` / 목업.

**전역 알림:** `GlobalMessengerService`를 DI에 등록하고 `MaterialApp.router(scaffoldMessengerKey: …)`와 동일 키로 연결. ViewModel은 **`BuildContext` 없이** `sl<GlobalMessengerService>()`로 성공/에러/일반 메시지를 표시한다.

---

## 5. 이미 해둔 일 (요약)

- **DI·라우팅·탭 셸** 정리, **모델 `json_serializable` 통일**.
- **대형 화면 분해** 및 **ViewModel 도입** (스케줄, 근무체크, 구인 상세/등록, 챌린지, 샵 홈, 공고 목록, 인증 등 — 세부는 `ARCHITECTURE_REFACTOR.md` 표 참고).
- **전역 스낵**으로 ViewModel–UI 결합 완화 (`GlobalMessengerService`).
- **Deprecated API·const·async context·미사용 코드** 등 린트 대청소로 **`dart analyze` 클린** 유지.

자세한 파일 매핑은 **`ARCHITECTURE_REFACTOR.md`의 완료 표**를 기준으로 하면 된다.

---

## 6. 앞으로의 진행 (로드맵 초안)

문서상 권장 순서와 실무에서 자주 붙는 다음 단계를 합쳐 정리했다.

| 우선순위 | 항목 | 메모 |
|----------|------|------|
| 높음 | **실서버/스테이징 API** 전환 시 목업 분기 정리 | `ApiConfig.useMockData` 등 분기 추적 |
| 높음 | **테스트** — ViewModel·서비스 단위, 핵심 플로우 위젯 | CI에 `dart test` / `flutter test` |
| 중간 | **injectable** 등으로 DI 등록 자동화 | 선택 — 현재 수동 등록으로도 동작 |
| 중간 | **남은 대형 화면** 추가 분해·ViewModel화 | `ARCHITECTURE_REFACTOR` Phase D |
| 중간 | **챌린지 비디오·성능** — 리스트/컨트롤러 생명주기 | 메모리·스크롤 이슈 예방 |
| 낮음·정리 | **`admin_*_old` 등 레거시** | 삭제 vs 유지 결정 |

---

## 7. 리스크·이슈 (솔직하게 공유할 포인트)

- **목업과 실 API**가 공존 — 전환 시 엣지 케이스·에러 처리 재검증 필요.
- **관리자·일부 서브 화면**은 사용 빈도가 낮아 리팩터링 우선순위에서 뒤로 밀릴 수 있음.
- **도메인이 넓음** — 한 번에 전부 “클린 아키텍처”로 가기보다 **기능 단위로 점진적**이 현실적이다.

---

## 8. 개발자에게 받고 싶은 조언 (질문 리스트)

미팅에서 아래를 **열린 질문**으로 던지면 논의가 잘 된다.

1. **아키텍처:** 현재 `Provider + ViewModel + Service` 조합에서, 팀 규모·납기 기준으로 **Riverpod/Bloc 등 전환**이 이득인 시점은 언제로 보는지.
2. **DI:** `get_it` 수동 등록 vs **injectable** — 이 코드베이스 규모에서 **ROI**가 나는지.
3. **테스트:** API 목업이 많을 때 **계약 테스트**·**golden test** 중 무엇부터 두는 게 좋은지.
4. **라우팅:** `go_router` + 중첩 셸에서 **딥링크·웹 확장**을 염두에 둘 때의 함정.
5. **성능:** 챌린지 피드처럼 **비디오 + 리스트**가 있는 화면의 권장 패턴(컨트롤러 풀, dispose 타이밍 등).
6. **배포:** 환경 분리(dev/stage/prod), **민감 정보**·`app.env` 관리 모범 사례.
7. **우선순위:** 위 로드맵 중 **실무에서 가장 먼저 할 일 한 가지**를 추천해 달라.

---

## 9. 미팅 체크리스트 (15분 안에)

- [ ] 제품 한 줄 + 주요 사용자(스페어/샵)
- [ ] 스택 & 폴더 한 장 (`core` / `services` / `view_models`)
- [ ] 완료된 리팩터링 3가지 + 전역 메신저
- [ ] 다음 분기 목표(실 API, 테스트, 성능 중 무엇을 먼저)
- [ ] 질문 리스트 중 **2~3개만** 골라 깊게 논의

---

*이 문서는 Sequential Thinking으로 논리 순서를 정리한 뒤 작성되었습니다.*
