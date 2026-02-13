# 관리자 페이지 디자인 개발 계획 (아카이브)

> 원본: Cursor Plans `admin_page_design_dev_8615454f.plan.md`  
> 상태: 진행/완료 혼재 - [ARCHITECTURE.md](../../ARCHITECTURE.md) 및 [PROJECT_STATUS.md](../../PROJECT_STATUS.md) 참고

## 개요

Refine 참고 디자인 기반 Flutter 관리자 페이지 개선, 목록 화면 간소화, 상세보기 화면 신규 구현.

## Phase 요약

- **Phase 0**: AdminLayout, AppTheme, 공통 위젯 (AdminPageHeader, AdminSearchFilterBar, AdminTableCard)
- **Phase 1**: 회원/공고/결제/에너지/노쇼 목록 화면 컴팩트 리팩터링
- **Phase 2**: 회원/공고/결제 상세 화면 신규 구현
- **Phase 3**: 디바운스, 스켈레톤, 빈 상태 등 UX 개선

## 주요 파일

- `admin_layout.dart`, `app_theme.dart`
- `admin_users_screen.dart`, `admin_jobs_screen.dart`, `admin_payments_screen.dart`, `admin_energy_screen.dart`, `admin_noshow_screen.dart`
- `admin_user_detail_screen.dart`, `admin_job_detail_screen.dart`, `admin_payment_detail_screen.dart`
