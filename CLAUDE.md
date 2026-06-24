# HairSpare Flutter

## Stack

- Flutter (Material 3), Provider + ChangeNotifier (MVVM)
- DI: `get_it` (`sl<T>()`), routing: `go_router`, network: Dio
- Flow: Screen → ViewModel → Service (no `BuildContext` in ViewModel/Service)
- Imports: prefer `package:hairspare/...`

## 세션 시작 시 필수 확인

모든 작업 시작 전 아래 두 가지를 **반드시** 먼저 확인한다:

1. **git 로그 확인** — `git log --oneline -10` 으로 최근 커밋 확인.
   - 다른 AI가 작업했을 수 있으므로 내가 모르는 변경사항이 있을 수 있다.
   - 커밋 내용이 내 기억과 다르면 실제 파일을 읽어서 현재 상태를 먼저 파악한다.

2. **앱 구조 파일 확인** — `~/.claude/projects/-Users-yoram-flutter/memory/app-architecture-overview.md`
   - 화면 연결 구조, 역할별 라우트, 미연결 화면 목록을 파악하고 작업에 반영한다.

## Sequential Thinking

Follow `~/.claude/CLAUDE.md`: when the user says **단계적으로 생각해서** (or similar), use the **sequentialthinking** MCP tool before implementing.

For non-trivial features (routing, auth, multi-file UI), default to sequential thinking even if not explicitly asked — unless the user wants a quick answer.
