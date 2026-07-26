import 'package:flutter/material.dart';

import '../../models/store_product.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';

/// HairSpare 스토어 — 프로모 배너 캐러셀.
class StorePromoBannerCarousel extends StatefulWidget {
  const StorePromoBannerCarousel({super.key, required this.banners});

  final List<StorePromoBanner> banners;

  @override
  State<StorePromoBannerCarousel> createState() =>
      _StorePromoBannerCarouselState();
}

class _StorePromoBannerCarouselState extends State<StorePromoBannerCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final banner = widget.banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing4,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (banner.imageUrl != null)
                        Image.network(
                          banner.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: HairSpareColors.brandPrimarySoft,
                          ),
                        )
                      else
                        Container(color: HairSpareColors.brandPrimarySoft),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.black.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner.subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    banner.ctaLabel,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: HairSpareColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: HairSpareColors.textPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: AppTheme.spacing2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (i) {
              final active = i == _index;
              return Container(
                width: active ? 8 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? HairSpareColors.activeStructural
                      : HairSpareColors.borderStrong,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
