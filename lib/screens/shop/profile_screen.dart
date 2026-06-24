import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../view_models/shop_profile_view_model.dart';
import '../../widgets/shop_profile/shop_profile_scroll_view.dart';

/// 샵 마이 탭 화면.
class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  ShopProfileViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= ShopProfileViewModel();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;
    if (vm == null) {
      return const SizedBox.shrink();
    }
    return ChangeNotifierProvider<ShopProfileViewModel>.value(
      value: vm,
      child: const _ShopProfileBody(),
    );
  }
}

class _ShopProfileBody extends StatefulWidget {
  const _ShopProfileBody();

  @override
  State<_ShopProfileBody> createState() => _ShopProfileBodyState();
}

class _ShopProfileBodyState extends State<_ShopProfileBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<ShopProfileViewModel>().loadInitial());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: ShopProfileScrollView(),
    );
  }
}
