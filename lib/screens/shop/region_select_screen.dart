import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';

class ShopRegionSelectScreen extends StatelessWidget {
  const ShopRegionSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(title: '지역 선택'),
      body: Center(
        child: Text('지역 선택 화면 (구현 예정)'),
      ),
    );
  }
}
