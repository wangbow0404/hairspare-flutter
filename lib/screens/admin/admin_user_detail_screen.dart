import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/admin_member_role.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

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
                            onDelete: _deleteUser,
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

  Future<void> _deleteUser() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1E1C30),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_off_outlined, color: Color(0xFFF5F3FF)),
              title: const Text(
                '비활성화 (삭제)',
                style: TextStyle(color: Color(0xFFF5F3FF), fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                '로그인이 차단되고 개인정보 화면 노출이 줄어듭니다. 공고·채팅·스케줄 등 기록은 유지되어 복구 가능합니다.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
              onTap: () => Navigator.pop(context, 'soft'),
            ),
            const Divider(height: 1, color: Color(0xFF3D3B56)),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppTheme.urgentRed),
              title: const Text(
                '완전 삭제',
                style: TextStyle(color: AppTheme.urgentRed, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                '계정 자체를 영구히 삭제합니다. 되돌릴 수 없습니다.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
              onTap: () => Navigator.pop(context, 'hard'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    if (choice == 'soft') {
      final reason = await AdminActionDialog.show(
        context,
        title: '회원 계정 비활성화',
        confirmLabel: '비활성화',
        summary: _user?['name']?.toString(),
        isDanger: true,
      );
      if (reason == null || !mounted) return;
      try {
        await _adminService.deleteUser(widget.userId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원 계정이 비활성화되었습니다')),
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
      return;
    }

    // 완전 삭제 — 복구 불가이므로 회원 이름을 정확히 입력해야 진행된다
    final expectedName = _user?['name']?.toString() ?? '';
    final confirmController = TextEditingController();
    final reason = await AdminActionDialog.show(
      context,
      title: '회원 완전 삭제',
      confirmLabel: '영구 삭제',
      summary: '복구할 수 없습니다. 계속하려면 회원 이름 "$expectedName"을(를) 정확히 입력하세요.',
      isDanger: true,
      extraFields: [
        AdminFieldConfig(label: '회원 이름 확인', controller: confirmController),
      ],
    );
    final typedName = confirmController.text.trim();
    confirmController.dispose();
    if (reason == null || !mounted) return;
    if (expectedName.isEmpty || typedName != expectedName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('입력한 이름이 일치하지 않아 삭제가 취소되었습니다'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }
    try {
      await _adminService.deleteUser(widget.userId, permanent: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 계정이 완전히 삭제되었습니다')),
      );
      context.pop();
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
    required this.onDelete,
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
  final VoidCallback onDelete;

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
            onDelete: onDelete,
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
    required this.onDelete,
  });

  final Map<String, dynamic> user;
  final String signupLabel;
  final bool isSuspended;
  final VoidCallback onSuspend;
  final VoidCallback onUnsuspend;
  final VoidCallback onAdjustEnergy;
  final VoidCallback onDelete;

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
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.person_remove_outlined, size: 18, color: AppTheme.urgentRed),
                  label: const Text(
                    '회원 계정 삭제',
                    style: TextStyle(color: AppTheme.urgentRed, fontWeight: FontWeight.w600),
                  ),
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

class AdminUserActivityTab extends StatefulWidget {
  const AdminUserActivityTab({
    super.key,
    required this.user,
    required this.formatDate,
  });

  final Map<String, dynamic> user;
  final String Function(String?) formatDate;

  @override
  State<AdminUserActivityTab> createState() => _AdminUserActivityTabState();
}

/// 필터 칩 라벨 <-> 백엔드가 내려주는 activity "type" 매핑
const Map<String, String?> _kActivityFilterTypes = {
  '전체': null,
  '공고': 'job',
  '지원': 'application',
  '스케줄': 'schedule',
  '에너지': 'energy',
  '노쇼': 'noshow',
  '정산취소': 'settlement_cancel',
  '신고': 'report',
};

class _AdminUserActivityTabState extends State<AdminUserActivityTab> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  String? _error;
  String _selectedLabel = '전체';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final userId = widget.user['id']?.toString();
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _error = '회원 ID를 확인할 수 없습니다';
      });
      return;
    }
    try {
      final items = await _adminService.getUserActivities(userId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e));
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final type = _kActivityFilterTypes[_selectedLabel];
    if (type == null) return _items;
    return _items.where((item) => item['type'] == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.user['_count'] as Map<String, dynamic>? ?? {};
    final filtered = _filtered;

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
        const SizedBox(height: AdminStitchTheme.sectionGap),
        AdminStitchFilterChips(
          tabs: _kActivityFilterTypes.keys.toList(),
          selectedTab: _selectedLabel,
          onTabChanged: (label) => setState(() => _selectedLabel = label),
        ),
        const SizedBox(height: AdminStitchTheme.sectionGap),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(_error!, style: const TextStyle(color: AppTheme.urgentRed)),
          )
        else if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              '해당 유형의 활동 내역이 없습니다',
              style: AdminStitchTheme.bodyMd.copyWith(color: AdminStitchTheme.textSecondary),
            ),
          )
        else
          Container(
            decoration: AdminStitchTheme.cardDecoration,
            padding: const EdgeInsets.all(AdminStitchTheme.componentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < filtered.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 16,
                      color: AdminStitchTheme.borderDefault.withValues(alpha: 0.5),
                    ),
                  Builder(
                    builder: (context) {
                      final item = filtered[i];
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
                              widget.formatDate(item['at']?.toString()),
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
