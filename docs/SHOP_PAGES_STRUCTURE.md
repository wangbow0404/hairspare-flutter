# Shop(미용실) 페이지 구조 문서

> **목적**: 이 문서는 Flutter 프로젝트에서 Shop(미용실) 역할의 모든 페이지 구조, 기능, 코드 구성을 Sequential Thinking 방식으로 상세하게 정리한 문서입니다.  
> **대상**: Shop 역할의 화면 개발 및 유지보수를 담당하는 개발자(AI 포함)가 각 페이지의 구조와 기능을 빠르게 파악할 수 있도록 합니다.

---

## 📋 목차

1. [전체 개요](#1-전체-개요)
2. [홈 화면 (Home Screen)](#2-홈-화면-home-screen)
3. [인력별 화면 (Spares List Screen)](#3-인력별-화면-spares-list-screen)
4. [공고 관리 화면들](#4-공고-관리-화면들)
5. [스케줄 화면 (Schedule Screen)](#5-스케줄-화면-schedule-screen)
6. [포인트 화면 (Points Screen)](#6-포인트-화면-points-screen)
7. [기타 화면들](#7-기타-화면들)
8. [코드 구조 및 주요 클래스](#8-코드-구조-및-주요-클래스)
9. [API 연동 정보](#9-api-연동-정보)
10. [UI 컴포넌트 및 위젯](#10-ui-컴포넌트-및-위젯)

---

## 1. 전체 개요

### 1.1 Shop 역할의 목적

Shop(미용실) 역할은 미용실 관리자가 사용하는 인터페이스로, 다음과 같은 주요 기능을 제공합니다:

- **공고 관리**: 급구 인력 모집을 위한 공고 등록, 수정, 삭제, 마감
- **인력 검색**: 스페어(디자이너) 검색 및 필터링
- **지원자 관리**: 공고에 지원한 스페어의 승인/거절
- **스케줄 관리**: 확정된 일정 확인 및 근무 확인/정산
- **포인트 시스템**: 미션 완료를 통한 포인트 적립
- **메시지**: 스페어와의 채팅
- **프로필 관리**: 미용실 정보 관리

### 1.2 화면 구조

```
Shop 화면 구조
├── 홈 화면 (home_screen.dart)
│   ├── 대시보드 카드 (활성 공고, 대기 지원자, 오늘 일정)
│   ├── 빠른 액션 (공고 올리기, 내 공고 확인, 지원자 확인, VIP 현황)
│   ├── 급구 공고 섹션
│   ├── 인기/신규/일반 지원자 섹션
│   └── 일반 공고 섹션
│
├── 인력별 화면 (spares_list_screen.dart)
│   ├── 필터 섹션 (지역, 역할, 정렬, 상세 필터)
│   └── 스페어 목록
│
├── 공고 관리 화면들
│   ├── 공고 목록 (jobs_list_screen.dart)
│   ├── 공고 상세 (job_detail_screen.dart)
│   ├── 공고 등록 (job_new_screen.dart)
│   └── 지원자 관리 (applicants_screen.dart)
│
├── 스케줄 화면 (schedule_screen.dart)
│   ├── 날짜별 그룹화
│   ├── 시간 슬롯별 그룹화
│   └── 근무 확인 및 정산
│
├── 포인트 화면 (points_screen.dart)
│   ├── 보유 포인트
│   ├── 오늘의 미션
│   ├── 간단미션
│   ├── 참여미션
│   └── 구매미션
│
└── 기타 화면들
    ├── 메시지 (messages_screen.dart)
    ├── 프로필 (profile_screen.dart)
    ├── 공간대여 관리 (my_spaces_screen.dart, space_bookings_screen.dart)
    └── 스페어 상세 (spare_detail_screen.dart)
```

### 1.3 공통 UI 요소

모든 Shop 화면에 공통으로 적용되는 요소:

- **하단 네비게이션 바**: 홈, 결제, 찜, 마이 (4개 탭)
- **Sticky 헤더**: 로고, 검색, 메시지, 알림 버튼
- **알림 시스템**: `NotificationBell` 위젯 사용
- **메시지 알림**: 읽지 않은 메시지 개수 표시

---

## 2. 홈 화면 (Home Screen)

### 2.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/home_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/home/HomeContent.tsx`

### 2.2 화면 구조

#### 2.2.1 전체 레이아웃

```dart
CustomScrollView
├── SliverAppBar (Sticky 헤더)
│   ├── 로고 (HairSpare)
│   ├── 검색 버튼 / 검색 입력 필드
│   ├── 메시지 버튼 (읽지 않은 메시지 개수 배지)
│   └── 알림 버튼 (NotificationBell)
│
├── SliverToBoxAdapter (배너 캐러셀)
│   └── BannerCarousel (4개 배너 이미지)
│
├── SliverToBoxAdapter (카테고리 그리드)
│   └── CategoryGrid (8개 카테고리)
│       ├── 인력별 (👥)
│       ├── 스케줄표 (📅)
│       ├── 스토어 (🏪)
│       ├── +포인트 (💰)
│       ├── 공간대여 (🗺️)
│       ├── 교육 (📚)
│       ├── 챌린지참여 (🎯)
│       └── 커넥트 (💡)
│
├── SliverToBoxAdapter (대시보드 카드)
│   └── Row (3개 카드)
│       ├── 활성 공고 카드 (보라색 그라데이션)
│       ├── 대기 지원자 카드 (파란색 그라데이션)
│       └── 오늘 일정 카드 (초록색 그라데이션)
│
├── SliverToBoxAdapter (빠른 액션 섹션)
│   └── Column
│       ├── Row (공고 올리기, 내 공고 확인)
│       └── Row (지원자 확인, VIP 현황)
│
├── SliverToBoxAdapter (급구 공고 섹션)
│   └── SizedBox (가로 스크롤 ListView)
│
├── SliverToBoxAdapter (인기 지원자 섹션)
│   └── SizedBox (가로 스크롤 ListView, HOT 배지)
│
├── SliverToBoxAdapter (신규 지원자 섹션)
│   └── SizedBox (가로 스크롤 ListView)
│
├── SliverToBoxAdapter (일반 지원자 섹션) - 조건부
│   └── SliverList
│
├── SliverToBoxAdapter (일반 공고 섹션) - 조건부
│   └── SliverList
│
└── BottomNavBar (하단 네비게이션 바)
```

#### 2.2.2 주요 상태 변수

```dart
class _ShopHomeScreenState extends State<ShopHomeScreen> {
  // UI 상태
  final ScrollController _scrollController;
  bool _isSearchOpen;
  final TextEditingController _searchController;
  int _currentNavIndex;
  
  // 데이터
  List<SpareProfile> _popularSpares;      // 인기 스페어 목록
  List<SpareProfile> _newSpares;          // 신규 스페어 목록
  List<SpareProfile> _regularSpares;      // 일반 스페어 목록
  List<Job> _urgentJobs;                  // 급구 공고 목록
  List<Job> _normalJobs;                  // 일반 공고 목록
  bool _isLoading;                        // 로딩 상태
  int _pendingApplicantsCount;            // 대기 중인 지원자 수
  
  // 서비스
  final SpareService _spareService;
  final JobService _jobService;
}
```

#### 2.2.3 데이터 로딩 로직

**`_loadData()` 메서드:**

```dart
Future<void> _loadData() async {
  // 1. 알림 로드 (대기 중인 지원자 수 계산을 위해)
  await Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
  
  // 2. 자신이 등록한 공고 가져오기
  final jobs = await _jobService.getMyJobs();
  
  // 3. 급구와 일반 공고 분리
  final urgent = jobs.where((job) => job.isUrgent).toList();
  final normal = jobs.where((job) => !job.isUrgent).toList();
  
  // 4. 인기 스페어 가져오기 (평점 높고 완료 건수 많은 순)
  final popularSpares = await _spareService.getSpares(
    sortBy: 'popular',
    limit: 10,
  );
  
  // 5. 신규 스페어 가져오기 (최근 가입한 순)
  final newSpares = await _spareService.getSpares(
    sortBy: 'newest',
    limit: 10,
  );
  
  // 6. 일반 스페어 가져오기
  final regularSpares = await _spareService.getSpares(
    limit: 10,
  );
  
  // 7. 대기 중인 지원자 수 계산 (알림에서 spare_application 타입 카운트)
  final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
  final pendingApplicants = notificationProvider.notifications
      .where((n) => n.type == 'spare_application' && !n.isRead)
      .length;
  
  // 8. 상태 업데이트
  setState(() {
    _urgentJobs = urgent;
    _normalJobs = normal;
    _popularSpares = popularSpares;
    _newSpares = newSpares;
    _regularSpares = regularSpares;
    _pendingApplicantsCount = pendingApplicants;
    _isLoading = false;
  });
}
```

#### 2.2.4 주요 기능

1. **대시보드 카드 클릭**:
   - 활성 공고 카드 → 공고 목록 화면으로 이동
   - 대기 지원자 카드 → 지원자 관리 화면으로 이동 (구현 예정)
   - 오늘 일정 카드 → 스케줄 화면으로 이동

2. **빠른 액션**:
   - 공고 올리기 → 공고 등록 화면으로 이동
   - 내 공고 확인 → 공고 목록 화면으로 이동
   - 지원자 확인 → 지원자 관리 화면으로 이동 (구현 예정)
   - VIP 현황 → 출근체크 화면으로 이동

3. **카테고리 그리드**:
   - 각 카테고리 클릭 시 해당 화면으로 이동
   - 스토어는 아직 구현되지 않아 모달만 표시

4. **하단 네비게이션 바**:
   - 홈: 현재 화면이므로 스크롤만 맨 위로
   - 결제: `ShopPaymentScreen`으로 이동
   - 찜: `ShopFavoritesScreen`으로 이동
   - 마이: `ShopProfileScreen`으로 이동

---

## 3. 인력별 화면 (Spares List Screen)

### 3.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/spares_list_screen.dart`

### 3.2 화면 구조

#### 3.2.1 전체 레이아웃

```dart
CustomScrollView
├── SliverAppBar (Sticky 헤더)
│   ├── 뒤로가기 버튼
│   ├── 제목 "인력별" / 검색 입력 필드
│   ├── 검색 버튼 / 닫기 버튼
│   ├── 메시지 버튼 (읽지 않은 메시지 개수 배지)
│   └── 알림 버튼
│
├── SliverToBoxAdapter (필터 및 통계 섹션)
│   └── Container
│       ├── 전체 인력 수 및 통계 (스텝/디자이너 수)
│       ├── 필터 초기화 버튼 (조건부 표시)
│       ├── 지역 필터 버튼 및 드롭다운
│       ├── 역할 필터 (전체, 스텝, 디자이너)
│       ├── 정렬 옵션 (인기순, 신규순, 경력순, 완료건수순)
│       └── 상세 필터 (ExpansionTile)
│           ├── 면허 인증 필터
│           └── 최소 따봉 개수 필터 (10, 50, 100, 200개 이상)
│
└── SliverList / SliverFillRemaining (스페어 목록)
    └── SpareCard 위젯 리스트
        └── 인기 배지 (상위 3명, 인기순 정렬 시)
```

#### 3.2.2 주요 상태 변수

```dart
class _ShopSparesListScreenState extends State<ShopSparesListScreen> {
  // 데이터
  List<SpareProfile> _allSpares;           // 전체 스페어 목록
  List<SpareProfile> _filteredSpares;      // 필터링된 스페어 목록
  bool _isLoading;
  String? _error;
  bool _isSearchOpen;
  
  // 필터 상태
  String _searchQuery;                      // 검색어
  List<String> _selectedRegionIds;          // 선택한 지역 ID 목록
  String _roleFilter;                       // 'all' | 'step' | 'designer'
  String _sortBy;                           // 'popular' | 'newest' | 'experience' | 'completed'
  bool _isLicenseVerifiedOnly;              // 면허 인증 완료만
  int? _minThumbsUpCount;                   // 최소 따봉 개수
  bool _showRegionFilter;                   // 지역 필터 드롭다운 표시 여부
}
```

#### 3.2.3 필터링 로직

**`_applyFilters()` 메서드:**

```dart
void _applyFilters() {
  List<SpareProfile> filtered = List.from(_allSpares);
  
  // 1. 검색 필터
  if (_searchQuery.isNotEmpty) {
    final query = _searchQuery.toLowerCase();
    filtered = filtered.where((spare) {
      return spare.name.toLowerCase().contains(query) ||
          spare.specialties.any((s) => s.toLowerCase().contains(query)) ||
          RegionHelper.getRegionName(spare.regionId).toLowerCase().contains(query);
    }).toList();
  }
  
  // 2. 지역 필터
  if (_selectedRegionIds.isNotEmpty) {
    filtered = filtered.where((spare) => 
        _selectedRegionIds.contains(spare.regionId)
    ).toList();
  }
  
  // 3. 역할 필터
  if (_roleFilter == 'step') {
    filtered = filtered.where((spare) => spare.role == 'step').toList();
  } else if (_roleFilter == 'designer') {
    filtered = filtered.where((spare) => spare.role == 'designer').toList();
  }
  
  // 4. 면허 인증 필터
  if (_isLicenseVerifiedOnly) {
    filtered = filtered.where((spare) => spare.isLicenseVerified).toList();
  }
  
  // 5. 최소 따봉 개수 필터
  if (_minThumbsUpCount != null) {
    filtered = filtered.where((spare) => 
        spare.thumbsUpCount >= _minThumbsUpCount!
    ).toList();
  }
  
  // 6. 정렬
  switch (_sortBy) {
    case 'popular':
      // 인기순: 따봉 개수 * 완료 건수
      filtered.sort((a, b) {
        final aPopularity = a.thumbsUpCount * a.completedJobs;
        final bPopularity = b.thumbsUpCount * b.completedJobs;
        return bPopularity.compareTo(aPopularity);
      });
      break;
    case 'newest':
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case 'experience':
      filtered.sort((a, b) => b.experience.compareTo(a.experience));
      break;
    case 'completed':
      filtered.sort((a, b) => b.completedJobs.compareTo(a.completedJobs));
      break;
  }
  
  setState(() {
    _filteredSpares = filtered;
  });
}
```

#### 3.2.4 지역 필터 UI

**지역 필터 드롭다운:**

```dart
// 도/시 목록 표시
RegionHelper.getAllRegions()
    .where((r) => r.type == RegionType.province)
    .map((province) {
      final districts = RegionHelper.getDistrictsByProvince(province.id);
      final selectedDistricts = districts
          .where((d) => _selectedRegionIds.contains(d.id))
          .toList();
      final isAllSelected = districts.isNotEmpty &&
          selectedDistricts.length == districts.length;
      
      // 도/시 클릭 시 해당 도/시의 모든 구/군 선택/해제
      return InkWell(
        onTap: () {
          if (isAllSelected) {
            // 전체 해제
            _selectedRegionIds.removeWhere(
              (id) => districts.any((d) => d.id == id),
            );
          } else {
            // 전체 선택
            for (final district in districts) {
              if (!_selectedRegionIds.contains(district.id)) {
                _selectedRegionIds.add(district.id);
              }
            }
          }
          _applyFilters();
        },
        child: Container(
          // 선택 상태에 따라 스타일 변경
          decoration: BoxDecoration(
            color: isAllSelected ? AppTheme.purple100 : AppTheme.backgroundWhite,
            border: Border.all(
              color: isAllSelected ? AppTheme.primaryPurple : AppTheme.borderGray,
            ),
          ),
          child: Text('${province.name}${isAllSelected ? ' ✓' : ''}'),
        ),
      );
    })
```

#### 3.2.5 API 호출

```dart
Future<void> _loadSpares() async {
  final spares = await _spareService.getSpares(
    regionIds: _selectedRegionIds.isNotEmpty ? _selectedRegionIds : null,
    role: _roleFilter != 'all' ? _roleFilter : null,
    isLicenseVerified: _isLicenseVerifiedOnly ? true : null,
    sortBy: _sortBy,
    searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
  );
  
  setState(() {
    _allSpares = spares;
    _applyFilters();
    _isLoading = false;
  });
}
```

---

## 4. 공고 관리 화면들

### 4.1 공고 목록 화면 (Jobs List Screen)

#### 4.1.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/jobs_list_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/jobs/JobsContent.tsx`

#### 4.1.2 화면 구조

```dart
CustomScrollView
├── SliverAppBar (Sticky 헤더)
│   ├── 뒤로가기 버튼
│   ├── 제목 "내 공고"
│   ├── 검색 버튼 / 검색 입력 필드
│   └── 공고 등록 버튼 (+)
│
├── SliverToBoxAdapter (공고 등록 버튼)
│   └── ElevatedButton.icon ("새 공고 등록")
│
├── SliverToBoxAdapter (필터 및 통계)
│   └── Container
│       ├── 전체 공고 수 표시
│       └── 상태 필터 칩 (전체, 진행중, 마감, 임시저장)
│
└── SliverList / SliverFillRemaining (공고 목록)
    └── 공고 카드 리스트
        └── 페이지네이션 (10개씩)
```

#### 4.1.3 공고 카드 구조

```dart
Card
├── 이미지 섹션 (있는 경우)
│   ├── 네트워크 이미지
│   └── 이미지 개수 배지 (여러 장인 경우)
│
└── 내용 섹션
    ├── 헤더
    │   ├── 제목
    │   ├── 상태 배지 (진행중/마감/임시저장)
    │   ├── 급구 배지 (조건부)
    │   ├── 프리미엄 배지 (조건부)
    │   └── 액션 버튼들 (마감/재오픈, 수정, 삭제)
    │
    ├── 날짜/시간 및 지역 정보
    │
    ├── 통계 정보 카드
    │   ├── 금액
    │   └── 지원자 수 (0/필요인원명)
    │
    └── 액션 버튼
        ├── 지원자 관리 버튼 (지원자 수 표시)
        ├── 마감하기 버튼 (진행중인 경우)
        └── 재오픈 버튼 (마감된 경우)
```

#### 4.1.4 주요 기능

**공고 삭제:**

```dart
Future<void> _handleDelete(Job job) async {
  final confirmed = await showDialog<bool>(...);
  if (confirmed != true) return;
  
  await _jobService.deleteJob(job.id);
  await _loadJobs();
  // 성공 메시지 표시
}
```

**공고 마감:**

```dart
Future<void> _handleClose(Job job) async {
  final confirmed = await showDialog<bool>(...);
  if (confirmed != true) return;
  
  await _jobService.updateJobStatus(job.id, 'closed');
  await _loadJobs();
  // 성공 메시지 표시
}
```

**공고 재오픈:**

```dart
Future<void> _handleReopen(Job job) async {
  final confirmed = await showDialog<bool>(...);
  if (confirmed != true) return;
  
  await _jobService.updateJobStatus(job.id, 'published');
  await _loadJobs();
  // 성공 메시지 표시
}
```

#### 4.1.5 페이지네이션

```dart
// 페이지당 10개씩 표시
final int _itemsPerPage = 10;
int _currentPage = 1;

List<Job> get _paginatedJobs {
  final startIndex = (_currentPage - 1) * _itemsPerPage;
  final endIndex = startIndex + _itemsPerPage;
  return _filteredJobs.sublist(
    startIndex,
    endIndex > _filteredJobs.length ? _filteredJobs.length : endIndex,
  );
}

int get _totalPages => (_filteredJobs.length / _itemsPerPage).ceil();
```

**페이지네이션 UI:**

```dart
Row(
  children: [
    IconButton(
      icon: Icon(Icons.chevron_left),
      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
    ),
    // 페이지 번호 버튼 (최대 5개 표시)
    ...List.generate(
      _totalPages > 5 ? 5 : _totalPages,
      (index) => _buildPageNumberButton(...),
    ),
    IconButton(
      icon: Icon(Icons.chevron_right),
      onPressed: _currentPage < _totalPages 
          ? () => setState(() => _currentPage++) 
          : null,
    ),
  ],
)
```

### 4.2 공고 상세 화면 (Job Detail Screen)

#### 4.2.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/job_detail_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/jobs/[id]/JobDetailContent.tsx`

#### 4.2.2 화면 구조

```dart
Scaffold
├── AppBar
│   ├── 뒤로가기 버튼
│   ├── 제목
│   └── 액션 버튼들 (수정, 삭제)
│
└── SingleChildScrollView
    ├── 이미지 캐러셀 (여러 장인 경우)
    │   └── PageView.builder
    │
    ├── 공고 정보 섹션
    │   ├── 제목
    │   ├── 상태 배지, 급구 배지, 프리미엄 배지
    │   ├── 날짜/시간
    │   ├── 지역
    │   ├── 금액
    │   ├── 필요 인원
    │   ├── 공고 설명
    │   └── 요구사항
    │
    ├── 지원자 목록 섹션
    │   └── 각 지원자 카드
    │       ├── 스페어 정보
    │       ├── 지원 메시지
    │       └── 승인/거절 버튼
    │
    └── 액션 버튼
        ├── 지원자 관리 버튼
        ├── 마감하기 버튼 (진행중인 경우)
        └── 재오픈 버튼 (마감된 경우)
```

#### 4.2.3 이미지 캐러셀

```dart
PageView.builder(
  controller: PageController(initialPage: _selectedImageIndex),
  itemCount: _job?.images?.length ?? 0,
  itemBuilder: (context, index) {
    return Image.network(
      _job!.images![index],
      fit: BoxFit.cover,
    );
  },
  onPageChanged: (index) {
    setState(() {
      _selectedImageIndex = index;
    });
  },
)
```

### 4.3 공고 등록 화면 (Job New Screen)

#### 4.3.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/job_new_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/jobs/new/page.tsx`

#### 4.3.2 주요 폼 필드

```dart
Form
├── 제목 (TextField, 필수)
├── 날짜 선택 (DatePicker)
├── 시간 선택 (TimePicker)
├── 종료 시간 선택 (TimePicker, 선택)
├── 금액 (TextField, 숫자, 필수)
├── 필요 인원 (TextField, 숫자, 필수)
├── 지역 선택 (DropdownButtonFormField)
├── 공고 설명 (TextField, 여러 줄)
├── 요구사항 (TextField, 여러 줄)
├── 이미지 업로드 (최대 5장)
├── 급구 옵션 (Switch)
├── 프리미엄 옵션 (Switch)
└── 저장/등록 버튼
```

---

## 5. 스케줄 화면 (Schedule Screen)

### 5.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/schedule_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/schedule/page.tsx`

### 5.2 화면 구조

#### 5.2.1 전체 레이아웃

```dart
Scaffold
├── AppBar
│   ├── 뒤로가기 버튼
│   └── 제목 "스케줄"
│
└── Stack
    ├── ListView.builder (날짜별 그룹화된 스케줄 목록)
    │   └── 날짜별 컨테이너
    │       ├── 날짜 헤더 (yyyy년 M월 d일 (요일))
    │       └── 시간 슬롯별 그룹
    │           ├── 시간 슬롯 헤더
    │           │   ├── 시간 및 공고 제목
    │           │   ├── 필요 인원 / 확정 인원
    │           │   └── 충원 완료 / 모집 중 배지
    │           └── 각 스케줄 상세 정보
    │               ├── 스페어 이름
    │               ├── 금액
    │               ├── 상태 배지
    │               ├── 체크인 시간 (있는 경우)
    │               └── 근무 확인 및 정산 버튼 (완료된 스케줄만)
    │
    └── 따봉 모달 (조건부 표시)
        ├── 제목 "근무 확인 및 정산"
        ├── 설명 텍스트
        └── 버튼
            ├── 정산만 하기
            ├── 따봉 보내기
            └── 취소
```

#### 5.2.2 데이터 그룹화 로직

**`_groupSchedulesByDateAndTime()` 메서드:**

```dart
Map<String, List<_ScheduleSlot>> _groupSchedulesByDateAndTime() {
  final grouped = <String, List<_ScheduleSlot>>{};
  
  for (final schedule in _schedules) {
    final dateStr = schedule.date;
    if (!grouped.containsKey(dateStr)) {
      grouped[dateStr] = [];
    }
    
    final timeStr = schedule.startTime;
    // 기존 슬롯 찾기
    _ScheduleSlot? existingSlot;
    for (final slot in grouped[dateStr]!) {
      if (slot.time == timeStr) {
        existingSlot = slot;
        break;
      }
    }
    
    if (existingSlot != null) {
      // 기존 슬롯에 추가
      existingSlot.confirmedCount += 1;
      existingSlot.schedules.add(schedule);
    } else {
      // 새 슬롯 생성
      grouped[dateStr]!.add(_ScheduleSlot(
        date: dateStr,
        time: timeStr,
        requiredCount: schedule.job?.requiredCount ?? 1,
        confirmedCount: 1,
        schedules: [schedule],
      ));
    }
  }
  
  // 시간 순으로 정렬
  grouped.forEach((date, slots) {
    slots.sort((a, b) => a.time.compareTo(b.time));
  });
  
  return grouped;
}
```

#### 5.2.3 _ScheduleSlot 클래스

```dart
class _ScheduleSlot {
  final String date;                    // 날짜 (YYYY-MM-DD)
  final String time;                   // 시간 (HH:mm)
  final int requiredCount;              // 필요 인원
  int confirmedCount;                   // 확정 인원 (변경 가능)
  final List<Schedule> schedules;      // 해당 시간대의 스케줄 목록
  
  _ScheduleSlot({
    required this.date,
    required this.time,
    required this.requiredCount,
    required this.confirmedCount,
    required this.schedules,
  });
}
```

#### 5.2.4 근무 확인 및 정산

**따봉 모달 표시:**

```dart
void _handleConfirmWork(String scheduleId) {
  setState(() {
    _selectedScheduleId = scheduleId;
    _showThumbsUpModal = true;
  });
}
```

**정산 처리:**

```dart
Future<void> _handleThumbsUpConfirm(bool giveThumbsUp) async {
  // 1. 정산 API 호출
  final result = await _scheduleService.confirmWork(
    scheduleId: _selectedScheduleId!,
    thumbsUp: giveThumbsUp,
  );
  
  // 2. 따봉이 true인 경우 따봉 API 호출
  if (giveThumbsUp) {
    final schedule = _schedules.firstWhere(
      (s) => s.id == _selectedScheduleId,
    );
    await _spareService.giveThumbsUpToSpare(schedule.spareId);
  }
  
  // 3. 성공 메시지 표시
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        giveThumbsUp
            ? '정산이 완료되었습니다.\n정산 금액: ${result['amount']}원\n예약금 반환: ${result['returnedEnergy']}개\n\n👍 따봉을 보냈습니다!'
            : '정산이 완료되었습니다.\n정산 금액: ${result['amount']}원\n예약금 반환: ${result['returnedEnergy']}개'
      ),
      backgroundColor: AppTheme.primaryGreen,
    ),
  );
  
  // 4. 모달 닫기 및 스케줄 새로고침
  setState(() {
    _showThumbsUpModal = false;
    _selectedScheduleId = null;
  });
  
  await _loadSchedules();
}
```

#### 5.2.5 상태 표시

**상태별 색상 및 텍스트:**

```dart
Color _getStatusColor(String status) {
  switch (status) {
    case 'scheduled':
      return AppTheme.primaryPurple;  // 예정됨
    case 'completed':
      return AppTheme.primaryBlue;    // 근무 완료
    case 'cancelled':
      return AppTheme.urgentRed;      // 취소됨
    default:
      return AppTheme.textSecondary;
  }
}

String _getStatusText(String status) {
  switch (status) {
    case 'scheduled':
      return '예정됨';
    case 'completed':
      return '근무 완료';
    case 'cancelled':
      return '취소됨';
    default:
      return status;
  }
}
```

---

## 6. 포인트 화면 (Points Screen)

### 6.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/points_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/points/PointsContent.tsx`

### 6.2 현재 상태

**⚠️ 아직 구현되지 않음** - 플레이스홀더만 존재합니다.

### 6.3 예상 구조 (Next.js 참고)

#### 6.3.1 전체 레이아웃

```dart
Scaffold
├── AppBar
│   ├── 로고
│   ├── 검색 버튼
│   ├── 메시지 버튼
│   └── 알림 버튼
│
└── SingleChildScrollView
    ├── 상단 배너 (광고용 그라데이션)
    │
    ├── 보유 포인트 섹션
    │   ├── 노란색 원 아이콘 (P)
    │   └── 포인트 금액 표시
    │
    ├── 오늘의 미션 섹션
    │   ├── 제목 "오늘의 미션"
    │   ├── 설명 "매주 일요일 00시에 초기화돼요"
    │   └── 출석체크 미션 카드
    │       ├── 아이콘 (🎮)
    │       ├── 제목 "출석체크"
    │       ├── 설명 "포포몬"
    │       └── 완료 버튼 (10P)
    │
    ├── 간단미션 섹션
    │   ├── 제목 "간단미션"
    │   ├── 더보기 버튼
    │   └── 미션 카드 리스트 (5개 표시, 더보기 클릭 시 전체 표시)
    │       ├── 아이콘 이미지
    │       ├── 제목 및 설명
    │       └── 완료 버튼 (포인트 표시)
    │
    ├── 참여미션 섹션
    │   ├── 제목 "참여미션"
    │   ├── 더보기 버튼
    │   └── 미션 카드 리스트 (5개 표시)
    │
    ├── 구매미션 섹션
    │   ├── 제목 "구매미션"
    │   ├── 더보기 버튼
    │   └── 미션 카드 리스트 (2개 표시)
    │
    └── 하단 배너 (광고용 그라데이션)
```

#### 6.3.2 미션 타입

```dart
enum MissionCategory {
  daily,          // 오늘의 미션 (출석체크)
  simple,         // 간단미션 (채널 추가, 구독하기 등)
  participation,  // 참여미션 (클릭하고 보기, 음악 듣기 등)
  purchase,       // 구매미션 (상품 구매)
}
```

#### 6.3.3 미션 모델 (예상)

```dart
class Mission {
  final String id;
  final String title;
  final String description;
  final int points;
  final String? icon;        // 이모지 아이콘
  final String? iconUrl;      // 이미지 URL
  final bool completed;
  final MissionCategory category;
  
  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.icon,
    this.iconUrl,
    required this.completed,
    required this.category,
  });
}
```

#### 6.3.4 필요한 구현 사항

1. **미션 목록 API 연동**:
   - `GET /api/points/missions` - 미션 목록 조회
   - 미션 타입별로 필터링

2. **미션 완료 처리 API 연동**:
   - `POST /api/points/missions/{id}/complete` - 미션 완료 처리
   - 포인트 적립 및 완료 상태 업데이트

3. **포인트 조회 API 연동**:
   - `GET /api/points/balance` - 현재 보유 포인트 조회

4. **출석체크 기능**:
   - 매주 일요일 00시에 초기화
   - 오늘의 미션 완료 여부 확인

---

## 7. 기타 화면들

### 7.1 메시지 화면 (Messages Screen)

#### 7.1.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/messages_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/messages/MessagesContent.tsx`

#### 7.1.2 주요 기능

- 채팅방 목록 표시
- 읽지 않은 메시지 개수 표시
- 스와이프 삭제 기능 (`Dismissible` 위젯 사용)
- 채팅방 클릭 시 채팅방 화면으로 이동

### 7.2 프로필 화면 (Profile Screen)

#### 7.2.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/profile_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/profile/page.tsx`

#### 7.2.2 주요 기능

- 미용실 정보 표시
- 메뉴 항목:
  - 프로필 편집
  - 결제 내역
  - 설정
  - 인증
  - 지원자 관리
  - 계정 삭제

### 7.3 공간대여 관리 화면들

#### 7.3.1 내 공간 관리 (My Spaces Screen)

**파일 위치**: `/Users/yoram/flutter/lib/screens/shop/my_spaces_screen.dart`

**주요 기능**:
- 미용실이 등록한 공간대여 목록 표시
- 공간 등록/수정/삭제

#### 7.3.2 공간 예약 관리 (Space Bookings Screen)

**파일 위치**: `/Users/yoram/flutter/lib/screens/shop/space_bookings_screen.dart`

**주요 기능**:
- 공간대여 예약 목록 표시
- 예약 승인/거절
- 예약 취소 처리

### 7.4 지원자 관리 화면 (Applicants Screen)

#### 7.4.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/applicants_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/jobs/[id]/applicants/page.tsx`

#### 7.4.2 주요 기능

- 공고별 지원자 목록 표시
- 지원자 상세 정보 확인
- 지원자 승인/거절 기능
- 지원자와의 채팅 시작

### 7.5 스페어 상세 화면 (Spare Detail Screen)

#### 7.5.1 파일 위치

**Flutter**: `/Users/yoram/flutter/lib/screens/shop/spare_detail_screen.dart`  
**Next.js 참고**: `/Users/yoram/hairspare/app/shop/spares/[id]/SpareDetailContent.tsx`

#### 7.5.2 주요 기능

- 스페어 프로필 정보 표시:
  - 이름, 프로필 이미지
  - 경력, 전문분야
  - 완료 건수, 따봉 수
  - 면허 인증 여부
  - 지역
- 채팅하기 버튼
- 찜하기 기능

---

## 8. 코드 구조 및 주요 클래스

### 8.1 주요 서비스 클래스

#### 8.1.1 JobService

**파일 위치**: `/Users/yoram/flutter/lib/services/job_service.dart`

**주요 메서드:**

```dart
class JobService {
  // 자신이 등록한 공고 목록 조회
  Future<List<Job>> getMyJobs();
  
  // 공고 상세 조회
  Future<Job> getJobById(String jobId);
  
  // 공고 등록
  Future<Job> createJob(CreateJobRequest request);
  
  // 공고 수정
  Future<Job> updateJob(String jobId, UpdateJobRequest request);
  
  // 공고 삭제
  Future<void> deleteJob(String jobId);
  
  // 공고 상태 변경 (마감/재오픈)
  Future<void> updateJobStatus(String jobId, String status);
}
```

#### 8.1.2 SpareService

**파일 위치**: `/Users/yoram/flutter/lib/services/spare_service.dart`

**주요 메서드:**

```dart
class SpareService {
  // 스페어 목록 조회 (필터링 및 정렬 지원)
  Future<List<SpareProfile>> getSpares({
    List<String>? regionIds,
    String? role,
    bool? isLicenseVerified,
    String? sortBy,  // 'popular' | 'newest' | 'experience' | 'completed'
    String? searchQuery,
    int? limit,
  });
  
  // 스페어 상세 조회
  Future<SpareProfile> getSpareById(String spareId);
  
  // 따봉 보내기
  Future<void> giveThumbsUpToSpare(String spareId);
}
```

#### 8.1.3 ScheduleService

**파일 위치**: `/Users/yoram/flutter/lib/services/schedule_service.dart`

**주요 메서드:**

```dart
class ScheduleService {
  // 스케줄 목록 조회
  Future<List<Schedule>> getSchedules({
    String? ownerId,  // 'me'로 설정 시 자신의 공고에 대한 스케줄만 조회
  });
  
  // 근무 확인 및 정산
  Future<Map<String, dynamic>> confirmWork({
    required String scheduleId,
    required bool thumbsUp,
  });
}
```

### 8.2 주요 모델 클래스

#### 8.2.1 Job 모델

**파일 위치**: `/Users/yoram/flutter/lib/models/job.dart`

**주요 필드:**

```dart
class Job {
  final String id;
  final String title;
  final String date;              // YYYY-MM-DD
  final String time;              // HH:mm
  final String? endTime;          // HH:mm
  final int amount;               // 금액
  final int energy;               // 에너지
  final int requiredCount;        // 필요 인원
  final String status;            // 'draft' | 'published' | 'closed'
  final bool isUrgent;            // 급구 여부
  final bool isPremium;           // 프리미엄 여부
  final String regionId;          // 지역 ID
  final String? description;      // 공고 설명
  final String? requirements;     // 요구사항
  final List<String>? images;      // 이미지 URL 목록
  final DateTime createdAt;
  final Shop? shop;               // 미용실 정보
}
```

#### 8.2.2 SpareProfile 모델

**파일 위치**: `/Users/yoram/flutter/lib/models/spare_profile.dart`

**주요 필드:**

```dart
class SpareProfile {
  final String id;
  final String name;
  final String? profileImageUrl;
  final String role;              // 'step' | 'designer'
  final int experience;            // 경력 (년)
  final List<String> specialties;  // 전문분야 목록
  final String regionId;          // 지역 ID
  final bool isLicenseVerified;   // 면허 인증 여부
  final int thumbsUpCount;        // 따봉 개수
  final int completedJobs;        // 완료 건수
  final DateTime createdAt;
}
```

#### 8.2.3 Schedule 모델

**파일 위치**: `/Users/yoram/flutter/lib/models/schedule.dart`

**주요 필드:**

```dart
class Schedule {
  final String id;
  final String date;              // YYYY-MM-DD
  final String startTime;        // HH:mm
  final String? endTime;         // HH:mm
  final String status;           // 'scheduled' | 'completed' | 'cancelled'
  final DateTime? checkInTime;   // 체크인 시간
  final String spareId;          // 스페어 ID
  final SpareProfile? spare;     // 스페어 정보
  final String jobId;            // 공고 ID
  final Job? job;                // 공고 정보
}
```

### 8.3 주요 위젯

#### 8.3.1 SpareCard

**파일 위치**: `/Users/yoram/flutter/lib/widgets/spare_card.dart`

**주요 구성 요소:**

```dart
Card
├── 프로필 이미지
├── 이름
├── 역할 배지 (스텝/디자이너)
├── 경력 및 전문분야
├── 지역
├── 통계 정보
│   ├── 완료 건수
│   ├── 따봉 수
│   └── 면허 인증 배지 (조건부)
└── 탭 이벤트 핸들러
```

#### 8.3.2 BottomNavBar

**파일 위치**: `/Users/yoram/flutter/lib/widgets/bottom_nav_bar.dart`

**주요 구성 요소:**

```dart
BottomNavigationBar
├── 홈 탭 (index: 0)
├── 결제 탭 (index: 1)
├── 찜 탭 (index: 2)
└── 마이 탭 (index: 3)
```

---

## 9. API 연동 정보

### 9.1 공고 관련 API

#### 9.1.1 자신이 등록한 공고 목록 조회

**엔드포인트**: `GET /api/jobs?ownerId=me`

**요청 헤더:**
```
Authorization: Bearer {token}
```

**응답 예시:**
```json
{
  "data": {
    "jobs": [
      {
        "id": "job-123",
        "title": "급구 디자이너 모집",
        "date": "2026-02-10",
        "time": "09:00",
        "amount": 150000,
        "requiredCount": 2,
        "status": "published",
        "isUrgent": true,
        ...
      }
    ]
  }
}
```

#### 9.1.2 공고 상태 변경

**엔드포인트**: `PATCH /api/jobs/{id}/status`

**요청 본문:**
```json
{
  "status": "closed"  // "published" | "closed" | "draft"
}
```

### 9.2 스페어 관련 API

#### 9.2.1 스페어 목록 조회

**엔드포인트**: `GET /api/spares`

**쿼리 파라미터:**
- `regionIds`: 지역 ID 목록 (쉼표로 구분)
- `role`: 역할 (`step` | `designer`)
- `isLicenseVerified`: 면허 인증 여부 (`true` | `false`)
- `sortBy`: 정렬 기준 (`popular` | `newest` | `experience` | `completed`)
- `searchQuery`: 검색어
- `limit`: 최대 개수

**응답 예시:**
```json
{
  "data": {
    "spares": [
      {
        "id": "spare-123",
        "name": "홍길동",
        "role": "designer",
        "experience": 5,
        "thumbsUpCount": 120,
        "completedJobs": 45,
        ...
      }
    ]
  }
}
```

### 9.3 스케줄 관련 API

#### 9.3.1 스케줄 목록 조회

**엔드포인트**: `GET /api/schedules?ownerId=me`

**응답 예시:**
```json
{
  "data": {
    "schedules": [
      {
        "id": "schedule-123",
        "date": "2026-02-10",
        "startTime": "09:00",
        "status": "completed",
        "spare": {
          "id": "spare-123",
          "name": "홍길동",
          ...
        },
        "job": {
          "id": "job-123",
          "title": "급구 디자이너 모집",
          "amount": 150000,
          "requiredCount": 2,
          ...
        }
      }
    ]
  }
}
```

#### 9.3.2 근무 확인 및 정산

**엔드포인트**: `POST /api/schedules/{id}/confirm`

**요청 본문:**
```json
{
  "thumbsUp": true  // 따봉 보내기 여부
}
```

**응답 예시:**
```json
{
  "data": {
    "amount": 150000,
    "returnedEnergy": 1
  }
}
```

---

## 10. UI 컴포넌트 및 위젯

### 10.1 공통 위젯

#### 10.1.1 NotificationBell

**파일 위치**: `/Users/yoram/flutter/lib/widgets/notification_bell.dart`

**사용 예시:**

```dart
NotificationBell(role: 'shop')
```

**기능:**
- 읽지 않은 알림 개수 표시
- 알림 목록 표시 (클릭 시)
- 알림 읽음 처리

#### 10.1.2 BannerCarousel

**파일 위치**: `/Users/yoram/flutter/lib/widgets/banner_carousel.dart`

**사용 예시:**

```dart
BannerCarousel(
  bannerImages: const [
    'assets/images/banners/banner1.jpg',
    'assets/images/banners/banner2.jpg',
    'assets/images/banners/banner3.jpg',
    'assets/images/banners/banner4.jpg',
  ],
  onBannerTap: (index) {
    // 배너 클릭 처리
  },
)
```

**기능:**
- 자동 스크롤 (3초마다)
- 수동 스크롤 감지
- 페이지 인디케이터

#### 10.1.3 CategoryGrid

**파일 위치**: `/Users/yoram/flutter/lib/widgets/category_grid.dart`

**사용 예시:**

```dart
CategoryGrid(
  categories: [
    CategoryItem(
      emoji: '👥',
      label: '인력별',
      has3DEffect: true,
      onTap: () {
        // 카테고리 클릭 처리
      },
    ),
    // ...
  ],
)
```

### 10.2 상태 관리

#### 10.2.1 Provider 사용

**주요 Provider:**

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => JobProvider()),
    ChangeNotifierProvider(create: (_) => FavoriteProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
  ],
  child: MyApp(),
)
```

#### 10.2.2 NotificationProvider

**주요 메서드:**

```dart
class NotificationProvider extends ChangeNotifier {
  List<Notification> notifications;
  
  Future<void> loadNotifications();
  Future<void> markAsRead(String notificationId);
}
```

---

## 11. Next.js와의 비교

### 11.1 주요 차이점

1. **상태 관리**:
   - Next.js: React의 `useState`, `useEffect` 사용
   - Flutter: `Provider` 패턴 사용

2. **네비게이션**:
   - Next.js: Next.js Router (`useRouter`, `Link`)
   - Flutter: Flutter Navigator (`Navigator.push`, `MaterialPageRoute`)

3. **스타일링**:
   - Next.js: Tailwind CSS 클래스 사용
   - Flutter: `AppTheme` 상수 및 `BoxDecoration` 사용

4. **API 호출**:
   - Next.js: `fetch` API 사용
   - Flutter: `dio` 또는 `http` 패키지 사용

### 11.2 UI 일치도

- ✅ 홈 화면: 대부분 일치 (대시보드 카드, 빠른 액션, 공고/지원자 섹션)
- ✅ 인력별 화면: 필터링 기능 일치
- ✅ 공고 관리 화면: 목록, 상세, 등록 기능 일치
- ✅ 스케줄 화면: 날짜별 그룹화, 근무 확인 기능 일치
- ⚠️ 포인트 화면: 아직 구현되지 않음

---

## 12. 향후 개선 사항

### 12.1 즉시 구현 필요

1. **포인트 화면 구현**: Next.js의 `PointsContent.tsx`를 참고하여 완전히 구현
2. **지원자 관리 화면**: 공고별 지원자 목록 및 승인/거절 기능 완성
3. **공고 수정 기능**: 공고 상세 화면에서 수정 버튼 클릭 시 수정 화면으로 이동

### 12.2 개선 사항

1. **에러 처리 강화**: 네트워크 오류, 서버 오류 등에 대한 사용자 친화적 메시지 표시
2. **로딩 상태 개선**: 스켈레톤 UI 또는 로딩 인디케이터 추가
3. **오프라인 지원**: 로컬 캐시를 활용한 오프라인 모드 지원
4. **푸시 알림**: 지원자 지원, 스케줄 확정 등에 대한 푸시 알림

---

**문서 작성일**: 2026-02-05  
**마지막 업데이트**: 2026-02-05  
**버전**: 1.0.0
