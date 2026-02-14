import 'package:flutter/foundation.dart';
import '../models/point_transaction.dart';
import '../services/point_service.dart';
import '../utils/error_handler.dart';

class PointProvider with ChangeNotifier {
  final PointService _pointService = PointService();
  int _balance = 0;
  List<PointTransaction> _history = [];
  bool _isLoading = false;
  bool _isHistoryLoading = false;
  String? _error;

  int get balance => _balance;
  List<PointTransaction> get history => _history;
  bool get isLoading => _isLoading;
  bool get isHistoryLoading => _isHistoryLoading;
  String? get error => _error;

  Future<void> loadBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _balance = await _pointService.getBalance();
      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _balance = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory({String? type}) async {
    _isHistoryLoading = true;
    _error = null;
    notifyListeners();

    try {
      _history = await _pointService.getHistory(type: type);
      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _history = [];
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeMission(String missionId, int points) async {
    try {
      final success = await _pointService.completeMission(missionId);
      if (success) {
        _balance += points;
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
