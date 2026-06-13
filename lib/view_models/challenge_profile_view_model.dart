import 'package:flutter/foundation.dart';

import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/services/global_messenger_service.dart';
import 'package:hairspare/models/challenge_profile.dart';
import 'package:hairspare/models/user.dart';
import 'package:hairspare/services/challenge_service.dart';
import 'package:hairspare/services/subscription_service.dart';
import 'package:hairspare/utils/error_handler.dart';

/// 챌린지 프로필 화면 상태 (구독·프로필·인기 영상).
class ChallengeProfileViewModel extends ChangeNotifier {
  ChallengeProfileViewModel({
    required this.targetUserId,
    required this.isOwnProfile,
    required this.canEdit,
  });

  final String targetUserId;
  final bool isOwnProfile;
  final bool canEdit;

  final ChallengeService _challengeService = ChallengeService();
  final SubscriptionService _subscriptionService = sl<SubscriptionService>();
  final GlobalMessengerService _messenger = sl<GlobalMessengerService>();

  ChallengeProfile? profile;
  List<MyChallenge> featuredVideos = [];
  bool isLoading = true;
  bool isFeaturedLoading = true;
  bool isSubscribeLoading = false;

  /// 타인 프로필일 때만 구독 UI 표시 (위치는 화면에서 [ChallengeProfileSubscribeBar] 배치).
  bool get showSubscribeButton => !isOwnProfile;

  String get videosTabLabel => isOwnProfile ? '내 영상' : '영상';

  Future<void> loadAll() async {
    await Future.wait([loadProfile(), loadFeaturedVideos()]);
  }

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    try {
      var loaded = await _challengeService.getChallengeProfile(targetUserId);
      if (!isOwnProfile) {
        final subscribed =
            await _subscriptionService.checkSubscriptionStatus(targetUserId);
        loaded = loaded.copyWith(isSubscribed: subscribed);
      }
      profile = loaded;
    } catch (e) {
      debugPrint('프로필 로드 오류: $e');
      profile = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFeaturedVideos() async {
    isFeaturedLoading = true;
    notifyListeners();

    try {
      featuredVideos =
          await _challengeService.getCreatorFeaturedVideos(targetUserId);
    } catch (e) {
      debugPrint('인기 영상 로드 오류: $e');
      featuredVideos = [];
    } finally {
      isFeaturedLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSubscribe(User? currentUser) async {
    if (profile == null || isOwnProfile) return;

    if (currentUser == null) {
      _messenger.showError('로그인이 필요합니다');
      return;
    }
    if (currentUser.id == targetUserId) {
      _messenger.showError('자신의 채널은 구독할 수 없습니다');
      return;
    }

    final wasSubscribed = profile!.isSubscribed;
    isSubscribeLoading = true;
    notifyListeners();

    try {
      if (wasSubscribed) {
        await _subscriptionService.unsubscribe(targetUserId);
      } else {
        await _subscriptionService.subscribe(targetUserId);
      }

      profile = profile!.copyWith(
        isSubscribed: !wasSubscribed,
        subscriberCount: wasSubscribed
            ? (profile!.subscriberCount - 1).clamp(0, 999999999)
            : profile!.subscriberCount + 1,
      );
      _messenger.showSuccess(
        wasSubscribed ? '구독이 취소되었습니다' : '구독되었습니다',
      );
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _messenger.showError(
        '구독 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}',
      );
    } finally {
      isSubscribeLoading = false;
      notifyListeners();
    }
  }
}
