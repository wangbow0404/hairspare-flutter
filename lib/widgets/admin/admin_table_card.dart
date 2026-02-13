import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 관리자 테이블 래퍼 (rounded-3xl, border, shadow)
class AdminTableCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AdminTableCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.adminCardDecoration,
      clipBehavior: Clip.antiAlias,
      child: padding != null
          ? Padding(
              padding: padding!,
              child: child,
            )
          : child,
    );
  }
}

/// 관리자 테이블 헤더 행
class AdminTableHeader extends StatelessWidget {
  final List<String> headers;
  final List<int> flexValues;

  const AdminTableHeader({
    super.key,
    required this.headers,
    this.flexValues = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacing6,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppTheme.adminPurple50, AppTheme.adminPink50],
        ),
        border: Border(
          bottom: BorderSide(color: AppTheme.adminPurple100, width: 2),
        ),
      ),
      child: Row(
        children: List.generate(headers.length, (i) {
          final flex = i < flexValues.length ? flexValues[i] : 1;
          return Expanded(
            flex: flex,
            child: Text(
              headers[i].toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textGray700,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ),
    );
  }
}

/// 관리자 테이블 스켈레톤 로딩
class AdminTableSkeleton extends StatelessWidget {
  final int rowCount;
  final int columnCount;

  const AdminTableSkeleton({
    super.key,
    this.rowCount = 5,
    this.columnCount = 7,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AdminTableHeader(
          headers: List.generate(columnCount, (i) => ''),
          flexValues: List.filled(columnCount, 1),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: rowCount,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing4,
                  vertical: AppTheme.spacing3,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.adminPurple100.withOpacity(0.3)),
                  ),
                ),
                child: Row(
                  children: List.generate(columnCount, (i) {
                    return Expanded(
                      child: Container(
                        height: 16,
                        margin: EdgeInsets.only(right: i < columnCount - 1 ? AppTheme.spacing2 : 0),
                        decoration: BoxDecoration(
                          color: AppTheme.borderGray.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
