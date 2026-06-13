import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/shop/job_new_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: ShopScreenSafeArea(
        child: Column(
          children: [
            ShopJobsListHeader(
              onOpenNewJob: () async {
                final vm = context.read<ShopJobsListViewModel>();
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (context) => const ShopJobNewScreen(),
                  ),
                );
                if (!context.mounted) return;
                if (created == true) {
                  await vm.refresh();
                }
              },
            ),
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
