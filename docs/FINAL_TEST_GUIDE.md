# Flutter 앱 최종 테스트 가이드

## ✅ 완료된 수정 사항

### 1. CORS 문제 해결 ✅
- 모든 API에 CORS 헤더 추가
- OPTIONS 핸들러 추가

### 2. 타입 오류 해결 ✅
- DateTime 파싱 함수 개선 (다양한 형식 지원)
- User 모델과 Job 모델 모두 수정

### 3. 로그인 API 응답 수정 ✅
- `username` 필드 추가
- `createdAt` 필드 추가
- `phone`, `profileImage` 필드 추가

### 4. 데이터베이스 스키마 수정 ✅
- `email` 컬럼 nullable로 변경 완료

## 📋 남은 작업

### 데이터베이스 스키마 수정 (Job 테이블)

Supabase 대시보드에서 다음 SQL 실행 필요:

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

## 🎯 테스트 방법

### 1. 브라우저 새로고침
- `Ctrl+R` (Mac: `Cmd+R`) 또는 `F5`
- 또는 브라우저 완전히 닫고 다시 열기

### 2. 로그인 테스트
- 회원가입한 계정으로 로그인 시도
  - 예: `test005` / `test123456`
- 타입 오류 없이 성공해야 함
- 홈 화면으로 이동 확인

### 3. 홈 화면 테스트
- 공고 목록 API 호출 확인
- 데이터베이스 스키마 수정 후 정상 작동해야 함

## 📝 체크리스트

- [x] CORS 오류 해결
- [x] 타입 오류 해결
- [x] 로그인 API 응답 수정
- [x] 데이터베이스 email 컬럼 수정
- [ ] Job 테이블 컬럼 추가 (SQL 실행 필요)
- [ ] 로그인 성공 테스트
- [ ] 홈 화면 공고 목록 표시

## 🚀 다음 단계

1. 브라우저 새로고침
2. 로그인 테스트
3. 데이터베이스 스키마 수정 (위 SQL 실행)
4. 공고 목록 테스트
