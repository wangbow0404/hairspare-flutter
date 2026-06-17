import 'package:flutter/foundation.dart';

import '../core/di/service_locator.dart';
import '../mocks/mock_auth_data.dart';
import '../models/hair_model.dart';
import '../models/model_match_preference.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';
import '../services/model_match_service.dart';
import '../utils/error_handler.dart';

/// 매칭 시도 결과.
enum MatchAttemptStatus { matched, limitReached, error }

class MatchAttemptResult {
  final MatchAttemptStatus status;
  final String? chatId;
  final HairModel? model;
  final String? message;

  const MatchAttemptResult(
    this.status, {
    this.chatId,
    this.model,
    this.message,
  });
}

/// 모델 매칭 후보·스와이프·하루 한도 상태.
class ModelMatchViewModel extends ChangeNotifier {
  ModelMatchViewModel({
    required ModelMatchService matchService,
    required ChatService chatService,
  })  : _matchService = matchService,
        _chatService = chatService;

  final ModelMatchService _matchService;
  final ChatService _chatService;

  ModelMatchPreference _preference = const ModelMatchPreference();
  ModelMatchPreference get preference => _preference;

  List<HairModel> _candidates = [];
  List<HairModel> get candidates => _candidates;

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
    } catch (e) {
      _error = ErrorHandler.handleException(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// X(스킵) — 다음 카드로.
  void skip() {
    if (!hasMore) return;
    _currentIndex += 1;
    notifyListeners();
  }

  /// 하트 — 한도 확인 후 채팅방 생성. 결과 반환.
  Future<MatchAttemptResult> like() async {
    final model = currentModel;
    if (model == null) {
      return const MatchAttemptResult(MatchAttemptStatus.error,
          message: '더 이상 추천할 모델이 없습니다.');
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
      final chatId = await _chatService.ensureChatForModel(
        modelId: model.id,
        modelName: model.name,
        spareId: user.id,
        spareName: user.name ?? user.username,
      );

      _remainingMatches = await _matchService.remainingMatchesToday();
      _currentIndex += 1;

      try {
        await sl<ChatProvider>().refreshChats(viewerRole: 'spare');
      } catch (_) {
        // 채팅 목록 갱신 실패는 무시 (다음 진입 시 갱신).
      }

      notifyListeners();
      return MatchAttemptResult(
        MatchAttemptStatus.matched,
        chatId: chatId,
        model: model,
      );
    } catch (e) {
      final message = ErrorHandler.handleException(e).message;
      return MatchAttemptResult(MatchAttemptStatus.error,
          model: model, message: message);
    }
  }
}
