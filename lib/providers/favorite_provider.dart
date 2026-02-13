import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/favorite_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  List<Job> _favorites = [];
  Set<String> _favoriteJobIds = {};
  bool _isLoading = false;
  String? _error;

  List<Job> get favorites => _favorites;
  Set<String> get favoriteJobIds => _favoriteJobIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 특정 공고가 찜되어 있는지 확인
  bool isFavorite(String jobId) {
    return _favoriteJobIds.contains(jobId);
  }

  /// 찜 목록 로드
  Future<void> loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favorites = await _favoriteService.getFavorites();
      _favoriteJobIds = _favorites.map((job) => job.id).toSet();
      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _favorites = [];
      _favoriteJobIds = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 찜 추가
  Future<bool> addFavorite(String jobId) async {
    try {
      await _favoriteService.addFavorite(jobId);
      _favoriteJobIds.add(jobId);
      // 찜 목록 다시 로드하여 최신 정보 가져오기
      await loadFavorites();
      notifyListeners();
      return true;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      notifyListeners();
      return false;
    }
  }

  /// 찜 삭제
  Future<bool> removeFavorite(String jobId) async {
    try {
      await _favoriteService.removeFavorite(jobId);
      _favoriteJobIds.remove(jobId);
      _favorites.removeWhere((job) => job.id == jobId);
      notifyListeners();
      return true;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      notifyListeners();
      return false;
    }
  }

  /// 찜 토글
  Future<bool> toggleFavorite(String jobId) async {
    if (isFavorite(jobId)) {
      return await removeFavorite(jobId);
    } else {
      return await addFavorite(jobId);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
