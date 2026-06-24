import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_table_card.dart';

/// M1. 회원 상세 — 탭 UI (Stitch §3 M1)
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

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'spare':
        return '스페어';
      case 'shop':
        return '미용실';
      case 'seller':
        return '디자이너';
      default:
        return role ?? '-';
    }
  }

  Color _getRoleBadgeColor(String? role) {
    switch (role) {
      case 'spare':
        return Colors.blue;
      case 'shop':
        return AppTheme.primaryPurple;
      case 'seller':
        return Colors.green;
      default:
        return Colors.grey;
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
                color: AppTheme.textPrimary,
              ),
              const SizedBox(width: AppTheme.spacing2),
              const Text(
                '회원 상세',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          Expanded(
            child: _isLoading && _user == null
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _user == null
                    ? Center(child: Text(_error!, style: const TextStyle(color: AppTheme.urgentRed)))
                    : _user != null
                        ? _buildContent()
                        : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final user = _user!;
    final roleColor = _getRoleBadgeColor(user['role']);
    final statusLabel = user['accountStatusLabel']?.toString() ?? '정상';
    final isSuspended = user['accountStatus'] == 'suspended';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTableCard(
          padding: const EdgeInsets.all(AppTheme.spacing6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple500, AppTheme.primaryPink],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                ),
                child: Center(
                  child: Text(
                    (user['name'] ?? '?')[0],
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppTheme.spacing2,
                      runSpacing: AppTheme.spacing1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(user['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        _Badge(text: _getRoleLabel(user['role']), color: roleColor),
                        _Badge(text: _getSignupLabel(user['accounts']), color: AppTheme.purple700, bg: AppTheme.adminPurple100),
                        _Badge(
                          text: statusLabel,
                          color: isSuspended ? AppTheme.urgentRed : AppTheme.green600,
                          bg: isSuspended ? AppTheme.red50 : AppTheme.green50,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing1),
                    Text(user['email'] ?? '', style: const TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: _suspendUser,
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('정지'),
                    style: FilledButton.styleFrom(backgroundColor: AppTheme.urgentRed, visualDensity: VisualDensity.compact),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  OutlinedButton.icon(
                    onPressed: _adjustEnergy,
                    icon: const Icon(Icons.bolt, size: 16),
                    label: const Text('에너지'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: '기본정보'),
            Tab(text: '활동'),
            Tab(text: '지갑'),
            Tab(text: '제재이력'),
            Tab(text: '인증상태'),
          ],
        ),
        const SizedBox(height: AppTheme.spacing4),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              AdminUserBasicTab(user: user, formatDate: _formatDate, roleLabel: _getRoleLabel(user['role'])),
              AdminUserActivityTab(user: user, formatDate: _formatDate),
              AdminUserWalletTab(user: user, onAdjustEnergy: _adjustEnergy, onAdjustPoints: _adjustPoints),
              AdminUserSanctionTab(user: user, formatDate: _formatDate),
              AdminUserVerificationTab(user: user, formatDate: _formatDate),
            ],
          ),
        ),
      ],
    );
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('회원이 정지되었습니다')));
      _loadUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
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
        TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '증감량 (+/-)', border: OutlineInputBorder())),
        const SizedBox(height: AppTheme.spacing2),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('에너지가 조정되었습니다')));
      _loadUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
    }
  }

  Future<void> _adjustPoints() async {
    final reason = await AdminActionDialog.show(context, title: '포인트 지급', confirmLabel: '지급', summary: _user?['name']?.toString());
    if (reason == null || !mounted) return;
    try {
      await _adminService.adjustPoints(widget.userId, 10, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('포인트가 지급되었습니다')));
      _loadUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))), backgroundColor: AppTheme.urgentRed));
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color, this.bg});

  final String text;
  final Color color;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (bg ?? color.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class AdminUserBasicTab extends StatelessWidget {
  const AdminUserBasicTab({
    super.key,
    required this.user,
    required this.formatDate,
    required this.roleLabel,
  });

  final Map<String, dynamic> user;
  final String Function(String?) formatDate;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return AdminTableCard(
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: ListView(
        children: [
          _Row(label: '이름', value: user['name']?.toString() ?? '-'),
          _Row(label: '이메일', value: user['email']?.toString() ?? '-'),
          _Row(label: '전화', value: user['phone']?.toString() ?? '-'),
          _Row(label: '역할', value: roleLabel),
          _Row(label: '가입일', value: formatDate(user['createdAt']?.toString())),
          _Row(label: '계정 상태', value: user['accountStatusLabel']?.toString() ?? '-'),
        ],
      ),
    );
  }
}

class AdminUserActivityTab extends StatelessWidget {
  const AdminUserActivityTab({super.key, required this.user, required this.formatDate});

  final Map<String, dynamic> user;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    final count = user['_count'] as Map<String, dynamic>? ?? {};
    final recent = user['recentActivity'] as List? ?? [];
    return AdminTableCard(
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: ListView(
        children: [
          Wrap(
            spacing: AppTheme.spacing2,
            children: [
              _StatChip(label: '공고', value: '${count['jobs'] ?? 0}'),
              _StatChip(label: '지원', value: '${count['applications'] ?? 0}'),
              _StatChip(label: '스케줄', value: '${count['schedules'] ?? 0}'),
            ],
          ),
          const SizedBox(height: AppTheme.spacing6),
          const Text('최근 활동', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.spacing3),
          ...recent.map((a) {
            final item = a as Map<String, dynamic>;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item['label']?.toString() ?? ''),
              subtitle: Text(item['detail']?.toString() ?? ''),
              trailing: Text(formatDate(item['at']?.toString()), style: const TextStyle(fontSize: 11, color: AppTheme.textTertiary)),
            );
          }),
        ],
      ),
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
    return AdminTableCard(
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WalletCard(title: '에너지', value: '$energy개', icon: Icons.bolt, color: AppTheme.yellow600, onAdjust: onAdjustEnergy),
          const SizedBox(height: AppTheme.spacing4),
          _WalletCard(title: '포인트', value: '${points}P', icon: Icons.stars, color: AppTheme.primaryPurple, onAdjust: onAdjustPoints),
        ],
      ),
    );
  }
}

class AdminUserSanctionTab extends StatelessWidget {
  const AdminUserSanctionTab({super.key, required this.user, required this.formatDate});

  final Map<String, dynamic> user;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    final history = user['sanctionHistory'] as List? ?? [];
    return AdminTableCard(
      child: history.isEmpty
          ? const Center(child: Text('제재 이력이 없습니다'))
          : ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => Divider(color: AppTheme.adminPurple100.withValues(alpha: 0.5)),
              itemBuilder: (_, i) {
                final s = history[i] as Map<String, dynamic>;
                return ListTile(
                  title: Text(s['typeLabel']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(s['reason']?.toString() ?? ''),
                  trailing: Text(formatDate(s['at']?.toString()), style: const TextStyle(fontSize: 11)),
                );
              },
            ),
    );
  }
}

class AdminUserVerificationTab extends StatelessWidget {
  const AdminUserVerificationTab({super.key, required this.user, required this.formatDate});

  final Map<String, dynamic> user;
  final String Function(String?) formatDate;

  @override
  Widget build(BuildContext context) {
    final v = user['verification'] as Map<String, dynamic>? ?? {};
    return AdminTableCard(
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(label: '인증 유형', value: v['typeLabel']?.toString() ?? '-'),
          _Row(label: '상태', value: v['statusLabel']?.toString() ?? '-'),
          _Row(label: '승인일', value: formatDate(v['verifiedAt']?.toString())),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
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
        color: AppTheme.adminPurple50,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.adminPurple100),
      ),
      child: Text('$label $value', style: const TextStyle(fontWeight: FontWeight.w600)),
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
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppTheme.spacing3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          OutlinedButton(onPressed: onAdjust, child: const Text('조정')),
        ],
      ),
    );
  }
}
