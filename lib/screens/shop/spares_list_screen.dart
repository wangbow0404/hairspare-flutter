import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/region.dart';
import '../../models/spare_profile.dart';
import '../../providers/chat_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/spare_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/job_filter_dropdown.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_filter_bar.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/stitch/stitch_list_spare_card.dart';

/// 인력 목록 빠른 필터 — 회원가입에 스텝/디자이너 구분 없음.
enum _SpareQuickFilter { all, popular, newest }

/// 샵 「인력별」목록 — 스페어 공고별 화면과 동일 Stitch 레이아웃.
class ShopSparesListScreen extends StatefulWidget {
  const ShopSparesListScreen({super.key});

  @override
  State<ShopSparesListScreen> createState() => _ShopSparesListScreenState();
}

class _ShopSparesListScreenState extends State<ShopSparesListScreen> {
  final SpareService _spareService = SpareService();

  List<SpareProfile> _allSpares = [];
  List<SpareProfile> _filteredSpares = [];
  bool _isLoading = true;
  String? _error;

  String? _selectedProvince;
  String? _selectedDistrict;
  _SpareQuickFilter _quickFilter = _SpareQuickFilter.all;
  String _sortBy = 'popular';
  bool _sortShowAllLabel = true;

  bool _showProvinceDropdown = false;
  bool _showDistrictDropdown = false;
  bool _showSortDropdown = false;

  final GlobalKey _provinceButtonKey = GlobalKey();
  final GlobalKey _districtButtonKey = GlobalKey();
  final GlobalKey _sortButtonKey = GlobalKey();

  List<Region> get _provinces => RegionHelper.getAllRegions()
      .where((r) => r.type == RegionType.province)
      .toList();

  List<Region> get _districts {
    if (_selectedProvince == null) return [];
    return RegionHelper.getDistrictsByProvince(_selectedProvince!);
  }

  List<String> get _selectedRegionIds {
    if (_selectedDistrict != null) return [_selectedDistrict!];
    if (_selectedProvince != null) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationProvider>().loadNotifications(audience: 'shop');
      context.read<ChatProvider>().loadChats(viewerRole: 'shop');
    });
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
        sortBy: _sortBy,
      );

      if (!mounted) return;
      setState(() {
        _allSpares = spares;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(
          ErrorHandler.handleException(e),
        );
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var filtered = List<SpareProfile>.from(_allSpares);

    final regionIds = _selectedRegionIds;
    if (regionIds.isNotEmpty) {
      filtered =
          filtered.where((s) => regionIds.contains(s.regionId)).toList();
    }

    if (_quickFilter == _SpareQuickFilter.popular && filtered.length > 1) {
      final ranked = List<SpareProfile>.from(filtered)
        ..sort(
          (a, b) => _popularityScore(b).compareTo(_popularityScore(a)),
        );
      final topCount = (ranked.length * 0.5).ceil().clamp(1, ranked.length);
      final topIds = ranked.take(topCount).map((s) => s.id).toSet();
      filtered = filtered.where((s) => topIds.contains(s.id)).toList();
    } else if (_quickFilter == _SpareQuickFilter.newest) {
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      filtered = filtered.where((s) => s.createdAt.isAfter(cutoff)).toList();
    }

    switch (_sortBy) {
      case 'popular':
        filtered.sort(
          (a, b) => _popularityScore(b).compareTo(_popularityScore(a)),
        );
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 'experience':
        filtered.sort((a, b) => b.experience.compareTo(a.experience));
      case 'completed':
        filtered.sort((a, b) => b.completedJobs.compareTo(a.completedJobs));
    }

    setState(() => _filteredSpares = filtered);
  }

  static int _popularityScore(SpareProfile spare) =>
      spare.thumbsUpCount * spare.completedJobs;

  Set<String> get _topPopularSpareIds {
    final ranked = List<SpareProfile>.from(_filteredSpares)
      ..sort(
        (a, b) => _popularityScore(b).compareTo(_popularityScore(a)),
      );
    return ranked.take(3).map((s) => s.id).toSet();
  }

  void _handleRefresh() {
    setState(() {
      _selectedProvince = null;
      _selectedDistrict = null;
      _quickFilter = _SpareQuickFilter.all;
      _sortBy = 'popular';
      _sortShowAllLabel = true;
      _showProvinceDropdown = false;
      _showDistrictDropdown = false;
      _showSortDropdown = false;
    });
    _loadSpares();
  }

  void _selectQuickFilter(_SpareQuickFilter filter) {
    setState(() {
      if (_quickFilter == filter && filter != _SpareQuickFilter.all) {
        _quickFilter = _SpareQuickFilter.all;
      } else {
        _quickFilter = filter;
      }
      switch (_quickFilter) {
        case _SpareQuickFilter.popular:
          _sortBy = 'popular';
          _sortShowAllLabel = false;
        case _SpareQuickFilter.newest:
          _sortBy = 'newest';
          _sortShowAllLabel = false;
        case _SpareQuickFilter.all:
          break;
      }
    });
    if (_quickFilter == _SpareQuickFilter.all) {
      _loadSpares();
    } else {
      _applyFilters();
    }
  }

  String? get _sortDropdownLabel {
    if (_sortBy == 'popular' && _sortShowAllLabel) return null;
    return switch (_sortBy) {
      'popular' => '인기순',
      'newest' => '최신순',
      'experience' => '경력순',
      'completed' => '완료건수순',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '인력별',
        showBackButton: Navigator.canPop(context),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return StitchEmptyState(
        message: _error!,
        iconName: 'alertcircle',
        actionLabel: '다시 시도',
        onAction: _loadSpares,
      );
    }

    return Column(
      children: [
        StitchFilterBar(
          totalCount: _filteredSpares.length,
          countLabel: '전체 인력',
          countUnit: '명',
          onRefresh: _handleRefresh,
          dropdownRow: Row(
            children: [
              JobFilterDropdown(
                label: '지역',
                options: _provinces.map((p) => p.name).toList(),
                selectedValue: _selectedProvince != null
                    ? _provinces
                        .firstWhere((p) => p.id == _selectedProvince)
                        .name
                    : null,
                onSelected: (value) {
                  setState(() {
                    _selectedProvince = value != null
                        ? _provinces.firstWhere((p) => p.name == value).id
                        : null;
                    _selectedDistrict = null;
                    _showProvinceDropdown = false;
                  });
                  _loadSpares();
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
                      ? _districts
                          .firstWhere((d) => d.id == _selectedDistrict)
                          .name
                      : null,
                  onSelected: (value) {
                    setState(() {
                      _selectedDistrict = value != null
                          ? _districts.firstWhere((d) => d.name == value).id
                          : null;
                      _showDistrictDropdown = false;
                    });
                    _loadSpares();
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
              JobFilterDropdown(
                label: '전체',
                options: const ['인기순', '최신순', '경력순', '완료건수순'],
                selectedValue: _sortDropdownLabel,
                onSelected: (value) {
                  setState(() {
                    if (value == null) {
                      _sortBy = 'popular';
                      _sortShowAllLabel = true;
                    } else if (value == '인기순') {
                      _sortBy = 'popular';
                      _sortShowAllLabel = false;
                    } else if (value == '최신순') {
                      _sortBy = 'newest';
                      _sortShowAllLabel = false;
                    } else if (value == '경력순') {
                      _sortBy = 'experience';
                      _sortShowAllLabel = false;
                    } else if (value == '완료건수순') {
                      _sortBy = 'completed';
                      _sortShowAllLabel = false;
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
          chipRow: Row(
            children: [
              StitchFilterChip(
                label: '전체',
                isSelected: _quickFilter == _SpareQuickFilter.all,
                onTap: () => _selectQuickFilter(_SpareQuickFilter.all),
              ),
              const SizedBox(width: AppTheme.spacing2),
              StitchFilterChip(
                label: '인기',
                emoji: '🔥',
                isSelected: _quickFilter == _SpareQuickFilter.popular,
                onTap: () => _selectQuickFilter(_SpareQuickFilter.popular),
              ),
              const SizedBox(width: AppTheme.spacing2),
              StitchFilterChip(
                label: '신규',
                isSelected: _quickFilter == _SpareQuickFilter.newest,
                onTap: () => _selectQuickFilter(_SpareQuickFilter.newest),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredSpares.isEmpty
              ? const StitchEmptyState(
                  message: '조건에 맞는 인력이 없습니다',
                  iconName: 'users',
                )
              : ListView.builder(
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  itemCount: _filteredSpares.length,
                  itemBuilder: (context, index) {
                    final spare = _filteredSpares[index];
                    return StitchListSpareCard(
                      spare: spare,
                      showPopularBadge:
                          _topPopularSpareIds.contains(spare.id),
                      onTap: () =>
                          ShellNavigation.pushShopSpareDetail(context, spare.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
