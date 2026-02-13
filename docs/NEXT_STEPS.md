# 다음 작업 가이드

## 🎯 현재 상태

### ✅ 완료된 작업
1. Flutter 프로젝트 생성 및 기본 구조
2. 데이터 모델 (User, Job, Region)
3. API 클라이언트 및 인증 서비스
4. 핵심 화면 구현:
   - 역할 선택 화면
   - 로그인 화면 (스페어/미용실)
   - 회원가입 화면 (스페어/미용실)
   - 홈 화면 (기본 구조)
   - 공고 상세 화면 (기본 구조)
5. CORS 문제 해결
6. 타입 오류 해결
7. 데이터베이스 email 컬럼 nullable로 변경

### ⚠️ 진행 중인 작업
- 데이터베이스 스키마 수정 (Job 테이블 컬럼 추가 필요)

## 📋 즉시 해야 할 작업 (우선순위 높음)

### 1. 데이터베이스 스키마 수정 ⚠️ 필수

**Supabase 대시보드에서 SQL 실행:**

```sql
ALTER TABLE "Job" ADD COLUMN IF NOT EXISTS "endTime" TEXT;
ALTER TABLE "Job" ADD COLUMN IF NOT EXISTS "description" TEXT;
ALTER TABLE "Job" ADD COLUMN IF NOT EXISTS "requirements" TEXT;
ALTER TABLE "Job" ADD COLUMN IF NOT EXISTS "images" TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE "Job" ADD COLUMN IF NOT EXISTS "exposurePolicy" TEXT;
ALTER TABLE "Job" ADD COLUMN IF NOT EXISTS "exposureTime" TIMESTAMP;
ALTER TABLE "Job" ADD COLUMN IF NOT EXISTS "countdown" INTEGER;
ALTER TABLE "Job" ADD COLUMN IF NOT EXISTS "status" TEXT DEFAULT 'draft';

UPDATE "Job" SET "status" = 'published' WHERE "status" IS NULL;
UPDATE "Job" SET "images" = ARRAY[]::TEXT[] WHERE "images" IS NULL;
```

**파일 위치**: `ADD_ALL_JOB_COLUMNS.sql`

### 2. Flutter 앱 테스트 완료

**브라우저에서:**
1. 새로고침 (`Ctrl+R` 또는 `F5`)
2. 로그인 테스트 (타입 오류 없이 성공 확인)
3. 홈 화면에서 공고 목록 표시 확인
4. 공고 카드 클릭 → 상세 화면 이동 확인

## 🚀 다음 구현할 기능 (우선순위 순)

### Phase 1: 기본 기능 완성
1. **지역 선택 화면 구현**
   - 지역 선택 UI
   - 선택한 지역으로 공고 필터링
   - 현재: 홈 화면에 지역 선택 버튼만 있음

2. **공고 지원 기능**
   - 공고 상세 화면에서 지원하기 버튼 동작
   - 지원 API 연동
   - 지원 상태 표시

3. **에너지(예약금) 시스템**
   - 에너지 지갑 조회
   - 에너지 구매 기능
   - 지원 시 에너지 잠금 처리

### Phase 2: 추가 화면 구현
4. **스케줄 화면**
   - 스페어: 내 일정 캘린더
   - 미용실: 공고별 일정 관리

5. **프로필 화면**
   - 사용자 정보 수정
   - 본인인증/면허 인증
   - 후기 관리

6. **채팅 화면**
   - 채팅 목록
   - 메시지 송수신
   - 실시간 업데이트

### Phase 3: 고급 기능
7. **알림 시스템**
   - 푸시 알림 설정
   - 알림 목록

8. **결제 시스템**
   - 에너지 구매
   - 구독 플랜 구매

9. **검색 및 필터**
   - 공고 검색
   - 고급 필터 옵션

## 📝 체크리스트

### 즉시 해야 할 것
- [ ] 데이터베이스 스키마 수정 (Job 테이블 컬럼 추가)
- [ ] 브라우저 새로고침 후 로그인 테스트
- [ ] 공고 목록 표시 확인

### 다음 구현할 것
- [ ] 지역 선택 화면 구현
- [ ] 공고 지원 기능 구현
- [ ] 에너지 시스템 구현

## 💡 참고사항

- 현재 Flutter 앱의 기본 구조는 완성되었습니다
- API 통신이 정상 작동하고 있습니다
- 데이터베이스 스키마만 수정하면 공고 목록이 정상 표시됩니다
- 이후에는 기능 추가와 UI 개선에 집중하면 됩니다
