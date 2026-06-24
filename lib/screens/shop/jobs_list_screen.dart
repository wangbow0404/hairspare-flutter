import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/deferred_route_body.dart';
import '../../utils/shell_navigation.dart';
import '../../theme/app_theme.dart';
import '../../view_models/shop_jobs_list_view_model.dart';
import '../../widgets/shop/shop_screen_safe_area.dart';
import '../../widgets/shop_jobs_list/shop_jobs_list_scroll_view.dart';

/// Shop 공고 목록 화면
class ShopJobsListScreen extends StatelessWidget {
  const ShopJobsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopJobsListViewModel(),
      child: const _ShopJobsListScaffold(),
    );
  }
}

class _ShopJobsListScaffold extends StatefulWidget {
  const _ShopJobsListScaffold();

  @override
  State<_ShopJobsListScaffold> createState() => _ShopJobsListScaffoldState();
}

class _ShopJobsListScaffoldState extends State<_ShopJobsListScaffold> {
  final ScrollController _scrollController = ScrollController();

  void _onScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 280) {
      final vm = context.read<ShopJobsListViewModel>();
      unawaited(vm.loadMore());
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ShopJobsListViewModel>().loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openNewJob() async {
    final vm = context.read<ShopJobsListViewModel>();
    final created = await ShellNavigation.pushShopJobNew(context);
    if (!mounted) return;
    if (created == true) {
      await vm.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    const fabBottomPadding = AppTheme.spacing4;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: fabBottomPadding),
        child: FloatingActionButton(
          onPressed: () => deferAfterTap(_openNewJob),
          backgroundColor: AppTheme.stitchPrimaryContainer,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      body: ShopScreenSafeArea(
        child: Column(
          children: [
            const ShopJobsListHeader(),
            Expanded(
              child: ShopJobsListScrollView(
                scrollController: _scrollController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
