import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/match_like.dart';
import '../../models/match_profile.dart';
import '../../providers/chat_provider.dart';
import '../../services/matching_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/messaging_navigation.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/app_screen_safe_area.dart';
import '../../widgets/common/glass_modal.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';

/// 매칭 상대 프로필 + 포트폴리오 — pending 수락/거절 또는 매칭 후 채팅.
class MatchProfileDetailScreen extends StatefulWidget {
  const MatchProfileDetailScreen({
    super.key,
    required this.likeId,
    this.initialLike,
  });

  final String likeId;

  /// 홈·매칭 목록에서 이미 알고 있는 like — 로딩 스피너 없이 즉시 표시.
  final MatchLike? initialLike;

  @override
  State<MatchProfileDetailScreen> createState() =>
      _MatchProfileDetailScreenState();
}

class _MatchProfileDetailScreenState extends State<MatchProfileDetailScreen> {
  MatchLike? _like;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLike;
    if (initial != null) {
      _like = initial;
      _isLoading = false;
      return;
    }
    _loadLike();
  }

  Future<void> _loadLike() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final like = await sl<MatchingService>().getLikeById(widget.likeId);
      if (!mounted) return;
      setState(() {
        _like = like;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHandler.handleException(e).message;
        _isLoading = false;
      });
    }
  }

  MatchProfile? get _profile => _like?.fromProfile;

  Future<void> _accept() async {
    if (_like == null || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final chatId = await sl<MatchingService>().acceptLike(_like!.id);
      if (!mounted) return;
      await context.read<ChatProvider>().refreshChats(viewerRole: 'model');
      if (!mounted) return;
      await _showMatchModal(chatId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(
            ErrorHandler.handleException(e),
          )),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _decline() async {
    if (_like == null || _isProcessing) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('관심 거절'),
        content: const Text('이 관심을 거절하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('거절'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await sl<MatchingService>().declineLike(_like!.id);
      if (mounted) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(
            ErrorHandler.handleException(e),
          )),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showMatchModal(String chatId) async {
    final profile = _profile;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => GlassModal(
        onDismiss: () => Navigator.of(dialogContext).pop(),
        child: GlassModalPanel(
          width: 330,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: GlassModalHeroIcon(emoji: '💜')),
              const SizedBox(height: 16),
              Text(
                '${profile?.displayName ?? ''}님과 매칭됐어요!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '채팅으로 촬영·시술 일정을 조율해 보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.stitchTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.pop(true);
                    MessagingNavigation.openChat(context, chatId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.stitchPrimaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                  ),
                  child: const Text(
                    '채팅하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.pop(true);
                },
                child: const Text('닫기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChat(String chatId) {
    MessagingNavigation.openChat(context, chatId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _profile == null) {
      return Scaffold(
        appBar: SpareSubpageAppBar(
          title: '프로필',
          showToolbarActions: false,
          onBackPressed: () => context.pop(),
        ),
        body: Center(
          child: Text(_error ?? '프로필을 찾을 수 없습니다.'),
        ),
      );
    }

    final profile = _profile!;
    final isMatched = _like!.isMatched;
    final chatId = _like!.chatId;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: profile.displayName,
        showToolbarActions: false,
        onBackPressed: () => context.pop(),
      ),
      body: AppScreenSafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                cacheExtent: 200,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProfileHeader(profile: profile),
                          const SizedBox(height: AppTheme.spacing4),
                          if (profile.intro != null &&
                              profile.intro!.isNotEmpty) ...[
                            Text(
                              profile.intro!,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.stitchTextPrimary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                          ],
                          if (profile.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: AppTheme.spacing2,
                              runSpacing: AppTheme.spacing2,
                              children: profile.tags
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacing3,
                                        vertical: AppTheme.spacing1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryPurpleLight,
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusFull,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.stitchPrimary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: AppTheme.spacing6),
                          ],
                          const Text(
                            '포트폴리오',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.stitchTextPrimary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing3),
                        ],
                      ),
                    ),
                  ),
                  _PortfolioSliver(images: profile.portfolioImages),
                ],
              ),
            ),
            _BottomActions(
              isMatched: isMatched,
              isProcessing: _isProcessing,
              onDecline: isMatched ? null : _decline,
              onAccept: isMatched ? null : _accept,
              onChat: isMatched && chatId != null
                  ? () => _openChat(chatId)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final MatchProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AppTheme.surfaceContainerLow,
          child: ClipOval(
            child: SizedBox(
              width: 72,
              height: 72,
              child: AppNetworkImage(
                imageUrl: profile.avatarUrl,
                memCacheWidth: 144,
                fallbackIcon: Icons.person,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacing4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.stitchTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PortfolioSliver extends StatelessWidget {
  const _PortfolioSliver({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacing6),
            child: Text(
              '등록된 포트폴리오가 없습니다.',
              style: TextStyle(color: AppTheme.stitchTextSecondary),
            ),
          ),
        ),
      );
    }

    final cacheWidth =
        (MediaQuery.sizeOf(context).width / 2 *
                MediaQuery.devicePixelRatioOf(context))
            .round();

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        0,
        AppTheme.spacing4,
        AppTheme.spacing4,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppTheme.spacing2,
          mainAxisSpacing: AppTheme.spacing2,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: AppNetworkImage(
                  imageUrl: images[index],
                  memCacheWidth: cacheWidth,
                  fallbackIcon: Icons.image_outlined,
                ),
              ),
            );
          },
          childCount: images.length,
          addRepaintBoundaries: false,
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.isMatched,
    required this.isProcessing,
    this.onDecline,
    this.onAccept,
    this.onChat,
  });

  final bool isMatched;
  final bool isProcessing;
  final VoidCallback? onDecline;
  final VoidCallback? onAccept;
  final VoidCallback? onChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(top: BorderSide(color: AppTheme.borderGray)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing4),
      child: SafeArea(
        top: false,
        child: isMatched
            ? SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isProcessing ? null : onChat,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('채팅하기'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.stitchPrimaryContainer,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : onDecline,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppTheme.borderGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        ),
                      ),
                      child: const Text('거절'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing3),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: isProcessing ? null : onAccept,
                      icon: isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.favorite, size: 18),
                      label: const Text('하트'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.stitchPrimaryContainer,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
