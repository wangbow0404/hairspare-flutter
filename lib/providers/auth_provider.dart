import 'package:flutter/foundation.dart';
import '../models/login_portal.dart';
import '../models/spare_subtype.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/admin_realtime_service.dart';
import '../utils/error_handler.dart';
class AuthProvider with ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;
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
    LoginPortal? portal,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(
        username: username,
        password: password,
        portal: portal,
      );
      _error = null;
      if (_currentUser?.role == UserRole.admin) {
        AdminRealtimeService.instance.reconnect();
      }
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
    SpareSubtype? spareSubtype,
    String? email,
    String? name,
    String? phone,
    String? referralCode,
    Map<String, dynamic>? profilePayload,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.register(
        username: username,
        password: password,
        role: role,
        spareSubtype: spareSubtype,
        email: email,
        name: name,
        phone: phone,
        referralCode: referralCode,
        profilePayload: profilePayload,
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
