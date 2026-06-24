import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';

/// 관리자 목록/상세 화면 공통 레이아웃 — [AdminLayout]의 Expanded 안에서 안전하게 동작.
class AdminScreenScaffold extends StatelessWidget {
  const AdminScreenScaffold({
    super.key,
    required this.body,
    this.header,
    this.padding = const EdgeInsets.all(AdminStitchTheme.pageMargin),
  });

  final Widget? header;
  final Widget body;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: AdminStitchTheme.sectionGap),
          ],
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
