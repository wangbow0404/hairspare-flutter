import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/admin/admin_table_card.dart';

/// 관리자 회원 상세 화면
class AdminUserDetailScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? initialData;

  const AdminUserDetailScreen({
    super.key,
    required this.userId,
    this.initialData,
  });

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _user = widget.initialData;
      _isLoading = false;
    }
    _loadUser();
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
          _user = data as Map<String, dynamic>?;
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
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(date);
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
    return Column(
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
          const SizedBox(height: AppTheme.spacing6),
          if (_isLoading && _user == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing8),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null && _user == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: AppTheme.urgentRed),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    TextButton(
                      onPressed: _loadUser,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            )
          else if (_user != null)
            _buildContent()
          else
            const SizedBox.shrink(),
        ],
      );
  }

  Widget _buildContent() {
    final user = _user!;
    final roleColor = _getRoleBadgeColor(user['role']);
    final jobs = user['_count']?['jobs'] ?? 0;
    final apps = user['_count']?['applications'] ?? 0;
    final sched = user['_count']?['schedules'] ?? 0;
    final balance = user['energyWallet']?['balance'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminTableCard(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryPurple500,
                            AppTheme.primaryPink,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                        boxShadow: AppTheme.shadowLg,
                      ),
                      child: Center(
                        child: Text(
                          (user['name'] ?? '?')[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user['name'] ?? '이름 없음',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing3,
                                  vertical: AppTheme.spacing1,
                                ),
                                decoration: BoxDecoration(
                                  color: roleColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  _getRoleLabel(user['role']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: roleColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing3,
                                  vertical: AppTheme.spacing1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.adminPurple100,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                ),
                                child: Text(
                                  _getSignupLabel(user['accounts']),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.purple700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: AppTheme.spacing1),
                              Text(
                                user['email'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing1),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: AppTheme.spacing1),
                              Text(
                                user['phone'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing2),
                          Text(
                            '가입일: ${_formatDate(user['createdAt'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing6),
                const Divider(height: 1),
                const SizedBox(height: AppTheme.spacing4),
                const Text(
                  '활동 통계',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),
                Row(
                  children: [
                    _buildStatChip('공고', jobs.toString()),
                    const SizedBox(width: AppTheme.spacing2),
                    _buildStatChip('지원', apps.toString()),
                    const SizedBox(width: AppTheme.spacing2),
                    _buildStatChip('스케줄', sched.toString()),
                    const SizedBox(width: AppTheme.spacing2),
                    _buildStatChip('에너지', '$balance개', color: AppTheme.yellow600),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing6),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('정지/해제 기능은 준비 중입니다')),
                        );
                      },
                      icon: const Icon(Icons.block, size: 18),
                      label: const Text('정지/해제'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.urgentRed,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing4),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('메시지 기능은 준비 중입니다')),
                        );
                      },
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text('메시지 보내기'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing2,
      ),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.adminPurple50).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.adminPurple100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: AppTheme.spacing1),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
