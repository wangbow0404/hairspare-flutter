import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/challenge_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/challenge_service.dart';
import '../../utils/error_handler.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// 챌린지 프로필 편집 화면
class ChallengeProfileEditScreen extends StatefulWidget {
  final ChallengeProfile profile;

  const ChallengeProfileEditScreen({
    super.key,
    required this.profile,
  });

  @override
  State<ChallengeProfileEditScreen> createState() => _ChallengeProfileEditScreenState();
}

class _ChallengeProfileEditScreenState extends State<ChallengeProfileEditScreen> {
  int _currentNavIndex = 0;
  final ChallengeService _challengeService = ChallengeService();
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  
  File? _profileImageFile;
  String? _profileImageUrl;
  bool _isPublic = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.profile.challengeNickname ?? '';
    _bioController.text = widget.profile.challengeBio ?? '';
    _profileImageUrl = widget.profile.challengeProfileImage;
    _isPublic = widget.profile.isPublic;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImageFile = File(image.path);
        _profileImageUrl = null; // 새 이미지 선택 시 기존 URL 제거
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다');
      }

      // 이미지 업로드 (있는 경우)
      String? profileImageUrl = _profileImageUrl;
      if (_profileImageFile != null) {
        try {
          // 이미지 업로드 API 호출 후 URL 받기
          profileImageUrl = await _challengeService.uploadChallengeProfileImage(_profileImageFile!);
        } catch (e) {
          final appException = ErrorHandler.handleException(e);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('이미지 업로드 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
                backgroundColor: AppTheme.urgentRed,
              ),
            );
          }
          return; // 이미지 업로드 실패 시 저장 중단
        }
      }

      // 프로필 정보 업데이트
      final updatedProfile = widget.profile.copyWith(
        challengeNickname: _nicknameController.text.trim(),
        challengeBio: _bioController.text.trim(),
        challengeProfileImage: profileImageUrl,
        isPublic: _isPublic,
      );

      await _challengeService.updateChallengeProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 저장되었습니다'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 저장 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '프로필 편집',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: Text(
              '저장',
              style: TextStyle(
                color: _isSaving ? AppTheme.textTertiary : AppTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppTheme.spacing(AppTheme.spacing4),
          child: Column(
            children: [
              // 프로필 사진 섹션
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryPurple,
                            AppTheme.primaryBlue,
                          ],
                        ),
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                        boxShadow: AppTheme.shadowLg,
                      ),
                      child: _profileImageFile != null
                          ? ClipRRect(
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                              child: Image.file(
                                _profileImageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : _profileImageUrl != null
                              ? ClipRRect(
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                  child: Image.network(
                                    _profileImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: IconMapper.icon('user', size: 60, color: Colors.white) ??
                                            const Icon(Icons.person, size: 60, color: Colors.white),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: IconMapper.icon('user', size: 60, color: Colors.white) ??
                                      const Icon(Icons.person, size: 60, color: Colors.white),
                                ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple,
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: IconMapper.icon('camera', size: 18, color: Colors.white) ??
                              const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacing6),

              // 닉네임 입력
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
                padding: AppTheme.spacing(AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '챌린지 닉네임',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _nicknameController,
                      decoration: InputDecoration(
                        hintText: '닉네임을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.borderGray),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.borderGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '닉네임을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacing4),

              // 바이오 입력
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
                padding: AppTheme.spacing(AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '소개',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '소개를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.borderGray),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.borderGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacing4),

              // 공개 설정
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                ),
                padding: AppTheme.spacing(AppTheme.spacing4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '공개 설정',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing1),
                        Text(
                          _isPublic ? '모든 사용자가 볼 수 있습니다' : '나만 볼 수 있습니다',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                      activeColor: AppTheme.primaryPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
