# HairSpare Flutter 프로젝트 상태 문서

> **목적**: 이 문서는 Flutter 프로젝트의 현재 상태, 구조, 완료된 작업, 진행 중인 작업, 기술 스택, 설정, 중요한 참고사항, 트러블슈팅 가이드를 종합적으로 정리한 문서입니다.  
> **대상**: Flutter 프로젝트에서 작업을 시작하는 개발자(AI 포함)가 프로젝트의 전체 맥락을 빠르게 파악할 수 있도록 합니다.

---

## 📋 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [프로젝트 구조](#2-프로젝트-구조)
3. [완료된 작업](#3-완료된-작업)
4. [진행 중/대기 중인 작업](#4-진행-중대기-중인-작업)
5. [기술 스택 및 설정](#5-기술-스택-및-설정)
6. [중요한 참고사항](#6-중요한-참고사항)
7. [트러블슈팅 가이드](#7-트러블슈팅-가이드)

---

## 1. 프로젝트 개요

### 1.1 프로젝트 목표

**HairSpare**는 미용실 스페어(디자이너) 급구 해결 플랫폼입니다. 이 프로젝트는 **Next.js로 구현된 웹 프론트엔드**를 **Flutter 모바일 앱**으로 마이그레이션하는 작업입니다.

**핵심 목표:**
- Next.js 웹 앱(`/Users/yoram/hairspare`)과 Flutter 모바일 앱(`/Users/yoram/flutter`)의 **화면을 최대한 동일하게** 구현
- 프론트엔드(Flutter)와 백엔드(Next.js API Routes 또는 Python FastAPI MSA)를 분리하여 독립적으로 관리
- 사용자 경험(UX)과 사용자 인터페이스(UI)를 Next.js 버전과 일치시키기

### 1.2 프로젝트 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    HairSpare 플랫폼                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐         ┌──────────────────┐           │
│  │  Next.js Web     │         │  Flutter Mobile  │           │
│  │  (참고용)        │         │  (개발 중)       │           │
│  └──────────────────┘         └──────────────────┘           │
│           │                              │                   │
│           │                              │                   │
│           └──────────────┬───────────────┘                   │
│                          │                                   │
│                  ┌───────▼────────┐                          │
│                  │  Backend APIs  │                          │
│                  └────────────────┘                          │
│                          │                                   │
│           ┌──────────────┼──────────────┐                    │
│           │              │              │                    │
│    ┌──────▼──────┐ ┌─────▼─────┐ ┌─────▼──────┐            │
│    │ Next.js API │ │ FastAPI   │ │ PostgreSQL │            │
│    │ Routes      │ │ MSA       │ │ Database  │            │
│    │ (현재 사용) │ │ (향후)    │ │           │            │
│    └─────────────┘ └───────────┘ └───────────┘            │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

**현재 상태:**
- **Flutter 앱**: Next.js API Routes를 직접 호출 (`http://localhost:8000/api/...`)
- **백엔드**: Next.js API Routes (`/Users/yoram/hairspare/app/api/`)가 주로 사용됨
- **향후 계획**: Python FastAPI MSA (`/Users/yoram/hairspare/backend/`)로 전환 예정

### 1.3 역할(Role) 구조

프로젝트는 **두 가지 사용자 역할**을 지원합니다:

1. **Spare (스페어)**: 디자이너/미용사
   - 공고 확인 및 지원
   - 스케줄 관리
   - 에너지 시스템 (출근체크, 포인트)
   - 공간대여 (미용실 공간 대여)
   - 채팅/메시지
   - 프로필 관리

2. **Shop (미용실)**: 미용실 관리자
   - 공고 등록 및 관리
   - 지원자 관리
   - 스케줄 관리
   - 채팅/메시지
   - 프로필 관리

**현재 개발 상태**: 주로 **Spare 역할**의 화면들이 구현되어 있으며, Shop 역할의 일부 화면도 존재합니다.

---

## 2. 프로젝트 구조

### 2.1 로컬 디렉토리 구조

#### 2.1.1 Flutter 프로젝트 (`/Users/yoram/flutter/`)

```
flutter/
├── lib/
│   ├── main.dart                    # 앱 진입점
│   ├── models/                      # 데이터 모델
│   │   ├── job.dart
│   │   ├── notification.dart
│   │   ├── region.dart
│   │   ├── schedule.dart
│   │   ├── space_rental.dart        # 공간대여 모델
│   │   ├── spare_profile.dart
│   │   └── user.dart
│   ├── services/                    # API 서비스 레이어
│   │   ├── auth_service.dart
│   │   ├── chat_service.dart
│   │   ├── energy_service.dart
│   │   ├── favorite_service.dart
│   │   ├── job_service.dart
│   │   ├── notification_service.dart
│   │   ├── payment_service.dart
│   │   ├── schedule_service.dart
│   │   ├── space_rental_service.dart  # 공간대여 서비스
│   │   ├── spare_service.dart
│   │   └── verification_service.dart
│   ├── providers/                   # 상태 관리 (Provider 패턴)
│   │   ├── auth_provider.dart
│   │   ├── energy_provider.dart
│   │   ├── favorite_provider.dart
│   │   ├── job_provider.dart
│   │   └── schedule_provider.dart
│   ├── screens/                     # 화면 컴포넌트
│   │   ├── common/
│   │   │   └── role_select_screen.dart
│   │   ├── spare/                   # Spare 역할 화면들
│   │   │   ├── home_screen.dart
│   │   │   ├── job_detail_screen.dart
│   │   │   ├── jobs_list_screen.dart
│   │   │   ├── schedule_screen.dart
│   │   │   ├── points_screen.dart
│   │   │   ├── work_check_screen.dart
│   │   │   ├── energy_screen.dart
│   │   │   ├── energy_purchase_screen.dart
│   │   │   ├── payments_screen.dart
│   │   │   ├── reviews_screen.dart
│   │   │   ├── region_select_screen.dart  # 공간대여 화면
│   │   │   ├── space_rental_detail_screen.dart
│   │   │   ├── my_space_bookings_screen.dart
│   │   │   ├── messages_screen.dart
│   │   │   ├── chat_room_screen.dart
│   │   │   ├── favorites_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── profile_edit_screen.dart
│   │   │   ├── challenge_screen.dart
│   │   │   ├── education_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── ... (기타 화면들)
│   │   └── shop/                    # Shop 역할 화면들
│   │       ├── home_screen.dart
│   │       ├── jobs_list_screen.dart
│   │       └── ... (일부 구현됨)
│   ├── widgets/                     # 재사용 가능한 위젯
│   │   ├── bottom_nav_bar.dart      # 하단 네비게이션 바
│   │   ├── banner_carousel.dart     # 배너 캐러셀
│   │   ├── category_grid.dart       # 카테고리 그리드
│   │   ├── job_card.dart
│   │   ├── space_rental_card.dart   # 공간대여 카드
│   │   ├── popular_jobs_section.dart
│   │   ├── new_jobs_section.dart
│   │   ├── normal_jobs_section.dart
│   │   ├── urgent_job_section.dart
│   │   ├── upcoming_shops_section.dart
│   │   └── ... (기타 위젯들)
│   ├── theme/
│   │   └── app_theme.dart           # 앱 테마 (색상, 스타일)
│   └── utils/                       # 유틸리티 함수
│       ├── api_client.dart          # HTTP 클라이언트
│       ├── api_config.dart          # API 설정 (Base URL)
│       ├── app_exception.dart       # 예외 처리
│       ├── error_handler.dart
│       ├── icon_mapper.dart
│       ├── navigation_helper.dart
│       └── region_helper.dart
├── assets/
│   └── images/
│       ├── banners/                 # 배너 이미지
│       └── social/                  # 소셜 로그인 아이콘
├── pubspec.yaml                    # Flutter 의존성 관리
└── README.md
```

#### 2.1.2 Next.js 백엔드 (`/Users/yoram/hairspare/`)

```
hairspare/
├── app/
│   ├── api/                        # API Routes (백엔드 엔드포인트)
│   │   ├── auth/                   # 인증 관련
│   │   ├── jobs/                   # 공고 관련
│   │   ├── schedules/              # 스케줄 관련
│   │   ├── chats/                  # 채팅 관련
│   │   ├── energy/                 # 에너지 시스템
│   │   ├── payments/               # 결제 관련
│   │   ├── space-rentals/          # 공간대여 API
│   │   └── ... (기타 API들)
│   ├── spare/                      # Spare 역할 웹 화면 (참고용)
│   │   ├── home/
│   │   ├── jobs/
│   │   ├── schedule/
│   │   ├── points/
│   │   └── ... (기타 화면들)
│   └── shop/                       # Shop 역할 웹 화면 (참고용)
├── src/
│   ├── services/                   # 백엔드 서비스 로직
│   │   ├── job.service.ts
│   │   ├── space-rental.service.ts
│   │   └── ... (기타 서비스들)
│   ├── middleware/                 # 미들웨어 (인증, 권한 등)
│   └── utils/                      # 유틸리티
├── prisma/
│   └── schema.prisma               # 데이터베이스 스키마
└── package.json
```

#### 2.1.3 Python FastAPI MSA 백엔드 (`/Users/yoram/hairspare/backend/`)

```
backend/
├── api-gateway/                    # API Gateway 서비스
├── services/                      # 마이크로서비스들
│   ├── auth-service/
│   ├── job-service/
│   ├── schedule-service/
│   ├── chat-service/
│   └── energy-service/
├── shared/                        # 공유 모듈
│   ├── auth/
│   ├── database/
│   └── exceptions/
├── docker-compose.yml             # Docker Compose 설정
└── README.md
```

**참고**: 현재는 **Next.js API Routes**를 주로 사용하고 있으며, Python FastAPI MSA는 향후 전환 예정입니다.

### 2.2 GitHub 저장소 구조

#### 2.2.1 Flutter 저장소 (`hairspare-flutter`)

**URL**: `https://github.com/wangbow0404/hairspare-flutter`

**구조:**
```
hairspare-flutter/
├── flutter/                       # Flutter 프로젝트 코드
│   ├── lib/
│   ├── assets/
│   ├── pubspec.yaml
│   └── ...
└── README.md
```

**중요 사항:**
- 이전에 `hairspare_flutter/` 폴더와 `Buffett Test/` 폴더가 잘못 포함되어 있었으나, 현재는 정리되어 `flutter/` 폴더만 포함됩니다.
- 백엔드 코드는 별도 저장소(`hairspare-backend`)로 분리 예정입니다.

#### 2.2.2 백엔드 저장소 (`hairspare-backend`)

**URL**: `https://github.com/wangbow0404/hairspare-backend` (사용자가 수동으로 생성 필요)

**구조:**
```
hairspare-backend/
├── backend/                       # Python FastAPI MSA 코드
│   ├── api-gateway/
│   ├── services/
│   └── ...
└── README.md
```

**현재 상태**: 저장소는 생성되었으나 아직 코드가 푸시되지 않았습니다.

---

## 3. 완료된 작업

### 3.1 핵심 화면 구현

#### 3.1.1 홈 화면 (`home_screen.dart`)

**완료된 기능:**
- ✅ 배너 자동 스크롤 (3초마다 자동 전환, 수동 스크롤 감지)
- ✅ 인기 공고 섹션 (가로 스크롤, 무한 스크롤, 자동 스크롤)
- ✅ 신규 공고 섹션 (가로 스크롤, 무한 스크롤, AD 배지)
- ✅ 오픈 예정 매장 섹션 (4개 그리드, 어두운 배경)
- ✅ 일반 공고 페이지네이션 (10개씩, 이전/다음 버튼)
- ✅ 급구 공고 섹션
- ✅ 카테고리 그리드 (공고별, 스케줄표, 스토어, +포인트, 공간대여, 교육, 챌린지, 커넥트)
- ✅ 하단 네비게이션 바 (홈, 결제, 찜, 마이)

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/home_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/home/HomeContent.tsx`

#### 3.1.2 +포인트 화면 (`points_screen.dart`)

**완료된 기능:**
- ✅ 상단 배너
- ✅ 보유 포인트 표시 섹션
- ✅ 오늘의 미션 섹션 (출석체크)
- ✅ 간단미션 섹션
- ✅ 참여미션 섹션
- ✅ 구매미션 섹션
- ✅ 하단 배너

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/points_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/points/PointsContent.tsx`

#### 3.1.3 출근체크 화면 (`work_check_screen.dart`)

**완료된 기능:**
- ✅ 에너지 게이지 (연속 근무일수 표시)
- ✅ 연속 근무일수에 따른 제목 및 이모지 표시
- ✅ 캘린더 그리드 (월별 표시, 근무 예정 날짜 표시)
- ✅ 선택된 날짜의 근무 예정 카드 목록
- ✅ 근무 체크하기 버튼
- ✅ 따봉 모달 (매장 평가)
- ✅ 시간 경고 모달 (근무 시간 전/후 체크 경고)

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/work_check_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/work-check/WorkCheckContent.tsx`

#### 3.1.4 스케줄 화면 (`schedule_screen.dart`)

**완료된 기능:**
- ✅ 날짜별 그룹화
- ✅ 스케줄 상세 모달
- ✅ 스케줄 취소 기능
- ✅ 과거/미래 스케줄 시각적 구분

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/schedule_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/schedule/page.tsx`

#### 3.1.5 에너지 구매 화면 (`energy_purchase_screen.dart`)

**완료된 기능:**
- ✅ 에너지 패키지 선택 UI (1개, 3개, 5개)
- ✅ 인기 상품 표시 (3개 패키지)
- ✅ 현재 에너지 잔액 표시
- ✅ 결제 연동 (결제 API 호출)

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/energy_purchase_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/energy/purchase/EnergyPurchaseContent.tsx`

#### 3.1.6 프로필 하위 화면들

**에너지 화면** (`energy_screen.dart`):
- ✅ 잔액 카드 (그라데이션 배경)
- ✅ 거래 내역 목록
- ✅ 구매 버튼 (구매 화면으로 이동)

**결제 내역 화면** (`payments_screen.dart`):
- ✅ 결제 목록 표시
- ✅ 결제 상태 표시 (완료/실패/대기중)
- ✅ 날짜 포맷팅

**후기 화면** (`reviews_screen.dart`):
- ✅ 후기 작성 폼
- ✅ 후기 목록 표시
- ✅ 평점 표시 (별점)

**참고 파일:**
- Next.js: `/Users/yoram/hairspare/app/spare/profile/energy/page.tsx`
- Next.js: `/Users/yoram/hairspare/app/spare/profile/payments/page.tsx`
- Next.js: `/Users/yoram/hairspare/app/spare/profile/reviews/page.tsx`

#### 3.1.7 공간대여 시스템 (`region_select_screen.dart`, `space_rental_detail_screen.dart`, `my_space_bookings_screen.dart`)

**완료된 기능:**
- ✅ 화면 텍스트 변경 (지역별 공고 → 공간대여)
- ✅ 공간대여 데이터 모델 (`SpaceRental`, `TimeSlot`, `SpaceBooking`)
- ✅ 공간대여 서비스 (`SpaceRentalService`)
- ✅ 공간대여 카드 위젯 (`SpaceRentalCard`)
- ✅ 공간대여 상세 화면 (이미지 캐러셀, 미용실 정보, 시간대 선택, 예약하기)
- ✅ 내 예약 내역 화면 (예약 목록, 상태별 필터링, 예약 취소)
- ✅ 필터 기능 강화 (시간대 필터, 가격 범위 필터, 시설 필터)
- ✅ 백엔드 API 연동 (Next.js API Routes)

**참고 파일:**
- Flutter 모델: `/Users/yoram/flutter/lib/models/space_rental.dart`
- Flutter 서비스: `/Users/yoram/flutter/lib/services/space_rental_service.dart`
- Flutter 위젯: `/Users/yoram/flutter/lib/widgets/space_rental_card.dart`
- Flutter 화면: `/Users/yoram/flutter/lib/screens/spare/region_select_screen.dart`
- Next.js API: `/Users/yoram/hairspare/app/api/space-rentals/route.ts`
- Next.js 서비스: `/Users/yoram/hairspare/src/services/space-rental.service.ts`

### 3.2 UI/UX 개선

#### 3.2.1 메시지 화면 (`messages_screen.dart`)

**완료된 기능:**
- ✅ 스와이프 삭제 기능 (`Dismissible` 위젯 사용)
- ✅ 삭제 확인 모달

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/messages_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/messages/MessagesContent.tsx`

#### 3.2.2 공고 상세화면 (`job_detail_screen.dart`)

**완료된 기능:**
- ✅ Next.js와 UI 레이아웃 비교 및 개선
- ✅ 이미지, 정보 카드, 버튼 위치 일치
- ✅ 모달 스타일 및 애니메이션
- ✅ 에너지 배지, 카운트다운 표시

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/job_detail_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/jobs/[id]/page.tsx`

#### 3.2.3 프로필 화면 (`profile_screen.dart`)

**완료된 기능:**
- ✅ Next.js 프로필 화면 구조 확인 및 비교
- ✅ 메뉴 항목, 레이아웃, 스타일 일치

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/profile_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/profile/page.tsx`

#### 3.2.4 채팅방 화면 (`chat_room_screen.dart`)

**완료된 기능:**
- ✅ 메시지 자동 스크롤 (새 메시지 전송 시)
- ✅ 읽음 처리 (채팅방 열 때)
- ✅ 메시지 시간 포맷팅
- ✅ 프로필 이미지 표시

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/chat_room_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/messages/[chatId]/ChatRoomContent.tsx`

### 3.3 하단 네비게이션 바 통합

**완료된 작업:**
- ✅ 모든 주요 화면에 하단 네비게이션 바 적용
- ✅ 홈, 결제, 찜, 마이 버튼 클릭 시 올바른 화면으로 이동 (`Navigator.pushReplacement` 사용)
- ✅ 네비게이션 상태 관리 (현재 선택된 탭 표시)

**적용된 화면:**
- `home_screen.dart`
- `payment_screen.dart`
- `favorites_screen.dart`
- `profile_screen.dart`
- `points_screen.dart`
- `work_check_screen.dart`
- `schedule_screen.dart`
- `energy_screen.dart`
- `energy_purchase_screen.dart`
- `payments_screen.dart`
- `reviews_screen.dart`
- `region_select_screen.dart`
- `messages_screen.dart`
- `chat_room_screen.dart`
- `job_detail_screen.dart`
- `jobs_list_screen.dart`
- `challenge_screen.dart`
- `education_screen.dart`
- `space_rental_detail_screen.dart`
- `my_space_bookings_screen.dart`
- 기타 모든 주요 화면

**참고 파일:**
- 위젯: `/Users/yoram/flutter/lib/widgets/bottom_nav_bar.dart`
- 유틸리티: `/Users/yoram/flutter/lib/utils/navigation_helper.dart`

### 3.4 테마 및 스타일링

**완료된 작업:**
- ✅ Next.js의 Tailwind CSS 색상과 Flutter 색상 매핑
- ✅ 그라데이션 색상 일치
- ✅ 폰트 크기, 굵기, 간격 일치
- ✅ 패딩, 마진 값 일치
- ✅ 반응형 브레이크포인트 고려 (`max-w-[768px]`)

**참고 파일:**
- 테마: `/Users/yoram/flutter/lib/theme/app_theme.dart`

---

## 4. 진행 중/대기 중인 작업

### 4.1 챌린지 화면 개선 (`challenge_screen.dart`)

**현재 상태**: 기본 구조는 있으나 Next.js의 복잡한 비디오 스크롤 기능이 누락됨

**필요한 작업:**
- ⏳ 복잡한 비디오 스크롤 기능 구현 (수직 스크롤, 스냅)
- ⏳ 자동 재생/일시정지 기능
- ⏳ 음소거 토글 기능
- ⏳ 좋아요 기능
- ⏳ 비디오 뷰어 최적화
- ⏳ 스크롤 락 기능 (스냅 중)

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/challenge_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/challenge/ChallengeContent.tsx`

**우선순위**: 중간

### 4.2 교육 화면 개선 (`education_screen.dart`)

**현재 상태**: 기본 구조는 있으나 Next.js의 복잡한 필터링 기능이 누락됨

**필요한 작업:**
- ⏳ 복잡한 필터링 기능 구현:
  - 지역 필터 (도/시 선택, 구/군 선택)
  - 카테고리 필터 (대분류, 소분류)
  - 정렬 옵션 (최신순, 가격순, 마감순, 신청자순)
  - 교육 유형 필터 (오프라인/온라인/전체)
- ⏳ 드롭다운 위치 계산 (버튼 위치 기준)
- ⏳ 필터링된 교육 목록 표시

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/education_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/education/EducationContent.tsx`

**우선순위**: 중간

### 4.3 프로필 편집 화면 개선 (`profile_edit_screen.dart`)

**현재 상태**: 기본 구조는 있으나 복잡한 기능들이 누락됨

**필요한 작업:**
- ⏳ 본인인증 정보 자동 채우기 (인증 완료 시)
- ⏳ 프로필 이미지 업로드 (최대 3개)
- ⏳ 휴대폰 인증 기능 (인증번호 발송/확인)
- ⏳ 출생년도/성별 선택
- ⏳ 본인인증 정보와 회원가입 정보 구분 표시

**참고 파일:**
- Flutter: `/Users/yoram/flutter/lib/screens/spare/profile_edit_screen.dart`
- Next.js: `/Users/yoram/hairspare/app/spare/profile/edit/ProfileEditContent.tsx`

**우선순위**: 낮음

### 4.4 애니메이션 최적화

**필요한 작업:**
- ⏳ 자동 스크롤 애니메이션 최적화 (`AnimationController` 사용)
- ⏳ 프레임 기반 애니메이션 (60fps 기준)
- ⏳ 수동 스크롤 감지 정확도 향상
- ⏳ 무한 스크롤 효과 개선 (카드 반복 로직 최적화)
- ⏳ 페이지 전환 애니메이션 (Next.js의 페이지 전환과 유사하게)

**우선순위**: 낮음

### 4.5 스타일링 세부 조정

**필요한 작업:**
- ⏳ 전체적인 스타일링 일치 확인 및 세부 조정
- ⏳ 색상 및 테마 일치 재확인
- ⏳ 폰트 및 타이포그래피 세부 조정
- ⏳ 간격 및 레이아웃 세부 조정

**우선순위**: 낮음

### 4.6 커넥트 화면 구현

**현재 상태**: 홈 화면에 카테고리로만 존재하며, 실제 화면이 구현되지 않음

**필요한 작업:**
- ⏳ 커넥트 화면 전체 구현
- ⏳ Next.js의 커넥트 화면 참고

**우선순위**: 낮음

### 4.7 스토어 화면 구현

**현재 상태**: 홈 화면에 카테고리로만 존재하며, 실제 화면이 구현되지 않음

**필요한 작업:**
- ⏳ 스토어 화면 전체 구현
- ⏳ Next.js의 스토어 화면 참고

**우선순위**: 낮음

### 4.8 백엔드 마이그레이션 (Python FastAPI MSA)

**현재 상태**: Next.js API Routes를 사용 중이며, Python FastAPI MSA는 준비되어 있으나 아직 전환되지 않음

**필요한 작업:**
- ⏳ Python FastAPI MSA로 API 엔드포인트 전환
- ⏳ Flutter 앱의 API 호출 경로 업데이트 (`api_config.dart`)
- ⏳ 인증 시스템 통합
- ⏳ 데이터베이스 연결 및 마이그레이션

**참고 파일:**
- FastAPI 백엔드: `/Users/yoram/hairspare/backend/`
- API 설정: `/Users/yoram/flutter/lib/utils/api_config.dart`

**우선순위**: 낮음 (향후 계획)

---

## 5. 기술 스택 및 설정

### 5.1 Flutter 기술 스택

#### 5.1.1 핵심 프레임워크

- **Flutter SDK**: `>=3.0.0 <4.0.0`
- **Dart SDK**: `>=3.0.0 <4.0.0`

#### 5.1.2 주요 의존성 패키지

**상태 관리:**
- `provider: ^6.1.1` - 상태 관리 (Provider 패턴)

**HTTP 통신:**
- `http: ^1.1.0` - 기본 HTTP 클라이언트
- `dio: ^5.4.0` - 고급 HTTP 클라이언트 (인터셉터, 에러 처리 등)

**로컬 저장소:**
- `shared_preferences: ^2.2.2` - 간단한 키-값 저장소
- `flutter_secure_storage: ^9.0.0` - 보안 저장소 (토큰 등)

**이미지 처리:**
- `image_picker: ^1.0.5` - 이미지 선택 (갤러리, 카메라)
- `cached_network_image: ^3.3.0` - 네트워크 이미지 캐싱

**비디오 플레이어:**
- `video_player: ^2.8.2` - 비디오 재생

**UI 컴포넌트:**
- `flutter_svg: ^2.0.9` - SVG 이미지 지원
- `intl: ^0.20.2` - 국제화 및 날짜/시간 포맷팅

**유틸리티:**
- `uuid: ^4.2.1` - UUID 생성
- `path_provider: ^2.1.1` - 파일 경로 관리
- `url_launcher: ^6.2.2` - URL 열기 (브라우저, 전화 등)

**로컬라이제이션:**
- `flutter_localizations` - 다국어 지원 (한국어, 영어)

### 5.2 백엔드 기술 스택

#### 5.2.1 Next.js API Routes (현재 사용 중)

- **프레임워크**: Next.js (App Router)
- **언어**: TypeScript
- **인증**: NextAuth.js
- **데이터베이스**: PostgreSQL (Prisma ORM)
- **포트**: `3000` (개발 서버)

**API Base URL**: `http://localhost:3000/api/` (또는 실제 도메인)

#### 5.2.2 Python FastAPI MSA (향후 전환 예정)

- **프레임워크**: FastAPI
- **언어**: Python 3.11+
- **인증**: JWT
- **데이터베이스**: PostgreSQL (SQLAlchemy ORM)
- **포트**: `8000` (API Gateway)

**API Base URL**: `http://localhost:8000/api/` (또는 실제 도메인)

**마이크로서비스 구조:**
- `api-gateway` - API Gateway 서비스
- `auth-service` - 인증 서비스
- `job-service` - 공고 서비스
- `schedule-service` - 스케줄 서비스
- `chat-service` - 채팅 서비스
- `energy-service` - 에너지 서비스

### 5.3 API 설정

#### 5.3.1 Flutter API 설정 (`api_config.dart`)

**현재 설정:**
- **웹**: `http://localhost:8000` (FastAPI Gateway 포트)
- **Android 에뮬레이터**: `http://10.0.2.2:8000`
- **iOS 시뮬레이터**: `http://localhost:8000`
- **실제 디바이스**: 컴퓨터의 로컬 IP 주소 필요 (예: `http://192.168.1.100:8000`)

**참고 파일**: `/Users/yoram/flutter/lib/utils/api_config.dart`

**중요 사항:**
- 현재는 Next.js API Routes를 사용하므로, 실제로는 `http://localhost:3000/api/`를 호출해야 할 수 있습니다.
- Python FastAPI MSA로 전환 시 `api_config.dart`를 업데이트해야 합니다.

### 5.4 개발 환경 설정

#### 5.4.1 Flutter 개발 환경

**필수 도구:**
- Flutter SDK 설치
- Android Studio 또는 VS Code (Flutter 확장 설치)
- Android SDK (Android 개발용)
- Xcode (iOS 개발용, macOS만)

**실행 명령어:**
```bash
# 의존성 설치
flutter pub get

# 웹에서 실행
flutter run -d chrome --web-port=8080

# Android 에뮬레이터에서 실행
flutter run -d android

# iOS 시뮬레이터에서 실행 (macOS만)
flutter run -d ios

# Hot Reload (터미널에서 'r' 키 입력)
# Hot Restart (터미널에서 'R' 키 입력)
```

**Hot Reload 가이드**: `HOT_RELOAD_GUIDE.md` 참고

#### 5.4.2 Next.js 백엔드 개발 환경

**필수 도구:**
- Node.js 18+ 설치
- PostgreSQL 데이터베이스 설치 및 실행

**실행 명령어:**
```bash
# 의존성 설치
npm install

# 개발 서버 실행
npm run dev

# 포트: http://localhost:3000
```

#### 5.4.3 Python FastAPI MSA 개발 환경

**필수 도구:**
- Python 3.11+ 설치
- Docker 및 Docker Compose (선택사항)

**실행 명령어:**
```bash
# Docker Compose로 모든 서비스 실행
cd /Users/yoram/hairspare/backend
docker-compose up

# 또는 개별 서비스 실행
cd api-gateway
python -m uvicorn app.main:app --reload --port 8000
```

**참고 파일**: `/Users/yoram/hairspare/backend/README.md`

---

## 6. 중요한 참고사항

### 6.1 프로젝트 구조 관련

#### 6.1.1 Git 저장소 구조

**중요**: 루트 Git 저장소가 `/Users/yoram`입니다. 이는 프로젝트별 폴더가 아닌 사용자 홈 디렉토리입니다.

**영향:**
- `.gitignore` 파일이 `/Users/yoram/.gitignore`에 위치합니다.
- Git 명령어 실행 시 현재 디렉토리를 명확히 확인해야 합니다.

**해결 방법:**
- 각 프로젝트 폴더(`/Users/yoram/flutter`, `/Users/yoram/hairspare`)에서 Git 작업을 수행할 때는 해당 폴더로 이동한 후 실행합니다.
- 또는 각 프로젝트를 별도의 Git 저장소로 초기화하는 것을 고려할 수 있습니다.

#### 6.1.2 백엔드 저장소 분리

**현재 상태:**
- Flutter 코드는 `hairspare-flutter` 저장소에 있습니다.
- 백엔드 코드는 별도 저장소(`hairspare-backend`)로 분리 예정입니다.

**작업 필요:**
- `/Users/yoram/hairspare/backend/` 폴더의 내용을 `hairspare-backend` 저장소에 푸시해야 합니다.

### 6.2 API 호출 관련

#### 6.2.1 CORS 설정

**문제**: Flutter 웹 앱에서 Next.js API를 호출할 때 CORS 오류가 발생할 수 있습니다.

**해결 방법:**
- Next.js API Routes에 CORS 헤더를 추가해야 합니다.
- 또는 Next.js의 `next.config.js`에 CORS 설정을 추가합니다.

**참고 파일**: `CORS_FIX.md`

#### 6.2.2 인증 토큰 관리

**현재 구현:**
- `flutter_secure_storage`를 사용하여 JWT 토큰을 안전하게 저장합니다.
- `ApiClient`에서 요청 시 자동으로 토큰을 헤더에 추가합니다.

**참고 파일:**
- 인증 서비스: `/Users/yoram/flutter/lib/services/auth_service.dart`
- API 클라이언트: `/Users/yoram/flutter/lib/utils/api_client.dart`

### 6.3 화면 네비게이션 관련

#### 6.3.1 하단 네비게이션 바

**중요**: 모든 주요 화면에 하단 네비게이션 바가 적용되어 있어야 합니다.

**구현 방법:**
- `BottomNavBar` 위젯을 사용합니다.
- 네비게이션 시 `Navigator.pushReplacement`를 사용하여 이전 화면을 스택에서 제거합니다.

**참고 파일:**
- 위젯: `/Users/yoram/flutter/lib/widgets/bottom_nav_bar.dart`
- 유틸리티: `/Users/yoram/flutter/lib/utils/navigation_helper.dart`

#### 6.3.2 화면 전환 애니메이션

**현재 상태**: 기본 Material 페이지 전환 애니메이션을 사용 중입니다.

**향후 개선**: Next.js의 페이지 전환과 유사한 커스텀 애니메이션을 적용할 수 있습니다.

### 6.4 상태 관리 관련

#### 6.4.1 Provider 패턴 사용

**현재 구현:**
- `Provider` 패키지를 사용하여 전역 상태를 관리합니다.
- 주요 Provider:
  - `AuthProvider` - 인증 상태
  - `JobProvider` - 공고 데이터
  - `FavoriteProvider` - 찜 목록
  - `ScheduleProvider` - 스케줄 데이터
  - `EnergyProvider` - 에너지 데이터

**참고 파일**: `/Users/yoram/flutter/lib/providers/`

#### 6.4.2 로컬 상태 관리

**구현 방법:**
- `StatefulWidget`의 `setState`를 사용하여 화면별 로컬 상태를 관리합니다.
- 복잡한 상태는 `Provider`로 전역화합니다.

### 6.5 에러 처리 관련

#### 6.5.1 예외 처리 구조

**현재 구현:**
- `AppException` 기반 예외 클래스 구조를 사용합니다.
- `ErrorHandler`를 통해 예외를 처리하고 사용자에게 메시지를 표시합니다.

**예외 타입:**
- `ServerException` - 서버 오류
- `NetworkException` - 네트워크 오류
- `AuthenticationException` - 인증 오류
- `PermissionException` - 권한 오류
- `NotFoundException` - 리소스 없음
- `ValidationException` - 유효성 검사 오류

**참고 파일:**
- 예외 클래스: `/Users/yoram/flutter/lib/utils/app_exception.dart`
- 에러 핸들러: `/Users/yoram/flutter/lib/utils/error_handler.dart`

### 6.6 이미지 및 에셋 관리

#### 6.6.1 이미지 로딩

**구현 방법:**
- 네트워크 이미지는 `cached_network_image` 패키지를 사용합니다.
- 로컬 이미지는 `assets/images/` 폴더에 저장하고 `pubspec.yaml`에 등록합니다.

**참고 파일**: `/Users/yoram/flutter/pubspec.yaml`

#### 6.6.2 배너 이미지

**위치**: `/Users/yoram/flutter/assets/images/banners/`
- `banner1.jpg`
- `banner2.jpg`
- `banner3.jpg`
- `banner4.jpg`

**사용**: `BannerCarousel` 위젯에서 사용됩니다.

### 6.7 공간대여 시스템 관련

#### 6.7.1 데이터 모델

**모델 파일**: `/Users/yoram/flutter/lib/models/space_rental.dart`

**주요 클래스:**
- `SpaceRental` - 공간대여 정보
- `TimeSlot` - 시간대 정보
- `SpaceBooking` - 예약 정보
- `SpaceStatus` - 공간 상태 열거형

#### 6.7.2 API 엔드포인트

**Next.js API Routes:**
- `GET /api/space-rentals` - 공간 목록 조회
- `GET /api/space-rentals/[id]` - 공간 상세 조회
- `POST /api/space-rentals/[id]/book` - 공간 예약
- `GET /api/space-rentals/my-bookings` - 내 예약 내역 조회
- `GET /api/space-rentals/bookings/[id]` - 예약 상세 조회
- `DELETE /api/space-rentals/bookings/[id]` - 예약 취소

**참고 파일**: `/Users/yoram/hairspare/app/api/space-rentals/`

---

## 7. 트러블슈팅 가이드

### 7.1 컴파일 오류

#### 7.1.1 "Not a constant expression" 오류

**증상:**
```
Error: Not a constant expression.
MaterialPageRoute(builder: (context) => const Widget()),
```

**원인**: `MaterialPageRoute`의 `builder`에서 `const` 키워드를 사용할 수 없습니다.

**해결 방법:**
- `const` 키워드를 제거합니다.
- 예: `MaterialPageRoute(builder: (context) => Widget())`

**참고**: 이 문제는 이미 대부분의 파일에서 수정되었습니다. 새로운 화면을 추가할 때 주의하세요.

#### 7.1.2 "The method 'X' isn't defined" 오류

**증상:**
```
Error: The method 'SpareHomeScreen' isn't defined for the type '_SomeScreenState'.
```

**원인**: 필요한 import 문이 누락되었습니다.

**해결 방법:**
- 해당 화면 파일의 상단에 import 문을 추가합니다.
- 예: `import '../spare/home_screen.dart';`

### 7.2 런타임 오류

#### 7.2.1 API 호출 실패 (404 Not Found)

**증상:**
```
Request URL http://localhost:8000/api/space-rentals
Status Code 404 Not Found
```

**원인:**
- API 엔드포인트가 존재하지 않거나 경로가 잘못되었습니다.
- 백엔드 서버가 실행되지 않았습니다.

**해결 방법:**
1. 백엔드 서버가 실행 중인지 확인합니다.
2. API 엔드포인트 경로를 확인합니다 (`api_config.dart` 참고).
3. Next.js API Routes 파일이 존재하는지 확인합니다 (`/Users/yoram/hairspare/app/api/`).

**참고**: 공간대여 API는 이미 구현되어 있습니다. 다른 API에서 404 오류가 발생하면 해당 API Route를 확인하세요.

#### 7.2.2 CORS 오류

**증상:**
```
Access to XMLHttpRequest at 'http://localhost:3000/api/...' from origin 'http://localhost:8080' has been blocked by CORS policy
```

**원인**: Flutter 웹 앱과 Next.js API 간의 CORS 설정이 없습니다.

**해결 방법:**
1. Next.js API Routes에 CORS 헤더를 추가합니다.
2. 또는 `next.config.js`에 CORS 설정을 추가합니다.

**참고 파일**: `CORS_FIX.md`

#### 7.2.3 인증 오류 (401 Unauthorized)

**증상:**
```
Status Code 401 Unauthorized
```

**원인:**
- JWT 토큰이 만료되었거나 유효하지 않습니다.
- 토큰이 요청 헤더에 포함되지 않았습니다.

**해결 방법:**
1. `flutter_secure_storage`에서 토큰을 확인합니다.
2. 토큰이 없거나 만료된 경우 다시 로그인합니다.
3. `ApiClient`에서 토큰이 자동으로 추가되는지 확인합니다.

**참고 파일:**
- 인증 서비스: `/Users/yoram/flutter/lib/services/auth_service.dart`
- API 클라이언트: `/Users/yoram/flutter/lib/utils/api_client.dart`

### 7.3 UI/UX 문제

#### 7.3.1 하단 네비게이션 바가 작동하지 않음

**증상**: 하단 네비게이션 바의 버튼을 클릭해도 화면이 전환되지 않습니다.

**원인:**
- `Navigator.pushReplacement` 대신 `Navigator.push`를 사용했습니다.
- 또는 잘못된 화면 클래스를 참조했습니다.

**해결 방법:**
1. `NavigationHelper.navigateToBottomNavScreen`을 사용합니다.
2. 또는 `Navigator.pushReplacement`를 직접 사용합니다.
3. 올바른 화면 클래스를 import하고 사용합니다.

**참고 파일:**
- 유틸리티: `/Users/yoram/flutter/lib/utils/navigation_helper.dart`
- 위젯: `/Users/yoram/flutter/lib/widgets/bottom_nav_bar.dart`

#### 7.3.2 Hot Reload가 작동하지 않음

**증상**: 코드를 수정해도 앱이 자동으로 업데이트되지 않습니다.

**원인:**
- Hot Reload가 지원되지 않는 변경사항입니다 (예: `main()` 함수 수정, 상수 변경).

**해결 방법:**
1. 터미널에서 `R` 키를 눌러 Hot Restart를 수행합니다.
2. 또는 앱을 완전히 재시작합니다 (`flutter run`).

**참고 파일**: `HOT_RELOAD_GUIDE.md`

### 7.4 성능 문제

#### 7.4.1 이미지 로딩이 느림

**증상**: 네트워크 이미지가 느리게 로드됩니다.

**해결 방법:**
- `cached_network_image` 패키지를 사용하여 이미지를 캐싱합니다.
- 이미지 크기를 최적화합니다.

#### 7.4.2 스크롤이 버벅임

**증상**: 리스트 스크롤이 부드럽지 않습니다.

**해결 방법:**
- `ListView.builder`를 사용하여 가상화를 활성화합니다.
- 불필요한 위젯 재빌드를 방지하기 위해 `const` 생성자를 사용합니다.
- `setState` 호출을 최소화합니다.

### 7.5 Git 관련 문제

#### 7.5.1 "Operation not permitted" 오류

**증상:**
```
error: could not lock config file .git/config: Operation not permitted
```

**원인**: Git 작업에 필요한 권한이 없습니다.

**해결 방법:**
- 터미널 명령어 실행 시 `required_permissions: ['all']` 또는 `required_permissions: ['git_write']`를 사용합니다.
- 또는 수동으로 Git 명령어를 실행합니다.

#### 7.5.2 "could not read Username" 오류

**증상:**
```
fatal: could not read Username for 'https://github.com': Device not configured
```

**원인**: Git 인증 정보가 설정되지 않았습니다.

**해결 방법:**
1. GitHub Personal Access Token을 생성합니다.
2. Git credential helper를 설정합니다.
3. 또는 SSH 키를 사용하여 인증합니다.

#### 7.5.3 "fetch first" 오류

**증상:**
```
! [rejected] main -> main (fetch first)
```

**원인**: 원격 저장소와 로컬 저장소의 히스토리가 분기되었습니다.

**해결 방법:**
1. `git pull origin main --allow-unrelated-histories --no-rebase --no-edit`를 실행합니다.
2. 충돌이 있으면 해결한 후 커밋합니다.
3. `git push origin main`을 실행합니다.

---

## 8. 다음 단계 및 권장 사항

### 8.1 즉시 진행 가능한 작업

1. **챌린지 화면 개선**: 비디오 스크롤 기능 구현
2. **교육 화면 개선**: 복잡한 필터링 기능 구현
3. **프로필 편집 화면 개선**: 본인인증 연동 및 이미지 업로드

### 8.2 중장기 작업

1. **애니메이션 최적화**: 자동 스크롤 및 페이지 전환 애니메이션 개선
2. **스타일링 세부 조정**: Next.js와 완벽한 일치를 위한 세부 조정
3. **백엔드 마이그레이션**: Python FastAPI MSA로 전환

### 8.3 테스트 및 품질 관리

1. **단위 테스트**: 주요 서비스 및 유틸리티 함수에 대한 테스트 작성
2. **통합 테스트**: API 연동 테스트
3. **E2E 테스트**: 주요 사용자 플로우 테스트 (Playwright 사용 가능)

### 8.4 문서화

1. **API 문서**: 백엔드 API 엔드포인트 문서화
2. **컴포넌트 문서**: 주요 위젯 및 화면 컴포넌트 문서화
3. **배포 가이드**: 프로덕션 배포 가이드 작성

---

## 9. 참고 자료

### 9.1 플랜 파일

- **UI 동일화 플랜**: `/Users/yoram/.cursor/plans/next.js_flutter_ui_동일화_07bb8080.plan.md`
- **공간대여 시스템 플랜**: `/Users/yoram/.cursor/plans/공간대여_시스템_구현_플랜.md`

### 9.2 가이드 문서

- **Hot Reload 가이드**: `HOT_RELOAD_GUIDE.md`
- **CORS 수정 가이드**: `CORS_FIX.md`
- **디자인 마이그레이션 플랜**: `archive/DESIGN_MIGRATION_PLAN.md`

### 9.3 백엔드 문서

- **Next.js 백엔드**: `/Users/yoram/hairspare/README.md`
- **Python FastAPI MSA**: `/Users/yoram/hairspare/backend/README.md`

---

## 10. 문의 및 지원

프로젝트 관련 질문이나 문제가 발생하면:

1. 이 문서의 **트러블슈팅 가이드** 섹션을 먼저 확인하세요.
2. 관련 플랜 파일 및 가이드 문서를 참고하세요.          
3. Git 히스토리 및 커밋 메시지를 확인하여 변경사항을 파악하세요.

---

**문서 작성일**: 2026-02-05  
**마지막 업데이트**: 2026-02-05  
**버전**: 1.0.0
