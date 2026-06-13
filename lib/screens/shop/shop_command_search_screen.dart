import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/shop_command_search_item.dart';
import '../../theme/app_theme.dart';
import '../../utils/shop_command_navigation.dart';
import '../../utils/shop_command_search_catalog.dart';
import '../../view_models/shop_command_search_view_model.dart';
import '../../widgets/common/shared_app_bar.dart';

/// 샵 홈 검색 — 키워드 입력 후 관련 기능을 **선택**해 이동.
class ShopCommandSearchScreen extends StatelessWidget {
  const ShopCommandSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopCommandSearchViewModel(),
      child: const _ShopCommandSearchBody(),
    );
  }
}

class _ShopCommandSearchBody extends StatelessWidget {
  const _ShopCommandSearchBody();

  Future<void> _onSelect(BuildContext context, ShopCommandSearchItem item) async {
    context.pop();
    await ShopCommandNavigation.open(item.destination);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopCommandSearchViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(
        title: '',
        titleWidget: TextField(
          controller: vm.queryController,
          autofocus: true,
          style: SharedAppBar.titleTextStyle(context).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            hintText: '기능 검색 (예: 공고, 스케줄)',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          textInputAction: TextInputAction.search,
        ),
      ),
      body: vm.hasQuery
          ? _ShopCommandSearchResults(
              results: vm.results,
              onSelect: (item) => _onSelect(context, item),
            )
          : const _ShopCommandSearchEmptyHint(),
    );
  }
}

class _ShopCommandSearchEmptyHint extends StatelessWidget {
  const _ShopCommandSearchEmptyHint();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ShopCommandSearchViewModel>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: AppTheme.textTertiary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              '원하는 기능을 검색해 보세요',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              '키워드를 입력하면 관련 메뉴가 나타납니다.\n원하는 항목을 선택해 이동하세요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing6),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: [
                for (final keyword in ShopCommandSearchCatalog.exampleKeywords)
                  ActionChip(
                    label: Text(keyword),
                    onPressed: () => vm.applyExampleKeyword(keyword),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCommandSearchResults extends StatelessWidget {
  const _ShopCommandSearchResults({
    required this.results,
    required this.onSelect,
  });

  final List<ShopCommandSearchItem> results;
  final ValueChanged<ShopCommandSearchItem> onSelect;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing2,
      ),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 72,
        color: AppTheme.borderGray,
      ),
      itemBuilder: (context, index) {
        final item = results[index];
        return _ShopCommandSearchResultTile(
          item: item,
          onTap: () => onSelect(item),
        );
      },
    );
  }
}

class _ShopCommandSearchResultTile extends StatelessWidget {
  const _ShopCommandSearchResultTile({
    required this.item,
    required this.onTap,
  });

  final ShopCommandSearchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundWhite,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing4,
            vertical: AppTheme.spacing3,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Icon(
                  item.icon,
                  color: AppTheme.primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
