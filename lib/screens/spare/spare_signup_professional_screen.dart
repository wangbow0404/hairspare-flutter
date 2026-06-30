import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/spare_signup_data.dart';
import '../../models/spare_subtype.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import '../../services/verification_service.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../widgets/spare_signup/spare_signup_region_picker.dart';
import '../../widgets/spare_signup/spare_signup_terms_card.dart';
import '../../widgets/spare_signup/spare_signup_ui_kit.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';

/// 스페어·디자이너 회원가입 폼.
class SpareSignupProfessionalScreen extends StatefulWidget {
  const SpareSignupProfessionalScreen({super.key});

  @override
  State<SpareSignupProfessionalScreen> createState() =>
      _SpareSignupProfessionalScreenState();
}

class _SpareSignupProfessionalScreenState
    extends State<SpareSignupProfessionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();
  final _verificationCodeController = TextEditingController();
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
  int _experienceYears = 0;
  final Set<String> _specialties = {};

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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _referralController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  String _normalizedPhone() =>
      _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

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

  void _showTermsPlaceholder(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title 내용은 준비 중입니다.')),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_regionSelected || _regionLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('활동 지역을 선택해 주세요.')),
      );
      return;
    }
    if (_specialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전문 분야를 1개 이상 선택해 주세요.')),
      );
      return;
    }
    if (!_allRequiredTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 약관에 동의해 주세요.')),
      );
      return;
    }
    if (kSignupPhoneVerificationEnabled && !_phoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('휴대폰 인증을 완료해 주세요.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final profile = ProfessionalSignupProfile(
      region: _regionLabel!,
      regionId: _districtId ?? _provinceId,
      experienceYears: _experienceYears,
      specialties: _specialties.toList(),
    );

    await auth.register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      role: UserRole.spare,
      spareSubtype: SpareSubtype.professional,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      name: _nameController.text.trim(),
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
      context.pushReplacement(AppRoutes.spareSignupSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SharedAppBar(title: '스페어·디자이너 가입'),
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
              subtitle: '미용 일자리를 찾고 있어요',
              headline: '전문가 정보를\n입력해주세요',
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
                        () => _obscurePasswordConfirm = !_obscurePasswordConfirm,
                      ),
                    ),
                    validator: (v) => v != _passwordController.text
                        ? '비밀번호가 일치하지 않습니다'
                        : null,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupLabeledField(
                    controller: _nameController,
                    label: '이름',
                    hint: '성함',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? '이름을 입력해 주세요'
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
                    hint: 'example@hairspare.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  SpareSignupLabeledField(
                    controller: _referralController,
                    label: '추천인 코드 (선택)',
                    hint: '코드를 입력하면 포인트가 지급됩니다',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),
            SpareSignupSectionCard(
              title: '전문가 프로필',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpareSignupRegionPicker(
                    provinceId: _provinceId,
                    districtId: _districtId,
                    compactRow: true,
                    label: '활동 가능 지역',
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
                  const SizedBox(height: AppTheme.spacing6),
                  SpareSignupExperienceSlider(
                    years: _experienceYears,
                    onChanged: (v) => setState(() => _experienceYears = v),
                  ),
                  const SizedBox(height: AppTheme.spacing6),
                  const Padding(
                    padding: EdgeInsets.only(left: AppTheme.spacing1),
                    child: Text(
                      '전문 분야 (중복 선택 가능)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  Wrap(
                    spacing: AppTheme.spacing2,
                    runSpacing: AppTheme.spacing2,
                    children: [
                      for (final s in ProfessionalSpecialtyOptions.all)
                        StitchFilterChip(
                          label: s,
                          isSelected: _specialties.contains(s),
                          onTap: () => setState(() {
                            if (!_specialties.add(s)) _specialties.remove(s);
                          }),
                        ),
                    ],
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
