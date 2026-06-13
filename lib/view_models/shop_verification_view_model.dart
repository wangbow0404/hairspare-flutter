import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/services/global_messenger_service.dart';
import 'package:hairspare/models/business_registration_ocr_result.dart';
import 'package:hairspare/models/business_registration_validation.dart';
import 'package:hairspare/models/shop_business_verification_submit.dart';
import 'package:hairspare/services/verification_service.dart';
import 'package:hairspare/utils/business_registration_validator.dart';
import 'package:hairspare/utils/error_handler.dart';

/// 사업자 인증 UI 분기 (`not_started` → 미인증 폼, `pending` → 심사 중, `rejected` → 사유, `approved` → 완료).
enum ShopBusinessVerificationUiPhase {
  notStarted,
  pending,
  approved,
  rejected;

  static ShopBusinessVerificationUiPhase fromStatus(String s) {
    switch (s) {
      case 'pending':
        return pending;
      case 'approved':
        return approved;
      case 'rejected':
        return rejected;
      default:
        return notStarted;
    }
  }
}

/// 샵 인증 화면: 사업자 서류·본인인증·대리인 신청.
class ShopVerificationViewModel extends ChangeNotifier {
  ShopVerificationViewModel({
    VerificationService? verificationService,
    ImagePicker? imagePicker,
  })  : _verificationService = verificationService ?? sl<VerificationService>(),
        _imagePicker = imagePicker ?? sl<ImagePicker>() {
    businessNumberController.addListener(_onFormFieldChanged);
    businessNameController.addListener(_onFormFieldChanged);
    representativeNameController.addListener(_onFormFieldChanged);
    businessTypeController.addListener(_onFormFieldChanged);
    businessCategoryController.addListener(_onFormFieldChanged);
    addressController.addListener(_onFormFieldChanged);
  }

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final VerificationService _verificationService;
  final ImagePicker _imagePicker;

  final GlobalKey<FormState> businessFormKey = GlobalKey<FormState>();

  final TextEditingController businessNumberController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController representativeNameController = TextEditingController();
  final TextEditingController businessTypeController = TextEditingController();
  final TextEditingController businessCategoryController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();

  final TextEditingController proxyNameController = TextEditingController();
  final TextEditingController proxyRelationController = TextEditingController();
  final TextEditingController proxyPhoneController = TextEditingController();

  ShopBusinessVerificationUiPhase businessPhase = ShopBusinessVerificationUiPhase.notStarted;
  String? rejectionReason;
  String? verifiedAt;
  String? snapshotBusinessNumber;
  String? snapshotBusinessName;
  String? snapshotRepresentativeName;
  String? snapshotBusinessType;
  String? snapshotBusinessCategory;
  String? snapshotAddress;

  bool isLoadingInitial = true;
  bool isSubmittingBusiness = false;
  bool isScanningRegistration = false;

  File? businessRegistrationFile;
  File? idCardFile;

  BusinessRegistrationOcrResult? ocrResult;
  BusinessRegistrationValidation? registrationValidation;
  BusinessRegistrationValidation? numberFormatValidation;

  bool identityVerified = false;
  String? identityName;
  String? identityPhone;
  bool phoneVerificationSent = false;
  int verificationTimer = 0;
  bool isVerifyingPhone = false;
  Timer? _countdownTimer;

  String proxyStatus = 'not_started';
  bool isSubmittingProxy = false;

  int get currentStepIndex {
    if (businessPhase == ShopBusinessVerificationUiPhase.approved ||
        businessPhase == ShopBusinessVerificationUiPhase.pending) {
      if (identityVerified) {
        return proxyStatus == 'approved' ? 3 : 2;
      }
      return 1;
    }
    return 0;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    businessNumberController.removeListener(_onFormFieldChanged);
    businessNameController.removeListener(_onFormFieldChanged);
    representativeNameController.removeListener(_onFormFieldChanged);
    businessTypeController.removeListener(_onFormFieldChanged);
    businessCategoryController.removeListener(_onFormFieldChanged);
    addressController.removeListener(_onFormFieldChanged);
    businessNumberController.dispose();
    businessNameController.dispose();
    representativeNameController.dispose();
    businessTypeController.dispose();
    businessCategoryController.dispose();
    addressController.dispose();
    phoneController.dispose();
    verificationCodeController.dispose();
    proxyNameController.dispose();
    proxyRelationController.dispose();
    proxyPhoneController.dispose();
    super.dispose();
  }

  void _onFormFieldChanged() {
    _refreshClientValidation();
  }

  void _refreshClientValidation() {
    numberFormatValidation = BusinessRegistrationValidator.validateNumberFormat(
      businessNumberController.text,
    );
    if (ocrResult != null) {
      registrationValidation = BusinessRegistrationValidator.buildClientValidation(
        businessNumber: businessNumberController.text,
        ocr: ocrResult,
        businessName: businessNameController.text,
        representativeName: representativeNameController.text,
        businessType: businessTypeController.text,
        businessCategory: businessCategoryController.text,
        address: addressController.text,
      );
    } else {
      registrationValidation = numberFormatValidation;
    }
    notifyListeners();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    verificationTimer = 300;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (verificationTimer <= 0) {
        t.cancel();
        notifyListeners();
        return;
      }
      verificationTimer--;
      notifyListeners();
    });
  }

  Future<void> loadInitial() async {
    isLoadingInitial = true;
    notifyListeners();

    try {
      await Future.wait<void>([
        _loadBusinessSnapshot(),
        _loadIdentityStatus(),
      ]);
    } finally {
      isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> _loadBusinessSnapshot() async {
    final snap = await _verificationService.getShopBusinessVerification();
    businessPhase = ShopBusinessVerificationUiPhase.fromStatus(snap.status);
    rejectionReason = snap.rejectionReason;
    verifiedAt = snap.verifiedAt;
    snapshotBusinessNumber = snap.businessNumber;
    snapshotBusinessName = snap.businessName;
    snapshotRepresentativeName = snap.representativeName;
    snapshotBusinessType = snap.businessType;
    snapshotBusinessCategory = snap.businessCategory;
    snapshotAddress = snap.address;
  }

  Future<void> _loadIdentityStatus() async {
    try {
      final identityStatus = await _verificationService.getVerificationStatus();
      identityVerified = identityStatus['identityVerified'] == true;
      identityName = identityStatus['identityName']?.toString();
      identityPhone = identityStatus['identityPhone']?.toString();
    } catch (_) {}
  }

  Future<void> pickBusinessRegistration(ImageSource source) async {
    try {
      final x = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (x == null) return;
      final f = File(x.path);
      final len = await f.length();
      if (len > 5 * 1024 * 1024) {
        _m.showError('파일 크기는 5MB 이하여야 합니다');
        return;
      }
      businessRegistrationFile = f;
      ocrResult = null;
      registrationValidation = null;
      notifyListeners();
      await _scanBusinessRegistration(f);
    } catch (e) {
      _m.showError('이미지 선택 실패: $e');
    }
  }

  Future<void> _scanBusinessRegistration(File file) async {
    isScanningRegistration = true;
    notifyListeners();
    try {
      final result = await _verificationService.scanBusinessRegistration(file);
      ocrResult = result;
      _applyOcrAutoFill(result);
      _refreshClientValidation();
      _m.showInfo('사업자등록증을 인식했습니다. 내용을 확인해 주세요.');
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '인식 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}. 직접 입력해 주세요.',
      );
    } finally {
      isScanningRegistration = false;
      notifyListeners();
    }
  }

  void _applyOcrAutoFill(BusinessRegistrationOcrResult result) {
    void fill(TextEditingController c, String? value, double? confidence) {
      if (value == null || value.isEmpty) return;
      if (confidence != null &&
          confidence < BusinessRegistrationOcrResult.autoFillConfidenceThreshold) {
        return;
      }
      c.text = value;
    }

    fill(
      businessNumberController,
      result.businessNumber != null
          ? BusinessRegistrationValidator.formatDisplay(result.businessNumber!)
          : null,
      result.businessNumberConfidence,
    );
    fill(businessNameController, result.businessName, result.businessNameConfidence);
    fill(
      representativeNameController,
      result.representativeName,
      result.representativeNameConfidence,
    );
    fill(businessTypeController, result.businessType, result.businessTypeConfidence);
    fill(
      businessCategoryController,
      result.businessCategory,
      result.businessCategoryConfidence,
    );
    fill(addressController, result.address, result.addressConfidence);
  }

  Future<void> pickIdCard(ImageSource source) async {
    try {
      final x = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (x == null) return;
      final f = File(x.path);
      final len = await f.length();
      if (len > 5 * 1024 * 1024) {
        _m.showError('파일 크기는 5MB 이하여야 합니다');
        return;
      }
      idCardFile = f;
      notifyListeners();
    } catch (e) {
      _m.showError('이미지 선택 실패: $e');
    }
  }

  void clearBusinessRegistration() {
    businessRegistrationFile = null;
    ocrResult = null;
    registrationValidation = null;
    notifyListeners();
  }

  void clearIdCard() {
    idCardFile = null;
    notifyListeners();
  }

  Future<void> sendVerificationCode() async {
    final phone = phoneController.text.replaceAll('-', '').trim();
    if (phone.length < 10) {
      _m.showError('올바른 휴대폰 번호를 입력해주세요');
      return;
    }
    isVerifyingPhone = true;
    notifyListeners();
    try {
      await _verificationService.sendVerificationCode(phone);
      phoneVerificationSent = true;
      _startCountdown();
      isVerifyingPhone = false;
      notifyListeners();
      _m.showSuccess('인증번호가 발송되었습니다');
    } catch (e) {
      isVerifyingPhone = false;
      notifyListeners();
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '인증번호 발송 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    }
  }

  Future<void> verifyCode() async {
    final code = verificationCodeController.text.trim();
    if (code.isEmpty) {
      _m.showError('인증번호를 입력해주세요');
      return;
    }
    isVerifyingPhone = true;
    notifyListeners();
    try {
      final verified = await _verificationService.verifyCode(
        phoneController.text.replaceAll('-', ''),
        code,
      );
      isVerifyingPhone = false;
      _countdownTimer?.cancel();
      verificationTimer = 0;
      if (verified) {
        identityVerified = true;
        identityPhone = phoneController.text;
      }
      notifyListeners();
      if (verified) {
        _m.showSuccess('본인인증이 완료되었습니다');
      } else {
        _m.showError('인증번호가 올바르지 않습니다');
      }
    } catch (e) {
      isVerifyingPhone = false;
      notifyListeners();
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '인증 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    }
  }

  Future<void> submitBusinessVerification() async {
    final form = businessFormKey.currentState;
    if (form == null || !form.validate()) return;
    if (businessRegistrationFile == null) {
      _m.showError('사업자등록증 사진을 등록해주세요');
      return;
    }

    final numberCheck = BusinessRegistrationValidator.validateNumberFormat(
      businessNumberController.text,
    );
    if (!numberCheck.isNumberFormatValid) {
      _m.showError(numberCheck.numberFormatMessage ?? '사업자등록번호를 확인해 주세요');
      return;
    }

    isSubmittingBusiness = true;
    notifyListeners();

    try {
      final normalizedNumber = BusinessRegistrationValidator.formatDisplay(
        businessNumberController.text,
      );

      // Phase 2: 서버 NTS 검증 — mock에서는 즉시 success.
      await _verificationService.validateBusinessRegistration(
        businessNumber: normalizedNumber,
        businessName: businessNameController.text.trim(),
        representativeName: representativeNameController.text.trim(),
        businessType: businessTypeController.text.trim(),
        businessCategory: businessCategoryController.text.trim(),
        address: addressController.text.trim(),
        ocrRequestId: ocrResult?.requestId,
      );

      final submit = ShopBusinessVerificationSubmit(
        businessNumber: normalizedNumber,
        businessName: businessNameController.text.trim(),
        representativeName: representativeNameController.text.trim(),
        businessType: businessTypeController.text.trim(),
        businessCategory: businessCategoryController.text.trim(),
        address: addressController.text.trim(),
        businessRegistrationLocalPath: businessRegistrationFile!.path,
        idCardLocalPath: idCardFile?.path,
        ocrRequestId: ocrResult?.requestId,
      );
      await _verificationService.submitShopBusinessVerification(submit);
      businessPhase = ShopBusinessVerificationUiPhase.pending;
      _m.showSuccess(
        '사업자 인증 신청이 완료되었습니다. 검토 후 결과를 알려드리겠습니다.',
      );
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '인증 신청 중 오류가 발생했습니다: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    } finally {
      isSubmittingBusiness = false;
      notifyListeners();
    }
  }

  Future<void> submitProxyVerification() async {
    if (proxyNameController.text.trim().isEmpty ||
        proxyRelationController.text.trim().isEmpty ||
        proxyPhoneController.text.trim().isEmpty) {
      _m.showError('모든 필드를 입력해주세요');
      return;
    }
    isSubmittingProxy = true;
    notifyListeners();
    try {
      await _verificationService.submitShopProxyVerification(
        name: proxyNameController.text.trim(),
        relation: proxyRelationController.text.trim(),
        phone: proxyPhoneController.text.trim(),
      );
      proxyStatus = 'pending';
      _m.showSuccess(
        '대리인 인증 신청이 완료되었습니다. 검토 후 결과를 알려드리겠습니다.',
      );
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(
        '신청 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
      );
    } finally {
      isSubmittingProxy = false;
      notifyListeners();
    }
  }
}
