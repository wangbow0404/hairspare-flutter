import 'package:flutter/foundation.dart';
import '../services/energy_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class EnergyProvider with ChangeNotifier {
  final EnergyService _energyService = EnergyService();
  Map<String, dynamic>? _wallet;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get wallet => _wallet;
  int get balance => _wallet?['balance'] is int
      ? _wallet!['balance']
      : int.tryParse(_wallet?['balance']?.toString() ?? '0') ?? 0;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 에너지 지갑 로드
  Future<void> loadWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallet = await _energyService.getWallet();
      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _wallet = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 에너지 구매
  Future<bool> purchaseEnergy(int amount) async {
    try {
      await _energyService.purchaseEnergy(amount);
      // 지갑 정보 다시 로드
      await loadWallet();
      return true;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
