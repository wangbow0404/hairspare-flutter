import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';

class ShopChallengeScreen extends StatelessWidget {
  const ShopChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(title: '챌린지'),
      body: Center(
        child: Text('챌린지 화면 (구현 예정)'),
      ),
    );
  }
}
