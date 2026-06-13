import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/auth_service.dart';
import '../../services/verification_service.dart';
import '../../utils/app_exception.dart';
import '../../utils/error_handler.dart';

/// Next.js와 동일한 프로필 수정 화면
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthYearController = TextEditingController();
  
  String? _gender;
  final List<File> _profileImages = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  bool _success = false;
  
  // 본인인증 정보
  bool _isIdentityVerified = false;
  String? _verifiedName;
  String? _verifiedPhone;
  String? _verifiedBirthDate;
  String? _verifiedGender;
  
  // 휴대폰 인증
  final VerificationService _verificationService = VerificationService();
  bool _phoneVerificationSent = false;
  bool _phoneVerificationVerified = false;
  final TextEditingController _verificationCodeController = TextEditingController();
  int _verificationTimer = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthYearController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final authService = AuthService();
      final user = await authService.getCurrentUser();
      
      if (user != null) {
        setState(() {
          _nameController.text = user.name ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.phone ?? '';
          // birthYear와 gender는 User 모델에 없으므로 본인인증 정보에서만 가져옴
        });
      }
      
      // 본인인증 정보 확인
      try {
        final verificationStatus = await _verificationService.getVerificationStatus();
        if (verificationStatus['identityVerified'] == true) {
          setState(() {
            _isIdentityVerified = true;
            _verifiedName = verificationStatus['identityName'];
            _verifiedPhone = verificationStatus['identityPhone'];
            _verifiedBirthDate = verificationStatus['identityBirthDate'];
            _verifiedGender = verificationStatus['identityGender'];
            
            // 본인인증 정보로 자동 채우기
            if (_verifiedName != null) {
              _nameController.text = _verifiedName!;
            }
            if (_verifiedPhone != null) {
              _phoneController.text = _verifiedPhone!;
            }
            if (_verifiedBirthDate != null && _verifiedBirthDate!.length >= 4) {
              _birthYearController.text = _verifiedBirthDate!.substring(0, 4);
            }
            if (_verifiedGender != null) {
              _gender = _verifiedGender;
            }
          });
        }
      } catch (e) {
        // 인증 정보 조회 실패는 무시 (API가 없을 수 있음)
        debugPrint('인증 정보 조회 실패: $e');
      }
    } catch (e) {
      setState(() {
        _error = '프로필 정보를 불러오는 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_profileImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최대 3개까지 업로드할 수 있습니다.')),
      );
      return;
    }
    
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImages.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _profileImages.removeAt(index);
    });
  }

  Future<void> _sendVerificationCode() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전화번호를 입력해주세요.')),
      );
      return;
    }

    try {
      final messenger = ScaffoldMessenger.of(context);
      await _verificationService.sendVerificationCode(_phoneController.text);
      setState(() {
        _phoneVerificationSent = true;
        _verificationTimer = 300; // 5분
      });

      // 타이머 시작
      _startVerificationTimer();

      messenger.showSnackBar(
        const SnackBar(content: Text('인증번호가 발송되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증번호 발송 실패: ${e.toString()}')),
      );
    }
  }

  void _startVerificationTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _verificationTimer > 0) {
        setState(() {
          _verificationTimer--;
        });
        return _verificationTimer > 0;
      }
      return false;
    });
  }

  Future<void> _verifyCode() async {
    if (_verificationCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('인증번호를 입력해주세요.')),
      );
      return;
    }

    try {
      final messenger = ScaffoldMessenger.of(context);
      final verified = await _verificationService.verifyCode(
        _phoneController.text,
        _verificationCodeController.text,
      );

      if (verified) {
        setState(() {
          _phoneVerificationVerified = true;
          _verificationTimer = 0;
        });
        messenger.showSnackBar(
          const SnackBar(content: Text('인증이 완료되었습니다.')),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('인증번호가 올바르지 않습니다.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('인증 실패: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final messenger = ScaffoldMessenger.of(context);
      // API 호출하여 프로필 저장
      final authService = AuthService();
      
      // birthYear를 int로 변환
      int? birthYear;
      if (_birthYearController.text.trim().isNotEmpty) {
        birthYear = int.tryParse(_birthYearController.text.trim());
        if (birthYear == null || birthYear < 1950 || birthYear > DateTime.now().year) {
          throw ValidationException('올바른 출생년도를 입력해주세요');
        }
      }
      
      // gender를 'M' 또는 'F'로 변환
      String? gender;
      if (_gender != null) {
        gender = _gender == '남성' ? 'M' : (_gender == '여성' ? 'F' : null);
      }
      
      // 프로필 이미지 업로드 후 URL 반환
      String? profileImage;
      List<String>? profileImages;
      
      if (_profileImages.isNotEmpty) {
        try {
          if (_profileImages.length == 1) {
            // 단일 이미지 업로드
            profileImage = await authService.uploadProfileImage(_profileImages.first);
          } else {
            // 여러 이미지 업로드
            final uploadedUrls = await authService.uploadProfileImages(_profileImages);
            profileImages = uploadedUrls;
            if (uploadedUrls.isNotEmpty) {
              profileImage = uploadedUrls.first; // 첫 번째 이미지를 메인 프로필 이미지로 사용
            }
          }
        } catch (e) {
          final appException = ErrorHandler.handleException(e);
          messenger.showSnackBar(
            SnackBar(
              content: Text('이미지 업로드 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
          return; // 이미지 업로드 실패 시 저장 중단
        }
      }
      
      await authService.updateProfile(
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        birthYear: birthYear,
        gender: gender,
        profileImage: profileImage,
        profileImages: profileImages,
      );
      
      setState(() {
        _success = true;
      });

      messenger.showSnackBar(
        const SnackBar(
          content: Text('프로필이 저장되었습니다'),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로필 저장 실패: ${e.toString()}'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_success) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconMapper.icon('checkcircle', size: 64, color: AppTheme.primaryGreen) ??
                  const Icon(Icons.check_circle, size: 64, color: AppTheme.primaryGreen),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                '프로필이 수정되었습니다',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(
        title: '프로필 수정',
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: Text(
              '저장',
              style: TextStyle(
                color: _isSaving ? AppTheme.textTertiary : AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 본인인증 정보 안내
              if (_isIdentityVerified)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing3),
                  margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          '본인인증이 완료된 정보입니다.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 프로필 이미지 (최대 3개)
              Column(
                children: [
                  Wrap(
                    spacing: AppTheme.spacing3,
                    runSpacing: AppTheme.spacing3,
                    children: [
                      ..._profileImages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final image = entry.value;
                        return Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                border: Border.all(color: AppTheme.borderGray),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                child: Image.file(image, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.urgentRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (_profileImages.length < 3)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundGray,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: AppTheme.borderGray, style: BorderStyle.solid),
                            ),
                            child: const Icon(Icons.add, size: 32, color: AppTheme.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing6),
              // 이름
              TextFormField(
                controller: _nameController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: '이름',
                  prefixIcon: IconMapper.icon('user', size: 20, color: AppTheme.textSecondary) ??
                      const Icon(Icons.person, size: 20, color: AppTheme.textSecondary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing4),
              // 이메일
              TextFormField(
                controller: _emailController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: '이메일',
                  prefixIcon: IconMapper.icon('mail', size: 20, color: AppTheme.textSecondary) ??
                      const Icon(Icons.email, size: 20, color: AppTheme.textSecondary),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return '올바른 이메일 형식을 입력해주세요';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing4),
              // 전화번호
              TextFormField(
                controller: _phoneController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: '전화번호',
                  prefixIcon: IconMapper.icon('phone', size: 20, color: AppTheme.textSecondary) ??
                      const Icon(Icons.phone, size: 20, color: AppTheme.textSecondary),
                  suffixIcon: _isIdentityVerified && _verifiedPhone == _phoneController.text
                      ? const Icon(Icons.verified, color: Colors.blue, size: 20)
                      : null,
                ),
                keyboardType: TextInputType.phone,
                readOnly: _isIdentityVerified && _verifiedPhone == _phoneController.text,
              ),
              
              // 휴대폰 인증 섹션
              if (!_phoneVerificationVerified && !(_isIdentityVerified && _verifiedPhone == _phoneController.text)) ...[
                const SizedBox(height: AppTheme.spacing2),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _verificationCodeController,
                        decoration: AppTheme.inputDecoration.copyWith(
                          labelText: '인증번호',
                          hintText: '인증번호를 입력하세요',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing2),
                    ElevatedButton(
                      onPressed: _phoneVerificationSent ? _verifyCode : _sendVerificationCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_phoneVerificationSent ? '확인' : '발송'),
                    ),
                  ],
                ),
                if (_phoneVerificationSent && _verificationTimer > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spacing2),
                    child: Text(
                      '${(_verificationTimer / 60).floor()}:${(_verificationTimer % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
              ],
              const SizedBox(height: AppTheme.spacing4),
              // 출생년도
              TextFormField(
                controller: _birthYearController,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: '출생년도',
                  prefixIcon: IconMapper.icon('calendar', size: 20, color: AppTheme.textSecondary) ??
                      const Icon(Icons.calendar_today, size: 20, color: AppTheme.textSecondary),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppTheme.spacing4),
              // 성별
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: '성별',
                ),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('남성')),
                  DropdownMenuItem(value: 'F', child: Text('여성')),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: AppTheme.spacing4),
                Container(
                  padding: AppTheme.spacing(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppTheme.urgentRedLight,
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                  child: Row(
                    children: [
                      IconMapper.icon('xcircle', size: 20, color: AppTheme.urgentRed) ??
                          const Icon(Icons.error, size: 20, color: AppTheme.urgentRed),
                      const SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppTheme.urgentRed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
