# HairSpare UI Redesign Brief for Google Stitch

> **사용 방법:** 이 파일 전체를 Stitch 캔버스 프롬프트에 **한 번에 복사·붙여넣기** 하세요.  
> **권장 모드:** `Ideate` (브랜드 방향 3안) → 선택 후 `Redesign` (기존 스크린샷 리프레시)  
> **첨부 권장:** 현재 앱 스크린샷 8~10장 (Spare 홈, Shop 홈, Admin 대시보드 등)  
> **플랫폼:** Spare/Shop = 모바일 iOS/Android (390×844) · Admin = 웹/태블릿 대시보드 (1280×800)

---

## 0. Stitch에게 요청하는 최종 산출물

1. **DESIGN.md** — 색상·타이포·간격·컴포넌트 규칙 (Flutter 구현용 single source of truth)
2. **Spare 모바일** Must 화면 전체 (아래 목록)
3. **Shop 모바일** Must 화면 전체 (아래 목록)
4. **Admin 웹** Must 화면 전체 (아래 목록)
5. **Instant Prototype** — Spare: 공고→지원→스케줄 / Shop: 공고등록→지원자승인→스케줄
6. 모든 UI 텍스트는 **한국어**
7. **정보 구조(IA)와 기능은 유지**, 비주얼·UX·일관성만 개선

---

## 1. 제품 한 줄 요약

**HairSpare(헤어스페어)** 는 미용실 **Shop(사장)** 과 프리랜서 미용사 **Spare(스페어)** 를 연결하는 **급구·스케줄·채팅·에너지(예약금)** 마켓플레이스 모바일 앱 MVP입니다. 운영팀용 **Admin 웹 대시보드**가 함께 있습니다.

---

## 2. 사용자 역할 3가지

| 역할 | 사용자 | 핵심 행동 |
|------|--------|-----------|
| **Spare** | 구직 미용사·디자이너·스텝 | 공고 탐색 → 지원 → 에너지 결제 → 스케줄 → 출근 체크 → 채팅 |
| **Shop** | 미용실 사장·매니저 | 인력 검색 → 공고 등록 → 지원자 승인/거절 → 스케줄·채팅·공간대여 |
| **Admin** | 플랫폼 운영자 | 회원·공고·결제·에너지·노쇼·체크인 관리 |

---

## 3. 브랜드·톤앤매너

- **업종:** K-Beauty / 미용실 B2B2C
- **느낌:** 전문적이지만 친근함, 신뢰감 있는 매칭 플랫폼
- **타겟:** Shop 30~50대 사장님, Spare 20~40대 미용사
- **피할 것:** 제네릭 AI 보라 그라데이션, 과한 글래스모피즘, 이모지 남발, 알록달록 아이콘
- **지향:** 당근/토스/카카오비즈니스급 **정돈된 한국형 모바일 UX** + 급구(urgent)만 오렌지·레드로 강조

---

## 4. 현재 디자인 시스템 (기존 — 개선 대상)

> Stitch는 아래 토큰을 **출발점**으로 삼되, Blue/Purple 혼재·아이콘 색 분산 문제를 **통일된 DESIGN.md**로 정리해 주세요.

### 4.1 색상

| 토큰 | HEX | 용도 |
|------|-----|------|
| Primary Purple | `#9333EA` | 브랜드, CTA, 선택 상태, 로고 |
| Primary Purple Light | `#F3E8FF` | 선택 배경, 칩, 배지 배경 |
| Purple 700 | `#7E22CE` | 태그·보조 텍스트 |
| Primary Blue | `#3B82F6` | 현재 Theme seed (→ Purple로 통일 권장) |
| Background Gray | `#F9FAFB` | 페이지 배경 |
| Background White | `#FFFFFF` | 카드·상단바 |
| Text Primary | `#111827` | 제목·본문 |
| Text Secondary | `#6B7280` | 부가 정보 |
| Text Tertiary | `#9CA3AF` | 비활성 |
| Border Gray | `#E5E7EB` | 구분선·테두리 |
| Urgent Red | `#EF4444` | 급구·알림 뱃지 |
| Orange 500 | `#F97316` | 급구 강조 (절제해서 사용) |
| Yellow 400 | `#FACC15` | 인기 배지 그라데이션 |
| Green 600 | `#16A34A` | 성공·완료 |
| Admin gradient | purple-50 → blue-50 → pink-50 | Admin 배경 (→ 더 절제된 SaaS 톤 권장) |

### 4.2 레이아웃

- **간격:** 8px 그리드 — 4, 8, 12, 16, 24, 32px
- **Radius:** 카드·버튼·필터 **12px** (Admin 카드 24px)
- **Safe Area:** 상단바 = `44px + status bar padding`
- **화면 패딩:** 좌우 12~16px

### 4.3 타이포 (한국어)

| 역할 | 크기 | 굵기 |
|------|------|------|
| 페이지 제목 | 18~20px | Bold |
| 섹션 제목 | 16px | Bold |
| 본문 | 14px | Regular/Medium |
| 캡션·라벨 | 12px | Medium |
| 버튼 | 14~16px | SemiBold |

**폰트:** Pretendard 또는 SF Pro / Noto Sans KR 계열

---

## 5. 공통 네비게이션 (Spare · Shop 동일 패턴)

### 5.1 하단 탭 (4개 — 변경 금지)

| 순서 | 라벨 | 역할 |
|------|------|------|
| 0 | **홈** | 메인 피드 |
| 1 | **결제** | 결제·에너지 관련 |
| 2 | **찜** | 찜 목록 |
| 3 | **마이** | 프로필·설정 |

- 배경: White, 상단 1px `#E5E7EB` 구분선
- 활성: Primary Purple 아이콘+텍스트
- 비활성: `#6B7280`

### 5.2 상단 앱바 (홈 탭)

- **왼쪽:** `HairSpare` 로고 (20px Bold, `#9333EA`)
- **오른쪽:** 검색(아이콘) · 메시지(뱃지 가능) · 알림(뱃지 가능)
- 높이 44px + Safe Area, White 배경, 하단 1px border
- **검색:** 큰 검색창 X → **아이콘 버튼**만 (하단 탭과 시각적 충돌 방지)

### 5.3 서브 화면 상단바

- 뒤로가기 + 페이지 제목 (Purple 또는 Text Primary)
- SliverAppBar 패턴, `56px + Safe Area` 또는 `44px + Safe Area`

---

## 6. UX 개선 필수 요구사항 (디자인 리뷰 기준)

아래 원칙을 **모든 화면**에 적용해 주세요.

1. **아이콘 컬러 통일** — 네비·카테고리·액션 아이콘은 단색 outline 스타일, Primary Purple + Secondary Gray만
2. **카드 중첩 줄이기** — 홈에서 카드 안의 카드 남발 금지; 섹션 제목 + 여백으로 구분
3. **배너 몰입감** — 240px 히어로: flat rectangle X → 기울임·레이어·그라데이션 오버레이·CTA
4. **섹션 구조** — 급구/인기/신규 등: **탭 또는 세그먼트** + **가로 캐러셀**, 세로로 무한 나열 X
5. **급구 배지** — Orange/Red만 사용, 나머지 UI는 중립 톤
6. **터치 영역** — 최소 44×44px
7. **빈 상태·에러** — 중앙 아이콘 + 안내 문구 + Primary CTA
8. **Spare / Shop / Admin** — 같은 DESIGN.md 토큰, Admin만 정보 밀도 높게

---

## 7. Spare(스페어) — 화면 명세

### 7.1 Spare 홈

**구성 (위→아래, IA 유지):**

1. 상단 앱바 (§5.2)
2. **배너 캐러셀** (240px, 4장 rotator)
3. **카테고리 그리드** (2×4 또는 4×2):
   - 공고별 · 스케줄표 · 스토어(준비중) · +포인트
   - 공간대여 · 교육 · 챌린지참여 · 커넥트(준비중)
4. **급구 공고** 가로 스크롤 섹션 (`급구` Orange/Red 배지)
5. **인기 공고** 가로 스크롤
6. **신규 공고** 가로 스크롤
7. **일반 공고** 가로 스크롤
8. **다가오는 샵** 섹션
9. **고객센터** 푸터 섹션

**공고 카드 요소:** 샵명, 급구 배지, 급여/일당, 지역, 근무일, 찜 버튼

### 7.2 Spare Must 화면 목록

| # | 화면 | 핵심 UI |
|---|------|---------|
| 1 | **홈** | §7.1 |
| 2 | **공고 목록** | 지역·정렬 필터 드롭다운, 카테고리 칩, 공고 리스트 |
| 3 | **공고 상세** | 샵 정보, 급여, 일정, **지원하기** CTA, 에너지(예약금) 안내 |
| 4 | **스케줄** | 확정/대기/완료 탭, 일정 카드, 취소 버튼 |
| 5 | **근무 체크** | 근무 종료 후 체크인 카드, phase별 안내 |
| 6 | **메시지 목록** | 채팅방 리스트, 미읽음 뱃지 |
| 7 | **채팅방** | 메시지 버블, **연락처 공유 경고 배너**(상단 짧은 배너) |
| 8 | **결제/에너지** | 에너지 잔액, 충전, 사용 내역 |
| 9 | **찜** | 찜한 공고·인력 리스트 |
| 10 | **마이(프로필)** | 프로필 카드, 메뉴 리스트 (설정, 알림, 리뷰 등) |
| 11 | **알림 목록** | 알림 타입별 아이콘 + 본문 |
| 12 | **챌린지 피드** | TikTok式 immersive **또는** 라이트 테마 통일 — **하나만 선택**, 앱 전체와 조화 |

**Spare 핵심 CTA 라벨:** `지원하기` · `출근 체크` · `에너지 충전` · `채팅하기`

---

## 8. Shop(미용실) — 화면 명세

### 8.1 Shop 홈

**구성 (위→아래):**

1. 상단 앱바 (§5.2)
2. **배너 캐러셀** (240px)
3. **카테고리 그리드** (아이콘 단색 통일):
   - 인력별 · 스케줄표 · 스토어 · +포인트
   - 공간대여 · 교육 · 챌린지 · 커넥트
4. **운영 대시보드 카드** (3열 또는 스택):
   - 활성 공고 수
   - 대기 지원자 수
   - 오늘 일정 수
5. **빠른 액션** (가로 스크롤 또는 2×2 그리드):
   - 공고 올리기 · 내 공고 · 지원자 확인 · VIP 현황
6. **인기 스페어** 가로 스크롤
7. **신규 스페어** 가로 스크롤
8. **일반 스페어** 가로 스크롤

### 8.2 Shop Must 화면 목록

| # | 화면 | 핵심 UI |
|---|------|---------|
| 1 | **홈** | §8.1 |
| 2 | **인력별** | "인력별" 제목, 전체 N명, 지역·정렬 필터, 칩(전체/스텝/디자이너/면허인증), **SpareCard** |
| 3 | **인력 상세** | 프로필, 경력, 태그, 따봉·리뷰, 채팅/찜 |
| 4 | **공고 등록** | 급구 토글, 제목, 지역, 일정, 급여, 상세 |
| 5 | **내 공고 목록** | 상태 필터, 공고 카드, 마감/수정 |
| 6 | **지원자 목록** | 공고별 지원자, **승인/거절** 버튼 |
| 7 | **스케줄** | 근무 일정 카드 + **공간대여 예약** 카드 (예약자명, **채팅방 열기**) |
| 8 | **스케줄 취소** | Glass modal, 사유 선택, 패널티 경고 |
| 9 | **메시지·채팅** | Spare와 동일 패턴 + 연락처 위반 모달 |
| 10 | **샵 인증** | 사업자·서류 업로드, 진행 상태 |
| 11 | **포인트** | 미션, 적립 내역 |
| 12 | **마이(프로필)** | 샵 정보, VIP, 설정 |

### 8.3 Shop 인력 카드 (SpareCard) 스펙

- White 카드, 12px radius, 1px border, shadow-sm
- Row: [원형 프로필 48~60px, Blue→Purple 그라데이션 fallback]
- 이름(Bold 16px) + **인기** 배지(노랑→오렌지) + **면허인증** 배지(연보라)
- `경력 N년 · 완료 N건` (12px gray)
- 전문 태그 칩 (컷, 펌 등)
- `따봉 N · 리뷰 N` (12~14px)

**Shop 핵심 CTA:** `공고 등록` · `지원자 확인` · `승인` · `거절` · `채팅방 열기`

---

## 9. Admin(관리자) — 웹 대시보드 명세

### 9.1 레이아웃

- **사이드 네비** (데스크탑) / **햄버거** (모바일)
- 메뉴: 대시보드 · 회원 관리 · 공고 관리 · 결제 관리 · 에너지 관리 · 노쇼 관리 · 체크인 관리
- 배경: subtle gradient 또는 neutral gray (현재 heavy purple-pink gradient → **절제**)
- 카드: white, rounded-2xl~3xl, soft shadow

### 9.2 Admin Must 화면

| # | 화면 | 핵심 UI |
|---|------|---------|
| 1 | **대시보드** | KPI 카드 4~6개 (회원, 공고, 결제, 에너지), **최근 활동** 피드, 5초 갱신 느낌의 live UI |
| 2 | **회원 관리** | 검색·필터 바, 테이블 (이름, 역할, 상태, 가입일), 상세 드릴다운 |
| 3 | **공고 관리** | 공고 테이블, 상태, 급구 여부 |
| 4 | **결제 관리** | 결제 내역 테이블, 상세 |
| 5 | **에너지 관리** | 에너지 거래 테이블 |
| 6 | **노쇼 관리** | 노쇼 이력, 패널티 |
| 7 | **체크인 관리** | 출근 체크 로그 |

**Admin 톤:** Linear / Refine / Vercel Dashboard 느낌 + HairSpare Purple accent

---

## 10. 핵심 비즈니스 UI (디자인에 반영)

### 10.1 급구(Urgent)

- Orange `#F97316` + Red `#EF4444` 배지
- 급구 공고 카드: subtle orange border 또는 left accent bar
- Shop 홈 운영 카드: 중요 알림 시 orange 강조

### 10.2 에너지(Energy)

- Spare 예약금 개념 — Yellow 계열 포인트 (`#FACC15`, `#EAB308`)
- 잔액 카드 + 충전 CTA

### 10.3 스케줄 취소 v2

- Spare: 일방 취소, 에너지 미환불 안내
- Shop: 누적 취소 패널티 경고 (3회 → 7일 공고 정지)
- **Glass modal** 스타일, 사유 선택 bottom sheet

### 10.4 채팅 연락처 위반

- 상단 **짧은 경고 배너** (상세는 모달)
- 3회 위반 시 채팅방 삭제·제재 안내 모달

---

## 11. 컴포넌트 라이브러리 (DESIGN.md에 포함 요청)

Stitch DESIGN.md에 아래 컴포넌트를 정의해 주세요.

| 컴포넌트 | 설명 |
|----------|------|
| `Button/Primary` | Purple fill, white text, 12px radius, h=48 |
| `Button/Secondary` | Purple outline or text only |
| `Button/Danger` | Red, 취소·거절용 |
| `Chip/Filter` | default + selected (purple light bg) |
| `Dropdown/Filter` | JobFilterDropdown 스타일 |
| `Card/Job` | 공고 카드 |
| `Card/Spare` | 인력 카드 |
| `Card/Dashboard` | Shop KPI 카드 |
| `Badge/Urgent` | 급구 |
| `Badge/Popular` | 인기 (yellow-orange gradient) |
| `Badge/License` | 면허인증 |
| `Nav/BottomTab` | 4탭 |
| `Nav/TopBar` | HairSpare + actions |
| `Banner/Hero` | 캐러셀 |
| `Modal/Glass` | 스케줄 취소·패널티 |
| `Table/Admin` | Admin 데이터 테이블 |
| `Input/Text` | 12px radius, border gray, focus purple |
| `EmptyState` | 아이콘 + 문구 + CTA |
| `Snackbar` | 성공/에러/안내 |

---

## 12. DESIGN.md 출력 템플릿 (Stitch가 채워야 할 형식)

```markdown
# HairSpare Design System

## Brand
- Name: HairSpare
- Tagline: (제안해 주세요, 한국어)
- Personality: professional, trustworthy, friendly

## Colors
(primary, secondary, semantic, background, text, border — HEX + usage)

## Typography
(font family, scale 12/14/16/18/20/24, weights)

## Spacing
(4px base grid)

## Radius
(sm/md/lg/xl)

## Shadows
(sm/md/lg)

## Icons
(style: outline, size 24, colors)

## Components
(각 컴포넌트 states: default, hover, pressed, disabled)

## Layout
(mobile safe area, bottom tab height, app bar height)

## Admin
(desktop breakpoints, table styles)
```

---

## 13. Stitch 작업 지시 (프롬프트 마무리)

```
Please execute in this order:

1. Generate DESIGN.md first with unified purple brand (fix blue/purple inconsistency).
2. Design ALL Spare Must screens (Section 7.2) — mobile 390×844.
3. Design ALL Shop Must screens (Section 8.2) — same design system, different content.
4. Design ALL Admin Must screens (Section 9.2) — web 1280×800.
5. Apply UX rules from Section 6 strictly.
6. Create Instant Prototype:
   - Spare flow: Home → Job Detail → Apply → Schedule
   - Shop flow: Home → Post Job → Applicants → Approve → Schedule
7. Provide 2 visual direction variants in Ideate mode first if possible:
   - A: Minimal professional (white-heavy)
   - B: Warm beauty (soft purple + cream)
   - C: Bold urgent (strong orange accent for jobs)
   Then refine the chosen direction.

Constraints:
- Do NOT remove features or change IA.
- Do NOT use multicolor category icons — unify to purple/gray outline.
- Do NOT output generic "AI startup" aesthetics.
- All UI copy in Korean.
- Implementation target is Flutter Material 3 (not HTML) — design for component reuse.

If Redesign mode: keep screen structure from attached screenshots, refresh visual layer only.
If Ideate mode: research Korean job/marketplace apps for reference, then propose directions before generating.
```

---

## 14. Flutter 구현 메모 (Stitch 참고용 — 디자인 범위外)

- 개발 스택: **Flutter Material 3**, Provider, go_router
- 테마 파일: `lib/theme/app_theme.dart`
- Shop 가이드: `docs/DESIGN_GUIDE_SHOP_PAGES.md`
- Stitch HTML export는 **참고만** — 최종 구현은 DESIGN.md + PNG mockup 기준

---

## 15. 체크리스트 (완료 확인)

- [ ] DESIGN.md 생성됨
- [ ] Spare 12화면 + Shop 12화면 + Admin 7화면
- [ ] 하단탭 4개·상단바 패턴 Spare/Shop 동일
- [ ] 아이콘 단색 통일
- [ ] 급구 배지만 Orange/Red
- [ ] 배너 몰입감 개선
- [ ] 홈 섹션 탭+캐러셀 구조
- [ ] Instant Prototype 2 flows
- [ ] 한국어 UI copy
- [ ] Admin = mobile brand tokens + desktop density

---

*HairSpare Flutter MVP · 2026-05 · Stitch redesign brief v1*
