/// 스페어가 특정 공고에 대해 가진 관계(지원·제안·확정 일정).
enum SpareJobEngagement {
  /// 지원·제안·일정 없음 — 지원하기
  open,

  /// 미용실 근무 제안 대기 — 제안 확인
  proposed,

  /// 확정 일정 있음, 체크 전 — 스케줄표에서 확인
  scheduled,

  /// 근무 종료 후 체크 가능 — 근무체크하기
  workCheckReady,
}
