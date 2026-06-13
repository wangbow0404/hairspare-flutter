import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../models/job.dart';
import '../../models/region.dart';
import '../../models/space_rental.dart';
import '../../theme/app_theme.dart';
import '../../widgets/compact_announcement_card.dart';
import '../../widgets/job_filter_dropdown.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/date_filter_button.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/region_helper.dart';
import '../spare/job_detail_screen.dart';
import '../spare/space_rental_detail_screen.dart';
import '../spare/education_detail_screen.dart';
import '../spare/education_screen.dart';

/// Next.js와 동일한 공고 목록 화면
class JobsListScreen extends StatefulWidget {
  final String? filter; // 'urgent', 'latest', 'deadline', 'hourly', 'daily', 'recommended'
  final String? searchQuery; // 홈 검색에서 전달된 검색어

  const JobsListScreen({super.key, this.filter, this.searchQuery});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  String? _activeFilter;
  String _sortBy = 'latest';
  String? _searchQuery;

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
  DateTime? _selectedDateStart;
  
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
    _searchQuery = widget.searchQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      if (_searchQuery != null) jobProvider.setSearchQuery(_searchQuery);
      jobProvider.loadJobs(searchQuery: _searchQuery);
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
      _selectedDateStart = null;
      _searchQuery = null;
    });
    Provider.of<JobProvider>(context, listen: false)
      ..setSearchQuery(null)
      ..refreshJobs();
  }



  void _handleJobTap(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(jobId: job.id),
      ),
    );
  }

  /// 공고별 화면: 공고만 표시 (필터·정렬 순서 유지)
  List<Map<String, dynamic>> _buildCombinedList(List<Job> filteredJobs) {
    return filteredJobs
        .map((job) => {'type': 'job', 'data': job})
        .toList();
  }

  bool _isDeadlineImminent(Job job) {
    if (job.countdown != null && job.countdown! > 0) {
      return job.countdown! <= 86400;
    }
    try {
      final parts = job.time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1
          ? int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''))
          : 0;
      final day = DateTime.parse(job.date);
      final start = DateTime(day.year, day.month, day.day, hour, minute);
      final hoursLeft = start.difference(DateTime.now()).inHours;
      return hoursLeft >= 0 && hoursLeft <= 72;
    } catch (_) {
      return job.isUrgent;
    }
  }

  int _deadlineSortKey(Job job) {
    if (job.countdown != null && job.countdown! > 0) return job.countdown!;
    try {
      final parts = job.time.split(':');
      final hour = int.parse(parts[0]);
      final day = DateTime.parse(job.date);
      final start = DateTime(day.year, day.month, day.day, hour);
      return start.difference(DateTime.now()).inSeconds;
    } catch (_) {
      return job.isUrgent ? 0 : 1 << 30;
    }
  }

  void _applySort(List<Job> list) {
    if (_activeFilter == 'recommended') {
      list.sort((a, b) {
        if (a.isPremium != b.isPremium) return a.isPremium ? -1 : 1;
        if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      return;
    }
    switch (_sortBy) {
      case 'amount':
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case 'deadline':
        list.sort((a, b) => _deadlineSortKey(a).compareTo(_deadlineSortKey(b)));
      case 'latest':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, bool> favoriteMap,
    FavoriteProvider favoriteProvider,
  ) {
    final type = item['type'] as String;
    final data = item['data'];

    if (type == 'job') {
      final job = data as Job;
      return CompactAnnouncementCard(
        type: AnnouncementType.job,
        job: job,
        isFavorite: favoriteMap[job.id] ?? false,
        onTap: () => _handleJobTap(job),
        onFavoriteToggle: () => favoriteProvider.toggleFavorite(job.id),
      );
    }
    if (type == 'spaceRental') {
      final space = data as SpaceRental;
      return CompactAnnouncementCard(
        type: AnnouncementType.spaceRental,
        spaceRental: space,
        isFavorite: false,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpaceRentalDetailScreen(spaceId: space.id),
            ),
          );
        },
      );
    }
    if (type == 'education') {
      final edu = data as Education;
      return CompactAnnouncementCard(
        type: AnnouncementType.education,
        education: edu,
        isFavorite: false,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EducationDetailScreen(education: edu),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  List<Job> _getFilteredJobs(List<Job> allJobs) {
    List<Job> filtered = [...allJobs];

    // 검색어 필터 (searchQuery가 있으면 JobProvider에서 이미 필터링된 결과가 오지만, 이중 적용 방지)
    if (_searchQuery != null && _searchQuery!.trim().isNotEmpty) {
      final q = _searchQuery!.trim().toLowerCase();
      filtered = filtered.where((j) {
        return j.title.toLowerCase().contains(q) || j.shopName.toLowerCase().contains(q);
      }).toList();
    }

    // 날짜 필터
    if (_selectedDateStart != null) {
      final targetKey = '${_selectedDateStart!.year}-${_selectedDateStart!.month.toString().padLeft(2, '0')}-${_selectedDateStart!.day.toString().padLeft(2, '0')}';
      filtered = filtered.where((j) {
        try {
          final jobDate = DateTime.parse(j.date);
          final jobKey = '${jobDate.year}-${jobDate.month.toString().padLeft(2, '0')}-${jobDate.day.toString().padLeft(2, '0')}';
          return jobKey == targetKey;
        } catch (_) {
          return j.date == targetKey || j.date.contains(targetKey);
        }
      }).toList();
    }

    // 지역 필터
    if (_selectedDistrict != null) {
      filtered = filtered.where((j) => j.regionId == _selectedDistrict).toList();
    } else if (_selectedProvince != null) {
      final districtIds = _districts.map((d) => d.id).toList();
      filtered = filtered.where((j) => districtIds.contains(j.regionId)).toList();
    }

    // 카테고리 필터 (칩)
    switch (_activeFilter) {
      case 'urgent':
        filtered = filtered.where((j) => j.isUrgent).toList();
        break;
      case 'deadline':
        filtered = filtered.where(_isDeadlineImminent).toList();
        break;
      case 'hourly':
        filtered = filtered.where((j) => j.amount < 80000).toList();
        break;
      case 'daily':
        filtered = filtered.where((j) => j.amount >= 80000).toList();
        break;
      case 'recommended':
        break;
      default:
        break;
    }

    if (_isPremium) {
      filtered = filtered.where((j) => j.isPremium).toList();
    }

    _applySort(filtered);
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '공고별',
        showBackButton: Navigator.canPop(context),
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
                  const Text(
                    '오류가 발생했습니다',
                    style: TextStyle(color: AppTheme.urgentRed),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  ElevatedButton(
                    onPressed: () => jobProvider.refreshJobs(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final allJobs = jobProvider.jobs;
          final filteredJobs = _getFilteredJobs(allJobs);
          final allItems = _buildCombinedList(filteredJobs);

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
                          '전체 ${allItems.length}개',
                          style: const TextStyle(
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
                    const SizedBox(height: AppTheme.spacing3),
                    
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
                            const SizedBox(width: AppTheme.spacing2),
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
                          const SizedBox(width: AppTheme.spacing2),
                          // 날짜 선택
                          DateFilterButton(
                            selectedDate: _selectedDateStart,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedDateStart = date;
                              });
                            },
                            onClear: () {
                              setState(() {
                                _selectedDateStart = null;
                              });
                            },
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          // 정렬 드롭다운
                          JobFilterDropdown(
                            label: '정렬',
                            options: const ['최신순', '가격순', '마감순'],
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
                    const SizedBox(height: AppTheme.spacing3),
                    
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
                          const SizedBox(width: AppTheme.spacing2),
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
                          const SizedBox(width: AppTheme.spacing2),
                          _FilterChip(
                            label: '최신순',
                            emoji: '🕐',
                            isSelected:
                                _sortBy == 'latest' && _activeFilter == null,
                            onTap: () {
                              setState(() {
                                _sortBy = 'latest';
                                _activeFilter = null;
                              });
                            },
                          ),
                          const SizedBox(width: AppTheme.spacing2),
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
                          const SizedBox(width: AppTheme.spacing2),
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
                          const SizedBox(width: AppTheme.spacing2),
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
                          const SizedBox(width: AppTheme.spacing2),
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
                          const SizedBox(width: AppTheme.spacing2),
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
                    
                    return allItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconMapper.icon('briefcase', size: 48, color: AppTheme.textTertiary) ??
                                    const Icon(Icons.work_outline, size: 48, color: AppTheme.textTertiary),
                                const SizedBox(height: AppTheme.spacing4),
                                Text(
                                  '목록이 없습니다',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: AppTheme.spacing(AppTheme.spacing4),
                            itemCount: allItems.length,
                            itemBuilder: (context, index) {
                              final item = allItems[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
                                child: _buildAnnouncementCard(
                                  context,
                                  item,
                                  favoriteMap,
                                  favoriteProvider,
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
                    color: Colors.black.withValues(alpha: 0.05),
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
              const SizedBox(width: AppTheme.spacing1),
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
