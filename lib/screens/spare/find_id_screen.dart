import 'package:flutter/material.dart';
import 'dart:ui'; // ImageFilter를 위해 import
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../services/auth_service.dart';
import '../../utils/error_handler.dart';
import '../spare/login_screen.dart';
import '../spare/find_password_screen.dart';
import '../spare/signup_screen.dart';

/// Next.js와 동일한 아이디 찾기 화면
class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _foundId;

  @override
  void dispose() {
    _phoneController.dispose();
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
      // API 호출하여 아이디 찾기
      final result = await _authService.findUsername(
        phone: _phoneController.text.replaceAll('-', ''),
      );
      
      setState(() {
        _foundId = result['maskedId'] ?? result['id'];
      });
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
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
                SizedBox(height: AppTheme.spacing10),
                // 로고
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        // 그라데이션 박스
                        Container(
                          width: 80, // w-20
                          height: 80, // h-20
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryPurple, // from-purple-600
                                AppTheme.primaryPurpleDarker, // to-purple-800
                              ],
                            ),
                            borderRadius: AppTheme.borderRadius(AppTheme.radius2xl), // rounded-2xl
                            boxShadow: AppTheme.shadowLg, // shadow-lg
                          ),
                          child: const Center(
                            child: Text(
                              'H',
                              style: TextStyle(
                                fontSize: 30, // text-3xl (30px)
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        // 블러 효과 (노란색 오버레이)
                        Positioned(
                          top: -4, // -top-1
                          right: -4, // -right-1
                          child: Container(
                            width: 64, // w-16
                            height: 64, // h-16
                            decoration: BoxDecoration(
                              color: AppTheme.yellow400.withOpacity(0.4), // bg-yellow-400/40
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusXl), // rounded-xl
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // blur-sm
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      'hairspare',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 24, // text-2xl
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurpleDarker, // text-purple-800
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    Text(
                      '아이디 찾기',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing10),
                // 폼 또는 결과
                if (_foundId == null)
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                        SizedBox(height: AppTheme.spacing4),
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
                                    '아이디 찾기',
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
                  )
                else
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurpleLight,
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2), width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '회원님의 아이디는',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing2),
                        Text(
                          _foundId!,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurpleDarker,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        Text(
                          '입니다.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing4),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FindPasswordScreen(foundId: _foundId),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPurple,
                              foregroundColor: Colors.white,
                              padding: AppTheme.spacing(AppTheme.spacing3),
                            ),
                            child: Text(
                              '비밀번호 찾기',
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
                SizedBox(height: AppTheme.spacing8),
                // 하단 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SpareLoginScreen()),
                        );
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SpareSignupScreen()),
                        );
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FindPasswordScreen(foundId: _foundId),
                          ),
                        );
                      },
                      child: Text(
                        '비밀번호 찾기',
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
