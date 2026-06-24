import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../view_models/profile_edit_view_model.dart';
import '../spare_profile/spare_profile_avatar_gradients.dart';

/// 프로필 수정 — 원형 아바타 + 카메라 버튼.
class SpareProfileEditAvatar extends StatelessWidget {
  const SpareProfileEditAvatar({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Selector<ProfileEditViewModel, (File?, String?)>(
      selector: (_, vm) => (vm.pendingAvatarFile, vm.existingAvatarUrl),
      builder: (context, data, _) {
        final pending = data.$1;
        final existing = data.$2;
        return Center(
          child: Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: spareProfileAvatarGradient(userId),
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  boxShadow: AppTheme.shadowLg,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: pending != null
                      ? Image.file(pending, fit: BoxFit.cover)
                      : existing != null && existing.isNotEmpty
                          ? Image.network(
                              existing,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const _AvatarFallback(),
                            )
                          : const _AvatarFallback(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _pick(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.stitchPrimary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: AppTheme.shadowMd,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('카메라'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    await context.read<ProfileEditViewModel>().pickAvatar(source);
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.person_rounded, size: 52, color: Colors.white),
    );
  }
}
