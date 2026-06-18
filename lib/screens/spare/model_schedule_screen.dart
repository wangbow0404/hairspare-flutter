import 'package:flutter/material.dart';

import 'work_check_screen.dart';

/// 모델 스케줄 관리 탭 — 스페어 스케줄표(WorkCheck) 기반, 모델 카피.
class ModelScheduleScreen extends StatelessWidget {
  const ModelScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WorkCheckScreen(
      isTabRoot: true,
      isModelMode: true,
    );
  }
}
