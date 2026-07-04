import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/challenge_feed.dart';
import '../models/user.dart';
import '../services/challenge_service.dart';
import '../services/subscription_service.dart';
import '../utils/behavior_tracker.dart';
import '../utils/count_format.dart';
import '../utils/error_handler.dart';

/// 챌린지 피드 화면의 데이터·탭·상호작용 상태 (비디오 컨트롤러는 화면에서 관리).
class ChallengeViewModel extends ChangeNotifier {
  ChallengeViewModel({
    ChallengeService? challengeService,
    SubscriptionService? subscriptionService,
  }) : _challengeService = challengeService ?? sl<ChallengeService>(),
       _subscriptionService = subscriptionService ?? sl<SubscriptionService>();

  final ChallengeService _challengeService;
  final SubscriptionService _subscriptionService;

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  List<Challenge> challenges = [];
  List<Challenge> displayedChallenges = [];
  List<Challenge> subscribedChallenges = [];
  bool isLoading = true;
  int feedTabIndex = 0;
  int currentIndex = 0;
  bool isPlaying = true;
  bool isMuted = true;
  bool isSnapping = false;
  final Set<String> viewedChallengeIds = {};
  bool isFullscreen = false;
  bool showCommentSheet = false;

  /// 피드 탭 전환·목록 교체 시 비디오 전체 재바인딩용 토큰.
  int feedSwitchToken = 0;

  /// 프로필에서 진입 시 해당 크리에이터 영상만 먼저 재생.
  String? focusCreatorId;
  List<Challenge> _creatorFeedOrder = [];
  int _creatorFeedCursor = 0;
  List<Challenge> recommendationChallenges = [];
  bool _creatorQueueExhausted = false;
  bool _isCreatorProfileFeed = false;

  void loadInitial() {
    _isCreatorProfileFeed = false;
    focusCreatorId = null;
    loadChallengesInternal();
  }

  /// 프로필 · 인기영상 · 영상 탭에서 재생 시 호출.
  Future<void> loadCreatorProfileFeed({
    required String creatorId,
    required String initialVideoId,
  }) async {
    _isCreatorProfileFeed = true;
    focusCreatorId = creatorId;
    isLoading = true;
    feedTabIndex = 0;
    currentIndex = 0;
    viewedChallengeIds.clear();
    feedSwitchToken++;
    notifyListeners();

    try {
      creatorChallenges = await _challengeService.getCreatorChallengeFeed(
        creatorId,
      );
      final referenceTags = creatorChallenges
          .expand((c) => c.tags ?? const <String>[])
          .toSet()
          .toList();
      recommendationChallenges =
          await _challengeService.getSimilarChallenges(
        excludeCreatorId: creatorId,
        referenceTags: referenceTags.isEmpty ? null : referenceTags,
      );
      _bootstrapCreatorProfileFeed(initialVideoId);
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      debugPrint('크리에이터 피드 로드 오류: $appException');
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
      creatorChallenges = [];
      challenges = [];
      _creatorQueueExhausted = true;
      loadInitialChallenges();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Challenge> creatorChallenges = [];

  void _bootstrapCreatorProfileFeed(String initialVideoId) {
    viewedChallengeIds.clear();
    displayedChallenges = [];
    _creatorFeedCursor = 0;
    _creatorQueueExhausted = false;

    if (creatorChallenges.isEmpty) {
      challenges = recommendationChallenges;
      _creatorQueueExhausted = true;
      loadInitialChallenges();
      return;
    }

    Challenge? tapped;
    final rest = <Challenge>[];
    for (final c in creatorChallenges) {
      if (c.id == initialVideoId) {
        tapped = c;
      } else {
        rest.add(c);
      }
    }
    _creatorFeedOrder = [
      if (tapped != null) tapped,
      ...rest,
    ];
    if (_creatorFeedOrder.isEmpty) {
      _creatorFeedOrder = List<Challenge>.from(creatorChallenges);
    }

    final initialCount = min(4, _creatorFeedOrder.length);
    displayedChallenges = _creatorFeedOrder.take(initialCount).toList();
    _creatorFeedCursor = displayedChallenges.length;
    _creatorQueueExhausted = _creatorFeedCursor >= _creatorFeedOrder.length;
    viewedChallengeIds.addAll(displayedChallenges.map((c) => c.id));
    challenges = recommendationChallenges;
  }

  Future<void> loadChallengesInternal() async {
    _isCreatorProfileFeed = false;
    focusCreatorId = null;
    isLoading = true;
    notifyListeners();

    try {
      challenges = await _challengeService.getSimilarChallenges();
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      debugPrint('챌린지 피드 로드 오류: $appException');
      _m.showError(ErrorHandler.getUserFriendlyMessage(appException));
      challenges = [];
    }
    isLoading = false;
    loadInitialChallenges();
    notifyListeners();
  }

  Future<void> loadSubscribedChallenges() async {
    try {
      final list = await _challengeService.getSubscribedChallenges();
      subscribedChallenges = list;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      debugPrint('구독 피드 로드 오류: ${appException.toString()}');
      subscribedChallenges = [];
    }
    notifyListeners();
  }

  Future<void> switchFeedTab(int index) async {
    if (feedTabIndex == index) return;

    feedTabIndex = index;
    currentIndex = 0;
    viewedChallengeIds.clear();
    feedSwitchToken++;

    if (index == 0) {
      await loadChallengesInternal();
    } else {
      await loadSubscribedChallenges();
      if (subscribedChallenges.isEmpty) {
        displayedChallenges = [];
      } else {
        challenges = subscribedChallenges;
        loadInitialChallenges();
      }
    }
    notifyListeners();
  }

  void loadInitialChallenges() {
    final initialChallenges = <Challenge>[];
    final excludeIds = <String>[];

    for (int i = 0; i < 4 && i < challenges.length; i++) {
      final challenge = _getRandomChallenge(excludeIds);
      if (challenge != null) {
        initialChallenges.add(challenge);
        excludeIds.add(challenge.id);
        viewedChallengeIds.add(challenge.id);
      }
    }

    if (initialChallenges.isEmpty && challenges.isNotEmpty) {
      initialChallenges.add(challenges[0]);
      viewedChallengeIds.add(challenges[0].id);
    }

    displayedChallenges = initialChallenges;
    notifyListeners();
  }

  Challenge? _getRandomChallenge(List<String> excludeIds) {
    final available = challenges
        .where((c) => !excludeIds.contains(c.id))
        .toList();
    if (available.isEmpty) {
      viewedChallengeIds.clear();
      return challenges.isNotEmpty ? challenges[0] : null;
    }
    return available[Random().nextInt(available.length)];
  }

  void loadNextChallenge() {
    if (_isCreatorProfileFeed && !_creatorQueueExhausted) {
      if (_creatorFeedCursor < _creatorFeedOrder.length) {
        final next = _creatorFeedOrder[_creatorFeedCursor++];
        if (_creatorFeedCursor >= _creatorFeedOrder.length) {
          _creatorQueueExhausted = true;
        }
        displayedChallenges = [...displayedChallenges, next];
        viewedChallengeIds.add(next.id);
        notifyListeners();
        return;
      }
      _creatorQueueExhausted = true;
    }

    final pool = _isCreatorProfileFeed && _creatorQueueExhausted
        ? recommendationChallenges
        : challenges;
    final excludeIds = viewedChallengeIds.toList();
    final available = pool.where((c) => !excludeIds.contains(c.id)).toList();
    if (available.isEmpty) {
      if (pool.isEmpty) return;
      viewedChallengeIds.clear();
      final next = pool[Random().nextInt(pool.length)];
      displayedChallenges = [...displayedChallenges, next];
      viewedChallengeIds.add(next.id);
      notifyListeners();
      return;
    }

    final next = available[Random().nextInt(available.length)];
    displayedChallenges = [...displayedChallenges, next];
    viewedChallengeIds.add(next.id);
    notifyListeners();
  }

  void markPageChangeStart(int index) {
    isSnapping = true;
    currentIndex = index;
    notifyListeners();
  }

  void markPageChangeEndSoon() {
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      isSnapping = false;
      notifyListeners();
    });
  }

  void togglePlayPause() {
    isPlaying = !isPlaying;
    notifyListeners();
  }

  void toggleMute() {
    isMuted = !isMuted;
    notifyListeners();
  }

  void toggleFullscreen() {
    isFullscreen = !isFullscreen;
    notifyListeners();
  }

  void setShowCommentSheet(bool value) {
    showCommentSheet = value;
    notifyListeners();
  }

  void toggleLike() {
    if (currentIndex >= displayedChallenges.length) return;

    final challenge = displayedChallenges[currentIndex];
    final newIsLiked = !challenge.isLiked;

    if (newIsLiked && challenge.isDisliked) {
      displayedChallenges[currentIndex].isDisliked = false;
    }

    BehaviorTracker.trackInteraction(challenge.id, 'like', newIsLiked);
    displayedChallenges[currentIndex].isLiked = newIsLiked;
    notifyListeners();
  }

  Future<void> handleShare() async {
    if (currentIndex >= displayedChallenges.length) return;

    final challenge = displayedChallenges[currentIndex];
    BehaviorTracker.trackInteraction(challenge.id, 'share', true);

    try {
      await Share.share(
        '${challenge.title}\n${challenge.description}',
        subject: challenge.title,
      );
    } catch (e) {
      _m.showError('공유 실패: $e');
    }
  }

  Future<void> handleDislike() async {
    if (currentIndex >= displayedChallenges.length) return;

    final challenge = displayedChallenges[currentIndex];
    final newIsDisliked = !challenge.isDisliked;

    if (newIsDisliked && challenge.isLiked) {
      displayedChallenges[currentIndex].isLiked = false;
    }

    displayedChallenges[currentIndex].isDisliked = newIsDisliked;
    notifyListeners();

    try {
      await _challengeService.toggleChallengeDislike(challenge.id);
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      displayedChallenges[currentIndex].isDisliked = !newIsDisliked;
      if (newIsDisliked && challenge.isLiked) {
        displayedChallenges[currentIndex].isLiked = true;
      }
      notifyListeners();
      _m.showError(
        '싫어요 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}',
      );
    }
  }

  Future<void> handleSubscribe(User? currentUser) async {
    if (currentIndex >= displayedChallenges.length) return;

    final challenge = displayedChallenges[currentIndex];
    if (challenge.creatorId == null) return;

    if (currentUser == null) {
      _m.showError('로그인이 필요합니다');
      return;
    }

    if (challenge.creatorId == currentUser.id) {
      _m.showError('자신의 영상은 구독할 수 없습니다');
      return;
    }

    final isCurrentlySubscribed = challenge.isSubscribed;

    try {
      if (isCurrentlySubscribed) {
        await _subscriptionService.unsubscribe(challenge.creatorId!);
      } else {
        await _subscriptionService.subscribe(challenge.creatorId!);
      }

      displayedChallenges[currentIndex].isSubscribed = !isCurrentlySubscribed;
      if (!isCurrentlySubscribed) {
        displayedChallenges[currentIndex].subscriberCount++;
      } else {
        displayedChallenges[currentIndex].subscriberCount =
            (displayedChallenges[currentIndex].subscriberCount - 1)
                .clamp(0, double.infinity)
                .toInt();
      }
      notifyListeners();

      _m.showSuccess(isCurrentlySubscribed ? '구독이 취소되었습니다' : '구독되었습니다');
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _m.showError(
        '구독 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}',
      );
    }
  }

  void handleCommentOpen() {
    if (currentIndex >= displayedChallenges.length) return;
    BehaviorTracker.trackInteraction(
      displayedChallenges[currentIndex].id,
      'comment',
      true,
    );
    showCommentSheet = true;
    notifyListeners();
  }

  void handleRemix() {
    _m.showInfo('리믹스 기능은 준비 중입니다');
  }

  static String formatCount(int n) => CountFormat.compact(n);
}
