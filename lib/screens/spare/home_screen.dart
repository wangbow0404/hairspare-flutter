import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/chat_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../view_models/spare_home_view_model.dart';
import '../../widgets/spare_home/spare_home_scroll_view.dart';

/// 스페어 홈 탭 — [SpareHomeViewModel] + [SpareHomeScrollView].
class SpareHomeScreen extends StatefulWidget {
  const SpareHomeScreen({super.key});

  @override
  State<SpareHomeScreen> createState() => _SpareHomeScreenState();
}

class _SpareHomeScreenState extends State<SpareHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SpareHomeViewModel(
        jobProvider: Provider.of<JobProvider>(context, listen: false),
        favoriteProvider: Provider.of<FavoriteProvider>(context, listen: false),
        notificationProvider: Provider.of<NotificationProvider>(context, listen: false),
        chatProvider: Provider.of<ChatProvider>(context, listen: false),
      ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<SpareHomeViewModel>().loadInitial());
      context.read<SpareHomeViewModel>().startPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SpareHomeScrollView(scrollController: widget.scrollController),
    );
  }
}
