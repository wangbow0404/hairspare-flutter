# HairSpare — 스페어 vs 샵 UI/UX 디자인 비교 문서

> 목적: Stitch AI가 샵(Shop) 화면을 스페어(Spare) 화면과 같은 디자인 품질로 리디자인할 수 있도록,
> 두 역할의 모든 화면을 세세히 비교하고 차이점·개선 포인트를 정리한 문서입니다.

---

## 1. 디자인 시스템 (공통 기반)

### 1-1. 색상 팔레트

| 토큰 | 값 | 용도 |
|------|----|------|
| `stitchPrimary` | `#7800CE` | 브랜드 메인 퍼플 (어두움) |
| `stitchPrimaryContainer` | `#9333EA` | 브랜드 액센트 퍼플 |
| `primaryPurple` | `#9333EA` | 버튼·아이콘 강조 |
| `primaryBlue` | `#3B82F6` | 파란 계열 강조 |
| `primaryGreen` | `#10B981` | 녹색 강조 (완료·성공) |
| `primaryPink` | `#EC4899` | 분홍 강조 |
| `urgentRed` | `#EF4444` | 급구·오류·삭제 |
| `yellow400` | `#FACC15` | 에너지·별 |
| `backgroundGray` | `#F9FAFB` | 스크린 배경 |
| `backgroundWhite` | `#FFFFFF` | 카드·앱바 배경 |
| `borderGray` | `#E5E7EB` | 구분선 |
| `textPrimary` | `#111827` | 주 텍스트 |
| `textSecondary` | `#6B7280` | 보조 텍스트 |
| `stitchTextPrimary` | `#191F28` | Stitch 스타일 주 텍스트 |
| `stitchTextSecondary` | `#4E5968` | Stitch 스타일 보조 텍스트 |

### 1-2. 간격 시스템 (spacing)

| 토큰 | px |
|------|----|
| `spacing1` | 4px |
| `spacing2` | 8px |
| `spacing3` | 12px |
| `spacing4` | 16px |
| `spacing6` | 24px |
| `spacing8` | 32px |

### 1-3. 둥근 모서리 (border radius)

| 토큰 | px |
|------|----|
| `radiusSm` | 4px |
| `radiusMd` | 8px |
| `radiusLg` | 12px |
| `radiusXl` | 16px |
| `radius2xl` | 24px |
| `radiusFull` | 9999px (완전한 원형) |

---

## 2. 탭 구조 비교

### 스페어 (Spare) 탭
| 탭 | 라우트 | 아이콘 | 레이블 |
|----|--------|--------|--------|
| 홈 | `/spare/home` | `home_rounded` / `home_outlined` | 홈 |
| 결제 | `/spare/payment` | `credit_card` | 결제 |
| 찜 | `/spare/favorites` | `favorite_rounded` / `favorite_outline` | 찜 |
| 마이 | `/spare/profile` | `person_rounded` / `person_outline_rounded` | 마이 |

### 샵 (Shop) 탭
| 탭 | 라우트 | 아이콘 | 레이블 |
|----|--------|--------|--------|
| 홈 | `/shop/home` | `home_rounded` / `home_outlined` | 홈 |
| 결제 | `/shop/payment` | `credit_card` | 결제 |
| 찜 | `/shop/favorites` | `favorite_rounded` / `favorite_outline` | 찜 |
| 마이 | `/shop/profile` | `person_rounded` / `person_outline_rounded` | 마이 |

### 하단 탭바 공통 스타일
- 배경색: `backgroundWhite`
- 상단 구분선: `borderGray`, 1px
- 그림자: `boxShadow(black 6%, blurRadius 8, offset 0/-2)`
- 탭바 높이: 56px + SafeArea
- 활성 색상: `stitchPrimaryContainer` (`#9333EA`)
- 비활성 색상: `stitchTextSecondary` (`#4E5968`)
- 활성 탭: bold icon + `FontWeight.w600`
- 비활성 탭: outline icon + `FontWeight.w500`
- 라벨 폰트 크기: 11px

---

## 3. 상단 앱바 비교

### 스페어 홈 앱바 (`SpareAppBar`)
```
[로고(HairSpare)] ........... [검색] [메시지(+뱃지)] [알림벨]
```
- 높이: 72px
- 배경: `backgroundWhite` + 하단 border `borderGray`
- 로고: `HairSpareBrandLogo(height: 36)` (탭 시 홈으로 이동)
- 검색 아이콘: `IconMapper.icon('search')`, 24px, `textSecondary`
- 메시지 아이콘: `IconMapper.icon('messagecircle')`, 24px + 빨간 점 뱃지(12px, 흰 테두리 2px)
- 알림 아이콘: `NotificationBell(role: 'spare')`, 40x40 영역

### 샵 홈 앱바 (`ShopHomeAppBarRow`)
- 스페어 앱바와 동일한 구조가 필요하나, 현재 별도 구현 존재
- **개선 필요**: 메시지·알림 뱃지 스타일, 높이 등 스페어와 동일하게 통일

### 서브페이지 앱바 (`SpareSubpageAppBar`) — 양쪽 공통 사용
```
[← 뒤로가기] [제목] ...........
```
- 배경: `backgroundWhite` + 하단 border
- 뒤로가기: `chevronleft` 아이콘 또는 Flutter `arrow_back_ios`
- 제목: 17px, `FontWeight.w600`, `textPrimary`

---

## 4. 홈 화면 비교

### 4-1. 공통 구조
```
[고정 앱바]
[히어로 배너 — 240px 이미지 캐러셀]
[카테고리 그리드 — 4열 2행]
[콘텐츠 섹션들]
[고객센터 섹션]
[하단 여백 (SafeArea + 24px)]
```

### 4-2. 히어로 배너 (`StitchHeroBanner`)
- 높이: 240px
- 이미지 캐러셀 (3장)
- 페이지 인디케이터 (점)
- 탭 시 해당 index 기반 화면 이동
- **스페어 배너 이미지**: banner1, banner3, banner4
- **샵 배너 이미지**: banner2, banner3, banner4 (`variant: StitchHeroVariant.shop`)
- 탭 이동:
  - 스페어: 0→긴급공고 목록, 1→에너지, 2→교육
  - 샵: 0→스페어 목록, 1→결제, 2→스케줄

### 4-3. 카테고리 그리드

#### 스페어 카테고리 (색상 미지정)
| 순서 | 아이콘 | 레이블 | 이동 화면 |
|------|--------|--------|-----------|
| 1 | `work_outline` | 공고별 | JobsListScreen |
| 2 | `calendar_month_outlined` | 스케줄표 | WorkCheckScreen |
| 3 | `storefront_outlined` | 스토어 | (준비 중 다이얼로그) |
| 4 | `monetization_on_outlined` | +포인트 | PointsScreen |
| 5 | `chair_outlined` | 공간대여 | RegionSelectScreen |
| 6 | `school_outlined` | 교육 | EducationScreen |
| 7 | `star_outline_rounded` | 챌린지참여 | ChallengeScreen |
| 8 | `favorite_outline_rounded` | 모델매칭 | ModelMatchFilterScreen |

#### 샵 카테고리 (각 항목에 색상 지정됨)
| 순서 | 아이콘 | 레이블 | 색상 | 이동 화면 |
|------|--------|--------|------|-----------|
| 1 | `groups_2_outlined` | 인력별 | `primaryPurple` | ShopSparesListScreen |
| 2 | `event_note_outlined` | 스케줄표 | `primaryBlue` | ShopScheduleScreen |
| 3 | `storefront_outlined` | 스토어 | `primaryGreen` | (준비 중 다이얼로그) |
| 4 | `add_card_outlined` | +포인트 | `orange500` | ShopPointsScreen |
| 5 | `meeting_room_outlined` | 공간대여 | `primaryPink` | ShopMySpacesScreen |
| 6 | `school_outlined` | 교육 | `primaryPurple` | ShopEducationScreen |
| 7 | `workspace_premium_outlined` | 챌린지 | `primaryBlueDark` | ShopChallengeScreen |
| 8 | `lightbulb_outline` | 커넥트 | `yellow600` | (준비 중 다이얼로그) |

> **차이점**: 스페어는 카테고리 아이콘에 색상을 지정하지 않음 (기본 회색), 샵은 각 항목별로 고유 색상 지정.
> 스티치 AI에게: 스페어도 샵처럼 각 카테고리에 고유 색상을 추가하면 시각적 통일성이 높아집니다.

### 4-4. 홈 콘텐츠 섹션 — 핵심 차이

#### 스페어 홈 콘텐츠 섹션 (공고 중심)
1. **UrgentJobSection** — 급구 공고 가로 스크롤 카드
2. **CategoryJobsSection** — 지역별 카테고리 공고 탭 목록
3. **PopularJobsSection** — 인기 공고 (조회수·지원수 기반)
4. **NewJobsSection** — 최신 공고 (등록일 기준)
5. **UpcomingShopsSection** — 주목할 미용실 카드 3개
6. **NormalJobsSection** — 일반 공고 전체 목록
7. **CustomerServiceSection** — 고객센터

#### 샵 홈 콘텐츠 섹션 (스페어 인력 중심, mockup 기준)
1. **StitchHeroBanner** — 히어로 배너 (인력별 / 구독결제 / 스케줄 CTA)
2. **ShopHomeStatusStrip** — 흰색 상태 카드 Row (3개)
   - 진행중 공고 / 대기 지원자 / 오늘의 매칭
   - 카드 스타일: `backgroundWhite`, `radiusXl`, `stitchSoftShadow`, `borderGray` 1px
   - 숫자: `stitchPrimaryContainer` bold, 라벨: `stitchTextSecondary` 12px
3. **CategoryGrid** — 8칸 퀵 메뉴 (`ShopHomeQuickMenu`, 8번: 모델 매칭)
4. **ShopHomePopularSparesSection** — 인기 지원자 가로 캐러셀
5. **ShopHomeNewSparesSection** — 신규 지원자 세로 `ShopHomeSpareListTile` (max 6)
6. **ShopHomeTipsBanner** — 매칭 팁 promo (연보라 배경)
7. **CustomerServiceSection** — 고객센터

> **샵 상태 카드 세부 스타일**
> ```
> Ink(
>   decoration: BoxDecoration(
>     borderRadius: BorderRadius.circular(radiusXl),
>     border: Border.all(color: borderGray),
>     boxShadow: stitchSoftShadow,
>   ),
>   child: Column(
>     crossAxisAlignment: CrossAxisAlignment.start,
>     children: [
>       Text(value, style: dashboardValueOnWhite),   // 보라 bold
>       Text(label, style: dashboardLabelOnWhite),  // secondary 12px
>     ],
>   ),
> )
> ```

---

## 5. 결제 탭 비교

### 스페어 결제 화면 (`PaymentScreen`)
```
[SpareSubpageAppBar — "결제 정보"]
[padding: spacing4]
  [섹션 제목: "결제 내역" — 18px bold]
  [결제 목록 카드]
    [비어있으면: StitchEmptyState(creditcard)]
    [목록: 결제 항목 Row]
      - 40x40 원형 아이콘 (상태별 색상 배경)
      - 왼쪽: 설명 텍스트(14px w500) + 날짜(12px secondary)
      - 오른쪽: 금액(14px w600) + 상태 아이콘+텍스트(12px)
    [하단 border 구분선]
```
- 카드 스타일: `backgroundWhite`, `radiusXl`, `borderGray`, `stitchSoftShadow`

### 샵 결제 화면 (`ShopPaymentScreen`) — 더 풍부한 구성
```
[SpareSubpageAppBar — "결제 정보"]
[padding: spacing4]
  [구독 현황 카드 (_SubscriptionCard)]
    - 48x48 보라색 Star 아이콘 컨테이너
    - "현재 구독 플랜" + 플랜명
    - 일일 무료 채팅 횟수 정보
    - 구독 상태 (활성/비활성)
    - 무료 플랜이면: "구독 플랜 보기" 버튼 (보라색)
  [spacing4]
  [섹션 제목: "결제 내역" — 18px bold]
  [결제 목록 카드 — 스페어와 동일 구조]
  [spacing4]
  [결제 수단 관리 카드 (_PaymentMethodCard)]
    - "결제 수단 관리" 제목
    - 등록 수단 없음 안내 컨테이너
    - "결제 수단 추가" OutlinedButton (보라 테두리)
```

> **차이점 요약**:
> - 스페어는 결제 내역만 표시
> - 샵은 구독 현황 + 결제 내역 + 결제 수단 관리 3단 구성 (더 복잡)
> - **스티치 AI에게**: 스페어 결제 탭도 샵처럼 구독 상태 카드를 추가하면 일관성이 높아집니다.

---

## 6. 찜 탭 비교

### 스페어 찜 화면 (`FavoritesScreen`) — 공고 찜
```
[SpareSubpageAppBar — "찜한 공고"]
[비어있으면: StitchEmptyState(heart, "찜한 공고가 없습니다", actionLabel: "공고 둘러보기")]
[목록: ListView.builder, padding: spacing4]
  StitchListJobCard(
    job: ...,
    isFavorite: true,
    showPopularBadge: ...,
    onTap: 공고 상세 이동,
    onFavoriteToggle: 찜 해제,
  )
```

### 샵 찜 화면 (`ShopFavoritesScreen`) — 스페어 찜
```
[SpareSubpageAppBar — "찜한 스페어"]
[비어있으면: StitchEmptyState(heart, "찜한 스페어가 없습니다", actionLabel: "스페어 둘러보기")]
[목록: ListView.builder, padding: spacing4]
  Padding(bottom: spacing3)
    Stack(
      ShopHomeSpareListTile(spare, onTap),  // 스페어 카드
      Positioned(top:4, right:4)
        IconButton(favorite_rounded, urgentRed)  // 찜 해제 버튼 (오버레이)
    )
```

> **차이점 및 개선 필요**:
> - 스페어는 `StitchListJobCard` (Stitch 디자인 시스템 카드) 사용
> - 샵은 `ShopHomeSpareListTile` 위에 `Stack + Positioned`로 찜 버튼을 얹음 — 조잡한 구현
> - **스티치 AI에게**: 샵 찜 화면의 스페어 카드도 Stitch 스타일 카드 컴포넌트로 교체하고, 찜 해제 버튼을 카드 내부에 자연스럽게 통합해야 합니다.

---

## 7. 메시지 화면 비교

### 스페어 메시지 (`MessagesScreen`)
```
[SpareSubpageAppBar — "메시지"]
[_ModelMessagingPolicyBanner (모델 계정일 때만)]
[StitchSegmentTabs — "전체" / "안 읽음"]
[채팅 목록]
  _ChatListItem (swipe-to-delete)
    - 48x48 원형 아바타 (상호명 첫 글자, primaryPurpleLight 배경, stitchPrimary 텍스트)
    - 상호명(shopName, 16px w600) + 시간(12px secondary) — Row
    - 미리보기 텍스트 (jobTitle · lastMessage, 13px secondary, 1줄)
    - 안 읽음 뱃지 (urgentRed 원형, "9+" 처리)
  [왼쪽으로 스와이프 → 삭제 버튼 (80px, urgentRed 10% 배경)]
```

### 샵 메시지 (`ShopMessagesScreen`)
```
[SpareSubpageAppBar — "메시지"]
                              ← 정책 배너 없음
[StitchSegmentTabs — "전체" / "안 읽음"]
[채팅 목록]
  _ChatListItem (스페어와 완전 동일한 구조)
    - 48x48 원형 아바타 (spareName 첫 글자)
    - 스페어 이름(spareName, 16px w600) + 시간
    - 미리보기 텍스트
    - 안 읽음 뱃지
  [스와이프 → 삭제]
```

> **차이점**: 스페어는 모델 계정용 정책 배너가 있으나 샵에는 없음. 나머지 UI는 동일.
> **잠재적 개선**: 두 화면이 거의 동일하므로 공통 위젯으로 추출 가능.

---

## 8. 마이(프로필) 탭 비교

### 8-1. 전체 구조

#### 스페어 프로필 (`SpareProfileScrollView`)
```
Column(
  SpareProfileHeader,          ← 고정 헤더 (스크롤 안됨)
  Expanded(
    SingleChildScrollView(
      SpareProfileIdentitySection,
      SpareProfileQuickStats,
      SpareProfileMenuSection,
      SpareProfileLogoutSection,
      CustomerServiceSection,
    )
  )
)
```

#### 샵 프로필 (`ShopProfileScrollView`)
```
SingleChildScrollView(
  ShopProfileHeader,           ← 헤더가 같이 스크롤됨
  ShopProfileIdentitySection,
  ShopProfileQuickStats,
  ShopProfileMenuSection,
  SpareProfileLogoutSection,
  CustomerServiceSection,
)
```

> **핵심 UX 차이**: 스페어 프로필 헤더(로고+설정)는 **고정(sticky)**되어 스크롤해도 항상 보임.
> 샵 프로필 헤더는 콘텐츠와 함께 **같이 올라감(scroll away)**.
> **스티치 AI에게**: 샵도 스페어처럼 헤더를 고정해야 일관성 있는 UX가 됩니다.

### 8-2. 프로필 헤더 비교

#### 스페어 프로필 헤더 (`SpareProfileHeader`)
```
[HairSpareBrandLogo(height:36)] ........... [settings 아이콘]
```
- `AppScreenInsets.topBarShell` 래퍼 사용
- 로고 탭: 홈 화면으로 이동 (`SpareProfileNavigation.openHomeFromLogo`)
- 설정 아이콘: `IconMapper.icon('settings', size:24, color:textSecondary)`

#### 샵 프로필 헤더 (`ShopProfileHeader`)
- 스페어 프로필 헤더와 동일한 구조 (로고 + 설정)

### 8-3. 프로필 신원 섹션 비교

#### 공통 구조
```
Container(white, border-bottom)
  padding: spacing6
  Row(
    Stack(
      96x96 원형 아바타 (그라데이션 배경),
      32x32 편집 버튼 (우하단, stitchPrimary 원형),
    ),
    spacing4,
    Column(이름 + 뱃지, 이메일, 전화번호),
  )
  spacing4
  "프로필 수정" 버튼 (전체폭, backgroundGray, radiusLg)
```

#### 차이점
| 항목 | 스페어 | 샵 |
|------|--------|-----|
| 기본 아바타 아이콘 | `user` (사람 아이콘, 48px) | `storefront` (매장 아이콘, 40px) |
| 업로드 로딩 오버레이 | 있음 (반투명 검정 + 스피너) | 없음 |
| 프로필 수정 버튼 아이콘 | `user` | `storefront` |
| 편집 버튼 탭 | `SpareProfileNavigation.pushProfileEdit()` | `MaterialPageRoute(ShopProfileEditScreen)` |

> **개선 필요**: 샵 프로필에도 사진 업로드 로딩 오버레이 추가 필요.

### 8-4. 통계(QuickStats) 비교

공통 구조: 3열, 세로 구분선(`borderGray`, 1px, 40px 높이), 각 열에 숫자(24px bold) + 레이블(12px secondary)

| 열 | 스페어 | 색상 | 샵 | 색상 |
|----|--------|------|----|------|
| 1열 | 에너지 잔액 | `stitchPrimary` | VIP 등급 (Star아이콘+이름) | tier별 동적 색상 |
| 2열 | 진행중 스케줄 수 | `stitchPrimaryContainer` | 완료 근무 수 | `primaryPurple` |
| 3열 | 완료 스케줄 수 | `green600` | 진행중 스케줄 수 | `green600` |

> **차이**: 스페어는 에너지(포인트) 중심, 샵은 VIP 등급 중심.

### 8-5. 메뉴 섹션 비교

공통 위젯: `SpareProfileMenuItem` (아이콘 컨테이너 + 레이블 + 설명 + 화살표)
간격: 항목 사이 `spacing2` (8px)
패딩: `spacing4` (16px)

#### 스페어 메뉴 (9개 항목)
| 아이콘 | 색상 | 레이블 | 설명 | 이동 |
|--------|------|--------|------|------|
| `video` | `stitchPrimaryContainer` | 챌린지 프로필 | 내 영상 및 챌린지 프로필 관리 | ChallengeProfileScreen |
| `heart` | `urgentRed` | 구독한 크리에이터 | 내가 구독한 크리에이터 목록 | SubscriptionsScreen |
| `zap` | `yellow400` | 내 에너지 | 에너지 잔액 및 거래 내역 | EnergyScreen |
| `calendar` | `stitchPrimaryContainer` | 내 스케줄 | 근무 일정 확인 및 체크인 | WorkCheckScreen |
| `filetext` | `stitchPrimaryContainer` | 내 지원 현황 | 공고 지원 내역 확인 | MyApplicationsScreen |
| `home` | `primaryGreen` | 내 공간 예약 | 공간대여 예약 내역 | MySpaceBookingsScreen |
| `creditcard` | `stitchPrimaryContainer` | 결제 정보 | 결제 내역 및 구독 관리 | 결제 탭으로 이동 |
| `users` | `Colors.pink` | 추천하기 | 친구 추천 및 보상 | ReferralScreen |
| `shield` | `primaryGreen` | 인증 관리 | 본인인증 | VerificationScreen |
| `settings` | `textSecondary` | 설정 | 앱 설정 및 계정 관리 | SettingsScreen |

#### 샵 메뉴 (8개 항목)
| 아이콘 | 색상 | 레이블 | 설명 | 이동 |
|--------|------|--------|------|------|
| `star_rounded` | `primaryPurple` | VIP 등급 | 근무 통계 및 VIP 등급 확인 | ShopVipStatusScreen |
| `calendar_today` | `Colors.blue` | 스케줄 관리 | 근무 일정 확인 및 관리 | ShopScheduleScreen |
| `work_outline` | `Colors.indigo` | 공고 관리 | 등록한 공고 확인 및 관리 | ShopJobsListScreen |
| `meeting_room_outlined` | `Colors.teal` | 내 공간 관리 | 등록한 공간 확인 및 관리 | ShopMySpacesScreen |
| `people_outline` | `primaryBlue` | 지원자 관리 | 지원자 확인 및 승인/거절 | ShopApplicantsScreen |
| `credit_card_outlined` | `primaryPurple` | 결제 정보 | 결제 내역 및 구독 관리 | 결제 탭으로 이동 |
| `verified_outlined` | `primaryGreen` | 인증 관리 | 사업자·본인·대리인 인증 | ShopVerificationScreen |
| `settings_outlined` | `textSecondary` | 설정 | 앱 설정 및 계정 관리 | ShopSettingsScreen |

> **아이콘 일관성 문제 (개선 필요)**:
> - 스페어 메뉴: `IconMapper.icon('name')` 함수 사용 → Stitch 아이콘 시스템 적용됨
> - 샵 메뉴: `Icon(Icons.xxx)` Flutter 기본 아이콘 직접 사용 → 디자인 불일치
> - **스티치 AI에게**: 샵 메뉴 아이콘도 `IconMapper.icon()` 패턴으로 교체해야 합니다.

---

## 9. 공통 컴포넌트 재사용 현황

### 양쪽 모두 동일하게 사용하는 컴포넌트
| 컴포넌트 | 파일 | 용도 |
|----------|------|------|
| `SpareSubpageAppBar` | `widgets/common/spare_subpage_app_bar.dart` | 서브페이지 상단바 |
| `StitchHeroBanner` | `widgets/stitch/stitch_hero_banner.dart` | 홈 배너 |
| `CategoryGrid` | `widgets/category_grid.dart` | 카테고리 8칸 그리드 |
| `CustomerServiceSection` | `widgets/customer_service_section.dart` | 고객센터 |
| `StitchEmptyState` | `widgets/stitch/stitch_empty_state.dart` | 빈 상태 화면 |
| `StitchSegmentTabs` | `widgets/stitch/stitch_segment_tabs.dart` | 탭 세그먼트 |
| `SpareProfileMenuItem` | `widgets/spare_profile/spare_profile_menu_item.dart` | 메뉴 항목 (샵도 공유) |
| `SpareProfileLogoutSection` | `widgets/spare_profile/spare_profile_logout_section.dart` | 로그아웃 버튼 (샵도 공유) |

### 스페어에만 있는 컴포넌트 (샵에서 부재)
| 컴포넌트 | 용도 | 샵 상태 |
|----------|------|---------|
| `StitchListJobCard` | 공고 카드 (찜 목록 등) | 없음 (ShopHomeSpareListTile 사용) |
| `UrgentJobSection` | 급구 공고 섹션 | 대시보드 카드로 대체 |
| `PopularJobsSection` | 인기 공고 섹션 | 없음 |
| `NewJobsSection` | 신규 공고 섹션 | 없음 |

---

## 10. 색상·스타일 사용 불일치 목록

| 항목 | 스페어 | 샵 | 통일 방향 |
|------|--------|-----|----------|
| 카테고리 아이콘 색상 | 미지정 (기본 회색) | 각 항목별 지정 | 샵 방식 적용 (각 아이콘 고유 색) |
| 메뉴 아이콘 시스템 | `IconMapper.icon('name')` | `Icon(Icons.xxx)` | `IconMapper.icon()` 통일 |
| 프로필 헤더 동작 | 고정 (sticky) | 스크롤됨 | 고정으로 통일 |
| 프로필 사진 업로드 | 로딩 오버레이 있음 | 없음 | 양쪽 동일하게 |
| 결제 탭 구성 | 결제 내역만 | 구독+결제+수단 3단 | 검토 필요 |
| 찜 아이템 카드 | Stitch 카드 컴포넌트 | 원시 Stack+Positioned | Stitch 카드 방식 적용 |
| 홈 앱바 높이 | 72px (`SpareAppBar`) | 별도 구현 확인 필요 | 72px 통일 |

---

## 11. 샵 화면 리디자인 우선순위

### High (즉시 반영)
1. **프로필 헤더 고정**: `ShopProfileScrollView`를 `Column(Header + Expanded(ScrollView))`로 변경
2. **메뉴 아이콘 교체**: `ShopProfileMenuSection` 아이콘을 `IconMapper.icon()` 방식으로 변경
3. **찜 화면 카드 개선**: `ShopFavoritesScreen`의 Stack+Positioned 방식을 Stitch 카드로 교체

### Medium (다음 이터레이션)
4. **카테고리 아이콘 색상**: 스페어 카테고리에도 샵처럼 각 항목별 색상 추가
5. **스페어 결제 탭 강화**: 구독 상태 카드 추가 (현재 샵만 있음)
6. **사진 업로드 로딩 오버레이**: 샵 프로필에도 추가

### Low (장기 개선)
7. **메시지 화면 공통화**: 스페어/샵 `_ChatListItem` 공유 위젯으로 추출
8. **대시보드 카드 스탠다드화**: 홈 대시보드 카드 컴포넌트 정의

---

## 12. 화면별 파일 경로 매핑

### 스페어 화면
```
lib/screens/spare/home_screen.dart         → 홈 탭
lib/screens/spare/payment_screen.dart      → 결제 탭
lib/screens/spare/favorites_screen.dart    → 찜 탭
lib/screens/spare/profile_screen.dart      → 마이 탭
lib/screens/spare/messages_screen.dart     → 메시지 (서브)
```

### 스페어 위젯
```
lib/widgets/spare_home/spare_home_scroll_view.dart     → 홈 본문
lib/widgets/spare_home/spare_home_app_bar.dart         → 홈 앱바
lib/widgets/spare_profile/spare_profile_scroll_view.dart → 마이 본문
lib/widgets/spare_profile/spare_profile_header.dart    → 마이 헤더
lib/widgets/spare_profile/spare_profile_identity_section.dart → 신원 섹션
lib/widgets/spare_profile/spare_profile_quick_stats.dart → 통계 섹션
lib/widgets/spare_profile/spare_profile_menu_section.dart → 메뉴 섹션
```

### 샵 화면
```
lib/screens/shop/home_screen.dart          → 홈 탭
lib/screens/shop/payment_screen.dart       → 결제 탭
lib/screens/shop/favorites_screen.dart     → 찜 탭
lib/screens/shop/profile_screen.dart       → 마이 탭
lib/screens/shop/messages_screen.dart      → 메시지 (서브)
```

### 샵 위젯
```
lib/widgets/shop_home/shop_home_scroll_view.dart      → 홈 본문
lib/widgets/shop_home/shop_home_app_bar.dart          → 홈 앱바
lib/widgets/shop_home/shop_home_spare_sections.dart   → 스페어 목록 섹션들
lib/widgets/shop_profile/shop_profile_scroll_view.dart → 마이 본문
lib/widgets/shop_profile/shop_profile_header.dart     → 마이 헤더
lib/widgets/shop_profile/shop_profile_identity_section.dart → 신원 섹션
lib/widgets/shop_profile/shop_profile_quick_stats.dart → 통계 섹션
lib/widgets/shop_profile/shop_profile_menu_section.dart → 메뉴 섹션
```
