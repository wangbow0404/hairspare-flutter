import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import 'profile_screen.dart';

/// Shop 프로필 수정 화면
class ShopProfileEditScreen extends StatefulWidget {
  const ShopProfileEditScreen({super.key});

  @override
  State<ShopProfileEditScreen> createState() => _ShopProfileEditScreenState();
}

class _ShopProfileEditScreenState extends State<ShopProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

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
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      setState(() {
        _nameController.text = user.name ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
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
      // TODO: 프로필 업데이트 API 호출
      // await authProvider.updateProfile(...);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 성공적으로 수정되었습니다'),
            backgroundColor: AppTheme.primaryPurple,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 수정 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('프로필 수정'),
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 사진 섹션
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: user?.id != null
                                  ? _getAvatarGradient(user!.id)
                                  : [const Color(0xFFC084FC), const Color(0xFFEC4899)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: user?.profileImage != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.profileImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: Colors.white,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    TextButton(
                      onPressed: () {
                        // TODO: 사진 변경 기능
                      },
                      child: const Text(
                        '사진 변경',
                        style: TextStyle(color: AppTheme.primaryPurple),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppTheme.spacing6),
              
              // 이름
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름 *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: AppTheme.spacing4),
              
              // 이메일
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일 *',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                    return '올바른 이메일 형식이 아닙니다';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: AppTheme.spacing4),
              
              // 전화번호
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '010-0000-0000',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[0-9-]+$').hasMatch(value)) {
                      return '올바른 전화번호 형식이 아닙니다';
                    }
                  }
                  return null;
                },
              ),
              
              SizedBox(height: AppTheme.spacing6),
              
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? '저장 중...' : '저장하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                  ),
                ),
              ),
              
              SizedBox(height: AppTheme.spacing4),
              
              // 비밀번호 변경 링크
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: 비밀번호 변경 화면으로 이동
                  },
                  child: const Text('비밀번호 변경'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getAvatarGradient(String userId) {
    final gradients = [
      [const Color(0xFFC084FC), const Color(0xFFEC4899)],
      [const Color(0xFFF472B6), const Color(0xFFEF4444)],
      [const Color(0xFFFB7185), const Color(0xFFF97316)],
      [const Color(0xFFA855F7), const Color(0xFFEC4899)],
      [const Color(0xFFE879F9), const Color(0xFFF472B6)],
      [const Color(0xFF9333EA), const Color(0xFF6366F1)],
      [const Color(0xFF6366F1), const Color(0xFFA855F7)],
      [const Color(0xFF9333EA), const Color(0xFFEC4899)],
    ];
    
    int hash = 0;
    for (int i = 0; i < userId.length; i++) {
      hash = userId.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % gradients.length;
    return gradients[index];
  }
}
