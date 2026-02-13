import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/spare_card.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/job_filter_dropdown.dart';
import '../../utils/region_helper.dart';
import '../../utils/icon_mapper.dart';
import '../../models/region.dart';
import '../../models/spare_profile.dart';
import '../../services/spare_service.dart';
import '../../providers/chat_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/error_handler.dart';
import 'spare_detail_screen.dart';
import 'messages_screen.dart';
import 'home_screen.dart';

class ShopSparesListScreen extends StatefulWidget {
  const ShopSparesListScreen({super.key});

  @override
  State<ShopSparesListScreen> createState() => _ShopSparesListScreenState();
}

class _ShopSparesListScreenState extends State<ShopSparesListScreen> {
  final SpareService _spareService = SpareService();
  final TextEditingController _searchController = TextEditingController();
  
  List<SpareProfile> _allSpares = [];
  List<SpareProfile> _filteredSpares = [];
  bool _isLoading = true;
  String? _error;
  bool _isSearchOpen = false;
  
  // 필터 상태
  String _searchQuery = '';
  String? _selectedProvince;
  String? _selectedDistrict;
  String _roleFilter = 'all'; // 'all' | 'step' | 'designer'
  String _sortBy = 'popular'; // 'popular' | 'newest' | 'experience' | 'completed'
  bool _isLicenseVerifiedOnly = false;
  
  // 드롭다운 상태
  bool _showProvinceDropdown = false;
  bool _showDistrictDropdown = false;
  bool _showSortDropdown = false;
  
  // 드롭다운 버튼 키
  final GlobalKey _provinceButtonKey = GlobalKey();
  final GlobalKey _districtButtonKey = GlobalKey();
  final GlobalKey _sortButtonKey = GlobalKey();
  
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
  
  List<String> get _selectedRegionIds {
    if (_selectedDistrict != null) {
      return [_selectedDistrict!];
    } else if (_selectedProvince != null) {
      return RegionHelper.getDistrictsByProvince(_selectedProvince!)
          .map((d) => d.id)
          .toList();
    }
    return [];
  }
  
  @override
  void initState() {
    super.initState();
    _loadSpares();
    _loadNotifications();
    _loadChats();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSpares() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final regionIds = _selectedRegionIds;
      final spares = await _spareService.getSpares(
        regionIds: regionIds.isNotEmpty ? regionIds : null,
        role: _roleFilter != 'all' ? _roleFilter : null,
        isLicenseVerified: _isLicenseVerifiedOnly ? true : null,
        sortBy: _sortBy,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      setState(() {
        _allSpares = spares;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e));
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadNotifications() async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    await provider.loadNotifications();
  }
  
  Future<void> _loadChats() async {
    final provider = Provider.of<ChatProvider>(context, listen: false);
    await provider.loadChats();
  }
  
  void _applyFilters() {
    List<SpareProfile> filtered = List.from(_allSpares);
    
    // 검색 필터
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((spare) {
        return spare.name.toLowerCase().contains(query) ||
            spare.specialties.any((s) => s.toLowerCase().contains(query)) ||
            RegionHelper.getRegionName(spare.regionId).toLowerCase().contains(query);
      }).toList();
    }
    
    // 지역 필터
    final regionIds = _selectedRegionIds;
    if (regionIds.isNotEmpty) {
      filtered = filtered.where((spare) => regionIds.contains(spare.regionId)).toList();
    }
    
    // 역할 필터
    if (_roleFilter == 'step') {
      filtered = filtered.where((spare) => spare.role == 'step').toList();
    } else if (_roleFilter == 'designer') {
      filtered = filtered.where((spare) => spare.role == 'designer').toList();
    }
    
    // 면허 인증 필터
    if (_isLicenseVerifiedOnly) {
      filtered = filtered.where((spare) => spare.isLicenseVerified).toList();
    }
    
    
    // 정렬
    switch (_sortBy) {
      case 'popular':
        // 인기순: 따봉 개수 * 완료 건수
        filtered.sort((a, b) {
          final aPopularity = a.thumbsUpCount * a.completedJobs;
          final bPopularity = b.thumbsUpCount * b.completedJobs;
          return bPopularity.compareTo(aPopularity);
        });
        break;
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'experience':
        filtered.sort((a, b) => b.experience.compareTo(a.experience));
        break;
      case 'completed':
        filtered.sort((a, b) => b.completedJobs.compareTo(a.completedJobs));
        break;
    }
    
    setState(() {
      _filteredSpares = filtered;
    });
  }

  // 인기 인력 상위 3명 확인 (인기순 정렬 시)
  Set<String> get _topPopularSpareIds {
    if (_sortBy != 'popular') return {};
    final sorted = _filteredSpares.take(3).map((s) => s.id).toSet();
    return sorted;
  }
  
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedProvince = null;
      _selectedDistrict = null;
      _roleFilter = 'all';
      _sortBy = 'popular';
      _isLicenseVerifiedOnly = false;
      _showProvinceDropdown = false;
      _showDistrictDropdown = false;
      _showSortDropdown = false;
    });
    _searchController.clear();
    _applyFilters();
  }
  
  bool get _hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedProvince != null ||
        _roleFilter != 'all' ||
        _isLicenseVerifiedOnly;
  }
  
  @override
  Widget build(BuildContext context) {
    final stepCount = _allSpares.where((s) => s.role == 'step').length;
    final designerCount = _allSpares.where((s) => s.role == 'designer').length;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: CustomScrollView(
        slivers: [
          // AppBar (스페어 스타일)
          SliverAppBar(
            pinned: true,
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
                        hintText: '이름, 전문분야, 지역 검색...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                        ),
                        contentPadding: EdgeInsets.all(AppTheme.spacing4),
                        filled: true,
                        fillColor: AppTheme.backgroundWhite,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _applyFilters();
                      },
                      onSubmitted: (value) {
                        setState(() {
                          _searchQuery = value;
                          _isSearchOpen = false;
                        });
                        _applyFilters();
                      },
                    ),
                  )
                : Text(
                    '인력별',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
            centerTitle: false,
            actions: _isSearchOpen
                ? [
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () {
                        setState(() {
                          _isSearchOpen = false;
                          _searchController.clear();
                          _searchQuery = '';
                        });
                        _applyFilters();
                      },
                    ),
                  ]
                : [
                    IconButton(
                      icon: const Icon(Icons.search, color: AppTheme.textSecondary),
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
                                  const Icon(Icons.message, color: AppTheme.textSecondary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ShopMessagesScreen(),
                                  ),
                                );
                              },
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, _) {
                        return NotificationBell(role: 'shop');
                      },
                    ),
                  ],
          ),
          
          // 필터 및 통계 섹션 (Spare 공고별 스타일)
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.backgroundWhite,
              padding: EdgeInsets.all(AppTheme.spacing3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 전체 인력 개수 및 새로고침
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '전체 인력 ${_filteredSpares.length}명',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: IconMapper.icon('refresh', size: 20, color: AppTheme.textSecondary) ??
                            const Icon(Icons.refresh, size: 20, color: AppTheme.textSecondary),
                        onPressed: _loadSpares,
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
                            _applyFilters();
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
                              _applyFilters();
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
                          options: ['인기순', '최신순', '경력순', '완료건수순'],
                          selectedValue: _sortBy == 'popular' ? '인기순'
                              : _sortBy == 'newest' ? '최신순'
                              : _sortBy == 'experience' ? '경력순'
                              : '완료건수순',
                          onSelected: (value) {
                            setState(() {
                              if (value == '인기순') {
                                _sortBy = 'popular';
                              } else if (value == '최신순') {
                                _sortBy = 'newest';
                              } else if (value == '경력순') {
                                _sortBy = 'experience';
                              } else if (value == '완료건수순') {
                                _sortBy = 'completed';
                              }
                              _showSortDropdown = false;
                            });
                            _applyFilters();
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
                          emoji: '👥',
                          isSelected: _roleFilter == 'all' && !_isLicenseVerifiedOnly,
                          onTap: () {
                            setState(() {
                              _roleFilter = 'all';
                              _isLicenseVerifiedOnly = false;
                            });
                            _applyFilters();
                          },
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        _FilterChip(
                          label: '스텝',
                          emoji: '✂️',
                          isSelected: _roleFilter == 'step',
                          onTap: () {
                            setState(() {
                              _roleFilter = _roleFilter == 'step' ? 'all' : 'step';
                            });
                            _applyFilters();
                          },
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        _FilterChip(
                          label: '디자이너',
                          emoji: '💇',
                          isSelected: _roleFilter == 'designer',
                          onTap: () {
                            setState(() {
                              _roleFilter = _roleFilter == 'designer' ? 'all' : 'designer';
                            });
                            _applyFilters();
                          },
                        ),
                        SizedBox(width: AppTheme.spacing2),
                        _FilterChip(
                          label: '면허인증',
                          emoji: '✅',
                          isSelected: _isLicenseVerifiedOnly,
                          onTap: () {
                            setState(() {
                              _isLicenseVerifiedOnly = !_isLicenseVerifiedOnly;
                            });
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 스페어 목록
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    ElevatedButton(
                      onPressed: _loadSpares,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredSpares.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_outline, size: 64, color: AppTheme.textSecondary),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      _hasActiveFilters
                          ? '조건에 맞는 인력이 없습니다'
                          : '인력 정보를 불러오는 중...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    if (_hasActiveFilters) ...[
                      SizedBox(height: AppTheme.spacing4),
                      ElevatedButton(
                        onPressed: _resetFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('필터 초기화'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final spare = _filteredSpares[index];
                  final isTopPopular = _topPopularSpareIds.contains(spare.id);
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing2,
                    ),
                    child: Stack(
                      children: [
                        SpareCard(
                          spare: spare,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShopSpareDetailScreen(spareId: spare.id),
                              ),
                            );
                          },
                        ),
                        // 인기 배지
                        if (isTopPopular && _sortBy == 'popular')
                          Positioned(
                            top: AppTheme.spacing2,
                            left: AppTheme.spacing2,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing2,
                                vertical: AppTheme.spacing1,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.yellow400,
                                    AppTheme.orange500,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                boxShadow: AppTheme.shadowMd,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: AppTheme.spacing1),
                                  Text(
                                    '인기',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                childCount: _filteredSpares.length,
              ),
            ),
        ],
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
