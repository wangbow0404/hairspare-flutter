import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/di/service_locator.dart';
import '../../theme/app_theme.dart';

/// 모델 가입 — 프로필 사진 1~3장 업로드.
class ModelPhotoUploadSection extends StatefulWidget {
  const ModelPhotoUploadSection({
    super.key,
    required this.photoPaths,
    required this.onChanged,
  });

  final List<String> photoPaths;
  final ValueChanged<List<String>> onChanged;

  @override
  State<ModelPhotoUploadSection> createState() => _ModelPhotoUploadSectionState();
}

class _ModelPhotoUploadSectionState extends State<ModelPhotoUploadSection> {
  static const int _maxPhotos = 3;

  Future<void> _pickPhoto(int index) async {
    final picker = sl<ImagePicker>();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (file == null) return;
    final paths = List<String>.from(widget.photoPaths);
    while (paths.length <= index) {
      paths.add('');
    }
    paths[index] = file.path;
    widget.onChanged(paths.where((p) => p.isNotEmpty).toList());
  }

  void _removePhoto(int index) {
    final paths = List<String>.from(widget.photoPaths);
    if (index < paths.length) {
      paths.removeAt(index);
      widget.onChanged(paths);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '프로필 사진 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.stitchTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing1),
        const Text(
          '얼굴과 헤어가 잘 보이는 밝은 사진 · 과한 필터·타인 사진 불가 · 매칭 카드 대표 사진으로 사용',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.stitchTextSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppTheme.spacing3),
        Row(
          children: [
            for (var i = 0; i < _maxPhotos; i++) ...[
              if (i > 0) const SizedBox(width: AppTheme.spacing3),
              Expanded(child: _PhotoSlot(
                path: i < widget.photoPaths.length ? widget.photoPaths[i] : null,
                label: i == 0 ? '대표' : '${i + 1}',
                onTap: () => _pickPhoto(i),
                onRemove: i < widget.photoPaths.length
                    ? () => _removePhoto(i)
                    : null,
              )),
            ],
          ],
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({
    required this.path,
    required this.label,
    required this.onTap,
    this.onRemove,
  });

  final String? path;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = path != null && path!.isNotEmpty;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Material(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasPhoto)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: Image.file(File(path!), fit: BoxFit.cover),
                )
              else
                const Center(
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: AppTheme.stitchTextSecondary,
                  ),
                ),
              Positioned(
                left: AppTheme.spacing2,
                top: AppTheme.spacing2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (hasPhoto && onRemove != null)
                Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                    onPressed: onRemove,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
