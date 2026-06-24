import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/router/app_routes.dart';
import '../../providers/chat_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../view_models/spare_home_view_model.dart';
import '../../widgets/common/app_screen_safe_area.dart';
import '../../widgets/spare_home/spare_home_scroll_view.dart';

/// 스페어 홈 탭 — [SpareHomeViewModel] + [SpareHomeScrollView].
class SpareHomeScreen extends StatefulWidget {
  const SpareHomeScreen({super.key});

  @override
  State<SpareHomeScreen> createState() => _SpareHomeScreenState();
}

class _SpareHomeScreenState extends State<SpareHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  SpareHomeViewModel? _viewModel;
  bool _providersReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providersReady) return;
    _providersReady = true;

    _viewModel = SpareHomeViewModel(
      jobProvider: context.read<JobProvider>(),
      favoriteProvider: context.read<FavoriteProvider>(),
      notificationProvider: context.read<NotificationProvider>(),
      chatProvider: context.read<ChatProvider>(),
    );
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;
    if (vm == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider<SpareHomeViewModel>.value(
      value: vm,
      child: _SpareHomeBody(scrollController: _scrollController),
    );
  }
}

class _SpareHomeBody extends StatefulWidget {
  const _SpareHomeBody({required this.scrollController});

  final ScrollController scrollController;

  @override
  State<_SpareHomeBody> createState() => _SpareHomeBodyState();
}

class _SpareHomeBodyState extends State<_SpareHomeBody> {
  @override
  void initState() {
    super.initState();
    appRouter.routerDelegate.addListener(_syncHomePolling);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<SpareHomeViewModel>().loadInitial();
      if (!mounted) return;
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      _syncHomePolling();
    });
  }

  @override
  void dispose() {
    appRouter.routerDelegate.removeListener(_syncHomePolling);
    super.dispose();
  }

  void _syncHomePolling() {
    if (!mounted) return;
    final vm = context.read<SpareHomeViewModel>();
    final onBareHome = appRouter.state.uri.path == AppRoutes.spareHome;
    if (onBareHome) {
      vm.startPolling();
    } else {
      vm.stopPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: AppScreenSafeArea(
        bottom: false,
        child: SpareHomeScrollView(scrollController: widget.scrollController),
      ),
    );
  }
}
