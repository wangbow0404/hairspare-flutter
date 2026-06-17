import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/login_portal.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/hairspare_brand_assets.dart';
import '../../core/router/app_navigation.dart';
import '../../core/router/app_routes.dart';
import '../../mocks/mock_auth_data.dart';
import '../../utils/api_config.dart';

class ShopLoginScreen extends StatefulWidget {
  const ShopLoginScreen({super.key});

  @override
  State<ShopLoginScreen> createState() => _ShopLoginScreenState();
}

class _ShopLoginScreenState extends State<ShopLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    await authProvider.login(
      username: username,
      password: password,
      portal: LoginPortal.shop,
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
      final user = authProvider.currentUser;
      if (mounted && user != null) {
        AppNavigation.goHomeForRole(user.role);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) AppNavigation.backFromLogin(context);
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.grey),
                    onPressed: () => AppNavigation.backFromLogin(context),
                  ),
                  Expanded(
                    child: Text(
                      '로그인',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // 뒤로가기 버튼과 균형 맞추기
                ],
              ),
            ),
            // 본문
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing6, vertical: AppTheme.spacing8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppTheme.spacing8),
                      // 로고
                      Center(
                        child: Column(
                          children: [
                            const HairSpareBrandSymbol(),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      if (ApiConfig.useMockData) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppTheme.spacing3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9333EA).withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(
                              color: const Color(0xFF9333EA).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            '목 데이터: 스페어 ${MockAuthData.devSpareUsername}/${MockAuthData.devSparePassword} · '
                            '샵 ${MockAuthData.devShopUsername}/${MockAuthData.devShopPassword} · '
                            '관리자 ${MockAuthData.devAdminUsername}/${MockAuthData.devAdminPassword}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                      ],
                      // 아이디 입력
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: '아이디',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(AppTheme.spacing4),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '아이디를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      // 비밀번호 입력
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: '비밀번호',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            borderSide: const BorderSide(color: Color(0xFF9333EA), width: 2),
                          ),
                          contentPadding: const EdgeInsets.all(AppTheme.spacing4),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '비밀번호를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      // 로그인 버튼
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
                              ),
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9333EA).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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
                                      '로그인',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      // 하단 링크
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.push(AppRoutes.shopSignup);
                            },
                            child: Text(
                              '회원가입',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Text(
                            '|',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(AppRoutes.shopFindPassword);
                            },
                            child: Text(
                              '비밀번호 찾기',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
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
          ],
        ),
      ),
    ),
    );
  }
}
