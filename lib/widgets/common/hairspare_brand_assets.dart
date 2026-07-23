import 'package:flutter/material.dart';

/// HairSpare 브랜드 이미지 — 2026-07 Stitch 신규 로고(H 심볼 + HairSpare 워드마크
/// 세로 조합, 512×457). 로고·심볼 둘 다 동일 이미지를 씀.
abstract final class HairSpareBrandAssets {
  static const String logo = 'assets/images/brand/hairspare_logo.png';
  static const String symbol = 'assets/images/brand/hairspare_symbol.png';

  /// Export 기준 512×457 (구버전 500×132 와이드 로고에서 정사각형에 가까운
  /// 세로 조합형으로 교체됨).
  static const double logoAspectRatio = 512 / 457;
}

/// 가로형 풀 로고 (앱바·역할 선택 등).
class HairSpareBrandLogo extends StatelessWidget {
  const HairSpareBrandLogo({
    super.key,
    this.height = 36,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final displayWidth = width ?? height * HairSpareBrandAssets.logoAspectRatio;

    return Image.asset(
      HairSpareBrandAssets.logo,
      width: displayWidth,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.high,
      semanticLabel: 'HairSpare',
    );
  }
}

/// 심볼 마크 (로그인·회원가입 등).
class HairSpareBrandSymbol extends StatelessWidget {
  const HairSpareBrandSymbol({
    super.key,
    this.size = 160,
    this.fit = BoxFit.contain,
  });

  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      HairSpareBrandAssets.symbol,
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
      semanticLabel: 'HairSpare',
    );
  }
}
