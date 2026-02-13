import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/behavior_tracker.dart';
import '../../services/subscription_service.dart';
import '../../services/challenge_service.dart';
import '../../models/challenge_comment.dart';
import '../../utils/error_handler.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'challenge_comments_screen.dart';
import 'challenge_profile_screen.dart';
import 'store_screen.dart';
import 'education_screen.dart';
import 'dart:math';
import 'dart:async';
import 'package:intl/intl.dart';

/// Next.js와 동일한 챌린지 화면 (TikTok 스타일 비디오 스크롤)
class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int _currentNavIndex = 0;
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isPlaying = true;
  bool _isMuted = true;
  bool _isSnapping = false;
  List<Challenge> _challenges = [];
  List<Challenge> _displayedChallenges = [];
  List<VideoPlayerController> _videoControllers = [];
  Set<String> _viewedChallengeIds = {};
  bool _isLoading = true;
  Timer? _watchTimeTimer; // 시청 시간 추적 타이머
  bool _isFullscreen = false;
  bool _showCommentSheet = false; // 댓글 시트 표시 여부
  final SubscriptionService _subscriptionService = SubscriptionService();
  final ChallengeService _challengeService = ChallengeService();
  int _feedTabIndex = 0; // 0: 전체, 1: 구독
  List<Challenge> _subscribedChallenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  @override
  void dispose() {
    // 전체화면 모드 해제
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _pageController.dispose();
    _watchTimeTimer?.cancel();
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    // Mock 데이터 (백엔드 API 없음)
    final allChallenges = _generateMockChallenges();
    
    setState(() {
      _challenges = allChallenges;
      _isLoading = false;
    });

    // 초기 4개 로드
    _loadInitialChallenges();
    
    // 첫 번째 비디오의 시청 시간 추적 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startWatchTimeTracking();
    });
  }

  Future<void> _loadSubscribedChallenges() async {
    try {
      // API 호출하여 구독한 크리에이터의 영상 목록 가져오기
      final challenges = await _challengeService.getSubscribedChallenges();
      setState(() {
        _subscribedChallenges = challenges;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      print('구독 피드 로드 오류: ${appException.toString()}');
      // API 실패 시 빈 리스트로 설정
      setState(() {
        _subscribedChallenges = [];
      });
    }
  }

  void _switchFeedTab(int index) {
    if (_feedTabIndex == index) return;

    setState(() {
      _feedTabIndex = index;
      _currentIndex = 0;
      _viewedChallengeIds.clear();
    });

    if (index == 0) {
      // 전체 피드
      _loadChallenges();
    } else {
      // 구독 피드
      _loadSubscribedChallenges();
      // 구독 피드가 비어있으면 전체 피드로 전환
      if (_subscribedChallenges.isEmpty) {
        setState(() {
          _displayedChallenges = [];
        });
      } else {
        // 구독 피드 로드
        setState(() {
          _challenges = _subscribedChallenges;
        });
        _loadInitialChallenges();
      }
    }
  }

  List<Challenge> _generateMockChallenges() {
    // Mock 챌린지 데이터 생성
    return List.generate(20, (index) {
      // 일부 챌린지에 제품/교육 태그 추가
      final hasProduct = index % 3 == 0;
      final hasEducation = index % 5 == 0 && !hasProduct;
      
      return Challenge(
        id: 'challenge_$index',
        title: '챌린지 ${index + 1}',
        description: '챌린지 ${index + 1} 설명입니다',
        creatorName: '크리에이터 ${index + 1}',
        creatorId: 'creator_$index',
        creatorAvatar: null,
          videoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
          thumbnailUrl: null,
        likes: Random().nextInt(1000),
        comments: Random().nextInt(100),
        shares: Random().nextInt(50),
        views: Random().nextInt(10000),
          isLiked: false,
        isDisliked: false,
        isSubscribed: false,
        subscriberCount: Random().nextInt(5000),
        tags: ['태그${index + 1}', '미용'],
        productUrl: hasProduct ? 'https://example.com/product/$index' : null,
        productName: hasProduct ? '제품 ${index + 1}' : null,
        productThumbnailUrl: hasProduct ? null : null,
        educationId: hasEducation ? 'edu_$index' : null,
        educationName: hasEducation ? '교육 ${index + 1}' : null,
        educationUrl: hasEducation ? 'https://example.com/education/$index' : null,
        educationThumbnailUrl: hasEducation ? null : null,
        taggedType: hasProduct ? 'product' : (hasEducation ? 'education' : null),
        musicName: '음악 ${index + 1}',
        musicArtist: '아티스트 ${index + 1}',
      );
    });
  }

  void _loadInitialChallenges() {
    final initialChallenges = <Challenge>[];
    final excludeIds = <String>[];

    // 초기 4개 랜덤 선택
    for (int i = 0; i < 4 && i < _challenges.length; i++) {
      final challenge = _getRandomChallenge(excludeIds);
      if (challenge != null) {
        initialChallenges.add(challenge);
        excludeIds.add(challenge.id);
        _viewedChallengeIds.add(challenge.id);
      }
    }

    // 최소 1개는 보장
    if (initialChallenges.isEmpty && _challenges.isNotEmpty) {
      initialChallenges.add(_challenges[0]);
      _viewedChallengeIds.add(_challenges[0].id);
    }

    setState(() {
      _displayedChallenges = initialChallenges;
    });

    // 비디오 컨트롤러 초기화
    _initializeVideoControllers();
  }

  Challenge? _getRandomChallenge(List<String> excludeIds) {
    final available = _challenges.where((c) => !excludeIds.contains(c.id)).toList();
    if (available.isEmpty) {
      // 모든 챌린지를 본 경우 Set 초기화
      _viewedChallengeIds.clear();
      return _challenges.isNotEmpty ? _challenges[0] : null;
    }
    return available[Random().nextInt(available.length)];
  }

  void _initializeVideoControllers() {
    // 기존 컨트롤러 정리
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    _videoControllers.clear();

    // 각 챌린지에 대한 비디오 컨트롤러 생성
    for (var challenge in _displayedChallenges) {
      if (challenge.videoUrl != null) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(challenge.videoUrl!),
        );
        _videoControllers.add(controller);
        controller.initialize().then((_) {
          if (mounted) {
            setState(() {});
            // 첫 번째 비디오만 자동 재생
            if (_videoControllers.indexOf(controller) == 0 && _isPlaying) {
              controller.setVolume(_isMuted ? 0.0 : 1.0);
              controller.play();
            }
          }
        });
      } else {
        _videoControllers.add(null as VideoPlayerController);
      }
    }
  }

  void _onPageChanged(int index) {
    if (_isSnapping || index == _currentIndex) return;

    // 이전 비디오의 시청 시간 추적 중지
    _stopWatchTimeTracking();

    setState(() {
      _isSnapping = true;
      final previousIndex = _currentIndex;
      _currentIndex = index;

      // 이전 비디오 일시정지 및 리셋
      if (previousIndex < _videoControllers.length && _videoControllers[previousIndex] != null) {
        _videoControllers[previousIndex]!.pause();
        _videoControllers[previousIndex]!.seekTo(Duration.zero);
      }

      // 현재 비디오 재생
      if (index < _videoControllers.length && _videoControllers[index] != null) {
        final controller = _videoControllers[index]!;
        controller.setVolume(_isMuted ? 0.0 : 1.0);
        controller.seekTo(Duration.zero);
        if (_isPlaying) {
          controller.play();
        }
      }
    });

    // 새 비디오의 시청 시간 추적 시작
    _startWatchTimeTracking();

    // 스냅 락 해제
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isSnapping = false;
        });
      }
    });

    // 무한 스크롤: 끝에 도달하면 다음 챌린지 추가
    if (index == _displayedChallenges.length - 1) {
      _loadNextChallenge();
    }
  }

  /// 시청 시간 추적 시작
  void _startWatchTimeTracking() {
    _watchTimeTimer?.cancel();
    
    if (_currentIndex >= _displayedChallenges.length) return;
    final challenge = _displayedChallenges[_currentIndex];
    if (challenge.videoUrl == null) return;
    
    if (_currentIndex >= _videoControllers.length) return;
    final controller = _videoControllers[_currentIndex];
    if (controller == null || !controller.value.isInitialized) return;

    // 1초마다 시청 시간 추적
    _watchTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _currentIndex >= _displayedChallenges.length) {
        timer.cancel();
        return;
      }
      
      final currentChallenge = _displayedChallenges[_currentIndex];
      if (currentChallenge.id != challenge.id) {
        timer.cancel();
        return;
      }
      
      if (_currentIndex >= _videoControllers.length) {
        timer.cancel();
        return;
      }
      
      final currentController = _videoControllers[_currentIndex];
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

  /// 시청 시간 추적 중지
  void _stopWatchTimeTracking() {
    _watchTimeTimer?.cancel();
    _watchTimeTimer = null;
  }

  void _loadNextChallenge() {
    final excludeIds = _viewedChallengeIds.toList();
    final nextChallenge = _getRandomChallenge(excludeIds);

    if (nextChallenge != null) {
      setState(() {
        _displayedChallenges.add(nextChallenge);
        _viewedChallengeIds.add(nextChallenge.id);
      });

      // 새 비디오 컨트롤러 생성
      if (nextChallenge.videoUrl != null) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(nextChallenge.videoUrl!),
        );
        _videoControllers.add(controller);
        controller.initialize().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        _videoControllers.add(null as VideoPlayerController);
      }
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_currentIndex < _videoControllers.length && _videoControllers[_currentIndex] != null) {
      if (_isPlaying) {
        _videoControllers[_currentIndex]!.play();
      } else {
        _videoControllers[_currentIndex]!.pause();
      }
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    if (_currentIndex < _videoControllers.length && _videoControllers[_currentIndex] != null) {
      _videoControllers[_currentIndex]!.setVolume(_isMuted ? 0.0 : 1.0);
    }
  }

  void _toggleLike() {
    if (_currentIndex >= _displayedChallenges.length) return;
    
    final challenge = _displayedChallenges[_currentIndex];
    final newIsLiked = !challenge.isLiked;
    
    // 좋아요와 싫어요는 동시에 불가능
    if (newIsLiked && challenge.isDisliked) {
    setState(() {
        _displayedChallenges[_currentIndex].isDisliked = false;
      });
    }
    
    // 상호작용 추적
    BehaviorTracker.trackInteraction(challenge.id, 'like', newIsLiked);
    
    setState(() {
      _displayedChallenges[_currentIndex].isLiked = newIsLiked;
    });
  }

  void _handleShare() async {
    if (_currentIndex >= _displayedChallenges.length) return;
    
    final challenge = _displayedChallenges[_currentIndex];
    
    // 상호작용 추적
    BehaviorTracker.trackInteraction(challenge.id, 'share', true);
    
    // 공유 기능 구현
    try {
      await Share.share(
        '${challenge.title}\n${challenge.description}',
        subject: challenge.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공유 실패: ${e.toString()}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _handleDislike() async {
    if (_currentIndex >= _displayedChallenges.length) return;
    
    final challenge = _displayedChallenges[_currentIndex];
    final newIsDisliked = !challenge.isDisliked;
    
    // 좋아요와 싫어요는 동시에 불가능
    if (newIsDisliked && challenge.isLiked) {
      setState(() {
        _displayedChallenges[_currentIndex].isLiked = false;
      });
    }
    
    setState(() {
      _displayedChallenges[_currentIndex].isDisliked = newIsDisliked;
    });
    
    try {
      // 싫어요 API 호출
      await _challengeService.toggleChallengeDislike(challenge.id);
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      // 실패 시 롤백
      setState(() {
        _displayedChallenges[_currentIndex].isDisliked = !newIsDisliked;
        if (newIsDisliked && challenge.isLiked) {
          _displayedChallenges[_currentIndex].isLiked = true;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('싫어요 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _handleSubscribe() async {
    if (_currentIndex >= _displayedChallenges.length) return;
    
    final challenge = _displayedChallenges[_currentIndex];
    if (challenge.creatorId == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인이 필요합니다'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      return;
    }

    // 자신의 영상은 구독할 수 없음
    if (challenge.creatorId == currentUser.id) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('자신의 영상은 구독할 수 없습니다'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      return;
    }

    final isCurrentlySubscribed = challenge.isSubscribed;

    try {
      if (isCurrentlySubscribed) {
        await _subscriptionService.unsubscribe(challenge.creatorId!);
      } else {
        await _subscriptionService.subscribe(challenge.creatorId!);
      }

      setState(() {
        _displayedChallenges[_currentIndex].isSubscribed = !isCurrentlySubscribed;
        if (!isCurrentlySubscribed) {
          _displayedChallenges[_currentIndex].subscriberCount++;
        } else {
          _displayedChallenges[_currentIndex].subscriberCount = 
              (_displayedChallenges[_currentIndex].subscriberCount - 1).clamp(0, double.infinity).toInt();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlySubscribed ? '구독이 취소되었습니다' : '구독되었습니다'),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구독 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  void _handleComment() {
    if (_currentIndex >= _displayedChallenges.length) return;
    
    final challenge = _displayedChallenges[_currentIndex];
    
    // 상호작용 추적
    BehaviorTracker.trackInteraction(challenge.id, 'comment', true);
    
    // 댓글 시트 표시
    setState(() {
      _showCommentSheet = true;
    });
  }

  void _handleRemix() {
    if (_currentIndex >= _displayedChallenges.length) return;
    
    final challenge = _displayedChallenges[_currentIndex];
    
    // TODO: 리믹스 기능 구현 (같은 챌린지로 새 영상 업로드)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('리믹스 기능은 준비 중입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      // 전체화면 모드
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // 일반 모드
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _handleMoreOptions() {
    if (_currentIndex >= _displayedChallenges.length) return;
    
    final challenge = _displayedChallenges[_currentIndex];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: IconMapper.icon('flag', size: 24, color: Colors.white) ??
                  const Icon(Icons.flag_outlined, color: Colors.white),
              title: const Text(
                '신고하기',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('신고 기능은 준비 중입니다'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            ListTile(
              leading: IconMapper.icon('bookmark', size: 24, color: Colors.white) ??
                  const Icon(Icons.bookmark_border, color: Colors.white),
              title: const Text(
                '저장하기',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('저장 기능은 준비 중입니다'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            ListTile(
              leading: IconMapper.icon('userx', size: 24, color: Colors.white) ??
                  const Icon(Icons.person_remove_outlined, color: Colors.white),
              title: const Text(
                '이 크리에이터 숨기기',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('숨기기 기능은 준비 중입니다'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            SizedBox(height: AppTheme.spacing2),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int num) {
    if (num >= 10000) {
      return '${(num / 10000).toStringAsFixed(1)}만';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}천';
    }
    return num.toString();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('링크를 열 수 없습니다: $url'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_displayedChallenges.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: IconMapper.icon('chevronleft', size: 24, color: Colors.white) ??
                const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            '챌린지가 없습니다',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // TikTok 스타일 비디오 스크롤 (PageView)
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _displayedChallenges.length,
            itemBuilder: (context, index) {
              final challenge = _displayedChallenges[index];
              return _VideoPage(
                challenge: challenge,
                videoController: index < _videoControllers.length ? _videoControllers[index] : null,
                isPlaying: index == _currentIndex && _isPlaying,
                        isMuted: _isMuted,
                        onControllerReady: (controller) {
                  if (index < _videoControllers.length) {
                    _videoControllers[index] = controller;
                  }
                },
                onTap: () {
                  _togglePlayPause();
                },
              );
            },
          ),

          // 오른쪽 상호작용 버튼들
          if (_currentIndex < _displayedChallenges.length)
            Positioned(
              right: AppTheme.spacing4,
              bottom: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 좋아요 버튼
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _displayedChallenges[_currentIndex].isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: _displayedChallenges[_currentIndex].isLiked
                                ? AppTheme.urgentRed
                                : Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatNumber(_displayedChallenges[_currentIndex].likes),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  // 싫어요 버튼
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _handleDislike,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _displayedChallenges[_currentIndex].isDisliked
                                ? Colors.blue[300]!.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _displayedChallenges[_currentIndex].isDisliked
                                ? Icons.thumb_down
                                : Icons.thumb_down_outlined,
                            size: 20,
                            color: _displayedChallenges[_currentIndex].isDisliked
                                ? Colors.blue[300]
                                : Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      const Text(
                        '싫어요',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  // 댓글 버튼
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _handleComment,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconMapper.icon(
                            'messagecircle',
                            size: 20,
                            color: Colors.white,
                          ) ??
                              const Icon(
                                Icons.comment_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatNumber(_displayedChallenges[_currentIndex].comments),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  // 공유 버튼
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _handleShare,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconMapper.icon(
                            'share2',
                            size: 20,
                            color: Colors.white,
                          ) ??
                              const Icon(
                                Icons.share_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                        ),
                      ),
                      SizedBox(height: 4),
                      const Text(
                        '공유',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  // 리믹스 버튼
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _handleRemix,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconMapper.icon(
                            'rotateccw',
                            size: 20,
                            color: Colors.white,
                          ) ??
                              const Icon(
                                Icons.replay_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                        ),
                      ),
                      SizedBox(height: 4),
                      const Text(
                        '리믹스',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  // 프로필 이미지 (클릭 가능)
                  GestureDetector(
                    onTap: () {
                      // 크리에이터 페이지로 이동 (mock)
                      final creatorId = _displayedChallenges[_currentIndex].creatorId;
                      if (creatorId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeProfileScreen(userId: creatorId),
                          ),
                        );
                          } else {
                        // creatorId가 없으면 현재 사용자 프로필로 이동
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('크리에이터 정보를 불러올 수 없습니다'),
                            backgroundColor: AppTheme.urgentRed,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[700],
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                        child: Center(
                        child: Text(
                          _displayedChallenges[_currentIndex].creatorAvatar ?? '👤',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
              ),
            ),
                ],
          ),
            ),

          // 상단 컨트롤
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
            child: Container(
                padding: EdgeInsets.all(AppTheme.spacing4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                children: [
                    IconButton(
                      icon: IconMapper.icon('volumeX', size: 20, color: Colors.white) ??
                          Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                            size: 20,
                    color: Colors.white,
                          ),
                      onPressed: _toggleMute,
                    ),
                    IconButton(
                      icon: IconMapper.icon('maximize', size: 20, color: Colors.white) ??
                          const Icon(Icons.fullscreen, size: 20, color: Colors.white),
                      onPressed: _handleFullscreen,
                    ),
                    IconButton(
                      icon: IconMapper.icon('morevertical', size: 20, color: Colors.white) ??
                          const Icon(Icons.more_vert, size: 20, color: Colors.white),
                      onPressed: _handleMoreOptions,
                  ),
                ],
              ),
            ),
          ),
          ),

          // 상단 헤더
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacing4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                          icon: IconMapper.icon('chevronleft', size: 20, color: Colors.white) ??
                              const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        IconButton(
                              icon: IconMapper.icon('shoppingbag', size: 20, color: Colors.white) ??
                                  const Icon(Icons.shopping_bag, size: 20, color: Colors.white),
                          onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('준비 중'),
                                    content: const Text('스토어 기능은 준비 중입니다.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('확인'),
                                      ),
                                    ],
                                  ),
                                );
                          },
                        ),
                        IconButton(
                              icon: IconMapper.icon('bookopen', size: 20, color: Colors.white) ??
                                  const Icon(Icons.menu_book, size: 20, color: Colors.white),
                          onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const EducationScreen()),
                                );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                    SizedBox(height: AppTheme.spacing2),
                    // 피드 탭
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FeedTabButton(
                          label: '전체',
                          isSelected: _feedTabIndex == 0,
                          onTap: () => _switchFeedTab(0),
                        ),
                        SizedBox(width: AppTheme.spacing4),
                        _FeedTabButton(
                          label: '구독',
                          isSelected: _feedTabIndex == 1,
                          onTap: () => _switchFeedTab(1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 하단 정보 영역 (오른쪽 버튼과 겹치지 않도록 right 여백 추가)
          Positioned(
            left: 0,
            right: 70, // 오른쪽 상호작용 버튼 영역을 위한 여백
            bottom: 80,
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacing3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 크리에이터 정보
                  if (_currentIndex < _displayedChallenges.length) ...[
                    Row(
                      children: [
                        // 프로필 이미지 (클릭 가능)
                        GestureDetector(
                          onTap: () {
                            // 크리에이터 페이지로 이동 (mock)
                            final creatorId = _displayedChallenges[_currentIndex].creatorId;
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
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[700],
                            ),
                            child: Center(
                              child: Text(
                                _displayedChallenges[_currentIndex].creatorAvatar ?? '👤',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                children: [
                  Text(
                                    '@${_displayedChallenges[_currentIndex].creatorName}',
                    style: const TextStyle(
                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.spacing1),
                                  GestureDetector(
                                    onTap: _handleSubscribe,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacing1,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _displayedChallenges[_currentIndex].isSubscribed
                                            ? AppTheme.primaryPurple
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: _displayedChallenges[_currentIndex].isSubscribed
                                            ? null
                                            : Border.all(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        _displayedChallenges[_currentIndex].isSubscribed
                                            ? '구독 중'
                                            : '구독',
                                        style: TextStyle(
                                          color: _displayedChallenges[_currentIndex].isSubscribed
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                '구독자 ${_formatNumber(_displayedChallenges[_currentIndex].subscriberCount)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                  ),
                  SizedBox(height: AppTheme.spacing2),
                    // 제목 및 설명
                    Text(
                      _displayedChallenges[_currentIndex].title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing1),
                    Text(
                      _displayedChallenges[_currentIndex].description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 태그
                    if (_displayedChallenges[_currentIndex].tags != null &&
                        _displayedChallenges[_currentIndex].tags!.isNotEmpty) ...[
                      SizedBox(height: AppTheme.spacing1),
                      Wrap(
                        spacing: AppTheme.spacing1,
                        runSpacing: AppTheme.spacing1,
                        children: _displayedChallenges[_currentIndex].tags!.map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing1,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    // 제품/교육 태그 카드 (3번 사진 스타일)
                    if (_displayedChallenges[_currentIndex].productName != null ||
                        _displayedChallenges[_currentIndex].educationName != null) ...[
                      SizedBox(height: AppTheme.spacing2),
                      _ProductEducationCard(
                        challenge: _displayedChallenges[_currentIndex],
                        onTap: () {
                          final challenge = _displayedChallenges[_currentIndex];
                          if (challenge.taggedType == 'product' && challenge.productUrl != null) {
                            // 제품 링크로 이동
                            _launchUrl(challenge.productUrl!);
                          } else if (challenge.taggedType == 'education' && challenge.educationUrl != null) {
                            // 교육 링크로 이동
                            _launchUrl(challenge.educationUrl!);
                          }
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),

          // 음악 정보 (4번 사진 하단부 스타일)
          if (_currentIndex < _displayedChallenges.length &&
              (_displayedChallenges[_currentIndex].musicName != null ||
               _displayedChallenges[_currentIndex].musicArtist != null))
            Positioned(
              left: AppTheme.spacing4,
              bottom: AppTheme.spacing2,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing2,
                  vertical: AppTheme.spacing1,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconMapper.icon('music', size: 16, color: Colors.white) ??
                        const Icon(
                          Icons.music_note,
                          size: 16,
                          color: Colors.white,
                        ),
                    SizedBox(width: AppTheme.spacing1),
                    Text(
                      _displayedChallenges[_currentIndex].musicName != null &&
                              _displayedChallenges[_currentIndex].musicArtist != null
                          ? '${_displayedChallenges[_currentIndex].musicName} - ${_displayedChallenges[_currentIndex].musicArtist}'
                          : _displayedChallenges[_currentIndex].musicName ??
                              _displayedChallenges[_currentIndex].musicArtist ??
                              '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 댓글 시트 (하단에서 올라오는 모달)
          if (_showCommentSheet && _currentIndex < _displayedChallenges.length)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showCommentSheet = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.5, // 화면의 절반 높이
                    minChildSize: 0.3,
                    maxChildSize: 0.9,
                    builder: (context, scrollController) {
                      return GestureDetector(
                        onTap: () {}, // 시트 내부 탭 이벤트 전파 방지
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.95),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              // 드래그 핸들
                              Container(
                                margin: EdgeInsets.symmetric(vertical: AppTheme.spacing2),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // 헤더
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '댓글 ${_formatNumber(_displayedChallenges[_currentIndex].comments)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                                      onPressed: () {
                                        setState(() {
                                          _showCommentSheet = false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.grey[800], height: 1),
                              // 댓글 목록
                              Expanded(
                                child: _CommentSheetContent(
                                  challengeId: _displayedChallenges[_currentIndex].id,
                                  scrollController: scrollController,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          
          // 네비게이션 처리
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}

/// 댓글 시트 콘텐츠 위젯
class _CommentSheetContent extends StatefulWidget {
  final String challengeId;
  final ScrollController? scrollController;

  const _CommentSheetContent({
    required this.challengeId,
    this.scrollController,
  });

  @override
  State<_CommentSheetContent> createState() => _CommentSheetContentState();
}

class _CommentSheetContentState extends State<_CommentSheetContent> {
  final ChallengeService _challengeService = ChallengeService();
  final TextEditingController _commentController = TextEditingController();
  List<ChallengeComment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // API 호출하여 댓글 목록 가져오기
      final comments = await _challengeService.getChallengeComments(widget.challengeId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      print('댓글 로드 오류: ${appException.toString()}');
      // API 실패 시 빈 리스트로 설정
      setState(() {
        _comments = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_commentController.text.trim().isEmpty) return;

    final content = _commentController.text.trim();
    _commentController.clear();

    try {
      // API 호출하여 댓글 등록
      final newComment = await _challengeService.createChallengeComment(
        challengeId: widget.challengeId,
        content: content,
      );

      setState(() {
        _comments.insert(0, newComment);
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('댓글 등록 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      // 실패 시 입력 내용 복원
      _commentController.text = content;
    }
  }

  Future<void> _toggleLike(String commentId) async {
    try {
      // API 호출하여 댓글 좋아요/좋아요 취소
      await _challengeService.toggleCommentLike(widget.challengeId, commentId);

      setState(() {
        final comment = _comments.firstWhere((c) => c.id == commentId);
        comment.isLiked = !comment.isLiked;
        comment.likes += comment.isLiked ? 1 : -1;
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('좋아요 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 댓글 목록
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconMapper.icon('messagecircle', size: 48, color: Colors.grey) ??
                              const Icon(Icons.comment_outlined, size: 48, color: Colors.grey),
                          const SizedBox(height: AppTheme.spacing3),
                          const Text(
                            '댓글이 없습니다',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: widget.scrollController,
                      padding: EdgeInsets.all(AppTheme.spacing3),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return _CommentSheetItem(
                          comment: _comments[index],
                          onLike: () => _toggleLike(_comments[index].id),
                          formatTime: _formatTime,
                        );
                      },
                    ),
        ),
        // 댓글 입력 영역
        Container(
          padding: EdgeInsets.all(AppTheme.spacing3),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border(
              top: BorderSide(color: Colors.grey[800]!, width: 1),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[500]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing3,
                        vertical: AppTheme.spacing2,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppTheme.spacing2),
                IconButton(
                  icon: IconMapper.icon('send', size: 24, color: Colors.white) ??
                      const Icon(Icons.send, size: 24, color: Colors.white),
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentSheetItem extends StatelessWidget {
  final ChallengeComment comment;
  final VoidCallback onLike;
  final String Function(DateTime) formatTime;

  const _CommentSheetItem({
    required this.comment,
    required this.onLike,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[700],
            ),
            child: Center(
              child: Text(
                comment.userAvatar ?? '👤',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacing2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Text(
                      formatTime(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing1),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: AppTheme.spacing1),
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        comment.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: comment.isLiked ? AppTheme.urgentRed : Colors.grey[500],
                      ),
                      SizedBox(width: AppTheme.spacing1),
                      Text(
                        comment.likes.toString(),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  int likes;
  bool isLiked;
  final DateTime createdAt;

  _Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.likes = 0,
    this.isLiked = false,
    required this.createdAt,
  });
}

class _VideoPage extends StatefulWidget {
  final Challenge challenge;
  final VideoPlayerController? videoController;
  final bool isPlaying;
  final bool isMuted;
  final Function(VideoPlayerController) onControllerReady;
  final VoidCallback? onTap;

  const _VideoPage({
    required this.challenge,
    this.videoController,
    required this.isPlaying,
    required this.isMuted,
    required this.onControllerReady,
    this.onTap,
  });

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
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
  void didUpdateWidget(_VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoController != oldWidget.videoController) {
    _controller?.dispose();
      _controller = widget.videoController;
      _isInitialized = _controller?.value.isInitialized ?? false;
    }
    _updateVideoState();
  }

  Future<void> _initializeVideo() async {
    if (widget.challenge.videoUrl == null) return;

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.challenge.videoUrl!),
    );
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
    // 컨트롤러는 부모에서 관리하므로 여기서는 dispose하지 않음
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Stack(
          children: [
            _controller != null && _isInitialized
                ? AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
                  )
                : Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
            // 재생/일시정지 오버레이
            if (!widget.isPlaying)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconMapper.icon(
                      'play',
                      size: 40,
                      color: Colors.white,
                    ) ??
                        const Icon(
                          Icons.play_arrow,
                          size: 40,
                          color: Colors.white,
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

class _ControlButton extends StatelessWidget {
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing3),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconMapper.icon(icon, size: 24, color: color) ??
            Icon(Icons.play_arrow, size: 24, color: color),
      ),
    );
  }
}

/// 제품/교육 링크 카드 (3번 사진 스타일)
class _ProductEducationCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;

  const _ProductEducationCard({
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isProduct = challenge.taggedType == 'product';
    final name = isProduct ? challenge.productName : challenge.educationName;
    final thumbnailUrl = isProduct
        ? challenge.productThumbnailUrl
        : challenge.educationThumbnailUrl;

    if (name == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: AppTheme.spacing2),
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 버튼 영역 (파란색) - 이름보다 위에 위치
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing2,
                vertical: AppTheme.spacing2,
              ),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isProduct ? '지금 구매하기' : '교육 보러가기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing1),
                  // 외부 링크 아이콘
                  IconMapper.icon('external-link', size: 14, color: Colors.white) ??
                      const Icon(
                        Icons.open_in_new,
                        size: 14,
                        color: Colors.white,
                      ),
                ],
              ),
            ),
            // 하단 정보 영역 (다크 그레이)
            Container(
              padding: EdgeInsets.all(AppTheme.spacing2),
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  // 썸네일 이미지
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  isProduct ? Icons.shopping_bag : Icons.menu_book,
                                  color: Colors.white70,
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : Icon(
                            isProduct ? Icons.shopping_bag : Icons.menu_book,
                            color: Colors.white70,
                            size: 24,
                          ),
                  ),
                  SizedBox(width: AppTheme.spacing2),
                  // 제품/교육 이름
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String creatorName;
  final String? creatorId; // 크리에이터 ID (구독용)
  final String? creatorAvatar;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  bool isLiked;
  bool isDisliked;
  bool isSubscribed; // 구독 여부
  int subscriberCount; // 구독자 수
  final List<String>? tags;
  final String? productUrl;
  final String? productName;
  final String? productThumbnailUrl;
  final String? educationId;
  final String? educationName;
  final String? educationUrl;
  final String? educationThumbnailUrl;
  final String? taggedType; // 'product' | 'education'
  final String? musicName; // 음악 이름
  final String? musicArtist; // 음악 아티스트
  final DateTime createdAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorName,
    this.creatorId,
    this.creatorAvatar,
    this.videoUrl,
    this.thumbnailUrl,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    this.isLiked = false,
    this.isDisliked = false,
    this.isSubscribed = false,
    this.subscriberCount = 0,
    this.tags,
    this.productUrl,
    this.productName,
    this.productThumbnailUrl,
    this.educationId,
    this.educationName,
    this.educationUrl,
    this.educationThumbnailUrl,
    this.taggedType,
    this.musicName,
    this.musicArtist,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? '',
      creatorId: json['creatorId']?.toString(),
      creatorAvatar: json['creatorAvatar']?.toString(),
      videoUrl: json['videoUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      likes: _parseInt(json['likes']) ?? 0,
      comments: _parseInt(json['comments']) ?? 0,
      shares: _parseInt(json['shares']) ?? 0,
      views: _parseInt(json['views']) ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isDisliked: json['isDisliked'] as bool? ?? false,
      isSubscribed: json['isSubscribed'] as bool? ?? false,
      subscriberCount: _parseInt(json['subscriberCount']) ?? 0,
      tags: json['tags'] != null
          ? List<String>.from((json['tags'] as List).map((e) => e?.toString() ?? ''))
          : null,
      productUrl: json['productUrl']?.toString(),
      productName: json['productName']?.toString(),
      productThumbnailUrl: json['productThumbnailUrl']?.toString(),
      educationId: json['educationId']?.toString(),
      educationName: json['educationName']?.toString(),
      educationUrl: json['educationUrl']?.toString(),
      educationThumbnailUrl: json['educationThumbnailUrl']?.toString(),
      taggedType: json['taggedType']?.toString(),
      musicName: json['musicName']?.toString(),
      musicArtist: json['musicArtist']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is num) return value.toInt();
    return null;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

/// 피드 탭 버튼
class _FeedTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedTabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing1,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(isSelected ? 0.5 : 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
