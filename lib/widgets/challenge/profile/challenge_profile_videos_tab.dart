import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/services/global_messenger_service.dart';
import 'package:hairspare/models/challenge_profile.dart';
import 'package:hairspare/services/challenge_service.dart';
import 'package:hairspare/theme/app_theme.dart';
import 'package:hairspare/utils/count_format.dart';
import 'package:hairspare/utils/error_handler.dart';
import 'package:hairspare/utils/icon_mapper.dart';
/// 프로필 · 영상 그리드 탭 (본인 / 타인).
class ChallengeProfileVideosTab extends StatefulWidget {
  const ChallengeProfileVideosTab({
    super.key,
    required this.targetUserId,
    required this.isOwnProfile,
    required this.onVideoTap,
  });

  final String targetUserId;
  final bool isOwnProfile;
  final void Function(MyChallenge video) onVideoTap;

  @override
  State<ChallengeProfileVideosTab> createState() =>
      _ChallengeProfileVideosTabState();
}

class _ChallengeProfileVideosTabState extends State<ChallengeProfileVideosTab> {
  final ChallengeService _challengeService = ChallengeService();
  final ImagePicker _imagePicker = ImagePicker();
  List<MyChallenge> _videos = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String _filter = 'all';
  String _sortBy = 'latest';

  GlobalMessengerService get _messenger => sl<GlobalMessengerService>();

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _showUploadSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppTheme.backgroundWhite,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: IconMapper.icon('image', size: 24, color: AppTheme.textPrimary) ??
                  const Icon(Icons.video_library_outlined),
              title: const Text('갤러리에서 영상 선택'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: IconMapper.icon('camera', size: 24, color: AppTheme.textPrimary) ??
                  const Icon(Icons.videocam_outlined),
              title: const Text('카메라로 촬영'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picked = await _imagePicker.pickVideo(source: source);
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    final length = await file.length();
    if (length > 100 * 1024 * 1024) {
      _messenger.showError('영상은 100MB 이하여야 합니다.');
      return;
    }
    if (!mounted) return;

    final title = await _promptVideoTitle();
    if (title == null || title.trim().isEmpty || !mounted) return;

    setState(() => _isUploading = true);
    try {
      final videoUrl = await _challengeService.uploadChallengeVideo(file);
      await _challengeService.createChallenge(
        videoUrl: videoUrl,
        title: title.trim(),
      );
      _messenger.showSuccess('영상이 업로드되었습니다.');
      await _loadVideos();
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      _messenger.showError(ErrorHandler.getUserFriendlyMessage(appException));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<String?> _promptVideoTitle() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('영상 제목'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(hintText: '영상 제목을 입력해주세요'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('업로드'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadVideos() async {
    setState(() => _isLoading = true);

    try {
      final filter = _filter != 'all' ? _filter : null;
      final list = widget.isOwnProfile
          ? await _challengeService.getMyChallenges(
              filter: filter,
              sortBy: _sortBy,
            )
          : await _challengeService.getCreatorPublicVideos(
              widget.targetUserId,
              filter: filter,
              sortBy: _sortBy,
            );
      if (mounted) {
        setState(() => _videos = list);
      }
    } catch (e) {
      ErrorHandler.handleException(e);
      if (mounted) setState(() => _videos = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPrivateFilter = widget.isOwnProfile;

    return Stack(
      children: [
        _buildBody(showPrivateFilter),
        if (widget.isOwnProfile)
          Positioned(
            right: AppTheme.spacing4,
            bottom: AppTheme.spacing4,
            child: _UploadVideoButton(
              isUploading: _isUploading,
              onTap: _isUploading ? null : _showUploadSheet,
            ),
          ),
      ],
    );
  }

  Widget _buildBody(bool showPrivateFilter) {
    return Column(
      children: [
        Container(
          color: AppTheme.backgroundWhite,
          padding: const EdgeInsets.all(AppTheme.spacing3),
          child: Row(
            children: [
              if (showPrivateFilter)
                Expanded(child: _FilterDropdown(
                  value: _filter,
                  onChanged: (v) {
                    setState(() => _filter = v);
                    _loadVideos();
                  },
                ))
              else
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '공개 영상',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: AppTheme.spacing2),
              Expanded(
                child: _SortDropdown(
                  value: _sortBy,
                  onChanged: (v) {
                    setState(() => _sortBy = v);
                    _loadVideos();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _videos.isEmpty
                  ? _EmptyVideosState(isOwnProfile: widget.isOwnProfile)
                  : GridView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacing3),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        final video = _videos[index];
                        return ChallengeProfileVideoGridCell(
                          video: video,
                          onTap: () => widget.onVideoTap(video),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class ChallengeProfileVideoGridCell extends StatelessWidget {
  const ChallengeProfileVideoGridCell({
    super.key,
    required this.video,
    required this.onTap,
  });

  final MyChallenge video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            video.thumbnailUrl != null
                ? Image.network(
                    video.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFF1F2937),
                    ),
                  )
                : const ColoredBox(color: Color(0xFF1F2937)),
            const Center(
              child: Icon(Icons.play_arrow, color: Colors.white70, size: 28),
            ),
            Positioned(
              left: 4,
              bottom: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, size: 11, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    CountFormat.compact(video.likes),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (!video.isPublic)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    '비공개',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _DropdownShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('전체')),
            DropdownMenuItem(value: 'public', child: Text('공개')),
            DropdownMenuItem(value: 'private', child: Text('비공개')),
          ],
          onChanged: (v) => onChanged(v ?? 'all'),
        ),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _DropdownShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'latest', child: Text('최신순')),
            DropdownMenuItem(value: 'popular', child: Text('인기순')),
            DropdownMenuItem(value: 'views', child: Text('조회수순')),
          ],
          onChanged: (v) => onChanged(v ?? 'latest'),
        ),
      ),
    );
  }
}

class _DropdownShell extends StatelessWidget {
  const _DropdownShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing2),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _UploadVideoButton extends StatelessWidget {
  const _UploadVideoButton({
    required this.isUploading,
    required this.onTap,
  });

  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: isUploading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _EmptyVideosState extends StatelessWidget {
  const _EmptyVideosState({required this.isOwnProfile});

  final bool isOwnProfile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconMapper.icon('video', size: 64, color: AppTheme.textTertiary) ??
              const Icon(
                Icons.video_library,
                size: 64,
                color: AppTheme.textTertiary,
              ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            isOwnProfile ? '업로드한 영상이 없습니다' : '공개된 영상이 없습니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
