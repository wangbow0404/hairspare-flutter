import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/hair_model.dart';
import '../../models/model_match_preference.dart';
import '../../theme/app_theme.dart';
import '../../view_models/model_match_view_model.dart';
import '../../widgets/common/glass_modal.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import 'chat_room_screen.dart';

/// 모델 매칭 2단계 — 카드 스와이프로 모델 선택.
class ModelMatchSwipeScreen extends StatelessWidget {
  const ModelMatchSwipeScreen({super.key, required this.preference});

  final ModelMatchPreference preference;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ModelMatchViewModel>(
      create: (_) => ModelMatchViewModel(
        matchService: sl(),
        chatService: sl(),
      )
        ..setPreference(preference)
        ..loadCandidates(),
      child: const _SwipeScaffold(),
    );
  }
}

class _SwipeScaffold extends StatelessWidget {
  const _SwipeScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        title: const Text(
          'Model Matching',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppTheme.spacing4),
            child: Center(child: _RemainingBadge()),
          ),
        ],
      ),
      body: Consumer<ModelMatchViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.stitchPrimary),
            );
          }
          if (vm.error != null) {
            return StitchEmptyState(
              icon: Icons.error_outline,
              iconName: 'alert-circle',
              message: vm.error!,
              actionLabel: '다시 시도',
              onAction: vm.loadCandidates,
            );
          }
          if (!vm.hasMore) {
            return StitchEmptyState(
              icon: Icons.favorite_border,
              iconName: 'heart',
              message: '추천할 모델을 모두 확인했어요.\n조건을 바꿔 다시 찾아보세요.',
              actionLabel: '조건 다시 설정',
              onAction: () => Navigator.of(context).pop(),
            );
          }
          return _SwipeDeck(vm: vm);
        },
      ),
    );
  }
}

class _RemainingBadge extends StatelessWidget {
  const _RemainingBadge();

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelMatchViewModel>(
      builder: (context, vm, _) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing3,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurpleLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                size: 14,
                color: AppTheme.stitchPrimary,
              ),
              const SizedBox(width: AppTheme.spacing1),
              Text(
                '${vm.remainingMatches}/${vm.dailyLimit}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.stitchPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SwipeDeck extends StatefulWidget {
  const _SwipeDeck({required this.vm});

  final ModelMatchViewModel vm;

  @override
  State<_SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<_SwipeDeck>
    with SingleTickerProviderStateMixin {
  static const double _threshold = 110;

  late final AnimationController _controller;
  Offset _drag = Offset.zero;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  bool _animating = false;
  VoidCallback? _pending;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )
      ..addListener(() {
        setState(() => _drag = Offset.lerp(_from, _to, _controller.value)!);
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          final cb = _pending;
          _pending = null;
          _animating = false;
          _drag = Offset.zero;
          if (cb != null) cb();
          setState(() {});
        }
      });
  }

  @override
  void didUpdateWidget(covariant _SwipeDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_animating) {
      _drag = Offset.zero;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runAnimation(Offset target, {VoidCallback? onDone}) {
    _from = _drag;
    _to = target;
    _pending = onDone;
    _animating = true;
    _controller.forward(from: 0);
  }

  void _snapBack() {
    _runAnimation(Offset.zero);
  }

  void _flyOut(bool right, VoidCallback onDone) {
    final width = MediaQuery.sizeOf(context).width;
    _runAnimation(
      Offset(right ? width * 1.6 : -width * 1.6, _drag.dy),
      onDone: onDone,
    );
  }

  void _onLike() {
    if (_busy || _animating) return;
    if (widget.vm.remainingMatches <= 0) {
      _snapBack();
      _showLimitModal();
      return;
    }
    _flyOut(true, _performLike);
  }

  void _onSkip() {
    if (_busy || _animating) return;
    _flyOut(false, widget.vm.skip);
  }

  Future<void> _performLike() async {
    _busy = true;
    final result = await widget.vm.like();
    _busy = false;
    if (!mounted) return;
    switch (result.status) {
      case MatchAttemptStatus.matched:
        _showMatchModal(result);
        break;
      case MatchAttemptStatus.limitReached:
        _showLimitModal();
        break;
      case MatchAttemptStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? '매칭에 실패했습니다.'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        break;
    }
  }

  void _showLimitModal() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => GlassModal(
        onDismiss: () => Navigator.of(dialogContext).pop(),
        child: GlassModalPanel(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: GlassModalHeroIcon(emoji: '⏰'),
              ),
              const SizedBox(height: 16),
              const Text(
                '오늘의 매칭을 모두 사용했어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '매칭은 하루 3번까지 가능해요.\n내일 새로운 모델을 만나보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.stitchTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _ModalPrimaryButton(
                label: '확인',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMatchModal(MatchAttemptResult result) {
    final model = result.model;
    final chatId = result.chatId;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => GlassModal(
        onDismiss: () => Navigator.of(dialogContext).pop(),
        child: GlassModalPanel(
          width: 330,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: GlassModalHeroIcon(emoji: '💜'),
              ),
              const SizedBox(height: 16),
              Text(
                '${model?.name ?? ''}님과 매칭됐어요!',
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
              _ModalPrimaryButton(
                label: '채팅하기',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (chatId != null && chatId.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChatRoomScreen(chatId: chatId),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  '계속 둘러보기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.stitchTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPreview(HairModel model) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => GlassModalBottomSheet(
        stitchStyle: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing5,
              AppTheme.spacing2,
              AppTheme.spacing5,
              AppTheme.spacing5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: GlassModalDragHandle(stitchStyle: true)),
                const SizedBox(height: AppTheme.spacing3),
                Text(
                  '${model.name} · ${model.age}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing1),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: AppTheme.stitchTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${model.region} · ${model.distanceKm.round()}km',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                  ],
                ),
                if (model.intro != null) ...[
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    model.intro!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.stitchTextPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacing4),
                _PreviewInfoRow(label: '기장', value: model.hairLength),
                _PreviewInfoRow(label: '경력', value: model.career),
                _PreviewInfoRow(label: '촬영 협의', value: model.shootAgreement),
                _PreviewInfoRow(
                  label: '선호 시술',
                  value: model.preferredTreatments.join(', '),
                ),
                _PreviewInfoRow(
                  label: '이미지',
                  value: model.imageTags.join(', '),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final current = vm.currentModel;
    if (current == null) return const SizedBox.shrink();
    final next = vm.currentIndex + 1 < vm.candidates.length
        ? vm.candidates[vm.currentIndex + 1]
        : null;

    final width = MediaQuery.sizeOf(context).width;
    final rotation = (_drag.dx / width) * 0.28;
    final likeOpacity = (_drag.dx / _threshold).clamp(0.0, 1.0);
    final nopeOpacity = (-_drag.dx / _threshold).clamp(0.0, 1.0);

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing4,
                AppTheme.spacing4,
                AppTheme.spacing4,
                AppTheme.spacing2,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (next != null)
                    Transform.scale(
                      scale: 0.94,
                      child: Transform.translate(
                        offset: const Offset(0, 12),
                        child: _ModelCard(model: next, dimmed: true),
                      ),
                    ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      if (_animating || _busy) return;
                      setState(() => _drag += details.delta);
                    },
                    onPanEnd: (_) {
                      if (_animating || _busy) return;
                      if (_drag.dx > _threshold) {
                        _onLike();
                      } else if (_drag.dx < -_threshold) {
                        _onSkip();
                      } else {
                        _snapBack();
                      }
                    },
                    child: Transform.translate(
                      offset: _drag,
                      child: Transform.rotate(
                        angle: rotation,
                        child: _ModelCard(
                          model: current,
                          likeOpacity: likeOpacity,
                          nopeOpacity: nopeOpacity,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _ActionButtons(
            onSkip: _onSkip,
            onPreview: () => _showPreview(current),
            onLike: _onLike,
          ),
          const SizedBox(height: AppTheme.spacing4),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.model,
    this.dimmed = false,
    this.likeOpacity = 0,
    this.nopeOpacity = 0,
  });

  final HairModel model;
  final bool dimmed;
  final double likeOpacity;
  final double nopeOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radius2xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTheme.radius2xl),
          boxShadow: dimmed ? null : AppTheme.stitchSoftShadow,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              model.primaryImage,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const ColoredBox(
                  color: AppTheme.surfaceContainerLow,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.stitchPrimary,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stack) => const ColoredBox(
                color: AppTheme.surfaceContainerLow,
                child: Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppTheme.stitchTextSecondary,
                  ),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xCC000000),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
            if (dimmed)
              const ColoredBox(color: Color(0x33000000)),
            Positioned(
              left: AppTheme.spacing5,
              right: AppTheme.spacing5,
              bottom: AppTheme.spacing6,
              child: _CardInfo(model: model),
            ),
            if (!dimmed)
              Positioned(
                top: AppTheme.spacing5,
                left: AppTheme.spacing5,
                child: _StampBadge(
                  label: 'LIKE',
                  color: AppTheme.stitchPrimary,
                  opacity: likeOpacity,
                  rotate: -0.3,
                ),
              ),
            if (!dimmed)
              Positioned(
                top: AppTheme.spacing5,
                right: AppTheme.spacing5,
                child: _StampBadge(
                  label: 'NOPE',
                  color: AppTheme.urgentRed,
                  opacity: nopeOpacity,
                  rotate: 0.3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo({required this.model});

  final HairModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              model.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppTheme.spacing2),
            Text(
              '${model.age}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing1),
        Row(
          children: [
            const Icon(Icons.place, size: 16, color: Colors.white70),
            const SizedBox(width: 2),
            Text(
              '${model.region} · ${model.distanceKm.round()}km',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing3),
        Wrap(
          spacing: AppTheme.spacing2,
          runSpacing: AppTheme.spacing2,
          children: [
            _CardTag(label: model.hairLength),
            for (final tag in model.imageTags.take(2)) _CardTag(label: tag),
          ],
        ),
      ],
    );
  }
}

class _CardTag extends StatelessWidget {
  const _CardTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing3,
        vertical: AppTheme.spacing1,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StampBadge extends StatelessWidget {
  const _StampBadge({
    required this.label,
    required this.color,
    required this.opacity,
    required this.rotate,
  });

  final String label;
  final Color color;
  final double opacity;
  final double rotate;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: rotate,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing3,
            vertical: AppTheme.spacing1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: color, width: 3),
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.onSkip,
    required this.onPreview,
    required this.onLike,
  });

  final VoidCallback onSkip;
  final VoidCallback onPreview;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleAction(
          icon: Icons.close_rounded,
          size: 60,
          iconColor: AppTheme.stitchTextSecondary,
          background: AppTheme.backgroundWhite,
          border: AppTheme.borderGray,
          onTap: onSkip,
        ),
        const SizedBox(width: AppTheme.spacing5),
        _CircleAction(
          icon: Icons.visibility_outlined,
          size: 48,
          iconColor: AppTheme.stitchTextSecondary,
          background: AppTheme.surfaceContainerLow,
          onTap: onPreview,
        ),
        const SizedBox(width: AppTheme.spacing5),
        _CircleAction(
          icon: Icons.favorite,
          size: 68,
          iconColor: Colors.white,
          background: AppTheme.stitchPrimary,
          onTap: onLike,
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.size,
    required this.iconColor,
    required this.background,
    required this.onTap,
    this.border,
  });

  final IconData icon;
  final double size;
  final Color iconColor;
  final Color background;
  final Color? border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: CircleBorder(
        side: border != null
            ? BorderSide(color: border!)
            : BorderSide.none,
      ),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: iconColor, size: size * 0.42),
        ),
      ),
    );
  }
}

class _PreviewInfoRow extends StatelessWidget {
  const _PreviewInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalPrimaryButton extends StatelessWidget {
  const _ModalPrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.stitchPrimaryContainer,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}