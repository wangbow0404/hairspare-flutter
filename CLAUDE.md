# HairSpare Flutter

## Stack

- Flutter (Material 3), Provider + ChangeNotifier (MVVM)
- DI: `get_it` (`sl<T>()`), routing: `go_router`, network: Dio
- Flow: Screen → ViewModel → Service (no `BuildContext` in ViewModel/Service)
- Imports: prefer `package:hairspare/...`

## Sequential Thinking

Follow `~/.claude/CLAUDE.md`: when the user says **단계적으로 생각해서** (or similar), use the **sequentialthinking** MCP tool before implementing.

For non-trivial features (routing, auth, multi-file UI), default to sequential thinking even if not explicitly asked — unless the user wants a quick answer.
