# HairSpare 스페어/미용실/관리자 통합 개발 플랜 (아카이브)

> 원본: Cursor Plans `hairspare_통합_개발_플랜_df56ad8a.plan.md`  
> 상태: Phase별 진행 - [ARCHITECTURE.md](../../ARCHITECTURE.md) 참고

## 개요

스페어/미용실/관리자 역할 유기적 연결, 에너지·공고·스케줄·결제 흐름 완성.

## Phase 요약

- **Phase 0 (P0)**: Schedule check-in/confirm, Work-check stats, Application approve/reject, Job apply + Energy lock
- **Phase 1**: 에너지 플로우 완성 (lock/return 연동)
- **Phase 2**: Favorites 백엔드
- **Phase 3**: Review/ThumbsUp
- **Phase 4**: Chat 응답 보강
- **Phase 5**: Admin 실데이터 연동 (회원/공고/에너지)
- **Phase 6**: Payment/Notification/Store 스텁 최소 구현

## 주요 백엔드 연동

- Schedule Service: 체크인 API, 확정 API, work-check stats
- Job Service: Shop 지원 목록, approve/reject, Energy lock on apply
- Energy Service: lock, return, forfeit
- API Gateway: Admin users DB 직접 조회 (proxy.py)
