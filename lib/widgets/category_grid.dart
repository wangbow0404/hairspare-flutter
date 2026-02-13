import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryItem {
  final String emoji;
  final String label;
  final VoidCallback? onTap;
  final bool has3DEffect;

  const CategoryItem({
    required this.emoji,
    required this.label,
    this.onTap,
    this.has3DEffect = false,
  });
}

class CategoryGrid extends StatelessWidget {
  final List<CategoryItem> categories;

  const CategoryGrid({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite, // bg-white
      ),
      padding: AppTheme.spacingVertical(AppTheme.spacing4), // py-4
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // grid-cols-4
          crossAxisSpacing: AppTheme.spacing4, // gap-4
          mainAxisSpacing: AppTheme.spacing4, // gap-4
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryItemWidget(
            emoji: category.emoji,
            label: category.label,
            onTap: category.onTap,
            has3DEffect: category.has3DEffect,
          );
        },
      ),
    );
  }
}

class _CategoryItemWidget extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback? onTap;
  final bool has3DEffect;

  const _CategoryItemWidget({
    required this.emoji,
    required this.label,
    this.onTap,
    this.has3DEffect = false,
  });

  @override
  State<_CategoryItemWidget> createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends State<_CategoryItemWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모지 아이콘
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: () {
                if (widget.has3DEffect) {
                  final matrix = Matrix4.identity();
                  matrix.setEntry(3, 2, 0.001);
                  matrix.rotateY(-0.14);
                  matrix.rotateX(0.14);
                  return matrix;
                }
                return Matrix4.identity();
              }(),
              child: Text(
                widget.emoji,
                style: const TextStyle(fontSize: 30), // text-3xl
              ),
            ),
            SizedBox(height: AppTheme.spacing2), // gap-2
            // 라벨 텍스트
            Text(
              widget.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 14, // text-sm
                color: AppTheme.textGray700, // text-gray-700
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
    );
  }
}
