import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hairspare/theme/app_theme.dart';

Future<void> showShopVerificationPickSource(
  BuildContext context, {
  required void Function(ImageSource source) onChosen,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusXl),
      ),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '사진 선택',
              style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppTheme.spacing3),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리'),
              onTap: () {
                Navigator.pop(ctx);
                onChosen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('카메라'),
              onTap: () {
                Navigator.pop(ctx);
                onChosen(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class ShopVerificationImageTile extends StatelessWidget {
  const ShopVerificationImageTile({
    super.key,
    required this.label,
    required this.guide,
    required this.file,
    required this.onPick,
    required this.onClear,
    this.isLoading = false,
  });

  final String label;
  final String guide;
  final File? file;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.backgroundGray,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              '사업자등록증 인식 중…',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    if (file != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
            child: Image.file(file!, height: 160, fit: BoxFit.cover),
          ),
          const SizedBox(height: AppTheme.spacing2),
          OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('다시 선택'),
          ),
        ],
      );
    }

    return Material(
      color: AppTheme.backgroundGray,
      borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
      child: InkWell(
        onTap: onPick,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        child: Container(
          padding: AppTheme.spacing(AppTheme.spacing5),
          decoration: BoxDecoration(
            borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.borderGray, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 36,
                color: AppTheme.primaryBlue.withValues(alpha: 0.8),
              ),
              const SizedBox(height: AppTheme.spacing2),
              Text(
                '$label 업로드',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                guide,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'JPG, PNG · 최대 5MB',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
