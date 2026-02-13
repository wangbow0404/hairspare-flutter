import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ShopChallengeScreen extends StatelessWidget {
  const ShopChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('챌린지'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('챌린지 화면 (구현 예정)'),
      ),
    );
  }
}
