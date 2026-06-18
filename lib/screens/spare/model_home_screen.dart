import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/model_home/model_home_scroll_view.dart';

/// 모델 전용 홈 탭 — [ModelHomeScrollView].
///
/// 기존 [SpareHomeScreen]의 `isModel` 분기에서 떼어낸 화면. 보이는 내용은 동일.
class ModelHomeScreen extends StatefulWidget {
  const ModelHomeScreen({super.key});

  @override
  State<ModelHomeScreen> createState() => _ModelHomeScreenState();
}

class _ModelHomeScreenState extends State<ModelHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: ModelHomeScrollView(scrollController: _scrollController),
    );
  }
}
