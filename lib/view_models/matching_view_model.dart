import 'package:flutter/foundation.dart';

import '../models/match_like.dart';
import '../models/model_home_data.dart';
import '../services/matching_service.dart';
import '../utils/error_handler.dart';

/// 모델 매칭 — 받은 관심·매칭 목록 상태.
class MatchingViewModel extends ChangeNotifier {
  MatchingViewModel(this._matchingService);

  final MatchingService _matchingService;

  List<MatchLike> _receivedLikes = [];
  List<MatchLike> _matches = [];
  bool _isLoading = false;
  String? _error;
  String _modelUserId = '';

  List<MatchLike> get receivedLikes => _receivedLikes;
  List<MatchLike> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingCount => _receivedLikes.length;

  /// 오늘(기기 로컬 날짜 기준) 받은 관심 수 — 홈 화면 "오늘 받은 관심" 카드용.
  int get todayPendingCount {
    final now = DateTime.now();
    return _receivedLikes.where((like) {
      final local = like.createdAt.toLocal();
      return local.year == now.year &&
          local.month == now.month &&
          local.day == now.day;
    }).length;
  }

  /// 홈 받은 관심 카드용 — VM 단일 소스.
  List<ModelHomeInterest> get pendingHomeInterests => _receivedLikes
      .map(
        (like) => ModelHomeInterest(
          id: like.id,
          designerName: like.fromProfile.displayName,
          treatment: like.fromProfile.treatment ?? '',
          region: like.fromProfile.region ?? '',
          avatarUrl: like.fromProfile.avatarUrl,
          isPrimaryCta: true,
        ),
      )
      .toList();

  /// Selector 키 — 목록 변경 시에만 리빌드.
  String get pendingInterestKey =>
      _receivedLikes.map((like) => like.id).join(',');

  Future<void> load({required String modelUserId}) async {
    _modelUserId = modelUserId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _receivedLikes =
          await _matchingService.getReceivedLikes(modelUserId: modelUserId);
      _matches = await _matchingService.getMatches(modelUserId: modelUserId);
      _error = null;
    } catch (e) {
      _error = ErrorHandler.handleException(e).message;
      _receivedLikes = [];
      _matches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_modelUserId.isEmpty) return;
    await load(modelUserId: _modelUserId);
  }

  Future<MatchLike?> findLike(String likeId) =>
      _matchingService.getLikeById(likeId);

  /// 수락 → chatId 반환.
  Future<String> acceptLike(String likeId) async {
    final chatId = await _matchingService.acceptLike(likeId);
    await refresh();
    return chatId;
  }

  Future<void> declineLike(String likeId) async {
    await _matchingService.declineLike(likeId);
    await refresh();
  }

  /// 이미 로드된 목록에서 like 조회 — 프로필 화면 즉시 표시용.
  MatchLike? findLikeLocal(String likeId) {
    for (final like in _receivedLikes) {
      if (like.id == likeId) return like;
    }
    for (final like in _matches) {
      if (like.id == likeId) return like;
    }
    return null;
  }
}
