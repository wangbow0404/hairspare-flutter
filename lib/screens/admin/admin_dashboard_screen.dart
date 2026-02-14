import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin_layout.dart';
import 'admin_users_screen.dart';
import 'admin_jobs_screen.dart';
import 'admin_payments_screen.dart';
import 'admin_energy_screen.dart';
import 'admin_noshow_screen.dart';
import 'admin_checkin_screen.dart';
import 'dart:async';

/// 관리자 대시보드 화면
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic>? _stats;
  List<dynamic> _activities = [];
  bool _isLoading = true;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadActivities();
    // 5초마다 자동 업데이트
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadStats(showLoading: false);
        _loadActivities();
      }
    });
  }

  Future<void> _loadActivities() async {
    try {
      final result = await _adminService.getRecentActivities();
      if (mounted) {
        setState(() {
          _activities = result['activities'] ?? [];
        });
      }
    } catch (_) {
      if (mounted && _activities.isEmpty) {
        setState(() {
          _activities = [
            {'type': 'signup', 'label': '회원가입', 'entity': '김디자이너', 'ago': '5분 전', 'color': 'blue'},
            {'type': 'job', 'label': '공고등록', 'entity': '이미용실', 'ago': '12분 전', 'color': 'purple'},
            {'type': 'payment', 'label': '결제완료', 'entity': '박스텝', 'ago': '23분 전', 'color': 'green'},
            {'type': 'noshow', 'label': '노쇼신고', 'entity': '최사장', 'ago': '1시간 전', 'color': 'red'},
            {'type': 'energy', 'label': '에너지충전', 'entity': '정디자이너', 'ago': '2시간 전', 'color': 'yellow'},
          ];
        });
      }
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final stats = await _adminService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('통계 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrencyFull(int amount) {
    return '${(amount / 10000).toStringAsFixed(0)}만원';
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: AppTheme.urgentRed),
                      const SizedBox(height: AppTheme.spacing4),
                      const Text(
                        '데이터를 불러올 수 없습니다',
                        style: TextStyle(color: AppTheme.urgentRed),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      ElevatedButton(
                        onPressed: () => _loadStats(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 768;
                    final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
                    
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 헤더
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '대시보드',
                                      style: TextStyle(
                                        fontSize: isMobile ? 20 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    if (!isMobile) ...[
                                      const SizedBox(height: AppTheme.spacing1),
                                      Text(
                                        'HairSpare 플랫폼 현황을 한눈에 확인하세요',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!isMobile) ...[
                                const SizedBox(width: AppTheme.spacing2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacing1),
                                    Text(
                                      '실시간 업데이트 중',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: isMobile ? AppTheme.spacing3 : AppTheme.spacing4),
                          // 통계 카드 그리드
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth > 1200 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                              final cards = [
                                _buildStatCard(
                                  title: '총 회원 수',
                                  value: '${_stats!['users']?['total'] ?? 0}',
                                  change: '오늘 +${_stats!['users']?['today'] ?? 0}',
                                  icon: Icons.people,
                                  color: Colors.blue,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminUsersScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildStatCard(
                                  title: '활성 공고',
                                  value: '${_stats!['jobs']?['active'] ?? 0}',
                                  change: '전체 ${_stats!['jobs']?['total'] ?? 0}개',
                                  icon: Icons.work,
                                  color: AppTheme.primaryPurple,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminJobsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildStatCard(
                                  title: '오늘 결제 금액',
                                  value: _formatCurrencyFull((_stats!['payments']?['today'] ?? 0) as int),
                                  change: '누적 ${_formatCurrencyFull((_stats!['payments']?['total'] ?? 0) as int)}',
                                  icon: Icons.payment,
                                  color: Colors.green,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminPaymentsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildStatCard(
                                  title: '오늘 체크인',
                                  value: '${_stats!['schedules']?['today'] ?? 0}',
                                  change: '전체 ${_stats!['schedules']?['total'] ?? 0}건',
                                  icon: Icons.calendar_today,
                                  color: Colors.orange,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminCheckinScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildStatCard(
                                  title: '에너지 지갑',
                                  value: '${_stats!['energy']?['wallets'] ?? 0}',
                                  change: '거래 ${_stats!['energy']?['transactions'] ?? 0}건',
                                  icon: Icons.bolt,
                                  color: Colors.yellow,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminEnergyScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _buildStatCard(
                                  title: '노쇼 이력',
                                  value: '${_stats!['noShow']?['total'] ?? 0}',
                                  change: '누적',
                                  icon: Icons.warning,
                                  color: AppTheme.urgentRed,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AdminNoshowScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ];
                              
                              return Wrap(
                                spacing: isMobile ? AppTheme.spacing2 : AppTheme.spacing3,
                                runSpacing: isMobile ? AppTheme.spacing2 : AppTheme.spacing3,
                                children: cards.map((card) {
                                  return SizedBox(
                                    width: (constraints.maxWidth - (crossAxisCount - 1) * (isMobile ? AppTheme.spacing2 : AppTheme.spacing3)) / crossAxisCount,
                                    child: card,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          SizedBox(height: isMobile ? AppTheme.spacing3 : AppTheme.spacing4),
                          // 역할별 회원 통계
                          Container(
                            padding: EdgeInsets.all(isMobile ? AppTheme.spacing3 : AppTheme.spacing4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.trending_up, color: AppTheme.textPrimary, size: isMobile ? 16 : 18),
                                SizedBox(width: AppTheme.spacing2),
                                Expanded(
                                  child: Text(
                                    '역할별 회원 수',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isMobile ? AppTheme.spacing3 : AppTheme.spacing4),
                            LayoutBuilder(
                              builder: (context, roleConstraints) {
                                // 화면 너비에 따라 레이아웃 조정
                                if (roleConstraints.maxWidth > 600) {
                                  // 가로 레이아웃
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '스페어',
                                                style: TextStyle(
                                                  fontSize: isMobile ? 11 : 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              SizedBox(height: AppTheme.spacing1),
                                              Text(
                                                '${(_stats!['users']?['byRole']?['spare'] ?? 0)}명',
                                                style: TextStyle(
                                                  fontSize: isMobile ? 16 : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryPurple.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '미용실',
                                                style: TextStyle(
                                                  fontSize: isMobile ? 11 : 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              SizedBox(height: AppTheme.spacing1),
                                              Text(
                                                '${(_stats!['users']?['byRole']?['shop'] ?? 0)}명',
                                                style: TextStyle(
                                                  fontSize: isMobile ? 16 : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryPurple,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '판매자',
                                                style: TextStyle(
                                                  fontSize: isMobile ? 11 : 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              SizedBox(height: AppTheme.spacing1),
                                              Text(
                                                '${(_stats!['users']?['byRole']?['seller'] ?? 0)}명',
                                                style: TextStyle(
                                                  fontSize: isMobile ? 16 : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // 세로 레이아웃 (작은 화면)
                                  return Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '스페어',
                                              style: TextStyle(
                                                fontSize: isMobile ? 11 : 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            SizedBox(height: AppTheme.spacing1),
                                            Text(
                                              '${(_stats!['users']?['byRole']?['spare'] ?? 0)}명',
                                              style: TextStyle(
                                                fontSize: isMobile ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryPurple.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '미용실',
                                              style: TextStyle(
                                                fontSize: isMobile ? 11 : 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            SizedBox(height: AppTheme.spacing1),
                                            Text(
                                              '${(_stats!['users']?['byRole']?['shop'] ?? 0)}명',
                                              style: TextStyle(
                                                fontSize: isMobile ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryPurple,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(isMobile ? AppTheme.spacing2 : AppTheme.spacing3),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '판매자',
                                              style: TextStyle(
                                                fontSize: isMobile ? 11 : 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                            SizedBox(height: AppTheme.spacing1),
                                            Text(
                                              '${(_stats!['users']?['byRole']?['seller'] ?? 0)}명',
                                              style: TextStyle(
                                                fontSize: isMobile ? 16 : 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                          SizedBox(height: isMobile ? AppTheme.spacing3 : AppTheme.spacing4),
                          // 최근 활동
                          if (_activities.isNotEmpty) _buildRecentActivities(isMobile),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Color _getActivityColor(String color) {
    switch (color) {
      case 'blue': return Colors.blue;
      case 'purple': return AppTheme.primaryPurple;
      case 'green': return Colors.green;
      case 'red': return AppTheme.urgentRed;
      case 'yellow': return Colors.amber;
      default: return AppTheme.textSecondary;
    }
  }

  Widget _buildRecentActivities(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? AppTheme.spacing3 : AppTheme.spacing4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: AppTheme.primaryPurple, size: isMobile ? 18 : 20),
                  SizedBox(width: AppTheme.spacing2),
                  Text(
                    '최근 활동',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  '전체보기',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing3),
          ...(_activities as List).take(5).map((a) {
            final activity = a as Map<String, dynamic>;
            final dotColor = _getActivityColor(activity['color']?.toString() ?? '');
            return Container(
              margin: EdgeInsets.only(bottom: AppTheme.spacing2),
              padding: EdgeInsets.symmetric(
                horizontal: AppTheme.spacing3,
                vertical: AppTheme.spacing2,
              ),
              decoration: BoxDecoration(
                color: dotColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: dotColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacing3),
                  Expanded(
                    child: Text(
                      '${activity['label'] ?? ''} · ${activity['entity'] ?? ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    activity['ago'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        child: Container(
        padding: EdgeInsets.all(isMobile ? AppTheme.spacing2 : AppTheme.spacing2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    change,
                    style: TextStyle(
                      fontSize: isMobile ? 9 : 10,
                      color: AppTheme.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: AppTheme.spacing2),
            Container(
              width: isMobile ? 28 : 36,
              height: isMobile ? 28 : 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: Colors.white, size: isMobile ? 14 : 18),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
