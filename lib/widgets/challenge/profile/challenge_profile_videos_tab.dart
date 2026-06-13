import 'package:flutter/material.dart';

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
  List<MyChallenge> _videos = [];
  bool _isLoading = true;
  String _filter = 'all';
  String _sortBy = 'latest';

  @override
  void initState() {
    super.initState();
    _loadVideos();
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
