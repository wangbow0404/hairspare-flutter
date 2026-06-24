import 'package:flutter/foundation.dart';

import '../core/di/service_locator.dart';
import '../mocks/mock_auth_data.dart';
import '../models/hair_model.dart';
import '../models/match_profile.dart';
import '../models/model_discovery_item.dart';
import '../models/model_match_preference.dart';
import '../providers/auth_provider.dart';
import '../services/matching_service.dart';
import '../services/model_match_service.dart';
import '../services/portfolio_service.dart';
import '../services/spare_designer_profile_service.dart';
import '../utils/error_handler.dart';

/// 매칭 시도 결과.
enum MatchAttemptStatus { likeSent, limitReached, error }

class MatchAttemptResult {
  final MatchAttemptStatus status;
  final HairModel? model;
  final String? message;

  const MatchAttemptResult(
    this.status, {
    this.model,
    this.message,
  });
}

/// 모델 매칭 후보·스와이프·하루 한도 상태.
class ModelMatchViewModel extends ChangeNotifier {
  ModelMatchViewModel({
    required ModelMatchService matchService,
    required MatchingService matchingService,
    SpareDesignerProfileService? designerProfileService,
  })  : _matchService = matchService,
        _matchingService = matchingService,
        _designerProfileService =
            designerProfileService ?? sl<SpareDesignerProfileService>();

  final ModelMatchService _matchService;
  final MatchingService _matchingService;
  final SpareDesignerProfileService _designerProfileService;

  ModelMatchPreference _preference = const ModelMatchPreference();
  ModelMatchPreference get preference => _preference;

  List<HairModel> _candidates = [];
  List<HairModel> get candidates => _candidates;

  List<ModelDiscoveryItem> _discoveryItems = [];
  List<ModelDiscoveryItem> get discoveryItems => _discoveryItems;

  bool _isDiscoveryLoading = false;
  bool get isDiscoveryLoading => _isDiscoveryLoading;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _remainingMatches = 0;
  int get remainingMatches => _remainingMatches;
  int get dailyLimit => _matchService.dailyMatchLimit;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  HairModel? get currentModel =>
      _currentIndex < _candidates.length ? _candidates[_currentIndex] : null;

  bool get hasMore => _currentIndex < _candidates.length;

  void setPreference(ModelMatchPreference pref) {
    _preference = pref;
  }

  Future<void> loadCandidates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _matchService.getCandidates(_preference),
        _matchService.remainingMatchesToday(),
      ]);
      _candidates = results[0] as List<HairModel>;
      _remainingMatches = results[1] as int;
      _currentIndex = 0;
      await loadDiscoveryModels();
    } catch (e) {
      _error = ErrorHandler.handleException(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDiscoveryModels() async {
    _isDiscoveryLoading = true;
    notifyListeners();
    try {
      final excludeIds = _candidates.map((m) => m.id).toSet();
      _discoveryItems = await _matchService.getDiscoveryModels(
        excludeIds: excludeIds,
      );
    } catch (_) {
      _discoveryItems = const [];
    } finally {
      _isDiscoveryLoading = false;
      notifyListeners();
    }
  }

  /// X(스킵) — 다음 카드로.
  void skip() {
    if (!hasMore) return;
    _currentIndex += 1;
    notifyListeners();
  }

  /// 하트 — pending 관심 전송 (즉시 채팅 생성 없음).
  Future<MatchAttemptResult> like() async {
    final model = currentModel;
    if (model == null) {
      return const MatchAttemptResult(
        MatchAttemptStatus.error,
        message: '더 이상 추천할 모델이 없습니다.',
      );
    }

    if (_remainingMatches <= 0) {
      return MatchAttemptResult(MatchAttemptStatus.limitReached, model: model);
    }

    try {
      final consumed = await _matchService.consumeMatch();
      if (!consumed) {
        _remainingMatches = 0;
        notifyListeners();
        return MatchAttemptResult(MatchAttemptStatus.limitReached, model: model);
      }

      final user = sl<AuthProvider>().currentUser ?? MockAuthData.spareUser();
      final portfolio = await sl<PortfolioService>().getImageUrls(
        ownerId: user.id,
        ownerRole: user.role.name,
      );
      final designerProfile =
          await _designerProfileService.getProfile(user.id);
      final intro = designerProfile.matchingIntro.trim().isNotEmpty
          ? designerProfile.matchingIntro.trim()
          : '${user.name ?? user.username} ${designerProfile.roleLabel}';
      final fromProfile = MatchProfile(
        id: user.id,
        role: 'spare',
        displayName: user.name ?? user.username,
        subtitle: designerProfile.matchSubtitle,
        intro: intro,
        tags: designerProfile.matchTags,
        region: designerProfile.regionLabel,
        treatment: designerProfile.specialties.isNotEmpty
            ? designerProfile.specialties.first
            : designerProfile.roleLabel,
        portfolioImages: portfolio,
        avatarUrl: portfolio.isNotEmpty
            ? portfolio.first
            : user.profileImage,
      );

      await _matchingService.sendLikeToModel(
        fromProfile: fromProfile,
        targetModel: model,
      );

      _remainingMatches = await _matchService.remainingMatchesToday();
      _currentIndex += 1;
      notifyListeners();

      return MatchAttemptResult(MatchAttemptStatus.likeSent, model: model);
    } catch (e) {
      final message = ErrorHandler.handleException(e).message;
      return MatchAttemptResult(
        MatchAttemptStatus.error,
        model: model,
        message: message,
      );
    }
  }
}
