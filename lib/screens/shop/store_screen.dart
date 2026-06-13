import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/common/shared_app_bar.dart';

/// Shop용 스토어 화면
class ShopStoreScreen extends StatefulWidget {
  const ShopStoreScreen({super.key});

  @override
  State<ShopStoreScreen> createState() => _ShopStoreScreenState();
}

class _ShopStoreScreenState extends State<ShopStoreScreen> {

  void _showComingSoonModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('준비 중'),
        content: const Text('스토어 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 모달 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showComingSoonModal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '스토어'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: IconMapper.icon('store', size: 32, color: AppTheme.textTertiary) ??
                  const Icon(Icons.store, size: 32, color: AppTheme.textTertiary),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              '스토어 화면',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              '준비 중입니다',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
