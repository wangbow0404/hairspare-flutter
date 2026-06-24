import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/spare_designer_profile.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/energy_provider.dart';
import '../providers/schedule_provider.dart';
import '../services/auth_service.dart';
import '../services/spare_designer_profile_service.dart';
import '../utils/api_config.dart';
import '../utils/error_handler.dart';

/// 스페어 마이 탭: 초기 데이터 로드·프로필 이미지 업로드(목업 분기).
///
/// 스낵바는 [GlobalMessengerService] 전역 키로 표시 — UI 콜백 없음.
class SpareProfileViewModel extends ChangeNotifier {
  SpareProfileViewModel({
    required ImagePicker imagePicker,
    required AuthService authService,
    required AuthProvider authProvider,
    required EnergyProvider energyProvider,
    required ScheduleProvider scheduleProvider,
    SpareDesignerProfileService? designerProfileService,
  })  : _imagePicker = imagePicker,
        _authService = authService,
        _authProvider = authProvider,
        _energyProvider = energyProvider,
        _scheduleProvider = scheduleProvider,
        _designerProfileService =
            designerProfileService ?? sl<SpareDesignerProfileService>();

  final ImagePicker _imagePicker;
  final AuthService _authService;
  final AuthProvider _authProvider;
  final EnergyProvider _energyProvider;
  final ScheduleProvider _scheduleProvider;
  final SpareDesignerProfileService _designerProfileService;

  GlobalMessengerService get _messenger => sl<GlobalMessengerService>();

  bool _isUploadingAvatar = false;
  bool get isUploadingAvatar => _isUploadingAvatar;

  SpareDesignerProfile? designerProfile;
  bool isDesignerProfileLoading = false;

  /// 에너지 지갑·스케줄·디자이너 프로필을 병렬로 불러옵니다.
  Future<void> loadInitial() async {
    try {
      final userId = _authProvider.currentUser?.id;
      await Future.wait<void>([
        _energyProvider.loadWallet(),
        _scheduleProvider.loadSchedules(),
        if (userId != null) _loadDesignerProfile(userId),
      ]);
    } catch (e, st) {
      debugPrint('SpareProfileViewModel.loadInitial: $e\n$st');
      _messenger.showError('일부 정보를 불러오지 못했습니다.');
    }
  }

  Future<void> _loadDesignerProfile(String userId) async {
    isDesignerProfileLoading = true;
    notifyListeners();
    try {
      designerProfile = await _designerProfileService.getProfile(userId);
    } catch (e, st) {
      debugPrint('SpareProfileViewModel._loadDesignerProfile: $e\n$st');
    } finally {
      isDesignerProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshDesignerProfile() async {
    final userId = _authProvider.currentUser?.id;
    if (userId == null) return;
    await _loadDesignerProfile(userId);
  }

  /// 갤러리 또는 카메라에서 이미지를 선택해 업로드 후 프로필에 반영합니다.
  Future<void> pickAndUploadAvatar(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 88,
    );
    if (picked == null) return;

    final file = File(picked.path);
    final length = await file.length();
    if (length > 12 * 1024 * 1024) {
      _messenger.showError('이미지는 12MB 이하여야 합니다.');
      return;
    }

    _isUploadingAvatar = true;
    notifyListeners();

    try {
      final current = _authProvider.currentUser;
      if (current == null) {
        _messenger.showError('로그인이 필요합니다.');
        return;
      }

      if (ApiConfig.useMockData) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        final mockUrl =
            'https://picsum.photos/seed/${current.id}_${DateTime.now().millisecondsSinceEpoch}/300/300';
        final merged = User.fromJson({
          ...current.toJson(),
          'profileImage': mockUrl,
        });
        await _authProvider.setUser(merged);
        _messenger.showSuccess('프로필 사진이 변경되었습니다.');
        return;
      }

      final imageUrl = await _authService.uploadProfileImage(file);
      if (imageUrl.isEmpty) {
        _messenger.showError('이미지 URL을 받지 못했습니다.');
        return;
      }
      final updated = await _authService.updateProfile(profileImage: imageUrl);
      await _authProvider.setUser(updated);
      _messenger.showSuccess('프로필 사진이 변경되었습니다.');
    } catch (e, st) {
      debugPrint('SpareProfileViewModel.pickAndUploadAvatar: $e\n$st');
      final msg = ErrorHandler.handleException(e);
      _messenger.showError(ErrorHandler.getUserFriendlyMessage(msg));
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }
}
