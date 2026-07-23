import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../../utils/jobs_list_sort.dart';
import '../../core/router/app_routes.dart';
import '../spare/education_screen.dart';

/// Next.js와 동일한 공고 목록 화면
class JobsListScreen extends StatefulWidget {
  final String? filter; // 'urgent', 'opening_soon', 'latest', 'deadline', 'hourly', 'daily', 'recommended'
  final String? searchQuery; // 홈 검색에서 전달된 검색어
  final JobsListSortMode? initialSortMode;
  final bool initialPremium; // 검색화면 "하이패스" 바로가기에서 전달

  const JobsListScreen({
    super.key,
    this.filter,
    this.searchQuery,
    this.initialSortMode,
    this.initialPremium = false,
  });

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  String? _activeFilter;
  JobsListSortMode _sortMode = JobsListSortMode.all;
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
  bool _bodyReady = false;
  
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
    _sortMode = widget.initialSortMode ?? JobsListSortMode.all;
    _searchQuery = widget.searchQuery;
    _isPremium = widget.initialPremium;
    _scheduleDataLoad();
    _scheduleBodyReveal();
  }

  /// push 애니메이션 완료 후 필터·목록 렌더 (ANR 방지).
  void _scheduleBodyReveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final animation = ModalRoute.of(context)?.animation;
      void reveal() {
        if (!mounted || _bodyReady) return;
        setState(() => _bodyReady = true);
      }

      if (animation != null && !animation.isCompleted) {
        late AnimationStatusListener listener;
        listener = (status) {
          if (status == AnimationStatus.completed) {
            animation.removeStatusListener(listener);
            Future<void>.delayed(const Duration(milliseconds: 150), reveal);
          }
        };
        animation.addStatusListener(listener);
      } else {
        Future<void>.delayed(const Duration(milliseconds: 450), reveal);
      }
    });
  }

  // 네비게이션 애니메이션이 완전히 끝난 뒤 데이터를 불러온다.
  // 애니메이션 중 notifyListeners()가 홈 화면 리빌드를 유발해 UI가 멈추는 문제를 방지.
  void _scheduleDataLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final animation = ModalRoute.of(context)?.animation;
      void runLoad() {
        if (!mounted) return;
        _loadData();
      }

      if (animation != null && !animation.isCompleted) {
        late AnimationStatusListener listener;
        listener = (status) {
          if (status == AnimationStatus.completed) {
            animation.removeStatusListener(listener);
            runLoad();
          }
        };
        animation.addStatusListener(listener);
      } else {
        // 전환 애니메이션이 없어도 홈 JobProvider 리빌드와 겹치지 않도록 짧게 지연
        Future<void>.delayed(const Duration(milliseconds: 350), runLoad);
      }
    });
  }

  void _loadData() {
    if (!mounted) return;
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    if (_searchQuery != null) {
      jobProvider.setSearchQuery(_searchQuery);
    }
    // 홈에서 이미 불러온 공고를 다시 loadJobs()하면 isLoading=true로
    // 홈·목록 화면이 동시에 리빌드되어 전환 중 프레임 오류/멈춤이 난다.
    if (jobProvider.jobs.isEmpty) {
      jobProvider.loadJobs(searchQuery: _searchQuery);
    }
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    if (favoriteProvider.favoriteJobIds.isEmpty) {
      favoriteProvider.loadFavorites();
    }
  }

  void _handleRefresh() {
    setState(() {
      _selectedProvince = null;
      _selectedDistrict = null;
      _activeFilter = null;
      _sortMode = JobsListSortMode.all;
      _isPremium = false;
      _selectedDateStart = null;
      _searchQuery = null;
    });
    Provider.of<JobProvider>(context, listen: false)
      ..setSearchQuery(null)
      ..refreshJobs();
  }



  void _handleJobTap(Job job) {
    context.push(AppRoutes.spareHomeJobDetail(job.id));
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
    sortJobsForList(
      list,
      sortMode: _sortMode,
      recommendedFilterActive: _activeFilter == 'recommended',
      deadlineSortKey: _deadlineSortKey,
    );
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
          context.push(AppRoutes.spareHomeSpaceDetail(space.id));
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
          context.push(AppRoutes.spareHomeEducationDetail, extra: edu);
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
      case 'opening_soon':
        filtered = filtered.where((j) => j.isOpeningSoon).toList();
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

          if (!_bodyReady) {
            return const Center(child: CircularProgressIndicator());
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
                            label: '전체',
                            options: const [
                              '인기순',
                              '최신순',
                              '가격순',
                              '마감순',
                            ],
                            selectedValue:
                                jobsListSortDropdownLabel(_sortMode),
                            onSelected: (value) {
                              setState(() {
                                _sortMode = jobsListSortModeFromDropdown(value);
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
                            isSelected:
                                _activeFilter == null &&
                                !_isPremium &&
                                _sortMode == JobsListSortMode.all,
                            onTap: () {
                              setState(() {
                                _activeFilter = null;
                                _isPremium = false;
                                _sortMode = JobsListSortMode.all;
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
                            label: '프리미엄',
                            isSelected: _isPremium,
                            onTap: () {
                              setState(() {
                                _isPremium = !_isPremium;
                              });
                            },
                          ),
                          const SizedBox(width: AppTheme.spacing2),
                          StitchFilterChip(
                            label: '최신순',
                            isSelected:
                                _sortMode == JobsListSortMode.latest &&
                                _activeFilter == null,
                            onTap: () {
                              setState(() {
                                _sortMode = JobsListSortMode.latest;
                                _activeFilter = null;
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
                            label: '마감임박',
                            isSelected: _activeFilter == 'deadline',
                            onTap: () {
                              setState(() {
                                _activeFilter = _activeFilter == 'deadline' ? null : 'deadline';
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
