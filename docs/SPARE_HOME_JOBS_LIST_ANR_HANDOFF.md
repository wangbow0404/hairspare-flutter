# 스페어 홈 → 공고별(JobsListScreen) ANR 핸드오프

> **목적:** 다른 AI/개발자가 이 문서만 읽고 원인 추적·수정을 이어갈 수 있도록 정리한 문서입니다.  
> **작성일:** 2026-06-19  
> **상태:** P0 수정(auto-scroll 비활성화, DebugSessionLog 제거) 적용 후에도 **공고별 탭 시 멈춤(ANR) 재현** — 사용자 보고

---

## 1. 증상 요약

| 항목 | 내용 |
|------|------|
| **재현** | 스페어 계정 로그인(`1/1`) → 홈 탭 → 퀵메뉴 **「공고별」** 탭 |
| **결과** | 화면 전환 없음 / 앱 프리즈 / Android 「HairSpare isn't responding」 |
| **플랫폼** | iOS 시뮬레이터 + Android 에뮬레이터 모두 |
| **hot reload** | ANR 발생 후 `r`/`R` 무반응 → **앱 강제 종료 후 `flutter run` 필요** |
| **테스트 계정** | Spare/Shop `1/1`, Model `4/4` |

### 같이 멈춘다고 보고된 메뉴

- **공고별** → `JobsListScreen` (가장 자주 재현)
- **+포인트** → `PointsScreen`
- **모델매칭** → `ModelMatchFilterScreen`

### 상대적으로 동작한다고 본 메뉴

- **스케줄표** → `WorkCheckScreen` (push/pop ~2초, 정상)

### 별개 이슈 (ANR 아님)

- 홈 **급구/인기/신규** 카드가 예전 사진 대신 **그라데이션 + storefront 아이콘**으로 보임  
- 원인: `mock_spare_data.dart`에서 `picsum.photos` → `mock://` URL 변경 + `AppNetworkImage` placeholder 렌더  
- UX 회귀이며 **탭 멈춤과는 무관**

---

## 2. 네비게이션 구조 (핵심)

```
go_router
└── StatefulShellRoute.indexedStack  (/spare)
    └── MainTabShell (BottomNavBar)
        └── tab 0: SpareHomeScreen  ← IndexedStack에 유지됨 (push 후에도 살아 있음)
            └── SpareHomeScrollView (CustomScrollView + 많은 섹션)
                └── CategoryGrid → SpareHomeQuickMenu.buildCategories()
                    └── onTap: NavigationLock.pushPage(context, JobsListScreen())
                        └── Navigator.push (MaterialPageRoute)  ← imperative push
```

**중요:** `JobsListScreen`은 **go_router 서브 라우트가 아님**. 홈 위젯 트리의 `BuildContext`에서 `Navigator.push`로 올라감.  
홈 탭은 `indexedStack` 때문에 **push 후에도 백그라운드에서 마운트·리빌드 가능**.

관련 파일:

- [`lib/core/router/app_router.dart`](../lib/core/router/app_router.dart) — L116~ `StatefulShellRoute.indexedStack`
- [`lib/core/shell/main_tab_shell.dart`](../lib/core/shell/main_tab_shell.dart)
- [`lib/core/shell/lazy_shell_tab.dart`](../lib/core/shell/lazy_shell_tab.dart) — tab 1~3만 lazy, **홈(tab 0)은 항상 마운트**
- [`lib/widgets/spare_home/spare_home_quick_menu.dart`](../lib/widgets/spare_home/spare_home_quick_menu.dart)

---

## 3. 공고별 탭 코드 경로

### 3.1 퀵메뉴 탭

```dart
// lib/widgets/spare_home/spare_home_quick_menu.dart
CategoryItem(
  label: '공고별',
  onTap: () => _push(context, const JobsListScreen(), label: '공고별'),
),

static void _push(BuildContext context, Widget screen, {String? label}) {
  if (!context.mounted) return;
  unawaited(NavigationLock.pushPage(context, screen));
}
```

### 3.2 NavigationLock

```dart
// lib/utils/navigation_lock.dart
static Future<T?> pushPage<T>(BuildContext context, Widget page) {
  if (!context.mounted) return Future.value(null);
  return beginNavigation(
    Navigator.push<T>(
      context,
      MaterialPageRoute<T>(builder: (_) => page),
    ),
  );
}

static void _beginPush() {
  _activePushes++;
  _locked = true;
  _pauseHomeAutoScroll();  // 리스너 Set — 현재 auto-scroll 비활성화 후 거의 no-op
}
```

**참고:** auto-scroll pause 리스너는 `NewJobsSection`/`PopularJobsSection`에서 **이미 제거됨**. `NavigationLock`의 auto-scroll 관련 API는 **사실상 dead code**에 가깝지만 push 잠금(`_locked`)은 유지.

### 3.3 JobsListScreen 진입

```dart
// lib/screens/spare/jobs_list_screen.dart
@override
void initState() {
  super.initState();
  _activeFilter = widget.filter;
  _sortMode = widget.initialSortMode ?? JobsListSortMode.all;
  _searchQuery = widget.searchQuery;
  _scheduleDataLoad();   // route animation 완료 후 _loadData()
  _scheduleBodyReveal(); // animation 완료 후 _bodyReady = true
}

void _loadData() {
  final jobProvider = Provider.of<JobProvider>(context, listen: false);
  if (jobProvider.jobs.isEmpty) {
    jobProvider.loadJobs(...);  // 홈에서 이미 로드됐으면 skip
  }
  ...
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: SpareSubpageAppBar(title: '공고별', ...),
    body: Consumer<JobProvider>(
      builder: (context, jobProvider, _) {
        if (jobProvider.isLoading) return CircularProgressIndicator();
        if (!_bodyReady) return CircularProgressIndicator();  // 첫 프레임은 가벼워야 함
        // 이후: StitchFilterBar + ListView (필터·정렬·지역 드롭다운, ~600줄)
      },
    ),
  );
}
```

`JobsListScreen`은 **616줄** 단일 파일. `_bodyReady == false`일 때는 스피너만 그리도록 되어 있으나, **ANR은 initState 직후·첫 build 전후**에 발생했다는 로그가 있음.

---

## 4. 홈 화면 백그라운드 부하

### 4.1 SpareHomeScreen

```dart
// lib/screens/spare/home_screen.dart
// initState → loadInitial() → 2초 후 startPolling() (10초마다 notification/chat refresh)
await context.read<SpareHomeViewModel>().loadInitial();
await Future.delayed(const Duration(seconds: 2));
context.read<SpareHomeViewModel>().startPolling();
```

### 4.2 홈 스크롤 본문

[`lib/widgets/spare_home/spare_home_scroll_view.dart`](../lib/widgets/spare_home/spare_home_scroll_view.dart)

- `CustomScrollView` + 배너 + CategoryGrid + `SpareHomeJobSections`
- `Consumer<JobProvider>` — job 로딩/에러/섹션 전체

[`lib/widgets/spare_home/spare_home_job_sections.dart`](../lib/widgets/spare_home/spare_home_job_sections.dart)

- `Consumer2<JobProvider, FavoriteProvider>`
- `UrgentJobSection`, `CategoryJobsSection`, `PopularJobsSection`, `NewJobsSection`, `NormalJobsSection` 등
- 여러 곳에서 동일하게 `NavigationLock.pushPage(..., JobsListScreen(...))`

### 4.3 가로 캐러셀 (auto-scroll 수정 후)

[`lib/widgets/new_jobs_section.dart`](../lib/widgets/new_jobs_section.dart)  
[`lib/widgets/popular_jobs_section.dart`](../lib/widgets/popular_jobs_section.dart)

**이미 적용된 P0 수정:**

- `Timer.periodic` + `jumpTo()` **완전 제거**
- 수동 스크롤 + 3배 job 리스트 복제 유지
- `initState`에서 **1회** `postFrameCallback` → `jumpTo(oneSetWidth)` (무한 스크롤 중간 위치)

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted || !_scrollController.hasClients) return;
  _scrollController.jumpTo(oneSetWidth);
});
```

**잔여 의심:** push와 같은 프레임에 홈의 `jumpTo` postFrameCallback이 겹칠 수 있음 (NavigationLock이 auto-scroll 리스너 없이는 막지 못함).

### 4.4 JobProvider (전역, 홈·목록 공유)

[`lib/providers/job_provider.dart`](../lib/providers/job_provider.dart)

```dart
Future<void> loadJobs(...) async {
  _isLoading = true;
  notifyListeners();  // ← 홈 Consumer + JobsListScreen Consumer 동시 리빌드
  ...
  _isLoading = false;
  notifyListeners();
}
```

홈에서 이미 jobs가 있으면 `JobsListScreen._loadData()`는 `loadJobs()`를 **skip**하도록 수정됨.  
그러나 `setSearchQuery`, `loadFavorites`, polling 등 다른 `notifyListeners()` 경로는 여전히 존재.

---

## 5. 디버그 세션에서 확인된 런타임 증거

세션 ID `4582d4` (instrumentation은 **이미 제거됨**, `lib/utils/debug_session_log.dart` 삭제)

| 단계 | 로그/증상 |
|------|-----------|
| 탭 | quick menu tap — `mounted: true`, navigator 있음 |
| push 시작 | `JobsListScreen initState` 출력 |
| **멈춤 지점** | `body ready` / `runLoad` 로그 **없음** → initState 직후 main thread block |
| Android | `Signal Catcher`, tombstone, 「isn't responding」 |
| FlutterError | **없음** (Dart 예외가 아닌 ANR) |
| WorkCheckScreen | push/pop 정상 (~2초) |

**해석:** `Navigator.push` + `JobsListScreen` 첫 프레임·애니메이션 구간에서 UI thread가 수 초 이상 블록됨.  
원인이 `JobsListScreen` build 자체보다 **홈 IndexedStack + Provider 리빌드 + layout 경합**일 가능성이 큼.

---

## 6. 이미 시도한 수정 (P0, uncommitted working tree)

| 수정 | 파일 | 의도 | 사용자 결과 |
|------|------|------|-------------|
| auto-scroll `Timer.periodic` 제거 | `new_jobs_section.dart`, `popular_jobs_section.dart` | jumpTo 50ms × 2섹션 ANR | **공고별 여전히 멈춤** |
| `NavigationLock.pushPage` | `spare_home_quick_menu.dart`, `spare_home_job_sections.dart`, `spare_home_scroll_view.dart` | push 중 홈 scroll 경합 방지 | 효과 불명확 |
| `JobsListScreen` deferred body/load | `jobs_list_screen.dart` | animation 후 heavy UI | initState에서 이미 멈춤 → 효과 제한적 |
| `loadJobs()` skip if jobs non-empty | `jobs_list_screen.dart` | 홈 isLoading 연쇄 rebuild 방지 | 동일 |
| DebugSessionLog 전부 제거 | ~12 files | build/initState logcat 부하 | 동일 |
| ChallengeScreen dispose fix | `challenge_screen.dart` | dispose에서 context.read assertion | 챌린지와 무관 |
| picsum → mock:// | `mock_spare_data.dart` | hot reload 최적화 | 이미지만 변경, ANR 무관 |

---

## 7. 아직 검증되지 않은 가설 (우선순위)

### H1 — IndexedStack 홈 + imperative push 구조적 경합

- `StatefulShellRoute.indexedStack` 아래 홈이 살아 있는 상태에서 `MaterialPageRoute` push
- push transition + 홈 `CustomScrollView`(다수 sliver/section) 동시 layout
- **대안:** `JobsListScreen`을 go_router sub-route(`/spare/home/jobs`)로 올리고 `context.push` 사용 → 홈 subtree 일부 detach 가능성

### H2 — 홈 postFrameCallback `jumpTo` (1회)가 push 프레임과 겹침

- `NewJobsSection` / `PopularJobsSection` 각 1회
- push 탭 직후 같은 frame/postFrame에서 layout 폭주
- **대안:** jumpTo 제거 또는 `NavigationLock.isLocked` 체크 후 skip

### H3 — `JobsListScreen`의 `Consumer<JobProvider>`가 홈과 동시 subscribe

- push 직후 JobProvider 변경 시 홈 전체 `SpareHomeJobSections` + 목록 화면 동시 rebuild
- **대안:** 목록 화면에서 `Selector`/`listen: false` + local state, 또는 push 시 홈 `RepaintBoundary`/`AutomaticKeepAliveClientMixin(wantKeepAlive: false)` 검토

### H4 — `JobsListScreen` 첫 build 이후 `_bodyReady` reveal 시 600줄 UI 한 번에 빌드

- 사용자가 「탭 즉시」 멈춘다면 H4보다 H1~H3 가능성 높음
- reveal 이후 버벅임이면 H4 — `ListView.builder` lazy 확인, filter bar 분리

### H5 — `RegionHelper.getAllRegions()` 등 getter가 build마다 호출

```dart
// jobs_list_screen.dart — _provinces getter
List<Region> get _provinces {
  return RegionHelper.getAllRegions()
      .where((r) => r.type == RegionType.province)
      .toList();
}
```

- `_bodyReady` 이후에만 heavy UI지만, province list는 static ~17개 — 단독 ANR 원인 가능성 낮음

### H6 — binary stale (hot reload로 P0 미반영)

- ANR 시 hot reload 불가 → 사용자가 **full `flutter run` 없이** 테스트했을 수 있음
- **확인:** `q` 종료 → `flutter run` → 공고별 재현 여부

---

## 8. 재현·디버깅 체크리스트 (다음 AI용)

```bash
# 반드시 full rebuild
flutter run

# 로그인: spare 1/1
# 홈 → 공고별 탭
```

1. **Timeline / Performance overlay** — push 직후 어떤 widget build가 긴지
2. **`flutter run --profile`** + DevTools — UI/raster thread blocked 구간
3. **A/B:** `NewJobsSection`/`PopularJobsSection`의 `initState` jumpTo **주석 처리** 후 재현
4. **A/B:** `NavigationLock.pushPage` 대신 bare `Navigator.push` — lock이 오히려 문제인지
5. **A/B:** `JobsListScreen`을 빈 `Scaffold(appBar: AppBar(), body: Text('test'))`로 교체 — 여전히 ANR이면 **목록 UI가 아니라 push+홈 구조** 문제
6. **A/B:** go_router `GoRoute(path: 'jobs', ...)` 추가 후 `context.push('/spare/home/jobs')`

### Android logcat 키워드

```
Choreographer: Skipped
ANR in
JobsListScreen
Signal Catcher
```

---

## 9. 관련 파일 전체 목록

| 파일 | 역할 |
|------|------|
| [`lib/widgets/spare_home/spare_home_quick_menu.dart`](../lib/widgets/spare_home/spare_home_quick_menu.dart) | 공고별 onTap → pushPage |
| [`lib/utils/navigation_lock.dart`](../lib/utils/navigation_lock.dart) | push 잠금 + (unused) auto-scroll 리스너 |
| [`lib/screens/spare/jobs_list_screen.dart`](../lib/screens/spare/jobs_list_screen.dart) | 공고별 화면 (616 lines) |
| [`lib/screens/spare/home_screen.dart`](../lib/screens/spare/home_screen.dart) | 홈 탭 root |
| [`lib/widgets/spare_home/spare_home_scroll_view.dart`](../lib/widgets/spare_home/spare_home_scroll_view.dart) | 홈 CustomScrollView |
| [`lib/widgets/spare_home/spare_home_job_sections.dart`](../lib/widgets/spare_home/spare_home_job_sections.dart) | 급구/인기/신규 섹션 + JobsListScreen push |
| [`lib/widgets/new_jobs_section.dart`](../lib/widgets/new_jobs_section.dart) | 신규 공고 캐러셀 |
| [`lib/widgets/popular_jobs_section.dart`](../lib/widgets/popular_jobs_section.dart) | 인기 공고 캐러셀 |
| [`lib/providers/job_provider.dart`](../lib/providers/job_provider.dart) | 공고 전역 state |
| [`lib/core/router/app_router.dart`](../lib/core/router/app_router.dart) | StatefulShellRoute |
| [`lib/core/shell/lazy_shell_tab.dart`](../lib/core/shell/lazy_shell_tab.dart) | 비활성 탭 lazy (홈 제외) |
| [`lib/mocks/mock_spare_data.dart`](../lib/mocks/mock_spare_data.dart) | mock job ~11건, mock:// images |
| [`docs/HOT_RELOAD_GUIDE.md`](HOT_RELOAD_GUIDE.md) | hot reload·auto-scroll 정책 |

---

## 10. 권장 수정 방향 (미구현)

1. **최소 재현 테스트:** `JobsListScreen` → empty scaffold A/B (§8-5)
2. **go_router declarative route** for jobs list (§7-H1)
3. **홈 캐러셀 initState jumpTo 제거** (§7-H2)
4. ANR 해결 후 **P2:** mock job 로컬 asset 이미지 복원 (`AppNetworkImage` asset 지원)
5. auto-scroll 재도입 시: 단일 coordinator + 3초 `animateTo` + push 시 pause (§HOT_RELOAD_GUIDE)

---

## 11. git / 커밋 상태

- ANR 관련 수정 대부분 **uncommitted working tree**
- 최근 커밋 HEAD: `a16b085` (모델 계정 홈·가입·스케줄)
- P0 수정은 커밋되지 않았을 수 있음 → 다른 AI는 **현재 워킹 트리 파일 내용**을 기준으로 할 것

---

## 12. 다른 AI에게 붙여넣을 한 줄 요약

> Flutter HairSpare 앱에서 스페어 홈(`StatefulShellRoute.indexedStack` tab 0)이 살아 있는 채 `NavigationLock.pushPage` → `Navigator.push(JobsListScreen)` 시 Android/iOS ANR. Dart 예외 없음. initState까지 로그 후 freeze. auto-scroll Timer 제거·JobsListScreen deferred load·DebugSessionLog 제거 후에도 재현. imperative push vs indexedStack 홈 layout 경합 또는 홈 postFrame jumpTo 의심. `JobsListScreen`을 go_router sub-route로 옮기거나 empty scaffold A/B로 원인 분리 필요.
