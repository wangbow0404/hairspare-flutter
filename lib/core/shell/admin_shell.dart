import 'package:flutter/material.dart';

import '../../widgets/admin_layout.dart';

/// 관리자 영역 Shell — [AdminLayout]을 한 곳에서 감싸 딥링크·`go()`와 동기화.
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: location,
      child: child,
    );
  }
}
