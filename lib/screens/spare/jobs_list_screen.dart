import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../models/job.dart';
import '../../models/region.dart';
import '../../models/space_rental.dart';
import '../../theme/app_theme.dart';
import '../../widgets/compact_announcement_card.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_filter_bar.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/stitch/stitch_list_job_card.dart';
import '../../widgets/job_filter_dropdown.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/date_filter_button.dart';
import '../../utils/region_helper.dart';
import '../../utils/job_popularity.dart';
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
    Set<String> popularJobIds,
  ) {
    final type = item['type'] as String;
    final data = item['data'];

    if (type == 'job') {
      final job = data as Job;
      return StitchListJobCard(
        job: job,
        isFavorite: favoriteMap[job.id] ?? false,
        showPopularBadge: JobPopularity.showsPopularBadge(job, popularJobIds),
        onTap: () => _handleJobTap(job),
        onFavoriteToggle: () => favoriteProvider.toggleFavorite(job.id),
        margin: EdgeInsets.zero,
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
            return StitchEmptyState(
              message: '오류가 발생했습니다',
              iconName: 'alertcircle',
              actionLabel: '다시 시도',
              onAction: () => jobProvider.refreshJobs(),
            );
          }

          final allJobs = jobProvider.jobs;
          final popularJobIds = JobPopularity.popularJobIds(allJobs);
          final filteredJobs = _getFilteredJobs(allJobs);
          final allItems = _buildCombinedList(filteredJobs);

          return Column(
            children: [
              // 필터 섹션
              StitchFilterBar(
                totalCount: allItems.length,
                onRefresh: _handleRefresh,
                dropdownRow: Row(
                  children: [
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
                chipRow: Row(
                  children: [
                          StitchFilterChip(
                            label: '전체',
                            isSelected: _activeFilter == null && !_isPremium,
                            onTap: () {
                              setState(() {
                                _activeFilter = null;
                                _isPremium = false;
                              });
                            },
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          StitchFilterChip(
                            label: '급구',
                            emoji: '🚀',
                            urgent: true,
                            isSelected: _activeFilter == 'urgent',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'urgent' ? null : 'urgent';
                              });
                            },
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          StitchFilterChip(
                            label: '최신순',
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
                          StitchFilterChip(
                            label: '마감임박',
                            isSelected: _activeFilter == 'deadline',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'deadline' ? null : 'deadline';
                              });
                            },
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          StitchFilterChip(
                            label: '시급',
                            isSelected: _activeFilter == 'hourly',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'hourly' ? null : 'hourly';
                              });
                            },
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          StitchFilterChip(
                            label: '일급',
                            isSelected: _activeFilter == 'daily',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'daily' ? null : 'daily';
                              });
                            },
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          StitchFilterChip(
                            label: '추천',
                            isSelected: _activeFilter == 'recommended',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'recommended' ? null : 'recommended';
                              });
                            },
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          StitchFilterChip(
                            label: '프리미엄',
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
                        ? const StitchEmptyState(
                            message: '조건에 맞는 공고가 없습니다',
                            iconName: 'briefcase',
                          )
                        : ListView.builder(
                            padding: AppTheme.spacing(AppTheme.spacing4),
                            itemCount: allItems.length,
                            itemBuilder: (context, index) {
                              final item = allItems[index];
                              return _buildAnnouncementCard(
                                context,
                                item,
                                favoriteMap,
                                favoriteProvider,
                                popularJobIds,
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
