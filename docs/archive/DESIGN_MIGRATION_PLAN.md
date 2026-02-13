# Flutter 앱 디자인 마이그레이션 계획

## 목표
Next.js 웹 앱의 디자인 시스템을 Flutter 앱에 적용하여 일관된 사용자 경험 제공

## 완료된 작업

### ✅ 1. 테마 시스템 구축
- `lib/theme/app_theme.dart` 생성
- Next.js Tailwind CSS 색상 팔레트 매핑
- Material 3 테마 설정

## 진행 중인 작업

### 🔄 2. 역할 선택 화면 디자인 업데이트
**현재 상태**: 기본 Material Design
**목표**: Next.js와 동일한 그라데이션 배경 및 버튼 스타일

**변경 사항**:
- 그라데이션 배경 적용 (`AppTheme.gradientBackground`)
- 버튼 스타일 개선 (그림자, 호버 효과)
- 타이포그래피 조정

### 🔄 3. 로그인 화면 디자인 업데이트
**현재 상태**: 기본 Material Design
**목표**: Next.js와 유사한 깔끔한 레이아웃

**변경 사항**:
- 입력 필드 스타일 개선
- 버튼 스타일 통일
- 레이아웃 여백 조정

### 🔄 4. 홈 화면 디자인 업데이트
**현재 상태**: 기본 Material Design
**목표**: Next.js와 동일한 복잡한 레이아웃

**변경 사항**:
- 헤더 스타일 (sticky header, 검색 바)
- 배너 캐러셀 구현
- 카테고리 그리드 레이아웃
- 급구/일반 공고 섹션 분리
- 공고 카드 디자인 개선

### 🔄 5. 공고 카드 위젯 디자인 업데이트
**현재 상태**: 기본 Material Card
**목표**: Next.js JobCard와 동일한 스타일

**변경 사항**:
- 급구/프리미엄 배지 스타일
- 찜 버튼 위치 및 스타일
- 레이아웃 및 여백 조정
- 카운트다운 표시

## 다음 단계

### 우선순위 1: 핵심 화면
1. 역할 선택 화면 업데이트
2. 로그인 화면 업데이트
3. 홈 화면 업데이트
4. 공고 카드 위젯 업데이트

### 우선순위 2: 추가 화면
5. 공고 상세 화면
6. 지역 선택 화면
7. 프로필 화면

## 디자인 토큰 매핑

### 색상
- `blue-500`: `#3B82F6` → `AppTheme.primaryBlue`
- `purple-600`: `#9333EA` → `AppTheme.primaryPurple`
- `gray-50`: `#F9FAFB` → `AppTheme.backgroundGray`
- `gray-900`: `#111827` → `AppTheme.textPrimary`
- `red-500`: `#EF4444` → `AppTheme.urgentRed`

### 간격
- Tailwind 기본 간격 (4px 단위) → Flutter 8px 단위로 변환
- `p-4` → `EdgeInsets.all(16)`
- `gap-4` → `SizedBox(width: 16)`

### 둥근 모서리
- `rounded-lg` → `BorderRadius.circular(12)`
- `rounded-xl` → `BorderRadius.circular(16)`

## 참고 파일
- Next.js 디자인: `app/page.tsx`, `app/spare/home/HomeContent.tsx`, `src/components/JobCard.tsx`
- Flutter 테마: `lib/theme/app_theme.dart`
