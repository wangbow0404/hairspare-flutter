/// 스페어 근무 / 모델 시술 등 스케줄 화면 역할별 문구.
enum ScheduleSessionAudience {
  spare,
  model;

  static ScheduleSessionAudience fromModelMode(bool isModelMode) =>
      isModelMode ? ScheduleSessionAudience.model : ScheduleSessionAudience.spare;

  bool get isModel => this == ScheduleSessionAudience.model;

  String get sessionNoun => isModel ? '시술' : '근무';

  String get checkCompleteNoun => isModel ? '시술 완료' : '근무체크';

  String get calendarSectionTitle => isModel ? '시술 캘린더' : '근무 현황';

  String get scheduledLegend => isModel ? '시술 예정' : '근무 예정';

  String get completedLegend => isModel ? '시술 완료' : '근무 완료';

  String get completeButtonLabel => isModel ? '시술 완료하기' : '근무체크하기';

  String get cancelButtonLabel => isModel ? '시술 일정 취소' : '일정 취소';

  String get streakPillLabel => isModel ? '예정 일정' : '현재 연속 근무';

  String scheduleCardSubtitle(String shopName) =>
      isModel ? '$shopName 시술' : '$shopName 근무';

  String completedAtLabel(String formatted) =>
      isModel ? '완료: $formatted' : '체크인: $formatted';

  String pendingProcessingMessage(String shopName) => isModel
      ? '$shopName 시술 완료 처리 중...'
      : '$shopName에서 승인 대기 중입니다...';

  String alreadyCompletedMessage() => isModel
      ? '이미 시술 완료 처리된 일정입니다.'
      : '이미 근무 체크가 완료된 일정입니다.';

  String beforeSessionMessage(String endHm) => isModel
      ? '아직 시술 전입니다. 시술 종료 시간($endHm) 이후에 완료 처리할 수 있어요.'
      : '근무체크는 근무 종료 후 가능합니다. 오늘은 $endHm부터 체크할 수 있어요.';

  String duringSessionMessage(String endHm) => isModel
      ? '아직 시술 중입니다. 시술 종료 시간($endHm) 이후에 완료 처리해 주세요.'
      : '아직 근무 중입니다. 근무 종료 시간($endHm) 이후에 완료 체크를 해주세요.';

  String scheduleInfoNotFoundMessage() =>
      isModel ? '시술 정보를 찾을 수 없습니다.' : '근무 정보를 찾을 수 없습니다.';

  String checkCompleteSuccessMessage() => isModel
      ? '시술 완료 처리되었습니다!'
      : '근무체크가 완료되었습니다!';

  String cancelConfirmTitle() =>
      isModel ? '시술 일정 취소 확인' : '근무 취소 확인';

  String cancelTargetLabel() => isModel ? '취소할 시술' : '취소할 근무';

  String get infoSectionTitle =>
      isModel ? '시술 일정 안내' : '근무체크 안내사항';

  List<String> get infoBulletLines => isModel
      ? [
          '시술 완료는 해당 일정의 종료 시간 이후에 처리할 수 있어요.',
          '시술 후 디자이너에게 응원을 보낼 수 있어요.',
          '일정 변경·취소는 디자이너와 메시지로 먼저 조율해 주세요.',
          '무단 노쇼 시 패널티가 적용될 수 있어요.',
        ]
      : [
          '근무체크는 승인받은 근무 일정에만 가능합니다. 당일 근무를 마치고 체크해주세요.',
          '노쇼 없이 10일 연속 근무하면 에너지 1개를 받을 수 있습니다.',
          '연속 근무가 끊기면 에너지 게이지는 초기화됩니다.',
          '연속 근무는 달이 넘어가도 이어집니다.',
        ];

  String get tipBannerMessage => isModel
      ? '시술 일정을 미리 확인하고 디자이너와 메시지로 조율해 보세요.'
      : '매일 출석하면 최대 에너지 3개를 받을 수 있어요!';

  /// 취소 정책·차단 메시지 — 모델 화면에서 근무 용어 치환.
  String? localizePolicyText(String? text) {
    if (!isModel || text == null || text.isEmpty) return text;
    return text
        .replaceAll('완료된 근무', '완료된 시술')
        .replaceAll('확정된 근무', '확정된 시술')
        .replaceAll('제안 대기 중인 근무', '제안 대기 중인 시술')
        .replaceAll('겹치는 근무', '겹치는 시술')
        .replaceAll('근무 시작', '시술 시작')
        .replaceAll('근무가 시작', '시술이 시작')
        .replaceAll('근무 종료', '시술 종료')
        .replaceAll('예약 에너지', '예약금·에너지')
        .replaceAll('근무', '시술');
  }

  String eligibilityChipLabel(String spareLabel) {
    if (!isModel) return spareLabel;
    return localizePolicyText(spareLabel) ?? spareLabel;
  }
}
