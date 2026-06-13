import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/challenge_feed.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';

/// 제품/교육 링크 — [glass] 시 반투명 패널 + 작은 아이콘 (숏폼 오버레이).
class ChallengeProductEducationCard extends StatelessWidget {
  const ChallengeProductEducationCard({
    super.key,
    required this.challenge,
    required this.onTap,
    this.glass = false,
  });

  final Challenge challenge;
  final VoidCallback onTap;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final isProduct = challenge.taggedType == 'product';
    final name = isProduct ? challenge.productName : challenge.educationName;
    final thumbnailUrl =
        isProduct ? challenge.productThumbnailUrl : challenge.educationThumbnailUrl;

    if (name == null) return const SizedBox.shrink();

    if (glass) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    if (thumbnailUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          thumbnailUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderIcon(isProduct),
                        ),
                      )
                    else
                      _placeholderIcon(isProduct),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                      ),
                      onPressed: onTap,
                      icon: IconMapper.icon('external-link', size: 18, color: Colors.white) ??
                          const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.white),
                      tooltip: isProduct ? '구매하기' : '교육 보러가기',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppTheme.spacing2),
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
                vertical: AppTheme.spacing2,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isProduct ? '지금 구매하기' : '교육 보러가기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing1),
                  IconMapper.icon('external-link', size: 14, color: Colors.white) ??
                      const Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: Colors.white,
                      ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing2),
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  isProduct ? Icons.shopping_bag : Icons.menu_book,
                                  color: Colors.white70,
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : Icon(
                            isProduct ? Icons.shopping_bag : Icons.menu_book,
                            color: Colors.white70,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon(bool isProduct) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isProduct ? Icons.shopping_bag_outlined : Icons.menu_book_outlined,
        color: Colors.white70,
        size: 22,
      ),
    );
  }
}
