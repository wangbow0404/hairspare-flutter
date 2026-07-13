import 'package:flutter/material.dart';

import '../theme/admin_stitch_theme.dart';

/// 관리자 회원 가입 경로 — HairSpare 앱 가입 vs 소셜(OAuth).
enum AdminSignupProvider {
  hairspare,
  kakao,
  naver,
  google,
  apple,
}

class AdminSignupProviderStyle {
  const AdminSignupProviderStyle({
    required this.provider,
    required this.label,
    required this.shortLabel,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.icon,
    this.leadingText,
  });

  final AdminSignupProvider provider;
  final String label;
  final String shortLabel;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final String? leadingText;
}

abstract final class AdminSignupProviderUtil {
  AdminSignupProviderUtil._();

  static const _nativeKeys = {'email', 'credentials', 'hairspare', 'password', 'social'};

  static AdminSignupProvider resolve(Map<String, dynamic> user) {
    final explicit = user['signupProvider']?.toString().trim().toLowerCase();
    if (explicit != null && explicit.isNotEmpty) {
      return _fromKey(explicit);
    }
    final accounts = user['accounts'];
    if (accounts is! List || accounts.isEmpty) {
      return AdminSignupProvider.hairspare;
    }
    final first = accounts.first;
    if (first is! Map) return AdminSignupProvider.hairspare;
    return _fromKey(first['provider']?.toString());
  }

  static String labelFor(Map<String, dynamic> user) {
    final explicit = user['signupProviderLabel']?.toString();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    return styleFor(user).label;
  }

  static AdminSignupProviderStyle styleFor(Map<String, dynamic> user) {
    return style(resolve(user));
  }

  static AdminSignupProvider _fromKey(String? raw) {
    final key = (raw ?? '').trim().toLowerCase();
    if (key.isEmpty || _nativeKeys.contains(key)) {
      return AdminSignupProvider.hairspare;
    }
    return switch (key) {
      'kakao' => AdminSignupProvider.kakao,
      'naver' => AdminSignupProvider.naver,
      'google' => AdminSignupProvider.google,
      'apple' => AdminSignupProvider.apple,
      _ => AdminSignupProvider.hairspare,
    };
  }

  static AdminSignupProviderStyle style(AdminSignupProvider provider) {
    return switch (provider) {
      AdminSignupProvider.hairspare => const AdminSignupProviderStyle(
          provider: AdminSignupProvider.hairspare,
          label: 'HairSpare 가입',
          shortLabel: 'HairSpare',
          backgroundColor: Color(0xFFF5F3FF),
          textColor: AdminStitchTheme.primary,
          borderColor: Color(0x33580099),
          icon: Icons.spa_outlined,
        ),
      AdminSignupProvider.kakao => const AdminSignupProviderStyle(
          provider: AdminSignupProvider.kakao,
          label: '카카오 가입',
          shortLabel: '카카오',
          backgroundColor: Color(0xFFFEE500),
          textColor: Color(0xFF191919),
          borderColor: Color(0x33CA8A04),
          leadingText: 'K',
        ),
      AdminSignupProvider.naver => const AdminSignupProviderStyle(
          provider: AdminSignupProvider.naver,
          label: '네이버 가입',
          shortLabel: '네이버',
          backgroundColor: Color(0xFF03C75A),
          textColor: Colors.white,
          borderColor: Color(0x3303C75A),
          leadingText: 'N',
        ),
      AdminSignupProvider.google => const AdminSignupProviderStyle(
          provider: AdminSignupProvider.google,
          label: '구글 가입',
          shortLabel: '구글',
          backgroundColor: Colors.white,
          textColor: Color(0xFF4285F4),
          borderColor: Color(0xFFE5E7EB),
          icon: Icons.g_mobiledata_rounded,
        ),
      AdminSignupProvider.apple => const AdminSignupProviderStyle(
          provider: AdminSignupProvider.apple,
          label: 'Apple 가입',
          shortLabel: 'Apple',
          backgroundColor: Color(0xFF111827),
          textColor: Colors.white,
          borderColor: Color(0x33111827),
          icon: Icons.apple,
        ),
    };
  }

  static const signupFilterOptions = {
    '': '전체',
    'hairspare': 'HairSpare',
    'kakao': '카카오',
    'naver': '네이버',
    'google': '구글',
    'apple': 'Apple',
  };
}

/// 회원 목록·상세에서 가입 경로를 표시하는 배지.
class AdminSignupProviderBadge extends StatelessWidget {
  const AdminSignupProviderBadge({
    super.key,
    required this.user,
    this.compact = false,
  });

  final Map<String, dynamic> user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = AdminSignupProviderUtil.styleFor(user);
    final label = compact ? style.shortLabel : style.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (style.leadingText != null) ...[
            Text(
              style.leadingText!,
              style: TextStyle(
                color: style.textColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
          ] else if (style.icon != null) ...[
            Icon(style.icon, size: 12, color: style.textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: style.textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
