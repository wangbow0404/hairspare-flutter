import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/challenge_view_model.dart';
import 'challenge_comment_sheet.dart';

/// 댓글 바텀시트 오버레이 — 헤더·목록 함께 아래로 당기면 닫힘.
class ChallengeCommentSheetLayer extends StatefulWidget {
  const ChallengeCommentSheetLayer({super.key});

  @override
  State<ChallengeCommentSheetLayer> createState() =>
      _ChallengeCommentSheetLayerState();
}

class _ChallengeCommentSheetLayerState extends State<ChallengeCommentSheetLayer> {
  static const double _minSheetSize = 0.35;
  static const double _closeThreshold = 0.32;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetSizeChanged);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetSizeChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetSizeChanged() {
    if (!_sheetController.isAttached) return;
    if (_sheetController.size <= _closeThreshold) {
      _dismiss();
    }
  }

  void _dismiss() {
    if (!mounted) return;
    context.read<ChallengeViewModel>().setShowCommentSheet(false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();
    if (!vm.showCommentSheet || vm.currentIndex >= vm.displayedChallenges.length) {
      return const SizedBox.shrink();
    }
    final challengeId = vm.displayedChallenges[vm.currentIndex].id;
    final commentCount = vm.displayedChallenges[vm.currentIndex].comments;

    return Positioned.fill(
      child: GestureDetector(
        onTap: _dismiss,
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.5,
            minChildSize: _minSheetSize,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.5, 0.9],
            builder: (context, scrollController) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ChallengeCommentSheetContent(
                    challengeId: challengeId,
                    commentTitle:
                        '댓글 ${ChallengeViewModel.formatCount(commentCount)}',
                    scrollController: scrollController,
                    onPullDownAtTop: _dismiss,
                    onClose: _dismiss,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
