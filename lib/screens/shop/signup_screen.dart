import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/shop_signup_data.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/verification_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/business_registration_validator.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../widgets/shop_signup/shop_signup_operator_section.dart';
import '../../widgets/spare_signup/spare_signup_region_picker.dart';
import '../../widgets/spare_signup/spare_signup_terms_card.dart';
import '../../widgets/spare_signup/spare_signup_ui_kit.dart';

/// 미용실(샵) 회원가입 — Stitch 카드 UI + SMS·운영유형·대리인.
class ShopSignupScreen extends StatefulWidget {
  const ShopSignupScreen({super.key});

  @override
  State<ShopSignupScreen> createState() => _ShopSignupScreenState();
}

class _ShopSignupScreenState extends State<ShopSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _salonNameController = TextEditingController();
  final _representativeNameController = TextEditingController();
  final _businessNumberController = TextEditingController();
  final _openDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();
  final _proxyNameController = TextEditingController();
  final _proxyRelationController = TextEditingController();
  final _proxyPhoneController = TextEditingController();
  final VerificationService _verificationService = VerificationService();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool _phoneVerified = false;
  bool _phoneCodeSent = false;
  bool _isPhoneVerifying = false;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _personalInfoProvisionAccepted = false;
  bool _ageAccepted = false;
  bool _marketingAccepted = false;

  String? _provinceId;
  String? _districtId;
  String? _regionLabel;
  ShopOperatorType _operatorType = ShopOperatorType.owner;

  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _businessLicenseBytes; // 사업자등록증 미리보기(웹/네이티브 공용)
  String? _businessLicenseName;

  static final _passwordSpecialCharPattern =
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]');

  bool get _allRequiredTermsAccepted =>
      _termsAccepted &&
      _privacyAccepted &&
      _personalInfoProvisionAccepted &&
      _ageAccepted;

  bool get _allTermsAccepted => _allRequiredTermsAccepted && _marketingAccepted;

  bool get _regionSelected {
    if (_provinceId == null) return false;
    final districts = RegionHelper.getDistrictsByProvince(_provinceId!);
    if (districts.isEmpty) return true;
    return _districtId != null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _salonNameController.dispose();
    _representativeNameController.dispose();
    _businessNumberController.dispose();
    _openDateController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    _proxyNameController.dispose();
    _proxyRelationController.dispose();
    _proxyPhoneController.dispose();
    super.dispose();
  }

  String _normalizedPhone() =>
      _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

  Future<void> _pickBusinessLicense() async {
    try {
      final x = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes(); // 웹·네이티브 모두 안전
      if (bytes.length > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('파일 크기는 5MB 이하여야 합니다.')),
        );
        return;
      }
      setState(() {
        _businessLicenseBytes = bytes;
        _businessLicenseName = x.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 실패: $e')),
      );
    }
  }

  void _showTermsPlaceholder(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title 내용은 준비 중입니다.')),
    );
  }

  Future<void> _sendPhoneVerification() async {
    final phone = _normalizedPhone();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 휴대폰 번호를 입력해 주세요.')),
      );
      return;
    }

    setState(() => _isPhoneVerifying = true);
    try {
      await _verificationService.sendVerificationCode(phone);
      if (!mounted) return;
      setState(() {
        _phoneCodeSent = true;
        _isPhoneVerifying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호가 발송되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPhoneVerifying = false);
      final ex = ErrorHandler.handleException(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '인증번호 발송 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<void> _verifyPhoneCode() async {
    final code = _verificationCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호를 입력해 주세요.')),
      );
      return;
    }

    setState(() => _isPhoneVerifying = true);
    try {
      final verified = await _verificationService.verifyCode(
        _normalizedPhone(),
        code,
      );
      if (!mounted) return;
      setState(() {
        _isPhoneVerifying = false;
        if (verified) _phoneVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            verified ? '휴대폰 인증이 완료되었습니다.' : '인증번호가 올바르지 않습니다.',
          ),
          backgroundColor:
              verified ? AppTheme.primaryGreen : AppTheme.urgentRed,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPhoneVerifying = false);
      final ex = ErrorHandler.handleException(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '인증 실패: ${ErrorHandler.getUserFriendlyMessage(ex)}',
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<String?> _uploadImageBytes(Uint8List bytes, String folder) async {
    try {
      final dio = sl<Dio>();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: 'upload.jpg'),
      });
      final response = await dio.post(
        '/api/auth/upload-image',
        data: formData,
        queryParameters: {'folder': folder},
      );
      final data = response.data['data'] ?? response.data;
      return data['url']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (kSignupPhoneVerificationEnabled && !_phoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('휴대폰 인증을 완료해 주세요.')),
      );
      return;
    }
    if (!_regionSelected || _regionLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('샵 위치를 선택해 주세요.')),
      );
      return;
    }
    if (_businessLicenseBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사업자등록증을 첨부해 주세요.')),
      );
      return;
    }
    if (!_allRequiredTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 약관에 동의해 주세요.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();

    // 사업자등록증 R2 업로드 (가입 전 선업로드)
    String? licenseUrl;
    if (_businessLicenseBytes != null) {
      licenseUrl = await _uploadImageBytes(_businessLicenseBytes!, 'shop-licenses');
      if (licenseUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사업자등록증 업로드 중 오류가 발생했습니다. 다시 시도해 주세요.')),
        );
        return;
      }
    }

    final isProxy = _operatorType == ShopOperatorType.proxy;
    final profile = ShopSignupProfile(
      salonName: _salonNameController.text.trim(),
      representativeName: _representativeNameController.text.trim(),
      region: _regionLabel!,
      regionId: _districtId ?? _provinceId,
      operatorType: _operatorType,
      businessNumber: BusinessRegistrationValidator.normalizeNumber(
        _businessNumberController.text,
      ),
      openDate: _openDateController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      businessLicenseUrl: licenseUrl,
      proxyName: isProxy ? _proxyNameController.text.trim() : null,
      proxyRelation: isProxy ? _proxyRelationController.text.trim() : null,
      proxyPhone: isProxy ? _proxyPhoneController.text.trim() : null,
    );

    await auth.register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      role: UserRole.shop,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      name: _salonNameController.text.trim(),
      phone: _phoneController.text.trim(),
      referralCode: _referralController.text.trim().isEmpty
          ? null
          : _referralController.text.trim(),
      profilePayload: profile.toJson(),
    );

    if (!mounted) return;
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }
    if (auth.isAuthenticated) {
      context.pushReplacement(AppRoutes.shopSignupSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '미용실 회원가입'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacing4,
            AppTheme.spacing6,
            AppTheme.spacing4,
            120,
          ),
          children: [
            const SpareSignupHeroHeader(
              subtitle: '미용실을 운영하고 있어요',
              headline: '샵 정보를\n입력해주세요',
            ),
            const SizedBox(height: AppTheme.spacing8),
            SpareSignupSectionCard(
              title: '계정 정보',
              child: Column(
                children: [
                  SpareSignupLabeledField(
                    controller: _usernameController,
                    label: '아이디',
                    hint: '아이디를 입력하세요',
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return '아이디를 입력해 주세요';
                      }
                      if (v.length < 4) {
                        return '아이디는 4자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupLabeledField(
                    controller: _passwordController,
                    label: '비밀번호',
                    hint: '비밀번호 (8자 이상, 특수문자 포함)',
                    obscureText: _obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.stitchTextSecondary,
                        size: 22,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return '비밀번호를 입력해 주세요';
                      }
                      if (v.length < 8) {
                        return '비밀번호는 8자 이상이어야 합니다';
                      }
                      if (!_passwordSpecialCharPattern.hasMatch(v)) {
                        return '특수문자를 포함해 주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupLabeledField(
                    controller: _passwordConfirmController,
                    label: '비밀번호 확인',
                    hint: '비밀번호를 한번 더 입력하세요',
                    obscureText: _obscurePasswordConfirm,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.stitchTextSecondary,
                        size: 22,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscurePasswordConfirm = !_obscurePasswordConfirm,
                      ),
                    ),
                    validator: (v) => v != _passwordController.text
                        ? '비밀번호가 일치하지 않습니다'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            SpareSignupSectionCard(
              title: '샵·운영자 정보',
              child: Column(
                children: [
                  SpareSignupLabeledField(
                    controller: _salonNameController,
                    label: '미용실 이름',
                    hint: '상호명을 입력하세요',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? '미용실 이름을 입력해 주세요'
                        : null,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupLabeledField(
                    controller: _representativeNameController,
                    label: '대표자명',
                    hint: '사업자등록증 대표자명',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? '대표자명을 입력해 주세요'
                        : null,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupPhoneVerificationField(
                    phoneController: _phoneController,
                    codeController: _verificationCodeController,
                    isVerified: _phoneVerified,
                    codeSent: _phoneCodeSent,
                    isLoading: _isPhoneVerifying,
                    onSendCode: _sendPhoneVerification,
                    onVerifyCode: _verifyPhoneCode,
                    phoneValidator: (v) => v == null || v.trim().isEmpty
                        ? '휴대폰 번호를 입력해 주세요'
                        : null,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupLabeledField(
                    controller: _emailController,
                    label: '이메일 주소',
                    hint: 'example@salon.co.kr',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupLabeledField(
                    controller: _referralController,
                    label: '추천인 코드 (선택)',
                    hint: '코드를 입력하면 포인트가 지급됩니다',
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  SpareSignupRegionPicker(
                    provinceId: _provinceId,
                    districtId: _districtId,
                    compactRow: true,
                    label: '샵 위치',
                    onChanged: ({
                      required provinceId,
                      required districtId,
                      required displayLabel,
                    }) {
                      setState(() {
                        _provinceId = provinceId;
                        _districtId = districtId;
                        _regionLabel =
                            displayLabel.isNotEmpty ? displayLabel : null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            ShopSignupOperatorSection(
              operatorType: _operatorType,
              onOperatorTypeChanged: (v) => setState(() => _operatorType = v),
              proxyNameController: _proxyNameController,
              proxyRelationController: _proxyRelationController,
              proxyPhoneController: _proxyPhoneController,
            ),
            const SizedBox(height: AppTheme.spacing8),
            SpareSignupSectionCard(
              title: '사업자 정보',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpareSignupLabeledField(
                    controller: _businessNumberController,
                    label: '사업자등록번호',
                    hint: '숫자 10자리 (예: 1234567890)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: BusinessRegistrationValidator.formValidator,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupLabeledField(
                    controller: _openDateController,
                    label: '개업일자',
                    hint: '8자리 (예: 20200115)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    validator: (v) {
                      final digits =
                          (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.length != 8) {
                        return '개업일자 8자리를 입력해 주세요 (예: 20200115)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    '입력하신 사업자등록번호·대표자명·개업일자로 국세청 진위확인을 자동 진행합니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  _BusinessLicenseAttachment(
                    bytes: _businessLicenseBytes,
                    fileName: _businessLicenseName,
                    onPick: _pickBusinessLicense,
                    onRemove: () => setState(() {
                      _businessLicenseBytes = null;
                      _businessLicenseName = null;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            SpareSignupTermsCard(
              allRequiredAccepted: _allTermsAccepted,
              termsAccepted: _termsAccepted,
              privacyAccepted: _privacyAccepted,
              personalInfoProvisionAccepted: _personalInfoProvisionAccepted,
              ageAccepted: _ageAccepted,
              marketingAccepted: _marketingAccepted,
              onToggleAllRequired: () => setState(() {
                final next = !_allTermsAccepted;
                _termsAccepted = next;
                _privacyAccepted = next;
                _personalInfoProvisionAccepted = next;
                _ageAccepted = next;
                _marketingAccepted = next;
              }),
              onTermsChanged: (v) => setState(() => _termsAccepted = v),
              onPrivacyChanged: (v) => setState(() => _privacyAccepted = v),
              onPersonalInfoProvisionChanged: (v) =>
                  setState(() => _personalInfoProvisionAccepted = v),
              onAgeChanged: (v) => setState(() => _ageAccepted = v),
              onMarketingChanged: (v) => setState(() => _marketingAccepted = v),
              onViewTerms: _showTermsPlaceholder,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, auth, _) => SpareSignupBlurredSubmitBar(
          label: '회원가입',
          isLoading: auth.isLoading,
          onPressed: _submit,
        ),
      ),
    );
  }
}

/// 사업자등록증 이미지 첨부 UI (웹·네이티브 공용 — 바이트 미리보기).
class _BusinessLicenseAttachment extends StatelessWidget {
  const _BusinessLicenseAttachment({
    required this.bytes,
    required this.fileName,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? bytes;
  final String? fileName;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (bytes == null) {
      return InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderGray300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.upload_file, color: AppTheme.textSecondary),
              const SizedBox(height: 6),
              Text(
                '사업자등록증 첨부 (필수)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes!,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.check_circle,
                color: AppTheme.primaryGreen, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                fileName ?? '첨부됨',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
            TextButton(onPressed: onRemove, child: const Text('삭제')),
            TextButton(onPressed: onPick, child: const Text('변경')),
          ],
        ),
      ],
    );
  }
}
