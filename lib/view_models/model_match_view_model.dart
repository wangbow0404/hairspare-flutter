import 'dart:async';

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
  })  : _matchService = matchService,
        _matchingService = matchingService;

  final ModelMatchService _matchService;
  final MatchingService _matchingService;

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

  /// 백그라운드로 보낸 하트가 실패했을 때 화면에 알려주기 위한 콜백
  /// (스와이프 자체는 이미 끝난 뒤라 되돌리지 않고 안내만 한다).
  void Function(String message)? onBackgroundLikeFailed;

  /// 하트 — pending 관심 전송 (즉시 채팅 생성 없음).
  ///
  /// 응답을 기다리지 않고 즉시 다음 카드로 넘어가는 낙관적(optimistic)
  /// 업데이트를 쓴다 — 실제 전송은 백그라운드에서 처리되고, 실패 시에만
  /// [onBackgroundLikeFailed]로 알린다.
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

    _remainingMatches -= 1;
    _currentIndex += 1;
    notifyListeners();

    unawaited(_sendLikeInBackground(model));

    return MatchAttemptResult(MatchAttemptStatus.likeSent, model: model);
  }

  Future<void> _sendLikeInBackground(HairModel model) async {
    try {
      final user = sl<AuthProvider>().currentUser ?? MockAuthData.spareUser();
      // fromProfile은 서버가 실제로 쓰지 않고(targetModelId만 전송됨) 서버가
      // 직접 User/SpareExtProfile을 조회해 구성한다.
      final fromProfile = MatchProfile(
        id: user.id,
        role: 'spare',
        displayName: user.name ?? user.username,
        subtitle: '',
      );

      final like = await _matchingService.sendLikeToModel(
        fromProfile: fromProfile,
        targetModel: model,
      );

      // 서버가 응답에 실어준 실제 잔여 횟수로 맞춰준다(레이스 컨디션 보정).
      if (like.remainingQuota != null && like.remainingQuota != _remainingMatches) {
        _remainingMatches = like.remainingQuota!;
        notifyListeners();
      }
    } catch (e) {
      // 전송 실패 — 이미 다음 카드로 넘어간 뒤라 스와이프를 되돌리진 않고,
      // 소모한 횟수만 복구하고 사용자에게 알린다.
      _remainingMatches += 1;
      notifyListeners();
      final message = ErrorHandler.handleException(e).message;
      onBackgroundLikeFailed?.call(message);
    }
  }
}
