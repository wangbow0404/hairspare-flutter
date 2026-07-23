import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/router/auth_redirect.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/hairspare_brand_assets.dart';

/// 자동로그인·수동로그인 성공 직후 홈 진입 전에 잠깐 보여주는 브랜드 인터스티셜.
/// 참고: docs/STITCH_BRIEF_AUTO_LOGIN_SPLASH.md (Stitch 디자인 export 기준 레이아웃)
class AutoLoginSplashScreen extends StatefulWidget {
  const AutoLoginSplashScreen({super.key});

  @override
  State<AutoLoginSplashScreen> createState() => _AutoLoginSplashScreenState();
}

class _AutoLoginSplashScreenState extends State<AutoLoginSplashScreen> {
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), _proceed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _proceed() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final user = context.read<AuthProvider>().currentUser;
    context.go(user != null ? homeRouteFor(user) : AppRoutes.roleSelect);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final copy = _SplashCopy.forUser(user);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceed,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(copy.backgroundAsset, fit: BoxFit.cover),
            // 하단 텍스트 가독성용 암전 그라데이션 — 화면 하단 절반만.
            const Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.55,
                widthFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
              ),
            ),
            // 상단 좌측 로고 배지 — 흰 필 안에 심볼.
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const HairSpareBrandSymbol(size: 26),
                  ),
                ),
              ),
            ),
            // 하단 중앙 카피.
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        copy.headline,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        copy.subcopy,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.hankenGrotesk(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashCopy {
  const _SplashCopy({
    required this.headline,
    required this.subcopy,
    required this.backgroundAsset,
  });

  final String headline;
  final String subcopy;
  final String backgroundAsset;

  static const _bgShop = 'assets/images/brand/auto_login_splash_shop_bg.jpg';
  static const _bgSpare = 'assets/images/brand/auto_login_splash_spare_bg.jpg';

  static const shop = _SplashCopy(
    headline: '이런 스페어,\n우리 매장에도 올까?',
    subcopy: '지금 공고 올리고 확인해보세요',
    backgroundAsset: _bgShop,
  );

  static const spare = _SplashCopy(
    headline: '이 매장에서\n일할 수 있을까?',
    subcopy: '오늘 스케줄로 확인해보세요',
    backgroundAsset: _bgSpare,
  );

  static _SplashCopy forUser(User? user) {
    if (user?.role == UserRole.shop) return shop;
    return spare;
  }
}
