import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../view_models/shop_home_view_model.dart';
import '../../widgets/shop_home/shop_home_scroll_view.dart';

/// Shop 홈 화면
class ShopHomeScreen extends StatefulWidget {
  const ShopHomeScreen({super.key});

  @override
  State<ShopHomeScreen> createState() => _ShopHomeScreenState();
}

class _ShopHomeScreenState extends State<ShopHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ShopHomeViewModel(
        notificationProvider:
            Provider.of<NotificationProvider>(context, listen: false),
      ),
      child: _ShopHomeLoadedBody(
        scrollController: _scrollController,
      ),
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
      body: SafeArea(
        bottom: false,
        child: ShopHomeScrollView(scrollController: widget.scrollController),
      ),
    );
  }
}
