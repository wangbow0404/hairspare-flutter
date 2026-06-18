import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_routes.dart';
import '../../models/spare_signup_data.dart';
import '../../models/spare_subtype.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/region_helper.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../widgets/spare_signup/spare_signup_region_picker.dart';
import '../../widgets/spare_signup/spare_signup_terms_section.dart';
import '../../widgets/spare_signup/spare_signup_text_field.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/stitch/stitch_sticky_bottom_bar.dart';

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
  final _hourlyRateController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _personalInfoProvisionAccepted = false;
  bool _ageAccepted = false;

  String? _provinceId;
  String? _districtId;
  String? _regionLabel;
  int _experienceYears = 0;
  final Set<String> _specialties = {};

  bool get _allTermsAccepted =>
      _termsAccepted &&
      _privacyAccepted &&
      _personalInfoProvisionAccepted &&
      _ageAccepted;

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
    _hourlyRateController.dispose();
    super.dispose();
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
    if (!_allTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 약관에 동의해 주세요.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final hourlyText = _hourlyRateController.text.trim();
    final profile = ProfessionalSignupProfile(
      region: _regionLabel!,
      regionId: _districtId ?? _provinceId,
      experienceYears: _experienceYears,
      specialties: _specialties.toList(),
      hourlyRate: hourlyText.isEmpty ? null : int.tryParse(hourlyText),
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
            AppTheme.spacing6,
            AppTheme.spacing4,
            AppTheme.spacing6,
            AppTheme.spacing6,
          ),
          children: [
            const Text(
              '미용 일자리를 찾고 있어요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.stitchPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing6),
            _sectionTitle('계정 정보'),
            SpareSignupTextField(
              controller: _usernameController,
              label: '아이디 *',
              hint: '4자 이상',
              prefixIcon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.isEmpty) return '아이디를 입력해 주세요';
                if (v.length < 4) return '아이디는 4자 이상이어야 합니다';
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupTextField(
              controller: _passwordController,
              label: '비밀번호 *',
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return '비밀번호를 입력해 주세요';
                if (v.length < 6) return '비밀번호는 6자 이상이어야 합니다';
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupTextField(
              controller: _passwordConfirmController,
              label: '비밀번호 확인 *',
              obscureText: _obscurePasswordConfirm,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePasswordConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => setState(
                  () => _obscurePasswordConfirm = !_obscurePasswordConfirm,
                ),
              ),
              validator: (v) =>
                  v != _passwordController.text ? '비밀번호가 일치하지 않습니다' : null,
            ),
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupTextField(
              controller: _nameController,
              label: '이름 *',
              prefixIcon: Icons.badge_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '이름을 입력해 주세요' : null,
            ),
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupTextField(
              controller: _phoneController,
              label: '휴대폰 *',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '휴대폰 번호를 입력해 주세요' : null,
            ),
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupTextField(
              controller: _emailController,
              label: '이메일 (선택)',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupTextField(
              controller: _referralController,
              label: '추천 코드 (선택)',
              prefixIcon: Icons.card_giftcard_outlined,
            ),
            const SizedBox(height: AppTheme.spacing8),
            _sectionTitle('전문가 프로필'),
            SpareSignupRegionPicker(
              provinceId: _provinceId,
              districtId: _districtId,
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
            const SizedBox(height: AppTheme.spacing4),
            const Text(
              '경력 *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
            Slider(
              value: _experienceYears.toDouble(),
              min: 0,
              max: 20,
              divisions: 20,
              label: _experienceYears == 0 ? '신입' : '$_experienceYears년',
              onChanged: (v) =>
                  setState(() => _experienceYears = v.round()),
            ),
            Text(
              _experienceYears == 0 ? '신입 (0년)' : '경력 $_experienceYears년',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            const Text(
              '전문 분야 *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.stitchTextPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
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
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupTextField(
              controller: _hourlyRateController,
              label: '희망 시급 (선택)',
              hint: '원',
              prefixIcon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTheme.spacing8),
            SpareSignupTermsAllRow(
              allAccepted: _allTermsAccepted,
              onToggleAll: () => setState(() {
                final next = !_allTermsAccepted;
                _termsAccepted = next;
                _privacyAccepted = next;
                _personalInfoProvisionAccepted = next;
                _ageAccepted = next;
              }),
            ),
            SpareSignupTermsSection(
              termsAccepted: _termsAccepted,
              privacyAccepted: _privacyAccepted,
              personalInfoProvisionAccepted: _personalInfoProvisionAccepted,
              ageAccepted: _ageAccepted,
              onTermsChanged: (v) => setState(() => _termsAccepted = v),
              onPrivacyChanged: (v) => setState(() => _privacyAccepted = v),
              onPersonalInfoProvisionChanged: (v) =>
                  setState(() => _personalInfoProvisionAccepted = v),
              onAgeChanged: (v) => setState(() => _ageAccepted = v),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, auth, _) => StitchStickyBottomBar(
          primaryLabel: '회원가입',
          isLoading: auth.isLoading,
          onPrimary: _submit,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.stitchTextPrimary,
        ),
      ),
    );
  }
}
