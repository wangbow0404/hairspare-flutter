import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/app_routes.dart';
import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';
import '../../widgets/common/app_network_image.dart';

/// 구독 상세
class AdminSubscriptionDetailScreen extends StatefulWidget {
  const AdminSubscriptionDetailScreen({
    super.key,
    required this.subscriptionId,
    this.initialData,
  });

  final String subscriptionId;
  final Map<String, dynamic>? initialData;

  @override
  State<AdminSubscriptionDetailScreen> createState() =>
      _AdminSubscriptionDetailScreenState();
}

class _AdminSubscriptionDetailScreenState extends State<AdminSubscriptionDetailScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _subscription;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _subscription = widget.initialData;
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
      final data = await _adminService.getSubscriptionDetail(widget.subscriptionId);
      if (!mounted) return;
      setState(() {
        _subscription = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e));
        _isLoading = false;
        if (_subscription == null && widget.initialData != null) {
          _subscription = widget.initialData;
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

  String _formatAmount(dynamic amount) {
    if (amount is num && amount > 0) {
      return NumberFormat.currency(locale: 'ko_KR', symbol: '₩').format(amount);
    }
    return '무료 구독';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _subscription == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_subscription == null || _subscription!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? '구독을 찾을 수 없습니다'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final s = _subscription!;
    final isActive = s['isActive'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminStitchTheme.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text('구독 상세', style: AdminStitchTheme.pageTitleMobile),
                    Text(
                      '${s['userName']} → ${s['creatorName']}',
                      style: AdminStitchTheme.pageSubtitle.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.green50 : AdminStitchTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isActive ? '활성' : '해지',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppTheme.green600 : AdminStitchTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          AdminStitchCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(label: '구독 ID', value: s['id']?.toString() ?? '-'),
                _DetailRow(label: '구독 금액', value: _formatAmount(s['amount'])),
                _DetailRow(label: '시작일', value: _formatDate(s['startedAt']?.toString())),
              ],
            ),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          const AdminStitchSectionTitle(title: '구독자'),
          const SizedBox(height: AdminStitchTheme.stackTight),
          AdminStitchCard(
            onTap: s['userId'] != null
                ? () => context.push(AppRoutes.adminUserDetail(s['userId'].toString()))
                : null,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: s['userProfileImage'] != null
                      ? AppNetworkImage(
                          imageUrl: s['userProfileImage'].toString(),
                          fit: BoxFit.cover,
                        )
                      : ColoredBox(
                          color: AdminStitchTheme.surfaceContainer,
                          child: Center(
                            child: Text((s['userName']?.toString() ?? '?').characters.first),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['userName']?.toString() ?? '-',
                        style: AdminStitchTheme.bodyMd.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if ((s['userEmail']?.toString() ?? '').isNotEmpty)
                        Text(
                          s['userEmail'].toString(),
                          style: AdminStitchTheme.labelSm.copyWith(
                            color: AdminStitchTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AdminStitchTheme.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: AdminStitchTheme.sectionGap),
          const AdminStitchSectionTitle(title: '크리에이터'),
          const SizedBox(height: AdminStitchTheme.stackTight),
          AdminStitchCard(
            onTap: s['creatorId'] != null
                ? () => context.push(
                      AppRoutes.adminCreatorDetail(s['creatorId'].toString()),
                    )
                : null,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: s['creatorAvatarUrl'] != null
                      ? AppNetworkImage(
                          imageUrl: s['creatorAvatarUrl'].toString(),
                          fit: BoxFit.cover,
                        )
                      : ColoredBox(
                          color: AdminStitchTheme.primaryFixed,
                          child: Center(
                            child: Text(
                              (s['creatorName']?.toString() ?? '?').characters.first,
                              style: const TextStyle(color: AdminStitchTheme.primary),
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
                        s['creatorName']?.toString() ?? '-',
                        style: AdminStitchTheme.bodyMd.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '구독자 ${s['creatorSubscriberCount'] ?? 0}명',
                        style: AdminStitchTheme.labelSm.copyWith(
                          color: AdminStitchTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AdminStitchTheme.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: AdminStitchTheme.labelSm.copyWith(
                color: AdminStitchTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AdminStitchTheme.bodyMd),
          ),
        ],
      ),
    );
  }
}
