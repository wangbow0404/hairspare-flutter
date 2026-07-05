import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/shell_navigation.dart';
import '../../view_models/shop_home_view_model.dart';
import '../../widgets/common/app_screen_safe_area.dart';
import '../../widgets/shop_home/shop_home_scroll_view.dart';

/// Shop 홈 화면
class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  ShopHomeViewModel? _viewModel;
  bool _providersReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providersReady) return;
    _providersReady = true;

    _viewModel = ShopHomeViewModel(
      notificationProvider: context.read<NotificationProvider>(),
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

    return ChangeNotifierProvider<ShopHomeViewModel>.value(
      value: vm,
      child: _ShopHomeLoadedBody(scrollController: _scrollController),
    );
  }
}

class _ShopHomeLoadedBody extends StatefulWidget {
  const _ShopHomeLoadedBody({
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  State<_ShopHomeLoadedBody> createState() => _ShopHomeLoadedBodyState();
}

class _ShopHomeLoadedBodyState extends State<_ShopHomeLoadedBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<FavoriteProvider>().loadFavorites());
      unawaited(context.read<ChatProvider>().loadChats(viewerRole: 'shop'));
      context.read<ShopHomeViewModel>().loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: AppScreenSafeArea(
        bottom: false,
        child: ShopHomeScrollView(scrollController: widget.scrollController),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shop_home_new_job_fab',
        backgroundColor: AppTheme.primaryPurple,
        tooltip: '공고 올리기',
        onPressed: () => ShellNavigation.pushShopJobNew(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
