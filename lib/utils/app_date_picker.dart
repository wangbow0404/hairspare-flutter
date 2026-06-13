import 'package:flutter/material.dart';

import '../widgets/custom_date_picker_dialog.dart';

/// 앱 전역 날짜 선택 — 일요일·공휴일 빨강, 토요일 파랑.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return CustomDatePickerDialog.show(
    context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );
}
