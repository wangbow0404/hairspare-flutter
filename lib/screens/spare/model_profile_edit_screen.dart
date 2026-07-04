import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../models/model_match_preference.dart';
import '../../services/model_self_profile_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/stitch/stitch_sticky_bottom_bar.dart';

/// 모델 프로필 수정 — 가입 시 입력한 기장·선호시술·경력·자기소개·사진 등을 수정.
class ModelProfileEditScreen extends StatefulWidget {
  const ModelProfileEditScreen({super.key});

  @override
  State<ModelProfileEditScreen> createState() =>
      _ModelProfileEditScreenState();
}

class _ModelProfileEditScreenState extends State<ModelProfileEditScreen> {
  final ModelSelfProfileService _service = sl<ModelSelfProfileService>();
  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final _introController = TextEditingController();
  final _regionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  String? _hairLength;
  String? _career;
  final Set<String> _treatments = {};
  final Set<String> _imageTags = {};
  List<String> _imageUrls = [];

  static const int _maxPhotos = 3;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _introController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await _service.getMyProfile();
      setState(() {
        _hairLength = profile.hairLength.isNotEmpty ? profile.hairLength : null;
        _career = profile.career.isNotEmpty ? profile.career : null;
        _treatments
          ..clear()
          ..addAll(profile.preferredTreatments);
        _imageTags
          ..clear()
          ..addAll(profile.imageTags);
        _imageUrls = List<String>.from(profile.imageUrls);
        _introController.text = profile.intro;
        _regionController.text = profile.region;
        _isLoading = false;
      });
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(ex));
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPhoto() async {
    if (_imageUrls.length >= _maxPhotos) {
      _m.showError('사진은 최대 $_maxPhotos장까지 등록할 수 있습니다.');
      return;
    }
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final url = await _service.uploadPhoto(File(picked.path));
      setState(() => _imageUrls = [..._imageUrls, url]);
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(ex));
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _imageUrls = List<String>.from(_imageUrls)..removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_imageUrls.isEmpty) {
      _m.showError('사진을 1장 이상 등록해주세요.');
      return;
    }
    if (_hairLength == null) {
      _m.showError('현재 기장을 선택해주세요.');
      return;
    }
    if (_treatments.isEmpty) {
      _m.showError('선호 시술을 1개 이상 선택해주세요.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _service.updateMyProfile(
        hairLength: _hairLength,
        preferredTreatments: _treatments.toList(),
        imageTags: _imageTags.toList(),
        career: _career,
        intro: _introController.text.trim(),
        region: _regionController.text.trim(),
        imageUrls: _imageUrls,
      );
      _m.showSuccess('프로필이 수정되었습니다.');
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(ex));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SpareSubpageAppBar(
          title: '모델 프로필 수정',
          showToolbarActions: false,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '모델 프로필 수정',
        showToolbarActions: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing4),
        children: [
          _sectionTitle('프로필 사진'),
          _buildPhotoGrid(),
          const SizedBox(height: AppTheme.spacing6),
          _singleChipSection(
            '현재 기장 *',
            ModelMatchOptions.hairLengths,
            _hairLength,
            (v) => setState(() => _hairLength = v),
          ),
          _multiChipSection(
            '선호 시술 *',
            ModelMatchOptions.treatments,
            _treatments,
            (v) => setState(() {
              if (!_treatments.add(v)) _treatments.remove(v);
            }),
          ),
          _multiChipSection(
            '모델 이미지 *',
            ModelMatchOptions.imageStyles,
            _imageTags,
            (v) => setState(() {
              if (!_imageTags.add(v)) _imageTags.remove(v);
            }),
          ),
          _singleChipSection(
            '모델 경력',
            ModelMatchOptions.careers.where((c) => c != '전체').toList(),
            _career,
            (v) => setState(() => _career = v),
          ),
          const SizedBox(height: AppTheme.spacing2),
          TextField(
            controller: _regionController,
            decoration: const InputDecoration(
              labelText: '활동 지역',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          TextField(
            controller: _introController,
            decoration: const InputDecoration(
              labelText: '한줄 소개',
              hintText: '50자 내외로 자신을 소개해 주세요',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: AppTheme.spacing8),
        ],
      ),
      bottomNavigationBar: StitchStickyBottomBar(
        primaryLabel: '저장하기',
        isLoading: _isSaving,
        onPrimary: _isSaving ? null : _save,
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Row(
      children: [
        for (var i = 0; i < _maxPhotos; i++) ...[
          if (i > 0) const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: i < _imageUrls.length
                  ? _PhotoTile(
                      imageUrl: _imageUrls[i],
                      label: i == 0 ? '대표' : '${i + 1}',
                      onRemove: () => _removePhoto(i),
                    )
                  : _AddPhotoTile(
                      isUploading: _isUploadingPhoto && i == _imageUrls.length,
                      onTap: _isUploadingPhoto ? null : _addPhoto,
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _singleChipSection(
    String title,
    List<String> options,
    String? selected,
    ValueChanged<String> onSelect,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: [
              for (final o in options)
                StitchFilterChip(
                  label: o,
                  isSelected: selected == o,
                  onTap: () => onSelect(o),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _multiChipSection(
    String title,
    List<String> options,
    Set<String> selected,
    ValueChanged<String> onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: [
              for (final o in options)
                StitchFilterChip(
                  label: o,
                  isSelected: selected.contains(o),
                  onTap: () => onToggle(o),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.stitchTextPrimary,
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.imageUrl,
    required this.label,
    required this.onRemove,
  });

  final String imageUrl;
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          Positioned(
            left: AppTheme.spacing2,
            top: AppTheme.spacing2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          Positioned(
            right: 4,
            top: 4,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              style: IconButton.styleFrom(backgroundColor: Colors.black45),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.isUploading, required this.onTap});

  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Center(
          child: isUploading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.add_a_photo_outlined,
                  size: 32,
                  color: AppTheme.stitchTextSecondary,
                ),
        ),
      ),
    );
  }
}
