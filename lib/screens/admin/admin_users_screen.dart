import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/admin/admin_page_header.dart';
import '../../widgets/admin/admin_search_filter_bar.dart';
import '../../widgets/admin/admin_table_card.dart';
import 'admin_user_detail_screen.dart';

/// 관리자 회원 관리 화면 (Next.js와 동일한 스타일)
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _users = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  String _search = '';
  String _roleFilter = '';
  String _signupMethodFilter = 'all';
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  Timer? _updateTimer;
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    // 5초마다 자동 업데이트
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadUsers(showLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _updateTimer?.cancel();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUsers({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }

    try {
      final result = await _adminService.getUsers(
        role: _roleFilter.isEmpty ? null : _roleFilter,
        search: _search.isEmpty ? null : _search,
        signupMethod: _signupMethodFilter == 'all' ? null : _signupMethodFilter,
        page: _currentPage,
        limit: 20,
      );

      if (mounted) {
        setState(() {
          _users = result['users'] ?? [];
          _totalPages = result['pagination']?['totalPages'] ?? 1;
          _total = result['pagination']?['total'] ?? 0;
          _isLoading = false;
          _hasLoadError = false;
        });
      }
    } catch (e) {
      final appException = ErrorHandler.handleException(e);
      if (mounted) {
        if (showLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('회원 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(appException)}'),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
        setState(() {
          _isLoading = false;
          _hasLoadError = true;
        });
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy년 M월 d일', 'ko_KR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'spare':
        return '스페어';
      case 'shop':
        return '미용실';
      case 'seller':
        return '디자이너';
      default:
        return role;
    }
  }

  Color _getRoleBadgeColor(String role) {
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

  Widget _buildSignupMethodBadge(dynamic accounts) {
    if (accounts == null || (accounts as List).isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.email, size: 12, color: AppTheme.textSecondary),
          SizedBox(width: AppTheme.spacing1),
          Text(
            '일반 가입',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      );
    }

    final provider = (accounts as List).first['provider'] ?? '';
    switch (provider) {
      case 'kakao':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE500),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Icon(Icons.circle, size: 8, color: Colors.black),
            ),
            SizedBox(width: AppTheme.spacing1),
            Text(
              '카카오가입',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        );
      case 'naver':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF03C75A),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Center(
                child: Text(
                  'N',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppTheme.spacing1),
            Text(
              '네이버가입',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        );
      case 'google':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.borderGray),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Icon(Icons.g_mobiledata, size: 10, color: Colors.blue),
            ),
            SizedBox(width: AppTheme.spacing1),
            Text(
              '구글이입',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.email, size: 12, color: AppTheme.textSecondary),
            SizedBox(width: AppTheme.spacing1),
            Text(
              '일반 가입',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        );
    }
  }

  String _getSignupLabel(dynamic accounts) {
    if (accounts == null || (accounts as List).isEmpty) return '일반 가입';
    final provider = (accounts as List).first['provider'] ?? '';
    switch (provider) {
      case 'kakao': return '카카오';
      case 'naver': return '네이버';
      case 'google': return '구글';
      default: return '일반 가입';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/admin/users',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: '회원 관리',
            subtitle: '전체 회원을 조회하고 관리할 수 있습니다',
          ),
          SizedBox(height: AppTheme.spacing6),
          AdminSearchFilterBar(
            searchController: _searchController,
            filterTabs: const ['전체', '헤어스페어', '카카오', '네이버', '구글'],
            selectedTab: _signupMethodFilter == 'all'
                ? '전체'
                : _signupMethodFilter == 'email'
                    ? '헤어스페어'
                    : _signupMethodFilter == 'kakao'
                        ? '카카오'
                        : _signupMethodFilter == 'naver'
                            ? '네이버'
                            : _signupMethodFilter == 'google'
                                ? '구글'
                                : '전체',
            onTabChanged: (tab) {
              setState(() {
                _signupMethodFilter = tab == '전체'
                    ? 'all'
                    : tab == '헤어스페어'
                        ? 'email'
                        : tab == '카카오'
                            ? 'kakao'
                            : tab == '네이버'
                                ? 'naver'
                                : tab == '구글'
                                    ? 'google'
                                    : 'all';
                _currentPage = 1;
              });
              _loadUsers();
            },
            onSearchChanged: (value) {
              _searchDebounceTimer?.cancel();
              setState(() {
                _search = value;
                _currentPage = 1;
              });
              _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
                if (mounted) _loadUsers();
              });
            },
            filterDropdown: DropdownButton<String>(
              value: _roleFilter.isEmpty ? null : _roleFilter,
              hint: const Text('전체 역할'),
              items: const [
                DropdownMenuItem(value: '', child: Text('전체 역할')),
                DropdownMenuItem(value: 'spare', child: Text('스페어')),
                DropdownMenuItem(value: 'seller', child: Text('디자이너')),
                DropdownMenuItem(value: 'shop', child: Text('미용실')),
              ],
              onChanged: (value) {
                setState(() {
                  _roleFilter = value ?? '';
                  _currentPage = 1;
                });
                _loadUsers();
              },
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
          SizedBox(height: AppTheme.spacing6),
          SizedBox(
            height: 600,
            child: AdminTableCard(
              child: _isLoading && _users.isEmpty
                  ? _buildTableSkeleton()
                  : _hasLoadError
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacing8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cloud_off, size: 64, color: AppTheme.urgentRed),
                                SizedBox(height: AppTheme.spacing4),
                                Text(
                                  '회원 목록을 불러오지 못했습니다',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppTheme.spacing4),
                                Text(
                                  'API Gateway(localhost:8000)가 실행 중인지 확인해주세요',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textTertiary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppTheme.spacing6),
                                FilledButton.icon(
                                  onPressed: () => _loadUsers(),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('다시 시도'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _users.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppTheme.spacing8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people_outline, size: 64, color: AppTheme.textTertiary),
                                    SizedBox(height: AppTheme.spacing4),
                                    Text(
                                      '회원이 없습니다',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 900),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AdminTableHeader(
                                  headers: ['회원 정보', '연락처', '역할', '활동', '에너지', '가입일', '관리'],
                                  flexValues: [2, 1, 1, 1, 1, 1, 1],
                                ),
                                SizedBox(
                                  height: 480,
                                  child: ListView.builder(
                                itemCount: _users.length,
                                itemBuilder: (context, index) {
                                  final user = _users[index];
                                  final roleColor = _getRoleBadgeColor(user['role'] ?? '');
                                  final jobs = user['_count']?['jobs'] ?? 0;
                                  final apps = user['_count']?['applications'] ?? 0;
                                  final sched = user['_count']?['schedules'] ?? 0;
                                  final userId = user['id']?.toString();
                                  return InkWell(
                                    onTap: userId != null
                                        ? () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => AdminUserDetailScreen(
                                                  userId: userId,
                                                  initialData: user,
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacing4,
                                        vertical: AppTheme.spacing3,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(color: AppTheme.adminPurple100.withOpacity(0.5)),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 48,
                                                  height: 48,
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
                                                    boxShadow: AppTheme.shadowMd,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      (user['name'] ?? '?')[0],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: AppTheme.spacing4),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            user['name'] ?? '이름 없음',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                              color: AppTheme.textPrimary,
                                                            ),
                                                          ),
                                                          SizedBox(width: AppTheme.spacing2),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: AppTheme.spacing2,
                                                              vertical: 2,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: AppTheme.adminPurple100,
                                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                                            ),
                                                            child: Text(
                                                              _getSignupLabel(user['accounts']),
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.w600,
                                                                color: AppTheme.purple700,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: AppTheme.spacing1),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.email, size: 12, color: AppTheme.textSecondary),
                                                          SizedBox(width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              user['email'] ?? '',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: AppTheme.textSecondary,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                Icon(Icons.phone, size: 14, color: AppTheme.textSecondary),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    user['phone'] ?? '-',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme.textSecondary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: AppTheme.spacing2,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: roleColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                              ),
                                              child: Text(
                                                _getRoleLabel(user['role'] ?? ''),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: roleColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '공고 $jobs · 지원 $apps · 스케줄 $sched',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: AppTheme.spacing2,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppTheme.yellow50,
                                                    AppTheme.orange50,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                                                border: Border.all(color: AppTheme.yellow400.withOpacity(0.5)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check_circle, size: 14, color: AppTheme.yellow600),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${user['energyWallet']?['balance'] ?? 0}개',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppTheme.textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              _formatDate(user['createdAt'] ?? ''),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.visibility, size: 18, color: AppTheme.textSecondary),
                                                  onPressed: userId != null
                                                      ? () {
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                              builder: (context) => AdminUserDetailScreen(
                                                                userId: userId,
                                                                initialData: user,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      : null,
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  style: IconButton.styleFrom(
                                                    backgroundColor: AppTheme.adminPurple50,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                IconButton(
                                                  icon: Icon(Icons.more_vert, size: 18, color: AppTheme.textSecondary),
                                                  onPressed: () {},
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (_totalPages > 1)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing6,
                                  vertical: AppTheme.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.adminPurple50.withOpacity(0.3),
                                      AppTheme.adminPink50.withOpacity(0.3),
                                    ],
                                  ),
                                  border: Border(
                                    top: BorderSide(color: AppTheme.adminPurple100, width: 2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '총 $_total명 중 ${(_currentPage - 1) * 20 + 1}-${(_currentPage * 20).clamp(0, _total)}명 표시',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: _currentPage > 1
                                              ? () {
                                                  setState(() {
                                                    _currentPage--;
                                                  });
                                                  _loadUsers();
                                                }
                                              : null,
                                          child: const Text('이전'),
                                        ),
                                        SizedBox(width: AppTheme.spacing2),
                                        TextButton(
                                          onPressed: _currentPage < _totalPages
                                              ? () {
                                                  setState(() {
                                                    _currentPage++;
                                                  });
                                                  _loadUsers();
                                                }
                                              : null,
                                          child: const Text('다음'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ],
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSkeleton() {
    return AdminTableSkeleton(rowCount: 8, columnCount: 7);
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing4,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
