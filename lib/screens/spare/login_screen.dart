import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../core/router/app_navigation.dart';
import '../../core/router/app_routes.dart';
import '../../widgets/social_login_button.dart'; // SocialLoginButton import
import '../../widgets/common/hairspare_brand_assets.dart';
import '../../utils/icon_mapper.dart'; // IconMapper import
import '../../services/social_auth_service.dart';
import '../../utils/api_config.dart';
import '../../utils/env_config.dart';
import '../../utils/error_handler.dart';
import '../../utils/app_exception.dart';
import '../../mocks/mock_auth_data.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
  GoogleSignIn get _googleSignIn {
    final webClientId = EnvConfig.googleWebClientId;
    final iosClientId = EnvConfig.googleIosClientId;
    return GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: webClientId.isNotEmpty ? webClientId : null,
      clientId: iosClientId.isNotEmpty ? iosClientId : null,
    );
  }
  bool _obscurePassword = true;
  bool _isSocialLoggingIn = false;
  bool _saveId = false;
  bool _autoLogin = false;

  static const _keySaveId = 'spare_save_id';
  static const _keySavedUsername = 'spare_saved_username';
  static const _keyAutoLogin = 'auto_login_enabled';

  bool get _showAppleLogin =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final saveId = prefs.getBool(_keySaveId) ?? false;
    final autoLogin = prefs.getBool(_keyAutoLogin) ?? false;
    final savedUsername = prefs.getString(_keySavedUsername) ?? '';
    if (mounted) {
      setState(() {
        _saveId = saveId;
        _autoLogin = autoLogin;
        if (saveId && savedUsername.isNotEmpty) {
          _usernameController.text = savedUsername;
        }
      });
    }
  }

  Future<void> _onAutoLoginChanged(bool? value) async {
    final v = value ?? false;
    setState(() {
      _autoLogin = v;
      if (v) _saveId = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLogin, v);
  }

  Future<void> _onSaveIdChanged(bool? value) async {
    final v = value ?? false;
    setState(() {
      _saveId = v;
      if (!v) _autoLogin = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySaveId, v);
    if (!v) await prefs.setBool(_keyAutoLogin, false);
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
    
    // 로그인 화면을 역할별로 나누지 않으므로 portal 제한 없이 로그인한다 —
    // 실제 role은 서버 응답으로 오고, 성공 후 goHomeForRole이 알맞은 홈으로 보낸다.
    await authProvider.login(
      username: username,
      password: password,
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
      final prefs = await SharedPreferences.getInstance();
      if (_saveId) {
        await prefs.setString(_keySavedUsername, username);
        await prefs.setBool(_keySaveId, true);
      } else {
        await prefs.remove(_keySavedUsername);
        await prefs.setBool(_keySaveId, false);
      }
      await prefs.setBool(_keyAutoLogin, _autoLogin);

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
      AppNavigation.goHomeForRole(user.role);
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      final friendly = ErrorHandler.getUserFriendlyMessage(appException);
      final debugHint = () {
        if (appException is ServerException && appException.statusCode != null) {
          return ' (HTTP ${appException.statusCode})';
        }
        if (appException is NetworkException && appException.code == 'SERVER_UNAVAILABLE') {
          return ' (서버 재시작 중)';
        }
        return '';
      }();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 로그인 실패: $friendly$debugHint'),
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
        var accessToken = result.accessToken?.accessToken;
        if (accessToken == null || accessToken.isEmpty) {
          final token = await FlutterNaverLogin.getCurrentAccessToken();
          if (token.isValid() && token.accessToken.isNotEmpty) {
            accessToken = token.accessToken;
          }
        }
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('네이버 로그인 토큰을 받을 수 없습니다');
        }

        if (kDebugMode) {
          debugPrint('[NaverLogin] accessToken length=${accessToken.length}');
        }

        final user = await _socialAuthService.loginWithNaver(accessToken);

        await authProvider.setUser(user);

        if (!mounted) return;
        AppNavigation.goHomeForRole(user.role);
      } else {
        throw Exception('네이버 로그인이 취소되었습니다');
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      final friendly = ErrorHandler.getUserFriendlyMessage(appException);
      final debugHint = () {
        if (appException is ServerException && appException.statusCode != null) {
          return ' (HTTP ${appException.statusCode})';
        }
        if (appException is AuthenticationException) {
          return ' (인증 실패)';
        }
        return '';
      }();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('네이버 로그인 실패: $friendly$debugHint'),
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
    if (!EnvConfig.isGoogleSignInConfigured) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '구글 로그인 설정이 필요합니다. GOOGLE_WEB_CLIENT_ID / GOOGLE_IOS_CLIENT_ID 를 설정하세요.',
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }

    setState(() {
      _isSocialLoggingIn = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _isSocialLoggingIn = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('구글 로그인 토큰을 받을 수 없습니다');
      }

      if (kDebugMode) {
        debugPrint('[GoogleLogin] idToken length=${idToken.length}');
      }

      final user = await _socialAuthService.loginWithGoogle(idToken);

      await authProvider.setUser(user);

      if (!mounted) return;
      AppNavigation.goHomeForRole(user.role);
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      final friendly = ErrorHandler.getUserFriendlyMessage(appException);
      final debugHint = () {
        if (appException is ServerException && appException.statusCode != null) {
          return ' (HTTP ${appException.statusCode})';
        }
        if (appException is AuthenticationException) {
          return ' (인증 실패)';
        }
        return '';
      }();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구글 로그인 실패: $friendly$debugHint'),
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

  Future<void> _handleAppleLogin() async {
    setState(() => _isSocialLoggingIn = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw Exception('Apple 로그인 토큰을 받을 수 없습니다');
      }

      final user = await _socialAuthService.loginWithApple(
        identityToken: identityToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        givenName: credential.givenName,
        familyName: credential.familyName,
      );

      await authProvider.setUser(user);

      if (!mounted) return;
      AppNavigation.goHomeForRole(user.role);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Apple 로그인 실패: ${e.message}'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Apple 로그인 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}',
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSocialLoggingIn = false);
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
                                  '모델 ${MockAuthData.devModelUsername}/${MockAuthData.devModelPassword} · '
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
                                // 아이디 저장 / 자동로그인 체크박스
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _saveId,
                                        onChanged: _onSaveIdChanged,
                                        activeColor: AppTheme.primaryPurple,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _onSaveIdChanged(!_saveId),
                                      child: Text(
                                        '아이디 저장',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacing4),
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _autoLogin,
                                        onChanged: _onAutoLoginChanged,
                                        activeColor: AppTheme.primaryPurple,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => _onAutoLoginChanged(!_autoLogin),
                                      child: Text(
                                        '자동로그인',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppTheme.spacing4),

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
                                    if (_showAppleLogin) ...[
                                      const SizedBox(width: AppTheme.spacing4),
                                      SocialLoginButton(
                                        provider: SocialProvider.apple,
                                        isLoading: _isSocialLoggingIn,
                                        onPressed:
                                            _isSocialLoggingIn ? null : _handleAppleLogin,
                                      ),
                                    ],
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
            color: HairSpareColors.brandPrimary,
            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            boxShadow: AppTheme.shadowMd,
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

