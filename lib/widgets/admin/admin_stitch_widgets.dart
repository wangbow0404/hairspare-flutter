import 'package:flutter/material.dart';

import '../../theme/admin_stitch_theme.dart';

class AdminStitchPageHeader extends StatelessWidget {
  const AdminStitchPageHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AdminStitchTheme.headlineMobile),
        if (subtitle != null) ...[
          const SizedBox(height: AdminStitchTheme.stackTight),
          Text(
            subtitle!,
            style: AdminStitchTheme.bodyMd.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
          ),
        ],
      ],
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
    return SingleChildScrollView(
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
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? trendLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AdminStitchCard(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AdminStitchTheme.primaryFixed.withValues(alpha: 0.5),
                    AdminStitchTheme.secondaryContainer.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: AdminStitchTheme.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: AdminStitchTheme.labelSm.copyWith(
                        color: AdminStitchTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: AdminStitchTheme.headlineMobile.copyWith(fontSize: 24),
              ),
              if (trendLabel != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 14,
                      color: AdminStitchTheme.emerald,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendLabel!,
                      style: AdminStitchTheme.labelSm.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AdminStitchTheme.emerald,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        child: Container(
          padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
          decoration: BoxDecoration(
            color: AdminStitchTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            border: Border.all(color: AdminStitchTheme.borderDefault),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AdminStitchTheme.statusError,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AdminStitchTheme.statusError,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label.toUpperCase(),
                              style: AdminStitchTheme.labelSm.copyWith(
                                fontSize: 10,
                                color: AdminStitchTheme.statusError,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Icon(icon, size: 20, color: AdminStitchTheme.textSecondary),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: AdminStitchTheme.headlineMobile.copyWith(fontSize: 22),
                    ),
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

class AdminStitchPaymentsHeroCard extends StatelessWidget {
  const AdminStitchPaymentsHeroCard({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
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
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          size: 20,
                          color: AdminStitchTheme.onPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: AdminStitchTheme.labelSm.copyWith(
                            color: AdminStitchTheme.onPrimary.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: AdminStitchTheme.headlineMobile.copyWith(
                        color: AdminStitchTheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AdminStitchTheme.onPrimary,
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
                  label,
                  style: AdminStitchTheme.labelSm.copyWith(
                    color: AdminStitchTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  value,
                  style: AdminStitchTheme.headlineMobile.copyWith(fontSize: 22),
                ),
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
                  child: Text(
                    '전체보기',
                    style: AdminStitchTheme.labelSm.copyWith(
                      color: AdminStitchTheme.primary,
                    ),
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

  @override
  Widget build(BuildContext context) {
    final type = activity['type']?.toString() ?? '';
    final isSanction = type.contains('report') || type.contains('noshow');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSanction
                ? AdminStitchTheme.errorContainer
                : AdminStitchTheme.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSanction ? Icons.gavel : Icons.verified_outlined,
            size: 18,
            color: isSanction
                ? AdminStitchTheme.statusError
                : AdminStitchTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${activity['label'] ?? ''} · ${activity['entity'] ?? ''}',
                style: AdminStitchTheme.bodyMd,
              ),
              const SizedBox(height: 4),
              Text(
                activity['ago']?.toString() ?? '',
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
                          decoration: isActive ? null : TextDecoration.lineThrough,
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
            onPressed: onMore ?? onTap,
            icon: const Icon(Icons.more_vert, color: AdminStitchTheme.textSecondary),
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
                ? Image.network(
                    avatarUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initialsCircle(),
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
                border: Border.all(color: AdminStitchTheme.surfaceCard, width: 2),
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
              borderSide: const BorderSide(color: AdminStitchTheme.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(color: AdminStitchTheme.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(color: AdminStitchTheme.primary, width: 2),
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
              borderSide: const BorderSide(color: AdminStitchTheme.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(color: AdminStitchTheme.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              borderSide: const BorderSide(color: AdminStitchTheme.primary, width: 2),
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
  });

  final VoidCallback onReset;
  final VoidCallback onSave;
  final bool isSaving;

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
      decoration: const BoxDecoration(
        color: AdminStitchTheme.surfaceCard,
        border: Border(top: BorderSide(color: AdminStitchTheme.borderDefault)),
      ),
      child: Row(
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
                    borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
                  ),
                ),
                child: const Text('기본값 복원'),
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
                  backgroundColor: AdminStitchTheme.primary,
                  foregroundColor: AdminStitchTheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('변경 저장'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
