import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../core/router/auth_redirect.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/hairspare_colors.dart';
import '../../widgets/common/hairspare_brand_assets.dart';

/// 자동로그인 성공 직후 홈 진입 전에 잠깐 보여주는 브랜드 스플래시.
/// 참고: docs/STITCH_BRIEF_AUTO_LOGIN_SPLASH.md
///
/// ⚠️ TODO: 스페어용 배경 사진은 아직 전달받은 파일이 깨져있어 임시로 샵
/// 사진을 재사용 중 — 스페어 전용 사진 확보되면 [_SplashCopy.spare]의
/// backgroundAsset만 교체하면 됨.
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
            // 사진 위 텍스트 가독성 확보 + Stitch 목업에 있던 기존 카피 픽셀 가림.
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black87,
                    Colors.black45,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.32, 0.55],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.headline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      copy.subcopy,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  color: HairSpareColors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      const HairSpareBrandSymbol(size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: HairSpareColors.brandPrimary,
                            ),
                            children: [
                              const TextSpan(text: '헤어스페어'),
                              TextSpan(
                                text: '  |  ${copy.slogan}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: HairSpareColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
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
    required this.slogan,
    required this.backgroundAsset,
  });

  final String headline;
  final String subcopy;
  final String slogan;
  final String backgroundAsset;

  static const _bgShop = 'assets/images/brand/auto_login_splash_shop_bg.jpg';
  // TODO: 스페어 전용 사진으로 교체 필요 (섹션 상단 TODO 참고).
  static const _bgSpare = _bgShop;

  static const shop = _SplashCopy(
    headline: '이런 스페어,\n우리 매장에도 올까?',
    subcopy: '지금 공고 올리고 확인해보세요',
    slogan: '매칭 성공률 98%의 신뢰',
    backgroundAsset: _bgShop,
  );

  static const spare = _SplashCopy(
    headline: '이 매장처럼\n일할 수 있을까?',
    subcopy: '오늘 스케줄로 확인해보세요',
    slogan: '매칭 성공률 98%의 신뢰',
    backgroundAsset: _bgSpare,
  );

  static _SplashCopy forUser(User? user) {
    if (user?.role == UserRole.shop) return shop;
    return spare;
  }
}
