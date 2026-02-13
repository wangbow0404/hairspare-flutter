import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_exception.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> login({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(
        username: username,
        password: password,
        role: role,
      );
      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String username,
    required String password,
    required UserRole role,
    String? email,
    String? name,
    String? phone,
    String? referralCode,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        username: username,
        password: password,
        role: role,
        email: email,
        name: name,
        phone: phone,
        referralCode: referralCode,
      );
      _error = null;
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _error = ErrorHandler.getUserFriendlyMessage(appException);
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuth() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> setUser(User user) async {
    _currentUser = user;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
