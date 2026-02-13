import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ShopRegionSelectScreen extends StatelessWidget {
  const ShopRegionSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지역 선택'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('지역 선택 화면 (구현 예정)'),
      ),
    );
  }
}
