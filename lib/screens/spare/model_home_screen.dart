import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/matching_service.dart';
import '../../theme/app_theme.dart';
import '../../view_models/matching_view_model.dart';
import '../../widgets/model_home/model_home_scroll_view.dart';

/// 모델 전용 홈 탭 — [ModelHomeScrollView].
class ModelHomeScreen extends StatefulWidget {
  const ModelHomeScreen({super.key});

  @override
  State<ModelHomeScreen> createState() => _ModelHomeScreenState();
}

class _ModelHomeScreenState extends State<ModelHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  MatchingViewModel? _matchingViewModel;
  bool _providersReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatProvider>().loadChats(viewerRole: 'model');
      context.read<NotificationProvider>().loadNotifications(audience: 'model');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providersReady) return;
    _providersReady = true;

    final userId =
        context.read<AuthProvider>().currentUser?.id ?? 'mock-model-dev';
    _matchingViewModel = MatchingViewModel(sl<MatchingService>())
      ..load(modelUserId: userId);
  }

  @override
  void dispose() {
    _matchingViewModel?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _matchingViewModel;
    if (vm == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider<MatchingViewModel>.value(
      value: vm,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: ModelHomeScrollView(scrollController: _scrollController),
      ),
    );
  }
}
