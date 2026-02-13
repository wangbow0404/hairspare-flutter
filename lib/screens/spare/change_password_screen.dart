import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/auth_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 비밀번호 변경 화면
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  int _currentNavIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, String> _errors = {};
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  List<String> _validatePassword(String password) {
    final errors = <String>[];
    if (password.length < 8) {
      errors.add('비밀번호는 최소 8자 이상이어야 합니다.');
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      errors.add('영문자를 포함해야 합니다.');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('숫자를 포함해야 합니다.');
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('특수문자를 포함해야 합니다.');
    }
    return errors;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errors = {};
      _success = false;
    });

    final newErrors = <String, String>{};

    if (_currentPasswordController.text.isEmpty) {
      newErrors['currentPassword'] = '현재 비밀번호를 입력해주세요.';
    }

    final passwordErrors = _validatePassword(_newPasswordController.text);
    if (passwordErrors.isNotEmpty) {
      newErrors['newPassword'] = passwordErrors.first;
    }

    if (_confirmPasswordController.text != _newPasswordController.text) {
      newErrors['confirmPassword'] = '새 비밀번호가 일치하지 않습니다.';
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      newErrors['newPassword'] = '현재 비밀번호와 동일한 비밀번호는 사용할 수 없습니다.';
    }

    if (newErrors.isNotEmpty) {
      setState(() {
        _errors = newErrors;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // API 호출하여 비밀번호 변경
      final authService = AuthService();
      await authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      
      setState(() {
        _success = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 변경되었습니다'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      setState(() {
        _errors['currentPassword'] = ErrorHandler.getUserFriendlyMessage(appException);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
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
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
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
              SizedBox(height: AppTheme.spacing4),
              Text(
                '비밀번호가 변경되었습니다',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: AppTheme.spacing2),
              Text(
                '설정 페이지로 이동합니다...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
          '비밀번호 변경',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing6),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 현재 비밀번호
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_showCurrentPassword,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: '현재 비밀번호',
                  prefixIcon: IconMapper.icon('lock', size: 20, color: AppTheme.textSecondary) ??
                      const Icon(Icons.lock, size: 20, color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: IconMapper.icon(
                      _showCurrentPassword ? 'eyeoff' : 'eye',
                      size: 20,
                      color: AppTheme.textSecondary,
                    ) ??
                        Icon(
                          _showCurrentPassword ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                    onPressed: () {
                      setState(() {
                        _showCurrentPassword = !_showCurrentPassword;
                      });
                    },
                  ),
                  errorText: _errors['currentPassword'],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '현재 비밀번호를 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppTheme.spacing6),
              // 새 비밀번호
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: '새 비밀번호',
                  prefixIcon: IconMapper.icon('lock', size: 20, color: AppTheme.textSecondary) ??
                      const Icon(Icons.lock, size: 20, color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: IconMapper.icon(
                      _showNewPassword ? 'eyeoff' : 'eye',
                      size: 20,
                      color: AppTheme.textSecondary,
                    ) ??
                        Icon(
                          _showNewPassword ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                    onPressed: () {
                      setState(() {
                        _showNewPassword = !_showNewPassword;
                      });
                    },
                  ),
                  errorText: _errors['newPassword'],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 입력해주세요';
                  }
                  final passwordErrors = _validatePassword(value);
                  if (passwordErrors.isNotEmpty) {
                    return passwordErrors.first;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppTheme.spacing2),
              Container(
                padding: AppTheme.spacing(AppTheme.spacing2),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGray,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '비밀번호 요구사항:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing1),
                    ...['최소 8자 이상', '영문자 포함', '숫자 포함', '특수문자 포함'].map((req) {
                      return Padding(
                        padding: EdgeInsets.only(left: AppTheme.spacing2),
                        child: Row(
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            Text(
                              req,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: AppTheme.spacing6),
              // 새 비밀번호 확인
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: AppTheme.inputDecoration.copyWith(
                  labelText: '새 비밀번호 확인',
                  prefixIcon: IconMapper.icon('lock', size: 20, color: AppTheme.textSecondary) ??
                      const Icon(Icons.lock_outline, size: 20, color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: IconMapper.icon(
                      _showConfirmPassword ? 'eyeoff' : 'eye',
                      size: 20,
                      color: AppTheme.textSecondary,
                    ) ??
                        Icon(
                          _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  errorText: _errors['confirmPassword'],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호 확인을 입력해주세요';
                  }
                  if (value != _newPasswordController.text) {
                    return '새 비밀번호가 일치하지 않습니다';
                  }
                  return null;
                },
              ),
              if (_confirmPasswordController.text.isNotEmpty &&
                  _confirmPasswordController.text == _newPasswordController.text &&
                  _errors['confirmPassword'] == null) ...[
                SizedBox(height: AppTheme.spacing2),
                Row(
                  children: [
                    IconMapper.icon('checkcircle', size: 16, color: AppTheme.primaryGreen) ??
                        const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen),
                    SizedBox(width: AppTheme.spacing1),
                    Text(
                      '비밀번호가 일치합니다',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: AppTheme.spacing8),
              // 제출 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: AppTheme.spacing(AppTheme.spacing3),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconMapper.icon('lock', size: 20, color: Colors.white) ??
                                const Icon(Icons.lock, size: 20, color: Colors.white),
                            SizedBox(width: AppTheme.spacing2),
                            Text(
                              '비밀번호 변경',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
          
          // 네비게이션 처리
          switch (index) {
            case 0:
              // 홈으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              // 결제로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              // 찜으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              // 마이(프로필)로 이동
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
