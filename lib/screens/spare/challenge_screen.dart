import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/di/service_locator.dart';
import '../../theme/app_theme.dart';
import '../../utils/behavior_tracker.dart';
import '../../view_models/challenge_view_model.dart';
import '../../widgets/challenge/challenge_bottom_metadata.dart';
import '../../widgets/challenge/challenge_comment_sheet_layer.dart';
import '../../widgets/challenge/challenge_immersive_top_layer.dart';
import '../../widgets/challenge/challenge_right_action_rail.dart';
import '../../widgets/challenge/challenge_screen_states.dart';
import '../../widgets/challenge/challenge_url_launcher.dart';
import '../../widgets/challenge/challenge_video_page.dart';
import 'challenge_profile_screen.dart';

/// 챌린지 숏폼 피드 — 풀스크린 비디오 + 오버레이 UI.
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({
    super.key,
    this.creatorId,
    this.initialVideoId,
  });

  /// 프로필에서 재생 시 — 해당 크리에이터 영상만 먼저, 이후 유사 추천.
  final String? creatorId;
  final String? initialVideoId;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = ChallengeViewModel(
          challengeService: sl(),
          subscriptionService: sl(),
        );
        final args = ModalRoute.of(context)?.settings.arguments;
        final creatorId = widget.creatorId ??
            (args is Map ? args['creatorId'] as String? : null);
        final initialVideoId = widget.initialVideoId ??
            (args is Map ? args['initialVideoId'] as String? : null);

        if (creatorId != null &&
            creatorId.isNotEmpty &&
            initialVideoId != null &&
            initialVideoId.isNotEmpty) {
          vm.loadCreatorProfileFeed(
            creatorId: creatorId,
            initialVideoId: initialVideoId,
          );
        } else {
          vm.loadInitial();
        }
        return vm;
      },
      child: const _ChallengeBody(),
    );
  }
}

class _ChallengeBody extends StatefulWidget {
  const _ChallengeBody();

  @override
  State<_ChallengeBody> createState() => _ChallengeBodyState();
}

class _ChallengeBodyState extends State<_ChallengeBody> {
  final PageController _pageController = PageController();
  final List<VideoPlayerController?> _videoControllers = [];
  Timer? _watchTimeTimer;

  int _videoBindingToken = -1;
  List<String> _lastBoundIds = [];

  @override
  void initState() {
    super.initState();
    context.read<ChallengeViewModel>().addListener(_onVmChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
      _syncVideos();
    });
  }

  void _onVmChanged() {
    if (!mounted) return;
    _syncVideos();
    setState(() {});
  }

  @override
  void dispose() {
    context.read<ChallengeViewModel>().removeListener(_onVmChanged);
    for (final c in _videoControllers) {
      c?.dispose();
    }
    _pageController.dispose();
    _watchTimeTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _prefixEquals(List<String> prefix, List<String> full) {
    if (prefix.length > full.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (prefix[i] != full[i]) return false;
    }
    return true;
  }

  VideoPlayerController? _buildController(String? videoUrl) {
    if (videoUrl == null || videoUrl.isEmpty) return null;
    if (videoUrl.startsWith('assets/')) {
      return VideoPlayerController.asset(videoUrl);
    }
    return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
  }

  void _syncVideos() {
    final vm = context.read<ChallengeViewModel>();
    final ids = vm.displayedChallenges.map((e) => e.id).toList();

    if (vm.feedSwitchToken != _videoBindingToken) {
      _videoBindingToken = vm.feedSwitchToken;
      _rebuildAllControllers(vm);
      _lastBoundIds = List<String>.from(ids);
      return;
    }

    if (ids.length == _lastBoundIds.length + 1 &&
        _prefixEquals(_lastBoundIds, ids)) {
      _appendLastController(vm);
      _lastBoundIds = List<String>.from(ids);
      return;
    }

    if (!_listEquals(ids, _lastBoundIds)) {
      _rebuildAllControllers(vm);
      _lastBoundIds = List<String>.from(ids);
    }
  }

  void _rebuildAllControllers(ChallengeViewModel vm) {
    for (final c in _videoControllers) {
      c?.dispose();
    }
    _videoControllers.clear();

    for (final challenge in vm.displayedChallenges) {
      final controller = _buildController(challenge.videoUrl);
      if (controller != null) {
        _videoControllers.add(controller);
        controller
            .initialize()
            .then((_) {
              if (!mounted) return;
              setState(() {});
              final i = _videoControllers.indexOf(controller);
              if (i == 0 && vm.isPlaying) {
                controller.setVolume(vm.isMuted ? 0.0 : 1.0);
                controller.play();
              }
            })
            .catchError((_) {
              // 네트워크/권한 이슈로 영상 초기화 실패 시 레이아웃만 확인 가능하도록 fallback.
              if (!mounted) return;
              final i = _videoControllers.indexOf(controller);
              controller.dispose();
              if (i >= 0 && i < _videoControllers.length) {
                _videoControllers[i] = null;
                setState(() {});
              }
            });
      } else {
        _videoControllers.add(null);
      }
    }

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  void _appendLastController(ChallengeViewModel vm) {
    final challenge = vm.displayedChallenges.last;
    final controller = _buildController(challenge.videoUrl);
    if (controller != null) {
      _videoControllers.add(controller);
      controller
          .initialize()
          .then((_) {
            if (mounted) setState(() {});
          })
          .catchError((_) {
            if (!mounted) return;
            final i = _videoControllers.indexOf(controller);
            controller.dispose();
            if (i >= 0 && i < _videoControllers.length) {
              _videoControllers[i] = null;
              setState(() {});
            }
          });
    } else {
      _videoControllers.add(null);
    }
  }

  void _onPageChanged(int index) {
    final vm = context.read<ChallengeViewModel>();
    if (vm.isSnapping || index == vm.currentIndex) return;

    _stopWatchTimeTracking();
    final previousIndex = vm.currentIndex;
    vm.markPageChangeStart(index);

    if (previousIndex < _videoControllers.length &&
        _videoControllers[previousIndex] != null) {
      _videoControllers[previousIndex]!.pause();
      _videoControllers[previousIndex]!.seekTo(Duration.zero);
    }

    if (index < _videoControllers.length && _videoControllers[index] != null) {
      final controller = _videoControllers[index]!;
      controller.setVolume(vm.isMuted ? 0.0 : 1.0);
      controller.seekTo(Duration.zero);
      if (vm.isPlaying) {
        controller.play();
      }
    }

    _startWatchTimeTracking();
    vm.markPageChangeEndSoon();

    if (index == vm.displayedChallenges.length - 1) {
      vm.loadNextChallenge();
    }
  }

  void _startWatchTimeTracking() {
    _watchTimeTimer?.cancel();
    final vm = context.read<ChallengeViewModel>();
    if (vm.currentIndex >= vm.displayedChallenges.length) return;
    final challenge = vm.displayedChallenges[vm.currentIndex];
    if (challenge.videoUrl == null) return;
    if (vm.currentIndex >= _videoControllers.length) return;
    final controller = _videoControllers[vm.currentIndex];
    if (controller == null || !controller.value.isInitialized) return;

    _watchTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || vm.currentIndex >= vm.displayedChallenges.length) {
        timer.cancel();
        return;
      }

      final currentChallenge = vm.displayedChallenges[vm.currentIndex];
      if (currentChallenge.id != challenge.id) {
        timer.cancel();
        return;
      }

      if (vm.currentIndex >= _videoControllers.length) {
        timer.cancel();
        return;
      }

      final currentController = _videoControllers[vm.currentIndex];
      if (currentController == null || !currentController.value.isInitialized) {
        timer.cancel();
        return;
      }

      final currentTime = currentController.value.position.inSeconds.toDouble();
      final duration = currentController.value.duration.inSeconds.toDouble();

      if (duration > 0) {
        BehaviorTracker.trackWatchTime(
          currentChallenge.id,
          currentTime,
          duration,
        );
      }
    });
  }

  void _stopWatchTimeTracking() {
    _watchTimeTimer?.cancel();
    _watchTimeTimer = null;
  }

  void _togglePlayPause() {
    final vm = context.read<ChallengeViewModel>();
    vm.togglePlayPause();
    final i = vm.currentIndex;
    if (i < _videoControllers.length && _videoControllers[i] != null) {
      if (vm.isPlaying) {
        _videoControllers[i]!.play();
      } else {
        _videoControllers[i]!.pause();
      }
    }
  }

  void _openCreatorProfile(String? creatorId) {
    if (creatorId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChallengeProfileScreen(userId: creatorId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('크리에이터 정보를 불러올 수 없습니다'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) =>
      launchChallengeExternalUrl(context, url);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChallengeViewModel>();

    if (vm.isLoading) {
      return const ChallengeLoadingScaffold();
    }

    if (vm.displayedChallenges.isEmpty) {
      return const ChallengeEmptyScaffold();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: vm.displayedChallenges.length,
            itemBuilder: (context, index) {
              final challenge = vm.displayedChallenges[index];
              return ChallengeVideoPage(
                challenge: challenge,
                videoController: index < _videoControllers.length
                    ? _videoControllers[index]
                    : null,
                isPlaying: index == vm.currentIndex && vm.isPlaying,
                isMuted: vm.isMuted,
                onControllerReady: (controller) {
                  if (index < _videoControllers.length) {
                    _videoControllers[index] = controller;
                  }
                },
                onTap: _togglePlayPause,
              );
            },
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ChallengeImmersiveTopLayer(),
          ),
          ChallengeRightActionRail(
            onOpenCreatorProfile: _openCreatorProfile,
            immersive: true,
          ),
          ChallengeBottomMetadata(
            onOpenCreatorProfile: _openCreatorProfile,
            onLaunchUrl: _launchUrl,
            immersive: true,
          ),
          const ChallengeCommentSheetLayer(),
        ],
      ),
    );
  }
}
