import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin_layout.dart';

/// 관리자 회원 관리 화면
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
  String _search = '';
  String _roleFilter = '';
  String _signupMethodFilter = 'all';
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  Timer? _updateTimer;

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
    super.dispose();
  }

  Future<void> _loadUsers({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        title: const Text('회원 관리'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 필터 영역
          Container(
            padding: EdgeInsets.all(AppTheme.spacing3),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: '이름, 이메일, 전화번호로 검색',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _search = value;
                    });
                    _loadUsers();
                  },
                ),
                const SizedBox(height: AppTheme.spacing2),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _roleFilter.isEmpty ? null : _roleFilter,
                        decoration: InputDecoration(
                          labelText: '역할',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('전체')),
                          DropdownMenuItem(value: 'spare', child: Text('스페어')),
                          DropdownMenuItem(value: 'shop', child: Text('미용실')),
                          DropdownMenuItem(value: 'seller', child: Text('판매자')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _roleFilter = value ?? '';
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _signupMethodFilter,
                        decoration: InputDecoration(
                          labelText: '가입 방법',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('전체')),
                          DropdownMenuItem(value: 'kakao', child: Text('카카오')),
                          DropdownMenuItem(value: 'naver', child: Text('네이버')),
                          DropdownMenuItem(value: 'google', child: Text('구글')),
                          DropdownMenuItem(value: 'email', child: Text('이메일')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _signupMethodFilter = value ?? 'all';
                          });
                          _loadUsers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 회원 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('회원이 없습니다'))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing3,
                              vertical: AppTheme.spacing1,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryPurple,
                                child: Text(
                                  (user['name'] ?? user['email'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(user['name'] ?? user['email'] ?? '이름 없음'),
                              subtitle: Text(
                                '${user['email'] ?? ''} | ${user['role'] ?? ''}',
                              ),
                              trailing: Text(
                                '에너지: ${user['energyWallet']?['balance'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // 페이지네이션
          Container(
            padding: EdgeInsets.all(AppTheme.spacing3),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                          _loadUsers();
                        }
                      : null,
                ),
                Text('$_currentPage / $_totalPages'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                          _loadUsers();
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
