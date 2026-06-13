# 미용실(샵) 페이지 디자인 가이드

HairSpare 앱의 **미용실(샵)** 영역 화면에 적용되는 디자인 규칙과 컴포넌트 스펙을 정리한 문서입니다. 신규 페이지 추가·수정 시 이 가이드를 기준으로 일관성을 유지합니다.

---

## 1. 적용 범위

- **대상**: `lib/screens/shop/` 하위 모든 화면 (홈, 인력별, 스케줄, 포인트, 내 공고, 프로필, 결제, 메시지 등)
- **테마 소스**: `lib/theme/app_theme.dart` (색상·간격·radius·그림자)
- **공용 위젯**: `lib/widgets/` (JobFilterDropdown, SpareCard, BottomNavBar 등)

---

## 2. 디자인 원칙

- **브랜드 톤**: Primary Purple(#9333EA)를 메인 포인트로, 보조에 연보라·회색 사용.
- **간격**: 8px 단위(spacing1~12)로 통일.
- **모서리**: 카드·버튼·필터는 12px(radiusLg) 기본.
- **Safe Area**: 상단 바는 반드시 `MediaQuery.padding.top`을 반영해 노치·상태바와 겹치지 않게.

---

## 3. 색상

| 용도 | 색상 | HEX | 사용 예 |
|------|------|-----|--------|
| Primary Purple | 메인 포인트 | `#9333EA` | 로고, CTA, 선택 테두리·텍스트, 강조 아이콘 |
| Primary Purple Light | 선택/강조 배경 | `#F3E8FF` | 필터 선택, 칩 선택, 배지 배경 |
| Purple 700 | 태그·보조 텍스트 | `#7E22CE` | 면허인증 배지, 전문 태그 텍스트 |
| Background White | 카드·상단바 | `#FFFFFF` | |
| Background Gray | 리스트·페이지 배경 | `#F9FAFB` | |
| Text Primary | 제목·본문 | `#111827` | |
| Text Secondary | 부가 정보 | `#6B7280` | |
| Border Gray | 구분선·테두리 | `#E5E7EB` | |
| Urgent Red | 알림·배지 | `#EF4444` | 메시지·알림 뱃지 |
| Yellow/Orange | 인기 배지 | `#FACC15` → `#F97316` | 인기 칩 그라데이션 |

---

## 4. 간격·레이아웃

- **기본 단위**: 4, 8, 12, 16, 24, 32 (px).  
  코드: `AppTheme.spacing1`(4) ~ `spacing8`(32).
- **화면 패딩**: 좌우 12~16px (`spacing3`~`spacing4`).
- **섹션 간 세로 간격**: 8~12px (`spacing2`~`spacing3`).
- **카드 간격**: 리스트 카드 사이 8~12px.

---

## 5. 타이포그래피

| 역할 | 크기 | 굵기 | 색 | 사용처 |
|------|------|------|-----|--------|
| 페이지 제목 | 18~20px | Bold | Primary Purple 또는 Text Primary | "인력별", "스케줄" 등 |
| 섹션/카드 제목 | 16px | Bold | Text Primary | 인력 이름, 공고 제목 |
| 본문 | 14px | Regular/Medium | Text Primary / Text Secondary | 설명, 경력·완료 건수 |
| 캡션/라벨 | 12px 이하 | Medium | Text Secondary | 태그, "전체 인력 N명" |
| 버튼/칩 라벨 | 14px | Medium/W600 | 선택 시 Purple, 미선택 시 Secondary | 필터 칩, 드롭다운 |

---

## 6. 상단 네비게이션 바

### 6.1 구조 (공통)

- **높이**: `44px + Safe Area 상단 패딩` (콘텐츠는 44px 높이로, 그 위에 status bar 영역 추가).
- **배경**: White. 하단 1px 구분선 `borderGray`.
- **콘텐츠 배치**: Safe Area 바로 아래에 44px 영역을 두고, 그 안에 Row 배치 (상단에 빈 공간 없이 붙임).

### 6.2 패턴 A – 홈·인력별 (SliverToBoxAdapter)

- `SliverToBoxAdapter` + `Container(height: 44 + padding.top)`.
- `padding: EdgeInsets.only(top: MediaQuery.padding.top, left: 16, right: 16)`.
- `child: SizedBox(height: 44, child: Row(...))`.
- **인력별**: [뒤로가기] [HairSpare 로고] [Spacer 또는 검색필드] [검색] [메시지] [알림].
- **홈**: [HairSpare 로고] [Spacer] [검색·메시지·알림]. (뒤로가기 없음)

### 6.3 패턴 B – 스케줄·포인트·내 공고 등 (SliverAppBar)

- `toolbarHeight: 56 + MediaQuery.padding.top` (또는 44 + padding.top).
- `flexibleSpace`: `Container`에 `padding.only(top: MediaQuery.padding.top)` 적용 후, 실제 툴바 콘텐츠를 **그 바로 아래**에 배치 (Align bottom 사용 시 여백이 커지지 않도록).
- 제목·뒤로가기·액션은 각 화면 스펙에 따라 배치.

### 6.4 로고·아이콘

- **HairSpare**: 20px, Bold, Primary Purple. 탭 시 홈으로 이동 가능.
- **아이콘**: 24px, Text Secondary. 메시지·알림에 빨간 뱃지 시 Urgent Red.

---

## 7. 페이지 제목·콘텐츠 섹션

- **페이지 제목**(상단바 바로 아래): 20px, Bold, Primary Purple. 상단바와 12px 정도 여백 권장.
- **인원/개수 문구**(예: "전체 인력 N명"): 14px, Medium/W600, Text Secondary. 오른쪽 정렬에 새로고침 버튼(퍼플 아이콘, 44px 터치 영역).

---

## 8. 필터 UI

### 8.1 드롭다운 버튼 (JobFilterDropdown)

- **미선택**: 배경 White, 테두리 1px borderGray, radius 12px.
- **선택 시**: 배경 primaryPurpleLight, 테두리 2px primaryPurple, 텍스트·화살표 primaryPurple, fontWeight 600.
- **패딩**: horizontal 16px, vertical 12px.
- **그림자**: 선택·미선택 모두 가벼운 shadow(blur 4, y 2).
- **텍스트**: 14px. 선택 값 또는 placeholder(예: "지역", "정렬") 표시.

### 8.2 카테고리 칩 (전체/스텝/디자이너/면허인증 등)

- **미선택**: 배경 backgroundGray, 테두리 1px borderGray (또는 없음), 텍스트 textSecondary.
- **선택 시**: 배경 primaryPurpleLight, 테두리 2px primaryPurple, 텍스트 primaryPurple, W600. 필요 시 약한 보라 그림자.
- **형태**: 12px 라운드, 패딩 8~12px. 이모지+텍스트 시 이모지 14px, 간격 8px.
- **칩 간 간격**: 8px.

---

## 9. 인력 카드 (SpareCard)

- **컨테이너**: 흰 배경, 12px 라운드, 1px borderGray, shadowSm.
- **패딩**: compact 8px, 일반 16px.
- **레이아웃**: Row. [원형 프로필] [간격 8~16] [Expanded(이름·배지·경력·태그·따봉·리뷰)].
- **프로필 원형**: 48(compact) 또는 60px. 그라데이션 Blue → Purple. 이미지 없을 땐 첫 글자 표시.
- **이름**: 16px Bold, Text Primary.
- **인기 배지**: 이름 **오른쪽**에 배치(프로필과 겹치지 않음). 노란·오렌지 그라데이션, 별 아이콘, "인기" 10px. 인기 배지와 면허인증 배지 사이 12px 간격.
- **면허인증 배지**: primaryPurpleLight 배경, purple700 텍스트, 12px 이하.
- **경력·완료**: 12px, textSecondary.
- **전문 태그**(컷, 펌 등): purple100 배경, purple700, radiusSm, 작은 패딩.
- **따봉·리뷰**: 12~14px. 따봉은 primaryPurple 강조.

---

## 10. 버튼·아이콘

- **Primary 버튼**: 배경 primaryPurple, 텍스트 흰색, 12px 라운드, padding 12~16.
- **Secondary/텍스트**: Primary Purple 텍스트, 배경 없음 또는 연보라.
- **아이콘 버튼**: 최소 44px 터치 영역. InkWell + padding 또는 IconButton.
- **새로고침 등**: Primary Purple 아이콘으로 포인트 부여.

---

## 11. 빈 상태·에러 상태

- **빈 리스트**: 중앙 정렬. 아이콘(48~64px, textTertiary) + 안내 문구(14px, textSecondary) + 필요 시 "필터 초기화" 등 보조 버튼(퍼플 톤).
- **에러**: 아이콘 + 에러 메시지 + "다시 시도" 버튼(primaryPurple).

---

## 12. 화면별 요약

| 화면 | 상단바 패턴 | 비고 |
|------|-------------|------|
| 홈 | SliverToBoxAdapter, 44+padding | HairSpare 로고, 검색·메시지·알림 |
| 인력별 | SliverToBoxAdapter, 44+padding | 뒤로+로고+Spacer/검색+아이콘. 제목 "인력별"은 바 밑 별도 행 |
| 스케줄 | SliverAppBar, 56+padding | 뒤로+제목+등급 뱃지 |
| 포인트 | SliverAppBar, 56+padding | 콘텐츠를 padding.top 바로 아래에 배치 |
| 내 공고 | SliverAppBar, 56+padding | 뒤로+제목+flexibleSpace(검색·추가) |
| 프로필(마이) | SliverAppBar, 44+padding | 로고+설정 |

---

## 13. Figma·디자인 툴 참고

- 색상·간격·radius는 위 표와 `app_theme.dart`를 Single Source of Truth로 사용.
- 컴포넌트: 상단바, 필터 드롭다운(기본/선택), 필터 칩(기본/선택), 인력 카드(컴팩트)를 재사용 컴포넌트로 정의하면 유지보수에 유리.
- 인력별 페이지 상세 Figma AI용 업무지시는 `docs/FIGMA_BRIEF_INRYEOKBYEOL_PAGE.md` 참고.
