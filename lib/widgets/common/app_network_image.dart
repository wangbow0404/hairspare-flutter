import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 네트워크 이미지 공용 위젯.
///
/// - **mock:// URL**: 목 데이터용 그라데이션 플레이스홀더 (원격 fetch 없음).
/// - **로컬 파일 경로**: 갤러리·카메라로 추가한 사진 ([Image.file]).
/// - **http(s) URL**: [CachedNetworkImage]로 디스크/메모리 캐시 + 디코딩 크기 제한.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.memCacheWidth,
    this.fallbackIcon,
  });

  final String? imageUrl;
  final BoxFit fit;
  final int? memCacheWidth;
  final IconData? fallbackIcon;

  static bool _isMockPlaceholder(String url) => url.startsWith('mock://');

  static bool _isLocalFilePath(String url) {
    if (url.startsWith('file://')) return true;
    if (!kIsWeb && url.startsWith('/')) return true;
    return false;
  }

  static String _filePathFromUrl(String url) =>
      url.startsWith('file://') ? url.substring('file://'.length) : url;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return _Placeholder(seed: '', icon: fallbackIcon);
    }

    if (_isMockPlaceholder(url)) {
      return _Placeholder(seed: url, icon: fallbackIcon);
    }

    if (!kIsWeb && _isLocalFilePath(url)) {
      final file = File(_filePathFromUrl(url));
      if (!file.existsSync()) {
        return _Placeholder(seed: url, icon: fallbackIcon);
      }
      return Image.file(
        file,
        fit: fit,
        cacheWidth: memCacheWidth,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) =>
            _Placeholder(seed: url, icon: fallbackIcon),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      memCacheWidth: memCacheWidth,
      filterQuality: FilterQuality.low,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => _Placeholder(seed: url, icon: fallbackIcon),
      errorWidget: (_, __, ___) => _Placeholder(seed: url, icon: fallbackIcon),
    );
  }
}

/// URL 해시로 결정되는 보라 계열 그라데이션 — 항목별로 다르게 보이되 0ms 렌더.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.seed, this.icon});

  final String seed;
  final IconData? icon;

  static const List<List<Color>> _palettes = [
    [Color(0xFFEDE7FF), Color(0xFFD7C2FF)],
    [Color(0xFFE6F0FF), Color(0xFFC2D9FF)],
    [Color(0xFFFFE7F4), Color(0xFFFFC2E0)],
    [Color(0xFFE7FBF0), Color(0xFFC2F0D7)],
    [Color(0xFFFFF1E0), Color(0xFFFFD9B0)],
  ];

  @override
  Widget build(BuildContext context) {
    final palette = seed.isEmpty
        ? const [AppTheme.surfaceContainerLow, AppTheme.surfaceContainerLow]
        : _palettes[seed.hashCode.abs() % _palettes.length];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
      ),
      child: icon == null
          ? null
          : Center(
              child: Icon(
                icon,
                color: AppTheme.stitchTextSecondary.withValues(alpha: 0.55),
                size: 28,
              ),
            ),
    );
  }
}
