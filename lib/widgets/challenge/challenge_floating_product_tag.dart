import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/icon_mapper.dart';
import '../../view_models/challenge_view_model.dart';

/// 숏폼 스타일 플로팅 제품/교육 태그 (작은 반투명 칩).
class ChallengeFloatingProductTag extends StatelessWidget {
  const ChallengeFloatingProductTag({
    super.key,
    required this.onLaunchUrl,
    required this.bottomInset,
  });

  final Future<void> Function(String url) onLaunchUrl;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();
    if (vm.currentIndex >= vm.displayedChallenges.length) {
      return const SizedBox.shrink();
    }
    final c = vm.displayedChallenges[vm.currentIndex];

    final bool hasProduct = c.taggedType == 'product' && c.productUrl != null;
    final bool hasEducation = c.taggedType == 'education' && c.educationUrl != null;
    if (!hasProduct && !hasEducation) {
      return const SizedBox.shrink();
    }

    final label = hasProduct ? '제품 (1)' : '교육 (1)';

    return Positioned(
      left: 12,
      bottom: bottomInset,
      child: GestureDetector(
        onTap: () async {
          if (hasProduct) {
            await onLaunchUrl(c.productUrl!);
          } else if (hasEducation) {
            await onLaunchUrl(c.educationUrl!);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconMapper.icon('shoppingbag', size: 14, color: Colors.white) ??
                  Icon(
                    hasProduct ? Icons.shopping_bag_outlined : Icons.menu_book_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              IconMapper.icon('chevronright', size: 12, color: Colors.white70) ??
                  const Icon(Icons.chevron_right, size: 14, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
