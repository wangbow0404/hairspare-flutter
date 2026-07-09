import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/api_config.dart';

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

  /// Flutter 웹(CanvasKit)은 fetch()로 이미지 로딩 → R2 직접 접근 시 CORS 차단.
  /// 웹에서는 백엔드 image-proxy를 통해 우회.
  static String _resolveUrl(String url) {
    if (!kIsWeb) return url;
    if (url.contains('.r2.dev/') && url.startsWith('https://')) {
      return '${ApiConfig.getBaseUrl()}/api/auth/image-proxy?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }

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
    final rawUrl = imageUrl;
    if (rawUrl == null || rawUrl.isEmpty) {
      return _Placeholder(seed: '', icon: fallbackIcon);
    }

    if (_isMockPlaceholder(rawUrl)) {
      return _Placeholder(seed: rawUrl, icon: fallbackIcon);
    }

    if (!kIsWeb && _isLocalFilePath(rawUrl)) {
      final file = File(_filePathFromUrl(rawUrl));
      if (!file.existsSync()) {
        return _Placeholder(seed: rawUrl, icon: fallbackIcon);
      }
      return Image.file(
        file,
        fit: fit,
        cacheWidth: memCacheWidth,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) =>
            _Placeholder(seed: rawUrl, icon: fallbackIcon),
      );
    }

    final url = _resolveUrl(rawUrl);

    if (kIsWeb) {
      return Image.network(
        url,
        fit: fit,
        cacheWidth: memCacheWidth,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : _Placeholder(seed: url, icon: fallbackIcon),
        errorBuilder: (_, __, ___) =>
            _Placeholder(seed: url, icon: fallbackIcon),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      memCacheWidth: memCacheWidth,
      filterQuality: FilterQuality.medium,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      placeholder: (_, __) => _Placeholder(seed: url, icon: fallbackIcon),
      errorWidget: (_, __, ___) => _Placeholder(seed: url, icon: fallbackIcon),
    );
  }
}

/// 사진을 전체화면으로 확대해서 보여준다. 핀치/드래그로 확대·이동 가능.
Future<void> showFullScreenImage(BuildContext context, String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return Future.value();
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (context, animation, secondaryAnimation) =>
          _FullScreenImageViewer(imageUrl: imageUrl),
    ),
  );
}

class _FullScreenImageViewer extends StatelessWidget {
  const _FullScreenImageViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              child: SizedBox.expand(
                child: AppNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 사진 여러 장을 전체화면 갤러리로 보여준다. 좌우로 넘기며 볼 수 있고
/// 핀치로 확대/축소도 된다.
Future<void> showFullScreenImageGallery(
  BuildContext context, {
  required List<String> imageUrls,
  int initialIndex = 0,
}) {
  final urls = imageUrls.where((u) => u.isNotEmpty).toList();
  if (urls.isEmpty) return Future.value();
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (context, animation, secondaryAnimation) =>
          _FullScreenImageGalleryViewer(
            imageUrls: urls,
            initialIndex: initialIndex.clamp(0, urls.length - 1),
          ),
    ),
  );
}

class _FullScreenImageGalleryViewer extends StatefulWidget {
  const _FullScreenImageGalleryViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_FullScreenImageGalleryViewer> createState() =>
      _FullScreenImageGalleryViewerState();
}

class _FullScreenImageGalleryViewerState
    extends State<_FullScreenImageGalleryViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _currentIndex = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: SizedBox.expand(
                  child: AppNetworkImage(
                    imageUrl: widget.imageUrls[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
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
