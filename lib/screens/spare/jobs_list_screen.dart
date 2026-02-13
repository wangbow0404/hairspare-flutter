import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/job.dart';
import '../../models/region.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/job_card.dart';
import '../../widgets/job_filter_dropdown.dart';
import '../../widgets/notification_bell.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/region_helper.dart';
import '../spare/job_detail_screen.dart';
import 'home_screen.dart';
import 'messages_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Next.js와 동일한 공고 목록 화면
class JobsListScreen extends StatefulWidget {
  final String? filter; // 'urgent', 'latest', 'deadline', 'hourly', 'daily', 'recommended'

  const JobsListScreen({super.key, this.filter});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  int _currentNavIndex = 0;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String? _activeFilter;
  String _sortBy = 'latest';
  
  // 지역 필터 상태
  String? _selectedProvince;
  String? _selectedDistrict;
  
  // 드롭다운 상태
  bool _showProvinceDropdown = false;
  bool _showDistrictDropdown = false;
  bool _showSortDropdown = false;
  
  // 드롭다운 버튼 키
  final GlobalKey _provinceButtonKey = GlobalKey();
  final GlobalKey _districtButtonKey = GlobalKey();
  final GlobalKey _sortButtonKey = GlobalKey();
  
  // 추가 필터 상태
  bool _isPremium = false;
  
  // 지역 데이터
  List<Region> get _provinces {
    return RegionHelper.getAllRegions()
        .where((r) => r.type == RegionType.province)
        .toList();
  }
  
  List<Region> get _districts {
    if (_selectedProvince == null) return [];
    return RegionHelper.getDistrictsByProvince(_selectedProvince!);
  }

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.filter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).loadJobs();
      Provider.of<FavoriteProvider>(context, listen: false).loadFavorites();
    });
  }
  
  void _handleRefresh() {
    setState(() {
      _selectedProvince = null;
      _selectedDistrict = null;
      _activeFilter = null;
      _sortBy = 'latest';
      _isPremium = false;
    });
    Provider.of<JobProvider>(context, listen: false).refreshJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _handleJobTap(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(jobId: job.id),
      ),
    );
  }

  List<Job> _getFilteredJobs(List<Job> allJobs) {
    List<Job> filtered = [...allJobs];

    // 지역 필터
    if (_selectedDistrict != null) {
      filtered = filtered.where((j) => j.regionId == _selectedDistrict).toList();
    } else if (_selectedProvince != null) {
      final districtIds = _districts.map((d) => d.id).toList();
      filtered = filtered.where((j) => districtIds.contains(j.regionId)).toList();
    }

    // 기본 필터
    if (_activeFilter == 'urgent') {
      filtered = filtered.where((j) => j.isUrgent).toList();
    } else if (_activeFilter == 'deadline') {
      filtered = filtered.where((j) => j.isUrgent && (j.countdown ?? 0) < 3600).toList();
    } else if (_activeFilter == 'latest') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_activeFilter == 'hourly' || _activeFilter == 'daily') {
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_activeFilter == 'recommended') {
      filtered.sort((a, b) {
        if (a.isPremium && !b.isPremium) return -1;
        if (!a.isPremium && b.isPremium) return 1;
        if (a.isUrgent && !b.isUrgent) return -1;
        if (!a.isUrgent && b.isUrgent) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    }

    // 추가 필터
    if (_isPremium) {
      filtered = filtered.where((j) => j.isPremium).toList();
    }

    // 정렬 적용
    if (_sortBy == 'latest') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'amount') {
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortBy == 'deadline') {
      filtered.sort((a, b) {
        final aCountdown = a.countdown ?? 0;
        final bCountdown = b.countdown ?? 0;
        return aCountdown.compareTo(bCountdown);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearchOpen
            ? Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                    contentPadding: AppTheme.spacing(AppTheme.spacing4),
                    filled: true,
                    fillColor: AppTheme.backgroundWhite,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : Text(
                '공고 목록',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
        actions: _isSearchOpen
            ? [
                IconButton(
                  icon: IconMapper.icon('x', size: 24, color: AppTheme.textSecondary) ??
                      const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () {
                    setState(() {
                      _isSearchOpen = false;
                      _searchController.clear();
                    });
                  },
                ),
              ]
            : [
                IconButton(
                  icon: IconMapper.icon('search', size: 24, color: AppTheme.textSecondary) ??
                      const Icon(Icons.search, color: AppTheme.textSecondary),
                  onPressed: () {
                    setState(() {
                      _isSearchOpen = true;
                    });
                  },
                ),
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    final unreadCount = chatProvider.totalUnreadCount;
                    return Stack(
                      children: [
                        IconButton(
                          icon: IconMapper.icon('messagecircle', size: 24, color: AppTheme.textSecondary) ??
                              const Icon(Icons.message_outlined, color: AppTheme.textSecondary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MessagesScreen()),
                            );
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.urgentRed,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                NotificationBell(
                  role: 'spare',
                ),
              ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (jobProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '오류가 발생했습니다',
                    style: TextStyle(color: AppTheme.urgentRed),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  ElevatedButton(
                    onPressed: () => jobProvider.refreshJobs(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final allJobs = jobProvider.normalJobs;
          final filteredJobs = _getFilteredJobs(allJobs);

          return Column(
            children: [
              // 필터 섹션
              Container(
                color: AppTheme.backgroundWhite,
                padding: AppTheme.spacing(AppTheme.spacing3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 전체공고 개수 및 새로고침
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '전체공고 총 ${allJobs.length}개',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: IconMapper.icon('refresh', size: 20, color: AppTheme.textSecondary) ??
                              const Icon(Icons.refresh, size: 20, color: AppTheme.textSecondary),
                          onPressed: _handleRefresh,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing3),
                    
                    // 첫 번째 줄: 지역 선택, 정렬
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // 지역(시/도) 드롭다운
                          JobFilterDropdown(
                            label: '지역',
                            options: _provinces.map((p) => p.name).toList(),
                            selectedValue: _selectedProvince != null
                                ? _provinces.firstWhere((p) => p.id == _selectedProvince).name
                                : null,
                            onSelected: (value) {
                              setState(() {
                                _selectedProvince = value != null
                                    ? _provinces.firstWhere((p) => p.name == value).id
                                    : null;
                                _selectedDistrict = null;
                                _showProvinceDropdown = false;
                              });
                            },
                            buttonKey: _provinceButtonKey,
                            isOpen: _showProvinceDropdown,
                            onToggle: () {
                              setState(() {
                                _showProvinceDropdown = !_showProvinceDropdown;
                                _showDistrictDropdown = false;
                                _showSortDropdown = false;
                              });
                            },
                          ),
                          // 상세지역(구/군) 드롭다운 - 지역 선택 시에만 표시
                          if (_selectedProvince != null && _districts.isNotEmpty) ...[
                            SizedBox(width: AppTheme.spacing2),
                            JobFilterDropdown(
                              label: '상세지역',
                              options: _districts.map((d) => d.name).toList(),
                              selectedValue: _selectedDistrict != null
                                  ? _districts.firstWhere((d) => d.id == _selectedDistrict).name
                                  : null,
                              onSelected: (value) {
                                setState(() {
                                  _selectedDistrict = value != null
                                      ? _districts.firstWhere((d) => d.name == value).id
                                      : null;
                                  _showDistrictDropdown = false;
                                });
                              },
                              buttonKey: _districtButtonKey,
                              isOpen: _showDistrictDropdown,
                              onToggle: () {
                                setState(() {
                                  _showDistrictDropdown = !_showDistrictDropdown;
                                  _showProvinceDropdown = false;
                                  _showSortDropdown = false;
                                });
                              },
                            ),
                          ],
                          SizedBox(width: AppTheme.spacing2),
                          // 정렬 드롭다운
                          JobFilterDropdown(
                            label: '정렬',
                            options: ['최신순', '가격순', '마감순'],
                            selectedValue: _sortBy == 'latest' ? '최신순'
                                : _sortBy == 'amount' ? '가격순'
                                : '마감순',
                            onSelected: (value) {
                              setState(() {
                                if (value == '최신순') {
                                  _sortBy = 'latest';
                                } else if (value == '가격순') {
                                  _sortBy = 'amount';
                                } else if (value == '마감순') {
                                  _sortBy = 'deadline';
                                }
                                _showSortDropdown = false;
                              });
                            },
                            buttonKey: _sortButtonKey,
                            isOpen: _showSortDropdown,
                            onToggle: () {
                              setState(() {
                                _showSortDropdown = !_showSortDropdown;
                                _showProvinceDropdown = false;
                                _showDistrictDropdown = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing3),
                    
                    // 두 번째 줄: 필터 버튼들
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: '전체',
                            emoji: '📋',
                            isSelected: _activeFilter == null && !_isPremium,
                            onTap: () {
                              setState(() {
                                _activeFilter = null;
                                _isPremium = false;
                              });
                            },
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          _FilterChip(
                            label: '급구',
                            emoji: '🚀',
                            isSelected: _activeFilter == 'urgent',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'urgent' ? null : 'urgent';
                              });
                            },
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          _FilterChip(
                            label: '최신순',
                            emoji: '🕐',
                            isSelected: _activeFilter == 'latest',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'latest' ? null : 'latest';
                              });
                            },
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          _FilterChip(
                            label: '마감임박',
                            emoji: '⏰',
                            isSelected: _activeFilter == 'deadline',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'deadline' ? null : 'deadline';
                              });
                            },
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          _FilterChip(
                            label: '시급',
                            emoji: '💵',
                            isSelected: _activeFilter == 'hourly',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'hourly' ? null : 'hourly';
                              });
                            },
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          _FilterChip(
                            label: '일급',
                            emoji: '💰',
                            isSelected: _activeFilter == 'daily',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'daily' ? null : 'daily';
                              });
                            },
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          _FilterChip(
                            label: '추천',
                            emoji: '⭐',
                            isSelected: _activeFilter == 'recommended',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'recommended' ? null : 'recommended';
                              });
                            },
                          ),
                          SizedBox(width: AppTheme.spacing2),
                          // 프리미엄 필터 (별도 토글)
                          _FilterChip(
                            label: '프리미엄',
                            emoji: '✨',
                            isSelected: _isPremium,
                            onTap: () {
                              setState(() {
                                _isPremium = !_isPremium;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 공고 목록
              Expanded(
                child: Consumer<FavoriteProvider>(
                  builder: (context, favoriteProvider, _) {
                    final favoriteMap = favoriteProvider.favoriteJobIds
                        .fold<Map<String, bool>>(
                          {},
                          (map, jobId) => map..[jobId] = true,
                        );
                    
                    return filteredJobs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconMapper.icon('briefcase', size: 48, color: AppTheme.textTertiary) ??
                                    const Icon(Icons.work_outline, size: 48, color: AppTheme.textTertiary),
                                SizedBox(height: AppTheme.spacing4),
                                Text(
                                  '공고가 없습니다',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: AppTheme.spacing(AppTheme.spacing4),
                            itemCount: filteredJobs.length,
                            itemBuilder: (context, index) {
                              final job = filteredJobs[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppTheme.spacing4),
                                child: JobCard(
                                  job: job,
                                  isFavorite: favoriteMap[job.id] ?? false,
                                  onTap: () => _handleJobTap(job),
                                  onFavoriteToggle: () {
                                    final currentFavorite = favoriteMap[job.id] ?? false;
                                    Provider.of<FavoriteProvider>(context, listen: false)
                                        .toggleFavorite(job.id);
                                  },
                                ),
                              );
                            },
                          );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          
          // 네비게이션 처리
          switch (index) {
            case 0:
              // 홈으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SpareHomeScreen()),
              );
              break;
            case 1:
              // 결제로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
              break;
            case 2:
              // 찜으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
              break;
            case 3:
              // 마이(프로필)로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: emoji != null ? AppTheme.spacing3 : AppTheme.spacing4,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? (emoji != null ? Colors.grey.shade200 : AppTheme.primaryBlue)
              : AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(20),
          border: isSelected && emoji != null
              ? Border.all(
                  color: Colors.grey.shade400,
                  width: 1.5,
                )
              : null,
          boxShadow: isSelected && emoji != null
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(
                emoji!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.0,
                ),
              ),
              SizedBox(width: AppTheme.spacing1),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? (emoji != null ? AppTheme.textPrimary : Colors.white)
                    : AppTheme.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
