import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Shop용 커넥트 화면
class ShopConnectScreen extends StatefulWidget {
  const ShopConnectScreen({super.key});

  @override
  State<ShopConnectScreen> createState() => _ShopConnectScreenState();
}

class _ShopConnectScreenState extends State<ShopConnectScreen> {
  int _currentNavIndex = 0;

  void _showComingSoonModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('준비 중'),
        content: const Text('커넥트 기능은 준비 중입니다.'),
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
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '커넥트',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
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
              child: IconMapper.icon('lightbulb', size: 32, color: AppTheme.textTertiary) ??
                  const Icon(Icons.lightbulb, size: 32, color: AppTheme.textTertiary),
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              '커넥트 화면',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppTheme.spacing2),
            Text(
              '준비 중입니다',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopPaymentScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopFavoritesScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
