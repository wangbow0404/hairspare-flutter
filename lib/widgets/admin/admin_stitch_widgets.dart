import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';
import '../common/app_network_image.dart';

class AdminStitchPageHeader extends StatelessWidget {
  const AdminStitchPageHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AdminStitchTheme.pageTitleForWidth(constraints.maxWidth),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AdminStitchTheme.stackTight),
              Text(
                subtitle!,
                style: AdminStitchTheme.pageSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
      },
    );
  }
}

class AdminStitchSearchField extends StatelessWidget {
  const AdminStitchSearchField({
    super.key,
    required this.controller,
    this.hint = '검색...',
    this.onChanged,
    this.trailing,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: AdminStitchTheme.searchFieldDecoration,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AdminStitchTheme.bodyMd,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AdminStitchTheme.bodyMd.copyWith(
                  color: AdminStitchTheme.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AdminStitchTheme.textSecondary,
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AdminStitchTheme.componentPadding,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AdminStitchTheme.stackTight),
          trailing!,
        ],
      ],
    );
  }
}

class AdminStitchFilterChips extends StatelessWidget {
  const AdminStitchFilterChips({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final tab in tabs) ...[
              AdminStitchFilterChip(
                label: tab,
                selected: tab == selectedTab,
                onTap: () => onTabChanged(tab),
              ),
              const SizedBox(width: AdminStitchTheme.stackTight),
            ],
          ],
        ),
      ),
    );
  }
}

class AdminStitchFilterChip extends StatelessWidget {
  const AdminStitchFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AdminStitchTheme.primary : AdminStitchTheme.surfaceCard,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: selected
                ? null
                : Border.all(color: AdminStitchTheme.borderDefault),
          ),
          child: Text(
            label,
            style: AdminStitchTheme.labelSm.copyWith(
              color: selected
                  ? AdminStitchTheme.onPrimary
                  : AdminStitchTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stitch 스타일 밑줄 탭 (비즈니스 설정 등).
class AdminStitchUnderlineTabBar extends StatelessWidget {
  const AdminStitchUnderlineTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AdminStitchTheme.surfaceCard,
        border: Border(bottom: BorderSide(color: AdminStitchTheme.borderDefault)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AdminStitchTheme.pageMargin),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++) ...[
              _UnderlineTab(
                label: tabs[i],
                selected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UnderlineTab extends StatelessWidget {
  const _UnderlineTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? AdminStitchTheme.primaryContainer
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: selected
              ? AdminStitchTheme.sectionHeader.copyWith(
                  color: AdminStitchTheme.primaryContainer,
                )
              : AdminStitchTheme.bodyMd.copyWith(
                  color: AdminStitchTheme.textSecondary,
                ),
        ),
      ),
    );
  }
}

/// Bento 스타일 세그먼트 탭 (알림 발송 등).
class AdminStitchSegmentedTabBar extends StatelessWidget {
  const AdminStitchSegmentedTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AdminStitchTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        border: Border.all(color: AdminStitchTheme.borderDefault),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: _SegmentedTab(
                label: tabs[i],
                selected: i == selectedIndex,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegmentedTab extends StatelessWidget {
  const _SegmentedTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AdminStitchTheme.surfaceContainerHigh
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AdminStitchTheme.bodyMd.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected
                  ? AdminStitchTheme.onSurface
                  : AdminStitchTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class AdminStitchInfoNote extends StatelessWidget {
  const AdminStitchInfoNote({super.key, required this.message, this.boldSpans});

  final String message;
  final List<String>? boldSpans;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
      decoration: BoxDecoration(
        color: AdminStitchTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
        border: Border.all(color: AdminStitchTheme.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AdminStitchTheme.textSecondary,
          ),
          const SizedBox(width: AdminStitchTheme.stackTight),
          Expanded(child: _buildMessageText()),
        ],
      ),
    );
  }

  Widget _buildMessageText() {
    if (boldSpans == null || boldSpans!.isEmpty) {
      return Text(
        message,
        style: AdminStitchTheme.bodyMd.copyWith(
          color: AdminStitchTheme.textSecondary,
          height: 1.6,
        ),
      );
    }

    final spans = <InlineSpan>[];
    var remaining = message;
    for (final bold in boldSpans!) {
      final index = remaining.indexOf(bold);
      if (index == -1) continue;
      if (index > 0) {
        spans.add(TextSpan(text: remaining.substring(0, index)));
      }
      spans.add(
        TextSpan(
          text: bold,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
      remaining = remaining.substring(index + bold.length);
    }
    if (remaining.isNotEmpty) {
      spans.add(TextSpan(text: remaining));
    }

    return Text.rich(
      TextSpan(
        style: AdminStitchTheme.bodyMd.copyWith(
          color: AdminStitchTheme.textSecondary,
          height: 1.6,
        ),
        children: spans,
      ),
    );
  }
}

/// 관리자 필터용 드롭다운. label(선택 안내)과 options(값→표시명)를 받아
/// 현재 선택값을 보여주고 탭하면 메뉴가 열린다.
class AdminStitchFilterDropdown extends StatelessWidget {
  const AdminStitchFilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> options; // value -> 표시명
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: options.containsKey(value) ? value : options.keys.first,
        isExpanded: true,
        isDense: true,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        style: AdminStitchTheme.labelSm.copyWith(
          color: AdminStitchTheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        selectedItemBuilder: (context) => options.entries
            .map(
              (e) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$label · ${e.value}',
                  style: AdminStitchTheme.labelSm.copyWith(
                    color: AdminStitchTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
        items: options.entries
            .map(
              (e) =>
                  DropdownMenuItem<String>(value: e.key, child: Text(e.value)),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

/// [AdminStitchFilterDropdown]을 카드 테두리로 감싼 컨테이너.
class AdminStitchFilterDropdownBox extends StatelessWidget {
  const AdminStitchFilterDropdownBox({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AdminStitchTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        border: Border.all(color: AdminStitchTheme.borderDefault),
      ),
      child: AdminStitchFilterDropdown(
        label: label,
        value: value,
        options: options,
        onChanged: onChanged,
      ),
    );
  }
}

class AdminStitchCard extends StatelessWidget {
  const AdminStitchCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AdminStitchTheme.componentPadding),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: AdminStitchTheme.cardDecoration,
      child: child,
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        child: card,
      ),
    );
  }
}

class AdminStitchSectionTitle extends StatelessWidget {
  const AdminStitchSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminStitchTheme.componentPadding),
      child: Text(title, style: AdminStitchTheme.sectionHeader),
    );
  }
}

class AdminStitchMetricCard extends StatelessWidget {
  const AdminStitchMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.trendLabel,
    this.useSecondaryIcon = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? trendLabel;
  final bool useSecondaryIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconBg = useSecondaryIcon
        ? AdminStitchTheme.secondaryFixed
        : AdminStitchTheme.primaryFixed;
    final iconColor = useSecondaryIcon
        ? AdminStitchTheme.secondary
        : AdminStitchTheme.primary;

    return AdminStitchCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AdminStitchTheme.labelSm.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: AdminStitchTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(
                    AdminStitchTheme.radiusLg,
                  ),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: AdminStitchTheme.headlineMd),
          if (trendLabel != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.arrow_upward,
                  size: 14,
                  color: AdminStitchTheme.emerald,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    trendLabel!,
                    style: AdminStitchTheme.labelSm.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AdminStitchTheme.emerald,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class AdminStitchAlertMetricCard extends StatelessWidget {
  const AdminStitchAlertMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AdminStitchDashboardPendingCard(
      label: label,
      value: value,
      subtitle: subtitle ?? '조치 필요',
      icon: icon,
      tone: AdminDashboardPendingTone.alert,
      onTap: onTap,
    );
  }
}

/// 대시보드 2×2 대기/알림 카드 (목업 parity)
enum AdminDashboardPendingTone { alert, neutral }

class AdminStitchDashboardPendingCard extends StatelessWidget {
  const AdminStitchDashboardPendingCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.tone = AdminDashboardPendingTone.neutral,
    this.onTap,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final AdminDashboardPendingTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isAlert = tone == AdminDashboardPendingTone.alert;
    final bg = isAlert
        ? AdminStitchTheme.alertPeachBg
        : AdminStitchTheme.surfaceCard;
    final borderColor = isAlert
        ? AdminStitchTheme.alertPeachBorder
        : AdminStitchTheme.borderDefault;
    final labelColor = isAlert
        ? AdminStitchTheme.alertPeachLabel
        : AdminStitchTheme.textSecondary;
    final subtitleColor = isAlert
        ? AdminStitchTheme.alertPeachSubtitle
        : AdminStitchTheme.textSecondary;
    final iconBg = isAlert
        ? Colors.white.withValues(alpha: 0.65)
        : AdminStitchTheme.surfaceContainer;
    final iconColor = isAlert
        ? AdminStitchTheme.alertPeachSubtitle
        : AdminStitchTheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
        child: Container(
          padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
            border: Border.all(color: borderColor),
            boxShadow: isAlert
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      style: AdminStitchTheme.labelSm.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.6,
                        color: labelColor,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(
                        AdminStitchTheme.radiusLg,
                      ),
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(value, style: AdminStitchTheme.headlineMd),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AdminStitchTheme.labelSm.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminStitchPaymentsHeroCard extends StatelessWidget {
  const AdminStitchPaymentsHeroCard({
    super.key,
    required this.label,
    required this.value,
    this.trendLabel,
    this.onTap,
  });

  final String label;
  final String value;
  final String? trendLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
          decoration: BoxDecoration(
            gradient: AdminStitchTheme.paymentsGradient,
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33580099),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AdminStitchTheme.labelSm.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.8,
                        color: AdminStitchTheme.onPrimary.withValues(
                          alpha: 0.85,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: AdminStitchTheme.headlineMobile.copyWith(
                        color: AdminStitchTheme.onPrimary,
                      ),
                    ),
                    if (trendLabel != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            size: 14,
                            color: AdminStitchTheme.emeraldLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trendLabel!,
                            style: AdminStitchTheme.labelSm.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AdminStitchTheme.emeraldLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    AdminStitchTheme.radiusLg,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AdminStitchTheme.onPrimary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminStitchListRowCard extends StatelessWidget {
  const AdminStitchListRowCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AdminStitchCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminStitchTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
            ),
            child: Icon(icon, color: AdminStitchTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AdminStitchTheme.labelSm.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: AdminStitchTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: AdminStitchTheme.headlineMd),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AdminStitchTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class AdminStitchUserDistributionCard extends StatelessWidget {
  const AdminStitchUserDistributionCard({super.key, required this.byRole});

  final Map<String, int> byRole;

  static const _roleLabels = {
    'spare_designer': '스페어·디자이너',
    'shop': '샵',
    'model': '모델',
  };

  static const _roleColors = {
    'spare_designer': AdminStitchTheme.primary,
    'shop': AdminStitchTheme.secondary,
    'model': AdminStitchTheme.emerald,
  };

  @override
  Widget build(BuildContext context) {
    final entries = _roleLabels.entries
        .map((e) => MapEntry(e.key, byRole[e.key] ?? 0))
        .toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final safeTotal = total > 0 ? total : 1;

    return AdminStitchCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('회원 분포', style: AdminStitchTheme.sectionHeader),
          const SizedBox(height: AdminStitchTheme.componentPadding),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _RoleDistributionRow(
              label: _roleLabels[entries[i].key]!,
              count: entries[i].value,
              fraction: entries[i].value / safeTotal,
              color: _roleColors[entries[i].key] ?? AdminStitchTheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}

class _RoleDistributionRow extends StatelessWidget {
  const _RoleDistributionRow({
    required this.label,
    required this.count,
    required this.fraction,
    required this.color,
  });

  final String label;
  final int count;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AdminStitchTheme.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count',
              style: AdminStitchTheme.labelSm.copyWith(
                color: AdminStitchTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AdminStitchTheme.surfaceContainerHigh,
            color: color,
          ),
        ),
      ],
    );
  }
}

class AdminStitchActivityList extends StatelessWidget {
  const AdminStitchActivityList({
    super.key,
    required this.activities,
    this.onViewAll,
  });

  final List<Map<String, dynamic>> activities;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return AdminStitchCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최근 활동', style: AdminStitchTheme.sectionHeader),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체보기',
                        style: AdminStitchTheme.labelSm.copyWith(
                          color: AdminStitchTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AdminStitchTheme.primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(color: AdminStitchTheme.borderDefault, height: 24),
          for (var i = 0; i < activities.length; i++) ...[
            AdminStitchActivityItem(activity: activities[i]),
            if (i < activities.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class AdminStitchActivityItem extends StatelessWidget {
  const AdminStitchActivityItem({super.key, required this.activity});

  final Map<String, dynamic> activity;

  ({IconData icon, Color bg, Color fg}) _resolveStyle() {
    final type = activity['type']?.toString() ?? '';
    final colorKey = activity['color']?.toString() ?? '';

    if (type.contains('report') || type.contains('noshow')) {
      return (
        icon: Icons.gavel,
        bg: AdminStitchTheme.errorContainer,
        fg: AdminStitchTheme.statusError,
      );
    }
    if (type.contains('payment')) {
      return (
        icon: Icons.payments_outlined,
        bg: const Color(0xFFD1FAE5),
        fg: AdminStitchTheme.emerald,
      );
    }
    if (type.contains('energy')) {
      return (
        icon: Icons.bolt,
        bg: const Color(0xFFFEF3C7),
        fg: const Color(0xFFD97706),
      );
    }
    if (type.contains('schedule') || type.contains('checkin')) {
      return (
        icon: Icons.event_available_outlined,
        bg: AdminStitchTheme.primaryFixed,
        fg: AdminStitchTheme.primary,
      );
    }
    if (type.contains('job')) {
      return (
        icon: Icons.work_outline,
        bg: AdminStitchTheme.secondaryFixed,
        fg: AdminStitchTheme.secondary,
      );
    }
    if (colorKey == 'green') {
      return (
        icon: Icons.payments_outlined,
        bg: const Color(0xFFD1FAE5),
        fg: AdminStitchTheme.emerald,
      );
    }
    if (colorKey == 'red') {
      return (
        icon: Icons.gavel,
        bg: AdminStitchTheme.errorContainer,
        fg: AdminStitchTheme.statusError,
      );
    }
    return (
      icon: Icons.person_add_outlined,
      bg: AdminStitchTheme.surfaceContainerHigh,
      fg: AdminStitchTheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: style.bg, shape: BoxShape.circle),
          child: Icon(style.icon, size: 20, color: style.fg),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['description']?.toString() ??
                    '${activity['label'] ?? ''} · ${activity['entity'] ?? ''}',
                style: AdminStitchTheme.bodyMd.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activity['source'] != null
                    ? '${activity['ago'] ?? ''} · ${activity['source']}'
                    : activity['ago']?.toString() ?? '',
                style: AdminStitchTheme.labelSm.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AdminStitchTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminStitchUserCard extends StatelessWidget {
  const AdminStitchUserCard({
    super.key,
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.roleColor,
    required this.joinedLabel,
    required this.isActive,
    this.avatarUrl,
    this.initials,
    this.onTap,
    this.onMore,
  });

  final String name;
  final String email;
  final String roleLabel;
  final Color roleColor;
  final String joinedLabel;
  final bool isActive;
  final String? avatarUrl;
  final String? initials;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return AdminStitchCard(
      onTap: onTap,
      child: Row(
        children: [
          _Avatar(
            avatarUrl: avatarUrl,
            initials: initials ?? name.characters.first,
            isActive: isActive,
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
                        name,
                        style: AdminStitchTheme.sectionHeader.copyWith(
                          fontSize: 16,
                          decoration: isActive
                              ? null
                              : TextDecoration.lineThrough,
                          color: isActive
                              ? AdminStitchTheme.onSurface
                              : AdminStitchTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _RoleBadge(label: roleLabel, color: roleColor),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AdminStitchTheme.bodyMd.copyWith(
                    color: AdminStitchTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AdminStitchTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      joinedLabel,
                      style: AdminStitchTheme.labelSm.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AdminStitchTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMore,
            tooltip: '더보기',
            icon: const Icon(
              Icons.more_vert,
              color: AdminStitchTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.isActive,
    this.avatarUrl,
  });

  final String? avatarUrl;
  final String initials;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          ClipOval(
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? SizedBox(
                    width: 48,
                    height: 48,
                    child: AppNetworkImage(
                      imageUrl: avatarUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : _initialsCircle(),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isActive
                    ? AdminStitchTheme.emerald
                    : AdminStitchTheme.statusError,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AdminStitchTheme.surfaceCard,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsCircle() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AdminStitchTheme.surfaceContainerHigh,
        shape: BoxShape.circle,
        border: Border.all(color: AdminStitchTheme.borderDefault),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: AdminStitchTheme.sectionHeader.copyWith(fontSize: 16),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isShop = color == AdminStitchTheme.secondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isShop
            ? AdminStitchTheme.secondaryContainer
            : AdminStitchTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AdminStitchTheme.labelSm.copyWith(
          fontSize: 11,
          color: isShop
              ? AdminStitchTheme.onSecondaryContainer
              : AdminStitchTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class AdminStitchReportCaseCard extends StatelessWidget {
  const AdminStitchReportCaseCard({
    super.key,
    required this.caseId,
    required this.title,
    required this.targetName,
    required this.reporterName,
    required this.priorityLabel,
    required this.priorityColor,
    required this.statusLabel,
    required this.isHighPriority,
    required this.isUnderReview,
    this.onTap,
    this.onDismiss,
    this.onReview,
    this.showActions = true,
  });

  final String caseId;
  final String title;
  final String targetName;
  final String reporterName;
  final String priorityLabel;
  final Color priorityColor;
  final String statusLabel;
  final bool isHighPriority;
  final bool isUnderReview;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onReview;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            color: AdminStitchTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            border: Border.all(color: AdminStitchTheme.borderDefault),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ColoredBox(
                  color: priorityColor,
                  child: const SizedBox(width: 4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AdminStitchTheme.componentPadding + 4,
                  top: AdminStitchTheme.componentPadding,
                  right: AdminStitchTheme.componentPadding,
                  bottom: AdminStitchTheme.componentPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              caseId,
                              style: AdminStitchTheme.labelSm.copyWith(
                                color: AdminStitchTheme.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _PriorityBadge(
                              label: priorityLabel,
                              isHigh: isHighPriority,
                            ),
                          ],
                        ),
                        _StatusBadge(
                          label: statusLabel,
                          isUnderReview: isUnderReview,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(title, style: AdminStitchTheme.sectionHeader),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: '피신고',
                      value: targetName,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.flag_outlined,
                      label: '신고자',
                      value: reporterName,
                    ),
                    if (showActions) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onDismiss != null)
                            OutlinedButton(
                              onPressed: onDismiss,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AdminStitchTheme.textSecondary,
                                side: const BorderSide(
                                  color: AdminStitchTheme.borderDefault,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('기각'),
                            ),
                          if (onReview != null) ...[
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: onReview,
                              style: FilledButton.styleFrom(
                                backgroundColor: AdminStitchTheme.primary,
                                foregroundColor: AdminStitchTheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('검토'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// M2. 인증 심사 큐 카드 (Stitch)
class AdminStitchVerificationCard extends StatelessWidget {
  const AdminStitchVerificationCard({
    super.key,
    required this.requestId,
    required this.typeLabel,
    required this.userName,
    required this.userEmail,
    required this.roleLabel,
    required this.statusLabel,
    required this.submittedAtLabel,
    required this.typeColor,
    required this.isPending,
    required this.isApproved,
    this.onTap,
    this.onApprove,
    this.onReject,
  });

  final String requestId;
  final String typeLabel;
  final String userName;
  final String userEmail;
  final String roleLabel;
  final String statusLabel;
  final String submittedAtLabel;
  final Color typeColor;
  final bool isPending;
  final bool isApproved;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            color: AdminStitchTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            border: Border.all(color: AdminStitchTheme.borderDefault),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ColoredBox(
                  color: typeColor,
                  child: const SizedBox(width: 4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: AdminStitchTheme.componentPadding + 4,
                  top: AdminStitchTheme.componentPadding,
                  right: AdminStitchTheme.componentPadding,
                  bottom: AdminStitchTheme.componentPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              requestId,
                              style: AdminStitchTheme.labelSm.copyWith(
                                color: AdminStitchTheme.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _VerificationTypeBadge(label: typeLabel),
                          ],
                        ),
                        _VerificationStatusBadge(
                          label: statusLabel,
                          isPending: isPending,
                          isApproved: isApproved,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(userName, style: AdminStitchTheme.sectionHeader),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: '이메일',
                      value: userEmail,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: '역할',
                      value: roleLabel,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: '제출일',
                      value: submittedAtLabel,
                    ),
                    if (isPending) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onReject != null)
                            OutlinedButton(
                              onPressed: onReject,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AdminStitchTheme.statusError,
                                side: const BorderSide(
                                  color: AdminStitchTheme.errorContainer,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('반려'),
                            ),
                          if (onApprove != null) ...[
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: onApprove,
                              style: FilledButton.styleFrom(
                                backgroundColor: AdminStitchTheme.emerald,
                                foregroundColor: AdminStitchTheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text('승인'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationTypeBadge extends StatelessWidget {
  const _VerificationTypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AdminStitchTheme.primaryFixed,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AdminStitchTheme.labelSm.copyWith(
          fontSize: 10,
          color: AdminStitchTheme.primary,
        ),
      ),
    );
  }
}

class _VerificationStatusBadge extends StatelessWidget {
  const _VerificationStatusBadge({
    required this.label,
    required this.isPending,
    required this.isApproved,
  });

  final String label;
  final bool isPending;
  final bool isApproved;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (isPending) {
      bg = const Color(0xFFFFF7ED);
      fg = const Color(0xFFEA580C);
    } else if (isApproved) {
      bg = const Color(0xFFD1FAE5);
      fg = AdminStitchTheme.emerald;
    } else {
      bg = AdminStitchTheme.errorContainer;
      fg = AdminStitchTheme.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AdminStitchTheme.labelSm.copyWith(
          fontSize: 10,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.label, required this.isHigh});

  final String label;
  final bool isHigh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isHigh
            ? AdminStitchTheme.errorContainer
            : AdminStitchTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AdminStitchTheme.labelSm.copyWith(
          fontSize: 10,
          color: isHigh
              ? AdminStitchTheme.onErrorContainer
              : AdminStitchTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.isUnderReview});

  final String label;
  final bool isUnderReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUnderReview
            ? AdminStitchTheme.primaryFixed
            : AdminStitchTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AdminStitchTheme.labelSm.copyWith(
          fontSize: 10,
          color: isUnderReview
              ? AdminStitchTheme.primary
              : AdminStitchTheme.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, size: 16, color: AdminStitchTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: AdminStitchTheme.bodyMd.copyWith(
                  color: AdminStitchTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: AdminStitchTheme.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class AdminStitchMoneyField extends StatelessWidget {
  const AdminStitchMoneyField({
    super.key,
    required this.label,
    required this.controller,
    this.prefix = '₩',
  });

  final String label;
  final TextEditingController controller;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AdminStitchTheme.labelSm.copyWith(
            color: AdminStitchTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: AdminStitchTheme.stackTight),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AdminStitchTheme.bodyLg,
          decoration: InputDecoration(
            prefixText: '$prefix ',
            prefixStyle: AdminStitchTheme.bodyLg.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
            filled: true,
            fillColor: AdminStitchTheme.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(
                color: AdminStitchTheme.borderDefault,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(
                color: AdminStitchTheme.borderDefault,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(
                color: AdminStitchTheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdminStitchNumberField extends StatelessWidget {
  const AdminStitchNumberField({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AdminStitchTheme.labelSm.copyWith(
            color: AdminStitchTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: AdminStitchTheme.stackTight),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AdminStitchTheme.bodyLg,
          decoration: InputDecoration(
            filled: true,
            fillColor: AdminStitchTheme.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(
                color: AdminStitchTheme.borderDefault,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(
                color: AdminStitchTheme.borderDefault,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(
                color: AdminStitchTheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdminStitchBottomActionBar extends StatelessWidget {
  const AdminStitchBottomActionBar({
    super.key,
    required this.onReset,
    required this.onSave,
    this.isSaving = false,
    this.infoMessage,
    this.resetLabel = '기본값 복원',
    this.saveLabel = '변경 저장',
    this.saveButtonColor,
  });

  final VoidCallback onReset;
  final VoidCallback onSave;
  final bool isSaving;
  final String? infoMessage;
  final String resetLabel;
  final String saveLabel;
  final Color? saveButtonColor;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AdminStitchTheme.pageMargin,
        16,
        AdminStitchTheme.pageMargin,
        16 + bottom,
      ),
      decoration: BoxDecoration(
        color: AdminStitchTheme.surfaceCard,
        border: const Border(top: BorderSide(color: AdminStitchTheme.borderDefault)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (infoMessage != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AdminStitchTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    infoMessage!,
                    textAlign: TextAlign.center,
                    style: AdminStitchTheme.labelSm.copyWith(
                      color: AdminStitchTheme.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AdminStitchTheme.buttonHeight,
                  child: OutlinedButton(
                    onPressed: isSaving ? null : onReset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminStitchTheme.textSecondary,
                      side: const BorderSide(color: AdminStitchTheme.borderDefault),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AdminStitchTheme.radiusXl,
                        ),
                      ),
                    ),
                    child: Text(resetLabel),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: AdminStitchTheme.buttonHeight,
                  child: FilledButton(
                    onPressed: isSaving ? null : onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          saveButtonColor ?? AdminStitchTheme.primary,
                      foregroundColor: AdminStitchTheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AdminStitchTheme.radiusXl,
                        ),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(saveLabel),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
