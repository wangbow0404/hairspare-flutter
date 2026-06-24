import 'package:flutter/material.dart';

import '../../models/hair_model.dart';
import '../../models/model_discovery_item.dart';
import '../../theme/app_theme.dart';
import '../../theme/home_text_styles.dart';
import '../common/app_network_image.dart';

/// 추천 카드가 모두 소진됐을 때: 상단 인기·신규 미니 카드 스와이프 + 하단 안내.
class ModelMatchExhaustedView extends StatefulWidget {
  const ModelMatchExhaustedView({
    super.key,
    required this.items,
    required this.onResetFilters,
    this.isLoading = false,
    this.onModelTap,
  });

  final List<ModelDiscoveryItem> items;
  final bool isLoading;
  final VoidCallback onResetFilters;
  final ValueChanged<HairModel>? onModelTap;

  @override
  State<ModelMatchExhaustedView> createState() => _ModelMatchExhaustedViewState();
}

class _ModelMatchExhaustedViewState extends State<ModelMatchExhaustedView> {
  static const double _cardHeight = 300;
  static const double _viewportFraction = 0.84;

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final items = widget.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing6,
              AppTheme.spacing6,
              AppTheme.spacing6,
              AppTheme.spacing2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이런 모델은 어떠세요?',
                  style: HomeTextStyles.sectionTitle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing2),
                Text(
                  _subtitleFor(items, _currentPage),
                  style: HomeTextStyles.homeCardMeta.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing5),
                Expanded(
                  child: widget.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.stitchPrimary,
                          ),
                        )
                      : items.isEmpty
                          ? Center(
                              child: Text(
                                '추천할 다른 모델이 없어요.',
                                style: HomeTextStyles.homeCardMeta.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: items.length,
                                    onPageChanged: (index) {
                                      setState(() => _currentPage = index);
                                    },
                                    itemBuilder: (context, index) {
                                      final item = items[index];
                                      final isActive = index == _currentPage;
                                      return AnimatedScale(
                                        scale: isActive ? 1 : 0.94,
                                        duration:
                                            const Duration(milliseconds: 220),
                                        curve: Curves.easeOut,
                                        child: AnimatedOpacity(
                                          opacity: isActive ? 1 : 0.72,
                                          duration:
                                              const Duration(milliseconds: 220),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppTheme.spacing2,
                                            ),
                                            child: ModelMatchDiscoveryCard(
                                              item: item,
                                              height: _cardHeight,
                                              onTap: widget.onModelTap == null
                                                  ? null
                                                  : () => widget.onModelTap!(
                                                        item.model,
                                                      ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing4),
                                _PageDots(
                                  count: items.length,
                                  index: _currentPage,
                                ),
                                const SizedBox(height: AppTheme.spacing2),
                                Text(
                                  '${_currentPage + 1} / ${items.length}',
                                  textAlign: TextAlign.center,
                                  style: HomeTextStyles.homeCardMeta.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppTheme.spacing6,
            AppTheme.spacing2,
            AppTheme.spacing6,
            AppTheme.spacing4 + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryPurpleLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 26,
                  color: AppTheme.primaryPurple,
                ),
              ),
              const SizedBox(height: AppTheme.spacing3),
              Text(
                '추천할 모델을 모두 확인했어요.\n조건을 바꿔 다시 찾아보세요.',
                textAlign: TextAlign.center,
                style: HomeTextStyles.homeCardMeta.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onResetFilters,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  child: const Text(
                    '조건 다시 설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _subtitleFor(List<ModelDiscoveryItem> items, int index) {
    if (items.isEmpty) return '인기·신규 모델';
    final kind = items[index.clamp(0, items.length - 1)].kind;
    return kind == ModelDiscoveryKind.popular
        ? '인기 모델'
        : '이번 주 새로 가입한 모델';
  }
}

class ModelMatchDiscoveryCard extends StatelessWidget {
  const ModelMatchDiscoveryCard({
    super.key,
    required this.item,
    required this.height,
    this.onTap,
  });

  final ModelDiscoveryItem item;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final model = item.model;
    final imageUrl = model.primaryImage.isNotEmpty ? model.primaryImage : null;
    final isNew = item.kind == ModelDiscoveryKind.newlyJoined;

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radius2xl),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radius2xl),
              boxShadow: AppTheme.stitchSoftShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radius2xl),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 640,
                    fallbackIcon: Icons.person_outline,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Colors.transparent,
                          Color(0xCC000000),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppTheme.spacing4,
                    left: AppTheme.spacing4,
                    child: _DiscoveryBadge(
                      label: item.badgeLabel,
                      isNew: isNew,
                    ),
                  ),
                  Positioned(
                    left: AppTheme.spacing5,
                    right: AppTheme.spacing5,
                    bottom: AppTheme.spacing5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                model.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Text(
                              '${model.age}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing1),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${model.region} · ${model.hairLength}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (model.imageTags.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacing2),
                          Wrap(
                            spacing: AppTheme.spacing2,
                            children: [
                              for (final tag in model.imageTags.take(2))
                                _MiniTag(label: tag),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoveryBadge extends StatelessWidget {
  const _DiscoveryBadge({required this.label, required this.isNew});

  final String label;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing3,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isNew
            ? Colors.white.withValues(alpha: 0.92)
            : AppTheme.stitchPrimary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: isNew ? AppTheme.stitchPrimary : Colors.white,
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing2,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? AppTheme.stitchPrimary
                : AppTheme.stitchPrimary.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
        );
      }),
    );
  }
}
