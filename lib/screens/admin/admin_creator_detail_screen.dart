import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_challenge_video_tile.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';
import '../../widgets/common/app_network_image.dart';

/// 크리에이터 상세
class AdminCreatorDetailScreen extends StatefulWidget {
  const AdminCreatorDetailScreen({
    super.key,
    required this.creatorId,
    this.initialData,
  });

  final String creatorId;
  final Map<String, dynamic>? initialData;

  @override
  State<AdminCreatorDetailScreen> createState() => _AdminCreatorDetailScreenState();
}

class _AdminCreatorDetailScreenState extends State<AdminCreatorDetailScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _creator;
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;
  bool _videosLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _creator = widget.initialData;
      _isLoading = false;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _adminService.getCreatorDetail(widget.creatorId);
      if (!mounted) return;
      setState(() {
        _creator = data;
        _isLoading = false;
      });
      await _loadVideos();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e));
        _isLoading = false;
        if (_creator == null && widget.initialData != null) {
          _creator = widget.initialData;
        }
      });
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    try {
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR')
          .format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  Future<void> _loadVideos() async {
    final userId = _creator?['userId']?.toString();
    if (userId == null) return;
    setState(() => _videosLoading = true);
    try {
      final videos = await _adminService.getUserChallengeVideos(userId);
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _videosLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _videosLoading = false);
    }
  }

  Future<void> _moderateVideo(
    Map<String, dynamic> video,
    String status, {
    required String title,
    required String confirmLabel,
  }) async {
    final note = await AdminActionDialog.show(
      context,
      title: title,
      confirmLabel: confirmLabel,
      summary: video['title']?.toString(),
    );
    if (note == null || !mounted) return;
    try {
      await _adminService.moderateChallengeVideo(
        video['id'].toString(),
        status: status,
        note: note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$confirmLabel 처리되었습니다')),
      );
      await _loadVideos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<void> _deleteVideo(Map<String, dynamic> video) async {
    final confirmed = await AdminActionDialog.confirm(
      context,
      title: '영상 삭제',
      message: '"${video['title']}" 영상을 삭제할까요? 삭제하면 복구할 수 없습니다.',
      confirmLabel: '삭제',
      isDanger: true,
    );
    if (confirmed != true || !mounted) return;
    try {
      await _adminService.deleteChallengeVideo(video['id'].toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('영상이 삭제되었습니다')),
      );
      await _loadVideos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<void> _verify() async {
    final reason = await AdminActionDialog.show(
      context,
      title: '크리에이터 인증',
      confirmLabel: '인증',
      summary: _creator?['name']?.toString(),
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.verifyCreator(widget.creatorId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('크리에이터 인증 완료')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _creator == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_creator == null || _creator!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? '크리에이터를 찾을 수 없습니다'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final c = _creator!;
    final verified = c['verified'] == true;
    final tags = (c['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final pendingCount = ChallengeVideoModeration.pendingCount(_videos);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              const SizedBox(width: AppTheme.spacing1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('크리에이터 상세', style: AdminStitchTheme.pageTitleMobile),
                    Text(
                      c['name']?.toString() ?? '-',
                      style: AdminStitchTheme.pageSubtitle.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (!verified)
                FilledButton.icon(
                  onPressed: _verify,
                  icon: const Icon(Icons.verified, size: 18),
                  label: const Text('인증'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
                ),
            ],
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchCard(
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: c['avatarUrl'] != null
                      ? AppNetworkImage(
                          imageUrl: c['avatarUrl'].toString(),
                          fit: BoxFit.cover,
                        )
                      : ColoredBox(
                          color: AdminStitchTheme.primaryFixed,
                          child: Center(
                            child: Text(
                              (c['name']?.toString() ?? '?').characters.first,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AdminStitchTheme.primary,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c['name']?.toString() ?? '-',
                              style: AdminStitchTheme.sectionHeader.copyWith(fontSize: 18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: verified ? AppTheme.green50 : AdminStitchTheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              verified ? '인증됨' : '미인증',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: verified ? AppTheme.green600 : AdminStitchTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((c['email']?.toString() ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          c['email'].toString(),
                          style: AdminStitchTheme.bodyMd.copyWith(
                            color: AdminStitchTheme.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '등록 ${_formatDate(c['createdAt']?.toString())}',
                        style: AdminStitchTheme.labelSm.copyWith(
                          color: AdminStitchTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          Row(
            children: [
              Expanded(
                child: AdminStitchMetricCard(
                  label: '구독자',
                  value: '${c['subscriberCount'] ?? 0}',
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminStitchMetricCard(
                  label: '영상',
                  value: '${_videos.isNotEmpty ? _videos.length : (c['videoCount'] ?? 0)}',
                  icon: Icons.play_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminStitchMetricCard(
                  label: '좋아요',
                  value: '${c['likeCount'] ?? 0}',
                  icon: Icons.favorite_border,
                ),
              ),
            ],
          ),
          if ((c['bio']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: AdminStitchTheme.sectionGap),
            const AdminStitchSectionTitle(title: '소개'),
            const SizedBox(height: AdminStitchTheme.stackTight),
            AdminStitchCard(
              child: Text(
                c['bio'].toString(),
                style: AdminStitchTheme.bodyMd,
              ),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: AdminStitchTheme.sectionGap),
            const AdminStitchSectionTitle(title: '태그'),
            const SizedBox(height: AdminStitchTheme.stackTight),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: AdminStitchTheme.primaryFixed,
                      labelStyle: const TextStyle(
                        color: AdminStitchTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: AdminStitchTheme.sectionGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AdminStitchSectionTitle(title: '최근 영상'),
              if (c['userId'] != null)
                TextButton(
                  onPressed: () => context.push(
                    AppRoutes.adminUserDetail(c['userId'].toString()),
                  ),
                  child: const Text('회원 상세'),
                ),
            ],
          ),
          const SizedBox(height: AdminStitchTheme.stackTight),
          if (pendingCount > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: AdminStitchTheme.stackTight),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.orange600.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
                border: Border.all(color: AppTheme.orange600.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Icon(Icons.rate_review, color: AppTheme.orange600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '검수 대기 영상 $pendingCount건 — 승인·제한·삭제 처리가 필요합니다',
                      style: AdminStitchTheme.labelSm.copyWith(
                        color: AppTheme.orange600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_videosLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_videos.isEmpty)
            AdminStitchCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '등록된 영상이 없습니다',
                    style: AdminStitchTheme.bodyMd.copyWith(
                      color: AdminStitchTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            )
          else
            ..._videos.map((video) {
              final status = ChallengeVideoModeration.statusOf(video);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AdminChallengeVideoTile(
                  video: video,
                  onApprove: status == 'pending'
                      ? () => _moderateVideo(
                            video,
                            'approved',
                            title: '영상 승인',
                            confirmLabel: '승인',
                          )
                      : null,
                  onLimit: status != 'limited'
                      ? () => _moderateVideo(
                            video,
                            'limited',
                            title: '제한 노출 (노딱)',
                            confirmLabel: '제한',
                          )
                      : null,
                  onHide: status != 'hidden'
                      ? () => _moderateVideo(
                            video,
                            'hidden',
                            title: '영상 숨김',
                            confirmLabel: '숨김',
                          )
                      : status == 'hidden'
                          ? () => _moderateVideo(
                                video,
                                'approved',
                                title: '영상 복구 (공개)',
                                confirmLabel: '복구',
                              )
                          : null,
                  onDelete: () => _deleteVideo(video),
                ),
              );
            }),
        ],
      ),
    );
  }
}
