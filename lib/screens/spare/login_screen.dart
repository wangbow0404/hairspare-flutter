import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/login_portal.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/router/app_navigation.dart';
import '../../core/router/app_routes.dart';
import '../../widgets/social_login_button.dart'; // SocialLoginButton import
import '../../widgets/common/hairspare_brand_assets.dart';
import '../../utils/icon_mapper.dart'; // IconMapper import
import '../../services/social_auth_service.dart';
import '../../utils/api_config.dart';
import '../../utils/error_handler.dart';
import '../../mocks/mock_auth_data.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SpareLoginScreen extends StatefulWidget {
  const SpareLoginScreen({super.key});

  @override
  State<SpareLoginScreen> createState() => _SpareLoginScreenState();
}

class _SpareLoginScreenState extends State<SpareLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final SocialAuthService _socialAuthService = SocialAuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  bool _obscurePassword = true;
  bool _isSocialLoggingIn = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 이전 에러 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
  }

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
      portal: LoginPortal.spare,
    );

    if (authProvider.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: AppTheme.urgentRed,
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

  Future<void> _handleKakaoLogin() async {
    setState(() {
      _isSocialLoggingIn = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // 카카오 SDK를 사용하여 로그인
      kakao.OAuthToken? token;

      // 카카오톡이 설치되어 있는지 확인
      if (await kakao.isKakaoTalkInstalled()) {
        // 카카오톡으로 로그인 시도
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          // 카카오톡 로그인 실패 시 카카오계정으로 로그인
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // 카카오톡이 없으면 카카오계정으로 로그인
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }
      
      final user = await _socialAuthService.loginWithKakao(token.accessToken);

      await authProvider.setUser(user);

      if (!mounted) return;
      AppNavigation.goSpareHome(context);
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 로그인 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSocialLoggingIn = false;
        });
      }
    }
  }

  Future<void> _handleNaverLogin() async {
    setState(() {
      _isSocialLoggingIn = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // 네이버 SDK를 사용하여 로그인
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        final accessToken = result.accessToken?.accessToken;
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('네이버 로그인 토큰을 받을 수 없습니다');
        }

        final user = await _socialAuthService.loginWithNaver(accessToken);

        await authProvider.setUser(user);

        if (!mounted) return;
        AppNavigation.goSpareHome(context);
      } else {
        throw Exception('네이버 로그인이 취소되었습니다');
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('네이버 로그인 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSocialLoggingIn = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isSocialLoggingIn = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // 구글 SDK를 사용하여 로그인
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인 취소
        setState(() {
          _isSocialLoggingIn = false;
        });
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('구글 로그인 토큰을 받을 수 없습니다');
      }
      
      final user = await _socialAuthService.loginWithGoogle(idToken);

      await authProvider.setUser(user);

      if (!mounted) return;
      AppNavigation.goSpareHome(context);
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구글 로그인 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSocialLoggingIn = false;
        });
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
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: AppTheme.spacing(AppTheme.spacing4), // px-4 py-4
              child: Row(
                children: [
                  // 뒤로가기 버튼
                  IconButton(
                    icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ?? const Icon(Icons.arrow_back),
                    color: AppTheme.textSecondary, // text-gray-600
                    onPressed: () => AppNavigation.backFromLogin(context),
                  ),
                  // 중앙 타이틀
                  Expanded(
                    child: Text(
                      '로그인',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18, // text-lg
                        fontWeight: FontWeight.w600, // font-semibold
                        color: AppTheme.textPrimary, // text-gray-900
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 균형을 위한 빈 공간
                  const SizedBox(width: 48), // w-6
                ],
              ),
            ),

            // 로그인 폼
            Expanded(
              child: SingleChildScrollView(
                padding: AppTheme.spacingSymmetric(
                  horizontal: AppTheme.spacing6, // px-6
                  vertical: AppTheme.spacing8, // py-8
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
                        child: Column(
                          children: [
                            // 로고 영역 (미용실 로그인과 동일: 보라 그라데이션 + 흰색 H)
                            Column(
                              children: [
                                const SizedBox(height: AppTheme.spacing12),
                                const HairSpareBrandSymbol(),
                              ],
                            ),

                                const SizedBox(height: AppTheme.spacing8), // mb-8

                            if (ApiConfig.useMockData) ...[
                              Container(
                                width: double.infinity,
                                padding: AppTheme.spacing(AppTheme.spacing3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                                  borderRadius:
                                      AppTheme.borderRadius(AppTheme.radiusLg),
                                  border: Border.all(
                                    color: AppTheme.primaryPurple.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  '목 데이터: 스페어 ${MockAuthData.devSpareUsername}/${MockAuthData.devSparePassword} · '
                                  '샵 ${MockAuthData.devShopUsername}/${MockAuthData.devShopPassword} · '
                                  '관리자 ${MockAuthData.devAdminUsername}/${MockAuthData.devAdminPassword}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                            ],

                            // 입력 필드들
                            Column(
                              children: [
                                // 아이디 입력
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    hintText: '아이디',
                                    border: OutlineInputBorder(
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg), // rounded-lg
                                      borderSide: const BorderSide(color: AppTheme.borderGray300), // border-gray-300
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                      borderSide: const BorderSide(color: AppTheme.borderGray300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                      borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2), // focus:border-purple-500
                                    ),
                                    contentPadding: AppTheme.spacing(AppTheme.spacing4), // p-4
                                    filled: true,
                                    fillColor: AppTheme.backgroundWhite, // bg-white
                                  ),
                                  style: const TextStyle(fontSize: 16), // text-base
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '아이디를 입력해주세요';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppTheme.spacing4), // space-y-4

                                // 비밀번호 입력
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: '비밀번호',
                                    border: OutlineInputBorder(
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg), // rounded-lg
                                      borderSide: const BorderSide(color: AppTheme.borderGray300), // border-gray-300
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                      borderSide: const BorderSide(color: AppTheme.borderGray300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                                      borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2), // focus:border-purple-500
                                    ),
                                    contentPadding: AppTheme.spacing(AppTheme.spacing4), // p-4
                                    filled: true,
                                    fillColor: AppTheme.backgroundWhite, // bg-white
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: AppTheme.textSecondary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16), // text-base
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '비밀번호를 입력해주세요';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppTheme.spacing4), // space-y-4

                                // 로그인 버튼
                                Consumer<AuthProvider>(
                                  builder: (context, authProvider, _) {
                                    return _LoginButton(
                                      isLoading: authProvider.isLoading,
                                      onPressed: _handleLogin,
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: AppTheme.spacing8), // mb-8

                            // 하단 링크
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    context.push(AppRoutes.spareSignup);
                                  },
                                  child: Text(
                                    '회원가입',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14, // text-sm
                                      color: AppTheme.textSecondary, // text-gray-600
                                    ),
                                  ),
                                ),
                                const Text(
                                  '|',
                                  style: TextStyle(color: AppTheme.borderGray300), // text-gray-300
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push(AppRoutes.spareFindId);
                                  },
                                  child: Text(
                                    '아이디 찾기',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14, // text-sm
                                      color: AppTheme.textSecondary, // text-gray-600
                                    ),
                                  ),
                                ),
                                const Text(
                                  '|',
                                  style: TextStyle(color: AppTheme.borderGray300), // text-gray-300
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push(AppRoutes.spareFindPassword);
                                  },
                                  child: Text(
                                    '비밀번호 찾기',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 14, // text-sm
                                      color: AppTheme.textSecondary, // text-gray-600
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppTheme.spacing8), // mb-8

                            // 간편 로그인 섹션
                            Column(
                              children: [
                                Text(
                                  '또는 간편 로그인/회원가입',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 14, // text-sm
                                    color: AppTheme.textTertiary, // text-gray-500
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacing4), // mb-4
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // 카카오 로그인 버튼
                                    SocialLoginButton(
                                      provider: SocialProvider.kakao,
                                      isLoading: _isSocialLoggingIn,
                                      onPressed: _isSocialLoggingIn ? null : _handleKakaoLogin,
                                    ),
                                    const SizedBox(width: AppTheme.spacing4), // gap-4
                                    // 네이버 로그인 버튼
                                    SocialLoginButton(
                                      provider: SocialProvider.naver,
                                      isLoading: _isSocialLoggingIn,
                                      onPressed: _isSocialLoggingIn ? null : _handleNaverLogin,
                                    ),
                                    const SizedBox(width: AppTheme.spacing4), // gap-4
                                    // 구글 로그인 버튼
                                    SocialLoginButton(
                                      provider: SocialProvider.google,
                                      isLoading: _isSocialLoggingIn,
                                      onPressed: _isSocialLoggingIn ? null : _handleGoogleLogin,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
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

class _LoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading) widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Opacity(
        opacity: widget.isLoading ? 0.5 : 1.0, // disabled:opacity-50
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: AppTheme.spacingVertical(AppTheme.spacing4), // py-4
          transform: Matrix4.identity()
            ..scaleByDouble(
              _isPressed ? 0.98 : 1.0,
              _isPressed ? 0.98 : 1.0,
              _isPressed ? 0.98 : 1.0,
              1.0,
            ), // active:scale-[0.98]
          decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: _isPressed
                ? [AppTheme.primaryPurpleDark, AppTheme.primaryPurpleDarker] // hover:from-purple-700 hover:to-purple-800
                : [AppTheme.primaryPurple, AppTheme.primaryPurpleDark], // from-purple-600 to-purple-700
          ),
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg), // rounded-lg
          boxShadow: AppTheme.shadowMd, // shadow-md
        ),
        child: widget.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '로그인',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 16, // text-base
                  fontWeight: FontWeight.w600, // font-semibold
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
        ),
      ),
    );
  }
}

