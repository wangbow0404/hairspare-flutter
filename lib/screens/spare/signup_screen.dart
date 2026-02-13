import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // ImageFilter를 위해 import
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../spare/home_screen.dart';

class SpareSignupScreen extends StatefulWidget {
  const SpareSignupScreen({super.key});

  @override
  State<SpareSignupScreen> createState() => _SpareSignupScreenState();
}

class _SpareSignupScreenState extends State<SpareSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _referralCodeController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await authProvider.register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      role: UserRole.spare,
      email: _emailController.text.trim().isNotEmpty 
          ? _emailController.text.trim() 
          : null,
      name: _nameController.text.trim().isNotEmpty 
          ? _nameController.text.trim() 
          : null,
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      referralCode: _referralCodeController.text.trim().isNotEmpty 
          ? _referralCodeController.text.trim() 
          : null,
    );

    if (authProvider.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (authProvider.isAuthenticated) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SpareHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스페어 회원가입'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
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
                    SizedBox(height: AppTheme.spacing8),
                  ],
                ),
                // 필수 입력 필드
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '아이디 *',
                    hintText: '아이디를 입력하세요',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '아이디를 입력해주세요';
                    }
                    if (value.length < 4) {
                      return '아이디는 4자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호 *',
                    hintText: '비밀번호를 입력하세요',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordConfirmController,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인 *',
                    hintText: '비밀번호를 다시 입력하세요',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePasswordConfirm = !_obscurePasswordConfirm;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePasswordConfirm,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // 선택 입력 필드
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일 (선택)',
                    hintText: '이메일을 입력하세요',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '이름 (선택)',
                    hintText: '이름을 입력하세요',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: '전화번호 (선택)',
                    hintText: '전화번호를 입력하세요',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referralCodeController,
                  decoration: const InputDecoration(
                    labelText: '추천 코드 (선택)',
                    hintText: '추천 코드를 입력하세요',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.card_giftcard),
                  ),
                ),
                const SizedBox(height: 32),
                // 회원가입 버튼
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '회원가입',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // 로그인 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('이미 계정이 있으신가요? '),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('로그인'),
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
