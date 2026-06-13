import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_navigation.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';

class SpareProfileLogoutSection extends StatelessWidget {
  const SpareProfileLogoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.spacing(AppTheme.spacing4),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('로그아웃'),
                    content: const Text('로그아웃하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('로그아웃'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await authProvider.logout();
                  if (context.mounted) {
                    AppNavigation.goRoleSelect(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red50,
                foregroundColor: AppTheme.red600,
                elevation: 0,
                padding: AppTheme.spacingSymmetric(
                  horizontal: AppTheme.spacing4,
                  vertical: AppTheme.spacing3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  side: const BorderSide(
                    color: AppTheme.red200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconMapper.icon('logout', size: 20, color: AppTheme.red600) ??
                      const Icon(Icons.logout, size: 20, color: AppTheme.red600),
                  const SizedBox(width: AppTheme.spacing2),
                  Text(
                    '로그아웃',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.red600,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
