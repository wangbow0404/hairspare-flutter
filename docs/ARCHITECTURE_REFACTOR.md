# HairSpare 아키텍처 리팩터링 가이드

MVP 이후 유지보수·확장을 위한 단계별 플랜과 **현재 저장소에 반영된 범위**를 정리합니다.

## 완료된 작업 (본 PR)

| 항목 | 설명 |
|------|------|
| **의존성 주입 (get_it)** | `lib/core/di/service_locator.dart`에서 모든 `*Service`(`JobService`, `EducationService` 등)·`ImagePicker`(구인/교육 등록 등)와 앱 전역 `Provider`를 등록. `main()`에서 `configureDependencies()` 호출 후 `sl<AuthProvider>()` 등으로 주입. |
| **라우팅 (go_router)** | `lib/core/router/app_router.dart`에 루트·로그인·홈 경로 정의. `AppRoutes` / `AppNavigation`으로 홈·로그인 이동 시 `Navigator.pushReplacement(..., *HomeScreen())` 제거. |
| **모델 파싱 DRY** | `lib/utils/json_parse_utils.dart` 추가. `Job`, `User`, `Schedule`, `Application`이 중복 `_parseDateTime` / `_parseInt` 제거. |
| **마이그레이션 스크립트** | `tool/apply_navigation_migration.py` — 유사 패턴 추가 시 참고. |
| **StatefulShellRoute (하단 탭)** | 스페어·샵 각각 `StatefulShellRoute.indexedStack` + `lib/core/shell/main_tab_shell.dart`에서 `navigationShell.goBranch`로 탭 전환. 메인 탭 이동은 `AppNavigation.goSpareMainTab` / `goShopMainTab` (`context.go`로 경로 일치). |
| **Phase B (json_serializable)** | `lib/models/` 전 모델을 `@JsonSerializable` + `*.g.dart`로 통일. 공통 파싱은 `lib/models/json_converters.dart`(`JsonParseUtils` 위임). 예외: `ShopTierInfo`는 등급 재계산 로직 때문에 `fromJson`만 수동, `toJson`은 생성 코드. `ChallengeComment` 일부 필드는 API 별칭(`readValue`). **freezed**는 도입하지 않음(Phase D에서 UI State 등 필요 시 검토). |

## 다음 단계 (권장 순서)

### Phase B 유지보수

- 모델/어노테이션 변경 후: `dart run build_runner build --delete-conflicting-outputs`

### Phase C — injectable (선택)

- `@injectable` + 코드 생성으로 `service_locator.dart` 수동 등록을 줄임. 현재는 **get_it 수동 등록**으로 충분히 테스트 가능.

### Phase D — 화면 분해 & ViewModel

- 1,000줄 이상 `*_screen.dart`는 `lib/widgets/<feature>/` 하위 위젯으로 분리.
- 화면별 `ChangeNotifier` ViewModel(또는 기존 Provider 확장)으로 API/`setState` 이전.

**PoC 반영 (샵 스케줄):** `lib/screens/shop/schedule_screen.dart`를 `ChangeNotifierProvider` + `ShopScheduleViewModel`(`lib/view_models/shop_schedule_view_model.dart`)로 정리하고, 본문·모달·앱바는 `lib/widgets/shop_schedule/`로 분리. 스낵바는 `ShopScheduleSnackKind`로 ViewModel → 화면 콜백 매핑. `loadData`는 `_loadSchedules()` 순차 호출로 등급 계산 레이스를 제거.

**보존 위젯 (샵·기획 재연결용):** 등급 혜택 다이얼로그 `showShopTierBenefitsModal` → `lib/widgets/shop_schedule/shop_tier_benefits_modal.dart`, 샵 스케줄 상세 오버레이 `ShopScheduleDetailModal` → `lib/widgets/shop_schedule/shop_schedule_detail_modal.dart` (화면 버튼 미연결, 필요 시 import 후 사용).

**PoC 반영 (스페어 챌린지):** `Challenge` 엔티티는 `lib/models/challenge_feed.dart`, 상태는 `ChallengeViewModel`(`lib/view_models/challenge_view_model.dart`), UI 조각은 `lib/widgets/challenge/`(비디오 페이지·탭·제품·교육 카드·댓글 시트). `PageController`·`VideoPlayerController`·시청 타이머는 `challenge_screen.dart`의 `_ChallengeBody`에서 유지.

**PoC 반영 (스페어 근무체크):** `WorkCheckViewModel`(`lib/view_models/work_check_view_model.dart`), 본문·상단 Sliver·모달은 `lib/widgets/work_check/`(`work_check_scroll_content.dart`, `work_check_app_bar.dart`, `work_check_modals.dart`). 스낵바는 `WorkCheckSnackKind`로 ViewModel → 화면 콜백. 초기 `loadData`는 스케줄·통계를 **순차** 로드해 `Future.wait` 레이스를 피함. 검색 필드 `TextEditingController`만 화면 State에 두고 나머지는 ViewModel.

**PoC 반영 (스페어 구인 상세):** `JobDetailViewModel`(`lib/view_models/job_detail_view_model.dart`), UI는 `lib/widgets/job_detail/`(헤더·스크롤 본문·하단 바·본인인증/지원 확인 모달), 표시용 문자열·지역 더미 맵은 `job_detail_formatters.dart`. 스낵바는 `JobDetailSnackKind`로 ViewModel → 부모 `State` 콜백(`mounted` 가드). 초기 로드는 공고 `loadJob`과 인증·찜·에너지 조회를 **병렬** 시작(기존 `initState`와 동일). 공유는 ViewModel에서 `Share.share` 호출.

**PoC 반영 (샵 구인 등록):** `ShopJobNewViewModel`(`lib/view_models/shop_job_new_view_model.dart`)이 제목·설명·금액·인원·상세주소 `TextEditingController`, 이미지·지역·일정·급여 유형·급구 등 폼 상태를 보유하고 `dispose`에서 컨트롤러 정리. 검증은 ViewModel 메서드(`validateTitle`, `validateSelections` 등). UI는 `lib/widgets/shop_job_new/`(`shop_job_new_form_content.dart`, `shop_job_new_input_decoration.dart`). 날짜/시간 피커는 상위 함수 `shopJobNewPickDate` 등으로 분리. 스낵바는 `ShopJobNewSnackKind`. `ImagePicker`는 `service_locator`에 `registerLazySingleton` 후 `sl<ImagePicker>()`로 ViewModel에 주입.

**PoC 반영 (샵 교육 등록):** 기존 ~1,280줄 `education_new_screen.dart`를 `ShopEducationNewViewModel`(`lib/view_models/shop_education_new_view_model.dart`) + `lib/widgets/shop_education_new/`(폼·`InputDecoration`)로 분리, 화면 파일은 스캐폴드·스낵·제출만 유지. 등록 API는 `CreateEducationRequest` → `EducationService.createEducation`(`lib/services/education_service.dart`, `ApiConfig.useMockData` 시 지연·더미 `EducationPostResult`). 스낵바는 `ShopEducationNewSnackKind`, 마감일 피커는 `shopEducationNewPickDeadline`. 성공 후 짧은 지연 뒤 `Navigator.pop`은 구인 등록과 동일 UX.

**PoC 반영 (샵 홈):** `lib/screens/shop/home_screen.dart`는 `ChangeNotifierProvider` + `ShopHomeViewModel`(`lib/view_models/shop_home_view_model.dart`)과 본문 `ShopHomeScrollView`(`lib/widgets/shop_home/shop_home_scroll_view.dart`), 상단 행·대시보드·퀵액션 카드는 `shop_home_app_bar.dart`·`shop_home_cards.dart`로 분리. 초기 데이터는 `notificationProvider.loadNotifications()`·`getMyJobs()`·스페어 3종 `getSpares`를 **`Future.wait` 한 번으로 병렬** 로드한 뒤 급구/일반 공고 분리 및 대기 지원자 수 계산. `FavoriteProvider`·`ChatProvider` 로드는 `unawaited`로 동시에 시작. 오류 스낵은 `ShopHomeSnackKind`.

**PoC 반영 (샵 내 공고 목록):** `lib/screens/shop/jobs_list_screen.dart`는 `ShopJobsListViewModel`(`lib/view_models/shop_jobs_list_view_model.dart`) + `lib/widgets/shop_jobs_list/`(`shop_jobs_list_scroll_view.dart`, `shop_jobs_list_job_card.dart`). 탭(전체·진행·마감·임시저장) 변경 시 `jobs`를 비운 뒤 `refresh()`. 목록은 `JobService.getMyJobs`(status·search·limit·offset)로 **페이지 단위 로드**·`jobs`에 병합, `hasMore`는 마지막 응답 길이로 판단. `loadMore`는 스크롤 하단 근접 시, `RefreshIndicator`는 `refresh()`와 연동. 검색은 `TextEditingController` + 400ms 디바운스; 첫 로드만 전체 스피너, 이후 갱신은 `isRefreshing`+상단 `LinearProgressIndicator`. 스낵은 `ShopJobsListSnackKind`. **DI:** 추가 등록 없음 — 기존 `sl<JobService>()`. **목업:** `JobService.getMyJobs` mock 분기에서 검색·상태 필터·`limit`/`offset` 슬라이스 적용.

**PoC 반영 (샵 인증):** `lib/screens/shop/verification_screen.dart`는 `ShopVerificationViewModel`(`lib/view_models/shop_verification_view_model.dart`) + `lib/widgets/shop_verification/shop_verification_body.dart`. 사업자 단계는 `ShopBusinessVerificationUiPhase`(미인증·심사중·승인·반려)로 UI 분기; 심사 중(`pending`)은 폼 대신 안내 카드, 반려 시 사유 + 재제출 폼, 승인 시 스냅샷 정보 카드. 이미지는 `sl<ImagePicker>()`로 갤러리/카메라, 사업자등록증 필수·신분증 선택. 제출·대리인 신청은 `VerificationService.submitShopBusinessVerification` / `submitShopProxyVerification`(목업은 `Future.delayed`). DTO: `ShopBusinessVerificationSnapshot`, `ShopBusinessVerificationSubmit`. 초기 로드는 `getShopBusinessVerification`과 `getVerificationStatus`를 **`Future.wait`로 병렬**. 스낵은 `ShopVerificationSnackKind`. **DI:** 추가 등록 없음 — 기존 `ImagePicker`·`VerificationService`.

### Phase E — 전역 알림

- `ScaffoldMessenger` 반복 호출을 `Messenger`/라우터 Observer 등으로 좁혀, ViewModel이 `BuildContext`에 덜 의존하도록 조정.

## 관련 파일

- DI: `lib/core/di/service_locator.dart`
- 라우터: `lib/core/router/app_router.dart`, `app_routes.dart`, `app_navigation.dart`
- 탭 셸: `lib/core/shell/main_tab_shell.dart`
- JSON: `lib/utils/json_parse_utils.dart`, `lib/models/json_converters.dart`, 모델 `*.g.dart` (`build_runner` 생성)
- 진입점: `lib/main.dart`
