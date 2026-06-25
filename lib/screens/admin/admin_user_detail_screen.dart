import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/admin_member_role.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';

/// M1. 회원 상세 — Stitch User Details mockup
class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({
    super.key,
    required this.userId,
    this.initialData,
  });

  final String userId;
  final Map<String, dynamic>? initialData;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    if (widget.initialData != null) {
      _user = widget.initialData;
      _isLoading = false;
    }
    _loadUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _adminService.getUserDetail(widget.userId);
      if (mounted) {
        setState(() {
          _user = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final appException = ErrorHandler.handleException(e);
        setState(() {
          _error = ErrorHandler.getUserFriendlyMessage(appException);
          _isLoading = false;
          if (_user == null && widget.initialData != null) {
            _user = widget.initialData;
          }
        });
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR')
          .format(DateTime.parse(dateString).toLocal());
    } catch (e) {
      return dateString;
    }
  }

  String _getSignupLabel(dynamic accounts) {
    if (accounts == null || (accounts as List).isEmpty) return '일반 가입';
    final provider = (accounts).first['provider'] ?? '';
    switch (provider) {
      case 'kakao':
        return '카카오';
      case 'naver':
        return '네이버';
      case 'google':
        return '구글';
      default:
        return '일반 가입';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AdminStitchTheme.bgSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminUserDetailPageHeader(onBack: () => context.pop()),
          Expanded(
            child: _isLoading && _user == null
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _user == null
                    ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppTheme.urgentRed),
                        ),
                      )
                    : _user != null
                        ? _AdminUserDetailBody(
                            user: _user!,
                            tabController: _tabController,
                            formatDate: _formatDate,
                            signupLabel: _getSignupLabel(_user!['accounts']),
                            bottomInset: MediaQuery.paddingOf(context).bottom,
                            onSuspend: _suspendUser,
                            onUnsuspend: _unsuspendUser,
                            onAdjustEnergy: _adjustEnergy,
                            onAdjustPoints: _adjustPoints,
                          )
                        : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _unsuspendUser() async {
    final reason = await AdminActionDialog.show(
      context,
      title: '정지 해제',
      confirmLabel: '해제',
      summary: _user?['name']?.toString(),
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.unsuspendUser(widget.userId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정지가 해제되었습니다')),
      );
      _loadUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<void> _suspendUser() async {
    final reason = await AdminActionDialog.show(
      context,
      title: '회원 정지',
      confirmLabel: '정지',
      summary: _user?['name']?.toString(),
      isDanger: true,
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.suspendUser(widget.userId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원이 정지되었습니다')),
      );
      _loadUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<void> _adjustEnergy() async {
    final amountController = TextEditingController();
    final reason = await AdminActionDialog.show(
      context,
      title: '에너지 조정',
      confirmLabel: '적용',
      summary: _user?['name']?.toString(),
      extraFields: [
        AdminFieldConfig(
          label: '증감량 (+/-)',
          controller: amountController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
    final deltaText = amountController.text.trim();
    amountController.dispose();
    if (reason == null || !mounted) return;
    final delta = int.tryParse(deltaText) ?? 0;
    if (delta == 0) return;
    try {
      await _adminService.adjustEnergy(widget.userId, delta, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('에너지가 조정되었습니다')),
      );
      _loadUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  Future<void> _adjustPoints() async {
    final reason = await AdminActionDialog.show(
      context,
      title: '포인트 지급',
      confirmLabel: '지급',
      summary: _user?['name']?.toString(),
    );
    if (reason == null || !mounted) return;
    try {
      await _adminService.adjustPoints(widget.userId, 10, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('포인트가 지급되었습니다')),
      );
      _loadUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }
}

class _AdminUserDetailBody extends StatelessWidget {
  const _AdminUserDetailBody({
    required this.user,
    required this.tabController,
    required this.formatDate,
    required this.signupLabel,
    required this.bottomInset,
    required this.onSuspend,
    required this.onUnsuspend,
    required this.onAdjustEnergy,
    required this.onAdjustPoints,
  });

  final Map<String, dynamic> user;
  final TabController tabController;
  final String Function(String?) formatDate;
  final String signupLabel;
  final double bottomInset;
  final VoidCallback onSuspend;
  final VoidCallback onUnsuspend;
  final VoidCallback onAdjustEnergy;
  final VoidCallback onAdjustPoints;

  @override
  Widget build(BuildContext context) {
    final isSuspended = user['accountStatus'] == 'suspended';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdminStitchTheme.pageMargin,
          ),
          child: AdminUserProfileCard(
            user: user,
            signupLabel: signupLabel,
            isSuspended: isSuspended,
            onSuspend: onSuspend,
            onUnsuspend: onUnsuspend,
            onAdjustEnergy: onAdjustEnergy,
          ),
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        AdminUserDetailTabBar(controller: tabController),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AdminStitchTheme.pageMargin,
                  AdminStitchTheme.sectionGap,
                  AdminStitchTheme.pageMargin,
                  bottomInset + 72,
                ),
                child: AdminUserBasicTab(
                  user: user,
                  formatDate: formatDate,
                  roleLabel: AdminMemberRole.detailRoleLabel(user),
                  categoryLabel: AdminMemberRole.categoryLabel(user),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AdminStitchTheme.pageMargin,
                  AdminStitchTheme.sectionGap,
                  AdminStitchTheme.pageMargin,
                  bottomInset + 72,
                ),
                child: AdminUserActivityTab(user: user, formatDate: formatDate),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AdminStitchTheme.pageMargin,
                  AdminStitchTheme.sectionGap,
                  AdminStitchTheme.pageMargin,
                  bottomInset + 72,
                ),
                child: AdminUserWalletTab(
                  user: user,
                  onAdjustEnergy: onAdjustEnergy,
                  onAdjustPoints: onAdjustPoints,
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AdminStitchTheme.pageMargin,
                  AdminStitchTheme.sectionGap,
                  AdminStitchTheme.pageMargin,
                  bottomInset + 72,
                ),
                child: AdminUserSanctionTab(user: user, formatDate: formatDate),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AdminStitchTheme.pageMargin,
                  AdminStitchTheme.sectionGap,
                  AdminStitchTheme.pageMargin,
                  bottomInset + 72,
                ),
                child: AdminUserVerificationTab(user: user, formatDate: formatDate),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminUserDetailPageHeader extends StatelessWidget {
  const AdminUserDetailPageHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AdminStitchTheme.pageMargin - 8,
        AdminStitchTheme.stackTight,
        AdminStitchTheme.pageMargin,
        AdminStitchTheme.sectionGap,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            color: AdminStitchTheme.onSurface,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            '회원 상세',
            style: AdminStitchTheme.headlineMd.copyWith(fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class AdminUserProfileCard extends StatelessWidget {
  const AdminUserProfileCard({
    super.key,
    required this.user,
    required this.signupLabel,
    required this.isSuspended,
    required this.onSuspend,
    required this.onUnsuspend,
    required this.onAdjustEnergy,
  });

  final Map<String, dynamic> user;
  final String signupLabel;
  final bool isSuspended;
  final VoidCallback onSuspend;
  final VoidCallback onUnsuspend;
  final VoidCallback onAdjustEnergy;

  static const _successBg = Color(0xFFD1FAE5);

  @override
  Widget build(BuildContext context) {
    final name = user['name']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';
    final initial = name.isNotEmpty ? name[0] : '?';
    final roleLabel = AdminMemberRole.badgeLabel(user);
    final statusLabel = user['accountStatusLabel']?.toString() ?? '정상';

    return Container(
      decoration: AdminStitchTheme.cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(AdminStitchTheme.radius2xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AdminStitchTheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AdminStitchTheme.secondary,
                        AdminStitchTheme.primary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AdminStitchTheme.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: AdminStitchTheme.headlineMobile.copyWith(
                      color: AdminStitchTheme.onPrimary,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Text(name, style: AdminStitchTheme.sectionHeader),
                    AdminUserRoleBadge(label: roleLabel),
                    AdminUserSignupBadge(label: signupLabel),
                  ],
                ),
                const SizedBox(height: 8),
                AdminUserStatusBadge(
                  label: statusLabel,
                  isSuspended: isSuspended,
                ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: AdminStitchTheme.bodyMd.copyWith(
                    color: AdminStitchTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: isSuspended
                          ? _ProfileActionButton(
                              label: '정지 해제',
                              icon: Icons.check_circle_outline,
                              backgroundColor: AdminStitchTheme.emerald,
                              foregroundColor: Colors.white,
                              borderColor: Colors.transparent,
                              onPressed: onUnsuspend,
                            )
                          : _ProfileActionButton(
                              label: '정지',
                              icon: Icons.block,
                              backgroundColor: AdminStitchTheme.statusError,
                              foregroundColor: Colors.white,
                              borderColor: Colors.transparent,
                              onPressed: onSuspend,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileActionButton(
                        label: '에너지',
                        icon: Icons.bolt,
                        backgroundColor: AdminStitchTheme.surfaceCard,
                        foregroundColor: AdminStitchTheme.primary,
                        borderColor: AdminStitchTheme.primary,
                        onPressed: onAdjustEnergy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminUserRoleBadge extends StatelessWidget {
  const AdminUserRoleBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: AdminStitchTheme.labelSm.copyWith(
          color: AdminStitchTheme.primary,
        ),
      ),
    );
  }
}

class AdminUserSignupBadge extends StatelessWidget {
  const AdminUserSignupBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AdminStitchTheme.primaryFixed,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: AdminStitchTheme.labelSm.copyWith(
          color: AdminStitchTheme.onPrimaryFixed,
        ),
      ),
    );
  }
}

class AdminUserStatusBadge extends StatelessWidget {
  const AdminUserStatusBadge({
    super.key,
    required this.label,
    required this.isSuspended,
  });

  final String label;
  final bool isSuspended;

  @override
  Widget build(BuildContext context) {
    if (isSuspended) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AdminStitchTheme.errorContainer,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: AdminStitchTheme.statusError.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: AdminStitchTheme.labelSm.copyWith(
            color: AdminStitchTheme.statusError,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AdminUserProfileCard._successBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: AdminStitchTheme.emerald.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: AdminStitchTheme.labelSm.copyWith(
          color: AdminStitchTheme.emerald,
        ),
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AdminStitchTheme.radiusXl),
            border: borderColor == Colors.transparent
                ? null
                : Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foregroundColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: AdminStitchTheme.labelSm.copyWith(
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminUserDetailTabBar extends StatelessWidget {
  const AdminUserDetailTabBar({super.key, required this.controller});

  final TabController controller;

  static const _tabs = ['기본정보', '활동', '지갑', '제재이력', '인증'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: AdminStitchTheme.borderDefault,
          dividerHeight: 1,
          indicatorColor: AdminStitchTheme.primary,
          indicatorWeight: 2,
          labelColor: AdminStitchTheme.primary,
          unselectedLabelColor: AdminStitchTheme.textSecondary,
          labelStyle: AdminStitchTheme.labelSm,
          unselectedLabelStyle: AdminStitchTheme.labelSm,
          labelPadding: const EdgeInsets.only(
            left: AdminStitchTheme.pageMargin,
            right: 24,
          ),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ],
    );
  }
}

class AdminUserBentoCard extends StatelessWidget {
  const AdminUserBentoCard({super.key, required this.rows});

  final List<AdminUserBentoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AdminStitchTheme.cardDecoration,
      padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            AdminUserBentoRow(label: rows[i].label, value: rows[i].value),
            if (i < rows.length - 1)
              Divider(
                height: 16,
                thickness: 1,
                color: AdminStitchTheme.borderDefault.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

class AdminUserBentoRowData {
  const AdminUserBentoRowData({required this.label, required this.value});

  final String label;
  final String value;
}

class AdminUserBentoRow extends StatelessWidget {
  const AdminUserBentoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: AdminStitchTheme.bodyMd.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: AdminStitchTheme.bodyMd.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class AdminUserBasicTab extends StatelessWidget {
  const AdminUserBasicTab({
    super.key,
    required this.user,
    required this.formatDate,
    required this.roleLabel,
    required this.categoryLabel,
  });

  final Map<String, dynamic> user;
  final String Function(String?) formatDate;
  final String roleLabel;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    return AdminUserBentoCard(
      rows: [
        AdminUserBentoRowData(
          label: '이름',
          value: user['name']?.toString() ?? '-',
        ),
        AdminUserBentoRowData(
          label: '이메일',
          value: user['email']?.toString() ?? '-',
        ),
        AdminUserBentoRowData(
          label: '전화',
          value: user['phone']?.toString() ?? '-',
        ),
        AdminUserBentoRowData(label: '회원 유형', value: categoryLabel),
        AdminUserBentoRowData(label: '역할', value: roleLabel),
        AdminUserBentoRowData(
          label: '가입일',
          value: formatDate(user['createdAt']?.toString()),
        ),
        AdminUserBentoRowData(
          label: '계정 상태',
          value: user['accountStatusLabel']?.toString() ?? '-',
        ),
      ],
    );
  }
}

class AdminUserActivityTab extends StatelessWidget {
  const AdminUserActivityTab({
    super.key,
    required this.user,
    required this.formatDate,
  });

  final Map<String, dynamic> user;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    final count = user['_count'] as Map<String, dynamic>? ?? {};
    final recent = user['recentActivity'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: AdminStitchTheme.cardDecoration,
          padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(label: '공고', value: '${count['jobs'] ?? 0}'),
              _StatChip(label: '지원', value: '${count['applications'] ?? 0}'),
              _StatChip(label: '스케줄', value: '${count['schedules'] ?? 0}'),
            ],
          ),
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: AdminStitchTheme.sectionGap),
          Container(
            decoration: AdminStitchTheme.cardDecoration,
            padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('최근 활동', style: AdminStitchTheme.sectionHeader),
                const SizedBox(height: 12),
                for (var i = 0; i < recent.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 16,
                      color: AdminStitchTheme.borderDefault.withValues(alpha: 0.5),
                    ),
                  Builder(
                    builder: (context) {
                      final item = recent[i] as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['label']?.toString() ?? '',
                                    style: AdminStitchTheme.bodyMd.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item['detail'] != null)
                                    Text(
                                      item['detail']!.toString(),
                                      style: AdminStitchTheme.bodyMd.copyWith(
                                        color: AdminStitchTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              formatDate(item['at']?.toString()),
                              style: AdminStitchTheme.labelSm.copyWith(
                                color: AdminStitchTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class AdminUserWalletTab extends StatelessWidget {
  const AdminUserWalletTab({
    super.key,
    required this.user,
    required this.onAdjustEnergy,
    required this.onAdjustPoints,
  });

  final Map<String, dynamic> user;
  final VoidCallback onAdjustEnergy;
  final VoidCallback onAdjustPoints;

  @override
  Widget build(BuildContext context) {
    final energy = user['energyWallet']?['balance'] ?? 0;
    final points = user['pointWallet']?['balance'] ?? 0;

    return Column(
      children: [
        _WalletCard(
          title: '에너지',
          value: '$energy개',
          icon: Icons.bolt,
          color: AppTheme.yellow600,
          onAdjust: onAdjustEnergy,
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        _WalletCard(
          title: '포인트',
          value: '${points}P',
          icon: Icons.stars,
          color: AdminStitchTheme.primary,
          onAdjust: onAdjustPoints,
        ),
      ],
    );
  }
}

class AdminUserSanctionTab extends StatelessWidget {
  const AdminUserSanctionTab({
    super.key,
    required this.user,
    required this.formatDate,
  });

  final Map<String, dynamic> user;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    final history = user['sanctionHistory'] as List? ?? [];

    if (history.isEmpty) {
      return Container(
        decoration: AdminStitchTheme.cardDecoration,
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            '제재 이력이 없습니다',
            style: AdminStitchTheme.bodyMd.copyWith(
              color: AdminStitchTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: AdminStitchTheme.cardDecoration,
      padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
      child: Column(
        children: [
          for (var i = 0; i < history.length; i++) ...[
            if (i > 0)
              Divider(
                height: 16,
                color: AdminStitchTheme.borderDefault.withValues(alpha: 0.5),
              ),
            Builder(
              builder: (context) {
                final s = history[i] as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s['typeLabel']?.toString() ?? '',
                              style: AdminStitchTheme.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              s['reason']?.toString() ?? '',
                              style: AdminStitchTheme.bodyMd.copyWith(
                                color: AdminStitchTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatDate(s['at']?.toString()),
                        style: AdminStitchTheme.labelSm.copyWith(
                          color: AdminStitchTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class AdminUserVerificationTab extends StatelessWidget {
  const AdminUserVerificationTab({
    super.key,
    required this.user,
    required this.formatDate,
  });

  final Map<String, dynamic> user;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    final v = user['verification'] as Map<String, dynamic>? ?? {};

    return AdminUserBentoCard(
      rows: [
        AdminUserBentoRowData(
          label: '인증 유형',
          value: v['typeLabel']?.toString() ?? '-',
        ),
        AdminUserBentoRowData(
          label: '상태',
          value: v['statusLabel']?.toString() ?? '-',
        ),
        AdminUserBentoRowData(
          label: '승인일',
          value: formatDate(v['verifiedAt']?.toString()),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AdminStitchTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
        border: Border.all(color: AdminStitchTheme.borderDefault),
      ),
      child: Text(
        '$label $value',
        style: AdminStitchTheme.labelSm.copyWith(
          color: AdminStitchTheme.onSurface,
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onAdjust,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onAdjust;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AdminStitchTheme.cardDecoration,
      padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AdminStitchTheme.labelSm.copyWith(
                    color: AdminStitchTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: AdminStitchTheme.sectionHeader.copyWith(color: color),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onAdjust,
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminStitchTheme.primary,
              side: const BorderSide(color: AdminStitchTheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminStitchTheme.radiusLg),
              ),
            ),
            child: const Text('조정'),
          ),
        ],
      ),
    );
  }
}
