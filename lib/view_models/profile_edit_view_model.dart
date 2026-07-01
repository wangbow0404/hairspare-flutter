import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/spare_designer_profile.dart';
import '../models/spare_signup_data.dart';
import '../services/auth_service.dart';
import '../services/spare_designer_profile_service.dart';
import '../services/verification_service.dart';
import '../providers/auth_provider.dart';
import '../utils/error_handler.dart';

/// 스페어 프로필 수정 — 기본 정보 + 매칭·전문가 프로필.
class ProfileEditViewModel extends ChangeNotifier {
  ProfileEditViewModel({
    AuthService? authService,
    SpareDesignerProfileService? designerProfileService,
    VerificationService? verificationService,
    AuthProvider? authProvider,
  })  : _authService = authService ?? sl<AuthService>(),
        _designerProfileService =
            designerProfileService ?? sl<SpareDesignerProfileService>(),
        _verificationService =
            verificationService ?? sl<VerificationService>(),
        _authProvider = authProvider ?? sl<AuthProvider>();

  final AuthService _authService;
  final SpareDesignerProfileService _designerProfileService;
  final VerificationService _verificationService;
  final AuthProvider _authProvider;

  GlobalMessengerService get _messenger => sl<GlobalMessengerService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final birthYearController = TextEditingController();
  final matchingIntroController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  bool isIdentityVerified = false;
  String? gender;

  int experienceYears = 0;
  Set<String> specialties = {};
  String? provinceId;
  String? districtId;
  String regionLabel = '';
  bool matchingVisible = true;
  String role = 'designer';
  int? hourlyRate;

  File? pendingAvatarFile;
  String? existingAvatarUrl;
  String? userId;
  DateTime? selectedBirthDate;

  Future<void> loadInitial() async {
    isLoading = true;
    notifyListeners();
    try {
      final user =
          _authProvider.currentUser ?? await _authService.getCurrentUser();
      if (user != null) {
        userId = user.id;
        nameController.text = user.name ?? '';
        emailController.text = user.email ?? '';
        phoneController.text = user.phone ?? '';
        existingAvatarUrl = user.profileImage;
      }

      try {
        final verificationStatus =
            await _verificationService.getVerificationStatus();
        if (verificationStatus['identityVerified'] == true) {
          isIdentityVerified = true;
          final verifiedName = verificationStatus['identityName']?.toString();
          final verifiedPhone = verificationStatus['identityPhone']?.toString();
          if (verifiedName != null) nameController.text = verifiedName;
          if (verifiedPhone != null) phoneController.text = verifiedPhone;
          final birth = verificationStatus['identityBirthDate']?.toString();
          if (birth != null && birth.length >= 4) {
            final cleanBirth = birth.replaceAll('-', '');
            birthYearController.text = cleanBirth.substring(0, 4);
            final year = int.tryParse(cleanBirth.substring(0, 4));
            final month = cleanBirth.length >= 6 ? int.tryParse(cleanBirth.substring(4, 6)) : null;
            final day = cleanBirth.length >= 8 ? int.tryParse(cleanBirth.substring(6, 8)) : null;
            if (year != null) {
              selectedBirthDate = DateTime(year, month ?? 1, day ?? 1);
            }
          }
          final verifiedGender =
              verificationStatus['identityGender']?.toString();
          if (verifiedGender == 'M' || verifiedGender == '남성') {
            gender = 'M';
          } else if (verifiedGender == 'F' || verifiedGender == '여성') {
            gender = 'F';
          }
        }
      } catch (_) {}

      if (user != null) {
        final designer = await _designerProfileService.getProfile(user.id);
        matchingIntroController.text = designer.matchingIntro;
        experienceYears = designer.experienceYears;
        specialties = designer.specialties.toSet();
        provinceId = designer.provinceId;
        districtId = designer.districtId;
        regionLabel = designer.regionLabel;
        matchingVisible = designer.matchingVisible;
        role = designer.role;
        hourlyRate = designer.hourlyRate;
      }
    } catch (e) {
      _messenger.showError('프로필 정보를 불러오지 못했습니다.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setBirthDate(DateTime date) {
    selectedBirthDate = date;
    birthYearController.text = date.year.toString();
    notifyListeners();
  }

  void setGender(String? value) {
    gender = value;
    notifyListeners();
  }

  void setExperienceYears(int value) {
    experienceYears = value;
    notifyListeners();
  }

  void toggleSpecialty(String specialty) {
    if (!specialties.add(specialty)) {
      specialties.remove(specialty);
    }
    notifyListeners();
  }

  void setRegion({
    required String? province,
    required String? district,
    required String label,
  }) {
    provinceId = province;
    districtId = district;
    regionLabel = label;
    notifyListeners();
  }

  void setMatchingVisible(bool value) {
    matchingVisible = value;
    notifyListeners();
  }

  void setRole(String value) {
    role = value;
    notifyListeners();
  }

  Future<void> pickAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 88,
    );
    if (picked == null) return;
    pendingAvatarFile = File(picked.path);
    notifyListeners();
  }

  String? validateForSave() {
    if (nameController.text.trim().isEmpty) {
      return '이름을 입력해 주세요.';
    }
    if (specialties.isEmpty) return '전문 분야를 1개 이상 선택해 주세요.';
    if (regionLabel.trim().isEmpty) return '활동 지역을 선택해 주세요.';
    if (matchingIntroController.text.trim().length > 80) {
      return '매칭 소개는 80자 이내로 입력해 주세요.';
    }
    if (birthYearController.text.trim().isNotEmpty) {
      final year = int.tryParse(birthYearController.text.trim());
      if (year == null || year < 1950 || year > DateTime.now().year) {
        return '올바른 출생년도를 입력해 주세요.';
      }
    }
    return null;
  }

  Future<bool> save() async {
    final validationError = validateForSave();
    if (validationError != null) {
      _messenger.showError(validationError);
      return false;
    }

    final user = _authProvider.currentUser;
    if (user == null) {
      _messenger.showError('로그인이 필요합니다.');
      return false;
    }

    isSaving = true;
    notifyListeners();

    try {
      int? parsedBirthYear;
      if (birthYearController.text.trim().isNotEmpty) {
        parsedBirthYear = int.parse(birthYearController.text.trim());
      }

      String? profileImageUrl;
      if (pendingAvatarFile != null) {
        profileImageUrl =
            await _authService.uploadProfileImage(pendingAvatarFile!);
      }

      final updatedUser = await _authService.updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        phone: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        birthYear: parsedBirthYear,
        gender: gender,
        profileImage: profileImageUrl,
      );
      await _authProvider.setUser(updatedUser);

      final designerProfile = SpareDesignerProfile(
        matchingIntro: matchingIntroController.text.trim(),
        specialties: specialties.toList(),
        experienceYears: experienceYears,
        regionLabel: regionLabel,
        provinceId: provinceId,
        districtId: districtId,
        hourlyRate: hourlyRate,
        matchingVisible: matchingVisible,
        role: role,
      );
      await _designerProfileService.saveProfile(user.id, designerProfile);

      _messenger.showSuccess('프로필이 저장되었습니다.');
      return true;
    } catch (e) {
      final msg = ErrorHandler.handleException(e);
      _messenger.showError(ErrorHandler.getUserFriendlyMessage(msg));
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  SpareDesignerProfile get currentDesignerProfile => SpareDesignerProfile(
        matchingIntro: matchingIntroController.text.trim(),
        specialties: specialties.toList(),
        experienceYears: experienceYears,
        regionLabel: regionLabel,
        provinceId: provinceId,
        districtId: districtId,
        hourlyRate: hourlyRate,
        matchingVisible: matchingVisible,
        role: role,
      );

  List<String> get specialtyOptions => ProfessionalSpecialtyOptions.all;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthYearController.dispose();
    matchingIntroController.dispose();
    super.dispose();
  }
}
