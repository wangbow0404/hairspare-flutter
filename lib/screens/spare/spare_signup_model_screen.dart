import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/model_match_preference.dart';
import '../../models/spare_signup_data.dart';
import '../../models/spare_subtype.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/birth_date_utils.dart';
import '../../utils/region_helper.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../widgets/spare_signup/model_photo_upload_section.dart';
import '../../widgets/spare_signup/spare_signup_birth_date_field.dart';
import '../../widgets/spare_signup/spare_signup_region_picker.dart';
import '../../widgets/spare_signup/spare_signup_terms_section.dart';
import '../../widgets/spare_signup/spare_signup_text_field.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/stitch/stitch_sticky_bottom_bar.dart';

/// 모델 회원가입 폼.
class SpareSignupModelScreen extends StatefulWidget {
  const SpareSignupModelScreen({super.key});

  @override
  State<SpareSignupModelScreen> createState() => _SpareSignupModelScreenState();
}

class _SpareSignupModelScreenState extends State<SpareSignupModelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _referralController = TextEditingController();
  final _introController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _personalInfoProvisionAccepted = false;
  bool _ageAccepted = false;

  DateTime? _birthDate;
  String? _provinceId;
  String? _districtId;
  String? _regionLabel;
  String? _gender;
  String? _hairLength;
  String? _career;
  final Set<String> _treatments = {};
  final Set<String> _imageTags = {};
  List<Uint8List> _photoBytes = [];

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
    _introController.dispose();
    super.dispose();
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
    if (!_regionSelected || _gender == null || _hairLength == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 프로필 항목을 선택해 주세요.')),
      );
      return;
    }
    if (_birthDate == null ||
        !BirthDateUtils.isValidSignupBirthDate(_birthDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일을 올바르게 선택해 주세요. (만 14세 이상)')),
      );
      return;
    }
    if (_career == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모델 경력을 선택해 주세요.')),
      );
      return;
    }
    if (_treatments.isEmpty || _imageTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선호 시술과 모델 이미지를 선택해 주세요.')),
      );
      return;
    }
    if (_photoBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 사진을 1장 이상 등록해 주세요.')),
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

    // 사진 R2 업로드 (가입 전 선업로드)
    final photoUrls = <String>[];
    for (final bytes in _photoBytes) {
      final url = await _uploadImageBytes(bytes, 'model-photos');
      if (url == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 업로드 중 오류가 발생했습니다. 다시 시도해 주세요.')),
        );
        return;
      }
      photoUrls.add(url);
    }

    final profile = ModelSignupProfile(
      birthDate: _birthDate!,
      gender: _gender!,
      region: _regionLabel!,
      regionId: _districtId ?? _provinceId,
      hairLength: _hairLength!,
      preferredTreatments: _treatments.toList(),
      imageTags: _imageTags.toList(),
      career: _career!,
      intro: _introController.text.trim(),
      photoUrls: photoUrls,
    );

    await auth.register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      role: UserRole.spare,
      spareSubtype: SpareSubtype.model,
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
      appBar: const SharedAppBar(title: '모델 가입'),
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
              '헤어 시술 모델로 활동해요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.stitchPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing6),
            _sectionTitle('계정 정보'),
            ..._accountFields(),
            const SizedBox(height: AppTheme.spacing8),
            _sectionTitle('모델 프로필'),
            ModelPhotoUploadSection(
              photoBytes: _photoBytes,
              onChanged: (bytes) => setState(() => _photoBytes = bytes),
            ),
            const SizedBox(height: AppTheme.spacing6),
            SpareSignupBirthDateField(
              value: _birthDate,
              onChanged: (date) => setState(() => _birthDate = date),
            ),
            const SizedBox(height: AppTheme.spacing4),
            _singleChipSection(
              '성별 *',
              ModelMatchOptions.genders.where((g) => g != '전체').toList(),
              _gender,
              (v) => setState(() => _gender = v),
            ),
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
            _singleChipSection(
              '현재 기장 *',
              ModelMatchOptions.hairLengths,
              _hairLength,
              (v) => setState(() => _hairLength = v),
            ),
            _multiChipSection(
              '선호 시술 *',
              ModelMatchOptions.treatments,
              _treatments,
              (v) => setState(() {
                if (!_treatments.add(v)) _treatments.remove(v);
              }),
            ),
            _multiChipSection(
              '모델 이미지 *',
              ModelMatchOptions.imageStyles,
              _imageTags,
              (v) => setState(() {
                if (!_imageTags.add(v)) _imageTags.remove(v);
              }),
            ),
            _singleChipSection(
              '모델 경력 *',
              ModelMatchOptions.careers.where((c) => c != '전체').toList(),
              _career,
              (v) => setState(() => _career = v),
            ),
            const SizedBox(height: AppTheme.spacing4),
            SpareSignupTextField(
              controller: _introController,
              label: '한줄 소개 *',
              hint: '50자 내외로 자신을 소개해 주세요',
              prefixIcon: Icons.notes_outlined,
              maxLines: 2,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? '한줄 소개를 입력해 주세요' : null,
            ),
            const SizedBox(height: AppTheme.spacing8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.primaryPurpleLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: AppTheme.stitchPrimary.withValues(alpha: 0.2),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppTheme.spacing4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: AppTheme.stitchPrimary,
                      size: 20,
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: Text(
                        '가입 후 디자이너 매칭에 노출됩니다.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.stitchTextSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

  List<Widget> _accountFields() {
    return [
      SpareSignupTextField(
        controller: _usernameController,
        label: '아이디 *',
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
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
            _obscurePasswordConfirm ? Icons.visibility_off : Icons.visibility,
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
    ];
  }

  Widget _singleChipSection(
    String title,
    List<String> options,
    String? selected,
    ValueChanged<String> onSelect,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
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
              for (final o in options)
                StitchFilterChip(
                  label: o,
                  isSelected: selected == o,
                  onTap: () => onSelect(o),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _multiChipSection(
    String title,
    List<String> options,
    Set<String> selected,
    ValueChanged<String> onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
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
              for (final o in options)
                StitchFilterChip(
                  label: o,
                  isSelected: selected.contains(o),
                  onTap: () => onToggle(o),
                ),
            ],
          ),
        ],
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
