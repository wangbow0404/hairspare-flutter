import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';

/// 관리자 목록 화면 공통 골격 — CustomScrollView + 헤더 sliver + 본문 sliver.
class AdminStitchListScreenShell extends StatelessWidget {
  const AdminStitchListScreenShell({
    super.key,
    required this.header,
    required this.body,
  });

  final Widget header;
  final Widget body;

  static EdgeInsets listPadding(BuildContext context, {double extraBottom = 72}) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return EdgeInsets.fromLTRB(
      AdminStitchTheme.pageMargin,
      0,
      AdminStitchTheme.pageMargin,
      AdminStitchTheme.pageMargin + bottom + extraBottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AdminStitchTheme.pageMargin,
            AdminStitchTheme.pageMargin,
            AdminStitchTheme.pageMargin,
            0,
          ),
          sliver: SliverToBoxAdapter(child: header),
        ),
        body,
      ],
    );
  }
}

/// 로딩 / 에러 / 빈 상태 sliver 헬퍼
class AdminStitchListStateSliver extends StatelessWidget {
  const AdminStitchListStateSliver.loading({super.key})
      : isLoading = true,
        hasError = false,
        emptyMessage = null,
        onRetry = null,
        emptyIcon = Icons.inbox_outlined;

  const AdminStitchListStateSliver.error({
    super.key,
    required VoidCallback this.onRetry,
  })  : isLoading = false,
        hasError = true,
        emptyMessage = null,
        emptyIcon = Icons.inbox_outlined;

  const AdminStitchListStateSliver.empty({
    super.key,
    required this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
  })  : isLoading = false,
        hasError = false,
        onRetry = null;

  final bool isLoading;
  final bool hasError;
  final String? emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ),
      );
    }
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 64, color: AdminStitchTheme.textSecondary),
            const SizedBox(height: 12),
            Text(emptyMessage ?? '데이터가 없습니다'),
          ],
        ),
      ),
    );
  }
}
