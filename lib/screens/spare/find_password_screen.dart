import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/hairspare_brand_assets.dart';
import '../../utils/icon_mapper.dart';
import '../../services/auth_service.dart';
import '../../services/verification_service.dart';
import '../../utils/error_handler.dart';
import '../../core/router/app_navigation.dart';
import '../../core/router/app_routes.dart';

/// Next.js와 동일한 비밀번호 찾기 화면
class FindPasswordScreen extends StatefulWidget {
  final String? foundId; // 아이디 찾기에서 넘어온 경우

  const FindPasswordScreen({super.key, this.foundId});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  final VerificationService _verificationService = VerificationService();
  
  String _step = 'input'; // 'input', 'verify', 'reset'
  bool _isLoading = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    if (widget.foundId != null) {
      _idController.text = widget.foundId!;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String value) {
    final numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    if (numbers.length <= 3) return numbers;
    if (numbers.length <= 7) return '${numbers.substring(0, 3)}-${numbers.substring(3)}';
    return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7, 11)}';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final messenger = ScaffoldMessenger.of(context);
      if (_step == 'input') {
        // API 호출하여 인증번호 발송
        await _verificationService.sendVerificationCode(_phoneController.text.replaceAll('-', ''));
        messenger.showSnackBar(
          const SnackBar(
            content: Text('인증번호가 발송되었습니다.'),
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
        setState(() {
          _step = 'verify';
        });
      } else if (_step == 'verify') {
        // API 호출하여 인증번호 확인
        final verified = await _verificationService.verifyCode(
          _phoneController.text.replaceAll('-', ''),
          _verificationCodeController.text,
        );
        
        if (verified) {
          setState(() {
            _step = 'reset';
          });
        } else {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('인증번호가 올바르지 않습니다.'),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
      } else if (_step == 'reset') {
        if (_newPasswordController.text != _confirmPasswordController.text) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('비밀번호가 일치하지 않습니다.'),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
          return;
        }

        if (_newPasswordController.text.length < 8) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('비밀번호는 8자 이상이어야 합니다.'),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
          return;
        }

        // API 호출하여 비밀번호 재설정
        await _authService.resetPassword(
          id: _idController.text.trim(),
          phone: _phoneController.text.replaceAll('-', ''),
          code: _verificationCodeController.text,
          newPassword: _newPasswordController.text,
        );

        messenger.showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 재설정되었습니다.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        if (!mounted) return;
        AppNavigation.goSpareLogin(context);
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppTheme.spacing(AppTheme.spacing6),
            child: Column(
              children: [
                // 헤더
                Row(
                  children: [
                    IconButton(
                      icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                          const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing10),
                // 로고
                Column(
                  children: [
                    const HairSpareBrandSymbol(),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      '비밀번호 찾기',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing10),
                // 폼
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_step == 'input') ...[
                        TextFormField(
                          controller: _idController,
                          decoration: AppTheme.inputDecoration.copyWith(
                            labelText: '아이디',
                            prefixIcon: IconMapper.icon('user', size: 20, color: AppTheme.textSecondary) ??
                                const Icon(Icons.person, size: 20, color: AppTheme.textSecondary),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '아이디를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        TextFormField(
                          controller: _phoneController,
                          decoration: AppTheme.inputDecoration.copyWith(
                            labelText: '휴대폰 번호',
                            hintText: '010-1234-5678',
                            prefixIcon: IconMapper.icon('phone', size: 20, color: AppTheme.textSecondary) ??
                                const Icon(Icons.phone, size: 20, color: AppTheme.textSecondary),
                          ),
                          keyboardType: TextInputType.phone,
                          maxLength: 13,
                          onChanged: (value) {
                            final formatted = _formatPhoneNumber(value);
                            if (formatted != value) {
                              _phoneController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(offset: formatted.length),
                              );
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '휴대폰 번호를 입력해주세요';
                            }
                            final numbers = value.replaceAll(RegExp(r'[^\d]'), '');
                            if (numbers.length != 11) {
                              return '올바른 휴대폰 번호를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ] else if (_step == 'verify') ...[
                        TextFormField(
                          controller: _verificationCodeController,
                          decoration: AppTheme.inputDecoration.copyWith(
                            labelText: '인증번호',
                            hintText: '인증번호 6자리',
                            prefixIcon: IconMapper.icon('lock', size: 20, color: AppTheme.textSecondary) ??
                                const Icon(Icons.lock, size: 20, color: AppTheme.textSecondary),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '인증번호를 입력해주세요';
                            }
                            if (value.length != 6) {
                              return '인증번호는 6자리입니다';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing2),
                        Text(
                          '${_phoneController.text}로 발송된 인증번호를 입력하세요.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ] else if (_step == 'reset') ...[
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: !_showNewPassword,
                          decoration: AppTheme.inputDecoration.copyWith(
                            labelText: '새 비밀번호',
                            hintText: '8자 이상',
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
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '새 비밀번호를 입력해주세요';
                            }
                            if (value.length < 8) {
                              return '비밀번호는 8자 이상이어야 합니다';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing4),
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
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '비밀번호 확인을 입력해주세요';
                            }
                            if (value != _newPasswordController.text) {
                              return '비밀번호가 일치하지 않습니다';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacing6),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: AppTheme.spacing(AppTheme.spacing4),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _step == 'input'
                                      ? '인증번호 발송'
                                      : _step == 'verify'
                                          ? '인증번호 확인'
                                          : '비밀번호 재설정',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                // 하단 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        AppNavigation.goSpareLogin(context);
                      },
                      child: Text(
                        '로그인',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ),
                    Text(
                      '|',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.replace(AppRoutes.spareSignup);
                      },
                      child: Text(
                        '회원가입',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ),
                    Text(
                      '|',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(AppRoutes.spareFindId);
                      },
                      child: Text(
                        '아이디 찾기',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
