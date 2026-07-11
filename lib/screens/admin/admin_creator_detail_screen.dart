import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
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
  bool _isLoading = true;
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
    final videos = (c['videos'] as List?) ?? [];
    final tags = (c['tags'] as List?)?.map((e) => e.toString()).toList() ?? [];

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
                  value: '${c['videoCount'] ?? 0}',
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
          if (videos.isEmpty)
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
            ...videos.map((v) {
              final video = v as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AdminStitchCard(
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 72,
                          height: 48,
                          child: video['thumbnailUrl'] != null
                              ? AppNetworkImage(
                                  imageUrl: video['thumbnailUrl'].toString(),
                                  fit: BoxFit.cover,
                                )
                              : ColoredBox(
                                  color: AdminStitchTheme.surfaceContainer,
                                  child: Icon(
                                    Icons.videocam_outlined,
                                    color: AdminStitchTheme.textSecondary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video['title']?.toString() ?? '제목 없음',
                              style: AdminStitchTheme.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '조회 ${video['views'] ?? 0} · 좋아요 ${video['likes'] ?? 0}',
                              style: AdminStitchTheme.labelSm.copyWith(
                                color: AdminStitchTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (video['isPublic'] == false)
                        const Icon(Icons.visibility_off, size: 18, color: AdminStitchTheme.textSecondary),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
