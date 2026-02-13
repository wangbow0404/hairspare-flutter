# Flutter 앱 테스트 체크리스트

## ✅ 완료된 작업

- [x] CORS 문제 해결
- [x] 타입 오류 해결 (DateTime 파싱 개선)
- [x] 데이터베이스 email 컬럼 nullable로 변경
- [x] cloudinary 패키지 설치

## ⚠️ 진행 중인 작업

- [ ] Job 테이블 컬럼 추가 (Supabase SQL 실행 필요)
  - `endTime`, `description`, `requirements`, `images`, `exposurePolicy`, `exposureTime`, `countdown`, `status`

## 📋 테스트 체크리스트

### 1. 회원가입
- [ ] 새 아이디로 회원가입 성공
- [ ] 이메일 없이 회원가입 성공
- [ ] 이메일 포함 회원가입 성공

### 2. 로그인
- [ ] 회원가입한 계정으로 로그인 성공
- [ ] 타입 오류 없이 사용자 정보 파싱
- [ ] 홈 화면으로 이동

### 3. 홈 화면
- [ ] 공고 목록 API 호출 성공
- [ ] 공고 목록 표시
- [ ] 공고 카드 클릭 → 상세 화면 이동

### 4. 공고 상세 화면
- [ ] 공고 정보 표시
- [ ] 지원하기 버튼 표시

## 🔧 남은 작업

### 데이터베이스 스키마 수정
Supabase 대시보드에서 다음 SQL 실행:

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

## 🚀 다음 단계

1. 브라우저 새로고침 후 로그인 테스트
2. 데이터베이스 스키마 수정 (위 SQL 실행)
3. 공고 목록 테스트
4. 추가 기능 구현
