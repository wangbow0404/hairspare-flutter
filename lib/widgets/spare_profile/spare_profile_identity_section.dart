import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/spare_profile_navigation.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../view_models/spare_profile_view_model.dart';
import 'spare_profile_avatar_gradients.dart';
import 'spare_profile_image_sheet.dart';

/// 프로필 사진·이름·연락처·프로필 수정 버튼.
class SpareProfileIdentitySection extends StatelessWidget {
  const SpareProfileIdentitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderGray,
            width: 1,
          ),
        ),
      ),
      padding: AppTheme.spacing(AppTheme.spacing6),
      child: Consumer2<AuthProvider, SpareProfileViewModel>(
        builder: (context, authProvider, vm, _) {
          final user = authProvider.currentUser;
          final displayName = user?.name ?? user?.username ?? '사용자';
          final displayEmail = user?.email ?? '';
          final displayPhone = user?.phone ?? '';

          return Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: user?.id != null
                                ? spareProfileAvatarGradient(user!.id)
                                : [AppTheme.primaryBlue, AppTheme.primaryPurple],
                          ),
                          borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                          boxShadow: AppTheme.shadowLg,
                        ),
                        child: user?.profileImage != null
                            ? ClipRRect(
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                child: Image.network(
                                  user!.profileImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: IconMapper.icon('user', size: 48, color: Colors.white) ??
                                    const Icon(Icons.person, size: 48, color: Colors.white),
                              ),
                      ),
                      if (vm.isUploadingAvatar)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                            child: Container(
                              color: Colors.black38,
                              child: const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: vm.isUploadingAvatar ? null : () => showSpareProfileImageSourceSheet(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                              boxShadow: AppTheme.shadowMd,
                            ),
                            child: IconMapper.icon('edit', size: 16, color: Colors.white) ??
                                const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppTheme.spacing4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            Container(
                              padding: AppTheme.spacingSymmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: AppTheme.spacing1 / 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundGray,
                                borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                              ),
                              child: Text(
                                '이메일',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textGray700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing2),
                        if (displayEmail.isNotEmpty)
                          Row(
                            children: [
                              IconMapper.icon('mail', size: 16, color: AppTheme.textSecondary) ??
                                  const Icon(Icons.email, size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: AppTheme.spacing2),
                              Expanded(
                                child: Text(
                                  displayEmail,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        if (displayPhone.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacing2),
                          Row(
                            children: [
                              IconMapper.icon('phone', size: 16, color: AppTheme.textSecondary) ??
                                  const Icon(Icons.phone, size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: AppTheme.spacing2),
                              Expanded(
                                child: Text(
                                  displayPhone,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => SpareProfileNavigation.pushProfileEdit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.backgroundGray,
                    foregroundColor: AppTheme.textGray700,
                    elevation: 0,
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing2 + AppTheme.spacing1 / 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconMapper.icon('user', size: 16, color: AppTheme.textGray700) ??
                          const Icon(Icons.person, size: 16, color: AppTheme.textGray700),
                      const SizedBox(width: AppTheme.spacing2),
                      Text(
                        '프로필 수정',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textGray700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
