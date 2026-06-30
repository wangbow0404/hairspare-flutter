import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/shop_signup_data.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/verification_service.dart';
import '../../theme/app_theme.dart';
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
    if (!_allRequiredTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 약관에 동의해 주세요.')),
      );
      return;
    }

    final isProxy = _operatorType == ShopOperatorType.proxy;
    final profile = ShopSignupProfile(
      salonName: _salonNameController.text.trim(),
      representativeName: _representativeNameController.text.trim(),
      region: _regionLabel!,
      regionId: _districtId ?? _provinceId,
      operatorType: _operatorType,
      proxyName: isProxy ? _proxyNameController.text.trim() : null,
      proxyRelation: isProxy ? _proxyRelationController.text.trim() : null,
      proxyPhone: isProxy ? _proxyPhoneController.text.trim() : null,
    );

    final auth = context.read<AuthProvider>();
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
