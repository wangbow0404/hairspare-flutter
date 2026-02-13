# Flutter Hot Reload 가이드

## Hot Reload란?
코드를 수정한 후 앱을 완전히 다시 실행하지 않고도 변경사항을 즉시 확인할 수 있는 기능입니다.

## 사용 방법

### 1. Flutter 앱 실행 중일 때
터미널에서 Flutter 앱이 실행 중인 상태에서:

- **`r` 키를 누르면**: Hot Reload (빠른 새로고침)
- **`R` 키를 누르면**: Hot Restart (전체 재시작)
- **`q` 키를 누르면**: 앱 종료

### 2. VS Code / Cursor에서
- **저장하면 자동으로 Hot Reload** (설정에 따라)
- 또는 **`Cmd + Shift + P`** → "Flutter: Hot Reload" 선택

### 3. Chrome DevTools에서
- 브라우저에서 **F12**로 개발자 도구 열기
- Flutter Inspector 사용 가능

## 주의사항
- Hot Reload는 대부분의 UI 변경사항을 즉시 반영합니다
- 하지만 다음 경우에는 Hot Restart가 필요합니다:
  - 새로운 패키지 추가
  - 네이티브 코드 변경
  - 초기화 로직 변경

## 추천 워크플로우
1. `flutter run -d chrome --web-port=8080` 실행
2. 코드 수정
3. 파일 저장
4. 터미널에서 `r` 키 누르기
5. 브라우저에서 즉시 확인!
