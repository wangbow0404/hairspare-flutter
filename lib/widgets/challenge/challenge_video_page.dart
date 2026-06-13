import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../models/challenge_feed.dart';
import '../../utils/icon_mapper.dart';

/// 풀스크린 챌린지 비디오 한 페이지 (부모가 [VideoPlayerController] 생명주기 관리).
class ChallengeVideoPage extends StatefulWidget {
  const ChallengeVideoPage({
    super.key,
    required this.challenge,
    this.videoController,
    required this.isPlaying,
    required this.isMuted,
    required this.onControllerReady,
    this.onTap,
  });

  final Challenge challenge;
  final VideoPlayerController? videoController;
  final bool isPlaying;
  final bool isMuted;
  final void Function(VideoPlayerController controller) onControllerReady;
  final VoidCallback? onTap;

  @override
  State<ChallengeVideoPage> createState() => _ChallengeVideoPageState();
}

class _ChallengeVideoPageState extends State<ChallengeVideoPage> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoController != null) {
      _controller = widget.videoController;
      _isInitialized = _controller!.value.isInitialized;
      if (_isInitialized) {
        widget.onControllerReady(_controller!);
      }
    } else if (widget.challenge.videoUrl != null) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(ChallengeVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoController != oldWidget.videoController) {
      _controller = widget.videoController;
      _isInitialized = _controller?.value.isInitialized ?? false;
    }
    _updateVideoState();
  }

  Future<void> _initializeVideo() async {
    if (widget.challenge.videoUrl == null) return;

    final url = widget.challenge.videoUrl!;
    if (url.startsWith('assets/')) {
      // 과거 경로(`assets/video/...`)와 신규 경로(`assets/videos/...`) 모두 허용.
      final candidates = <String>{
        url,
        url.replaceFirst('assets/videos/', 'assets/video/'),
        url.replaceFirst('assets/video/', 'assets/videos/'),
      };

      String? resolved;
      for (final candidate in candidates) {
        try {
          await rootBundle.load(candidate);
          resolved = candidate;
          break;
        } catch (_) {
          // 다음 후보 시도
        }
      }
      if (resolved == null) return;
      _controller = VideoPlayerController.asset(resolved);
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    }
    if (_controller == null) return;
    await _controller!.initialize();
    _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
    widget.onControllerReady(_controller!);
    setState(() {
      _isInitialized = true;
    });
    if (widget.isPlaying) {
      _controller!.play();
    }
  }

  void _updateVideoState() {
    if (_controller == null || !_isInitialized) return;

    if (widget.isPlaying) {
      _controller!.play();
    } else {
      _controller!.pause();
    }
    _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_controller != null && _isInitialized)
                  ColoredBox(
                    color: Colors.black,
                    child: ClipRect(
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1C1F24), Color(0xFF101215)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Mock Video Preview',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                if (!widget.isPlaying)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.28),
                    child: Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 1.2),
                        ),
                        child:
                            IconMapper.icon(
                              'play',
                              size: 40,
                              color: Colors.white,
                            ) ??
                            const Icon(
                              Icons.play_arrow_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
