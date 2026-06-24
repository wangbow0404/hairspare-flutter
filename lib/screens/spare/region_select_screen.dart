import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/date_filter_button.dart';
import '../../widgets/space_rental_card.dart';
import '../../widgets/job_filter_dropdown.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../widgets/common/spare_subpage_app_bar_actions.dart';
import '../../utils/icon_mapper.dart';
import '../../models/space_rental.dart';
import '../../models/region.dart';
import '../../services/space_rental_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import '../../utils/space_rental_list_sort.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/stitch/stitch_filter_bar.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';

/// 공간대여 목록 화면 (공고 목록 스타일)
class RegionSelectScreen extends StatefulWidget {
  const RegionSelectScreen({super.key});

  @override
  State<RegionSelectScreen> createState() => _RegionSelectScreenState();
}

class _RegionSelectScreenState extends State<RegionSelectScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _activeFilter;
  SpaceRentalListSortMode _sortMode = SpaceRentalListSortMode.all;
  
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
  String? _spaceType; // 'room' = 개인실
  List<String> _selectedFacilities = [];
  
  // 날짜 필터
  DateTime? _selectedDateStart;
  
  // 데이터
  List<SpaceRental> _allSpaces = [];
  List<SpaceRental> _filteredSpaces = [];
  bool _isLoading = true;
  final SpaceRentalService _spaceRentalService = SpaceRentalService();

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
    _loadSpaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpaces() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final spaces = await _spaceRentalService.getSpaceRentals(
        regionId: _selectedProvince,
        date: _selectedDateStart != null
            ? '${_selectedDateStart!.year}-${_selectedDateStart!.month.toString().padLeft(2, '0')}-${_selectedDateStart!.day.toString().padLeft(2, '0')}'
            : null,
        facilities: _selectedFacilities.isNotEmpty ? _selectedFacilities : null,
      );
      setState(() {
        _allSpaces = spaces;
        _filteredSpaces = _getFilteredSpaces(spaces);
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final appException = ErrorHandler.handleException(error);
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(appException);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  List<SpaceRental> _getFilteredSpaces(List<SpaceRental> spaces) {
    List<SpaceRental> filtered = [...spaces];

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((space) {
        return space.shopName.toLowerCase().contains(query) ||
            space.address.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedDistrict != null) {
      filtered =
          filtered.where((space) => space.regionId == _selectedDistrict).toList();
    } else if (_selectedProvince != null) {
      final districtIds = _districts.map((d) => d.id).toList();
      filtered = filtered
          .where((space) => districtIds.contains(space.regionId))
          .toList();
    }

    switch (_activeFilter) {
      case 'urgent':
        filtered = filtered.where(isSpaceUrgent).toList();
      case 'deadline':
        filtered = filtered.where(isSpaceDeadlineImminent).toList();
      default:
        break;
    }

    if (_selectedDateStart != null) {
      final targetDate = DateTime(
        _selectedDateStart!.year,
        _selectedDateStart!.month,
        _selectedDateStart!.day,
      );
      filtered = filtered.where((space) {
        return space.availableSlots.any((slot) {
          final slotDate = DateTime(
            slot.startTime.year,
            slot.startTime.month,
            slot.startTime.day,
          );
          return slotDate.isAtSameMomentAs(targetDate) && slot.isAvailable;
        });
      }).toList();
    }

    if (_spaceType == 'room') {
      filtered = filtered
          .where((space) => space.facilities.contains('개인실'))
          .toList();
    }

    sortSpacesForList(filtered, sortMode: _sortMode);
    return filtered;
  }

  void _applyFilters() {
    setState(() {
      _filteredSpaces = _getFilteredSpaces(_allSpaces);
    });
  }

  void _handleRefresh() {
    setState(() {
      _selectedProvince = null;
      _selectedDistrict = null;
      _activeFilter = null;
      _sortMode = SpaceRentalListSortMode.all;
      _spaceType = null;
      _selectedFacilities = [];
      _selectedDateStart = null;
      _searchController.clear();
    });
    _loadSpaces();
  }

  void _handleSpaceTap(SpaceRental space) {
    ShellNavigation.pushSpaceDetail(context, space.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(
        title: '공간대여',
        actions: buildSpareSubpageAppBarActions(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 필터 섹션
                Container(
                  color: AppTheme.backgroundWhite,
                  padding: AppTheme.spacing(AppTheme.spacing3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => _applyFilters(),
                        decoration: InputDecoration(
                          hintText: '미용실명 또는 주소 검색',
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4,
                            vertical: AppTheme.spacing2,
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing3),
                      StitchFilterBar(
                        countLabel: '전체공간 총',
                        totalCount: _filteredSpaces.length,
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
                                      ? _provinces
                                          .firstWhere((p) => p.name == value)
                                          .id
                                      : null;
                                  _selectedDistrict = null;
                                  _showProvinceDropdown = false;
                                });
                                _loadSpaces();
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
                            if (_selectedProvince != null &&
                                _districts.isNotEmpty) ...[
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
                                        ? _districts
                                            .firstWhere((d) => d.name == value)
                                            .id
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
                            const SizedBox(width: AppTheme.spacing2),
                            DateFilterButton(
                              selectedDate: _selectedDateStart,
                              onDateSelected: (date) {
                                setState(() => _selectedDateStart = date);
                                _loadSpaces();
                              },
                              onClear: () {
                                setState(() => _selectedDateStart = null);
                                _loadSpaces();
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
                                  spaceRentalSortDropdownLabel(_sortMode),
                              onSelected: (value) {
                                setState(() {
                                  _sortMode =
                                      spaceRentalSortModeFromDropdown(value);
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
                              isSelected: _activeFilter == null &&
                                  _spaceType == null &&
                                  _sortMode == SpaceRentalListSortMode.all,
                              onTap: () {
                                setState(() {
                                  _activeFilter = null;
                                  _spaceType = null;
                                  _sortMode = SpaceRentalListSortMode.all;
                                });
                                _applyFilters();
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
                                  _activeFilter =
                                      _activeFilter == 'urgent' ? null : 'urgent';
                                });
                                _applyFilters();
                              },
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            StitchFilterChip(
                              label: '인기순',
                              isSelected: _sortMode ==
                                      SpaceRentalListSortMode.popular &&
                                  _activeFilter == null,
                              onTap: () {
                                setState(() {
                                  _sortMode = SpaceRentalListSortMode.popular;
                                  _activeFilter = null;
                                });
                                _applyFilters();
                              },
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            StitchFilterChip(
                              label: '최신순',
                              isSelected: _sortMode ==
                                      SpaceRentalListSortMode.latest &&
                                  _activeFilter == null,
                              onTap: () {
                                setState(() {
                                  _sortMode = SpaceRentalListSortMode.latest;
                                  _activeFilter = null;
                                });
                                _applyFilters();
                              },
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            StitchFilterChip(
                              label: '마감임박',
                              isSelected: _activeFilter == 'deadline',
                              onTap: () {
                                setState(() {
                                  _activeFilter = _activeFilter == 'deadline'
                                      ? null
                                      : 'deadline';
                                });
                                _applyFilters();
                              },
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            StitchFilterChip(
                              label: '가격순',
                              isSelected: _sortMode ==
                                      SpaceRentalListSortMode.price &&
                                  _activeFilter == null,
                              onTap: () {
                                setState(() {
                                  _sortMode = SpaceRentalListSortMode.price;
                                  _activeFilter = null;
                                });
                                _applyFilters();
                              },
                            ),
                            const SizedBox(width: AppTheme.spacing2),
                            StitchFilterChip(
                              label: '개인실',
                              isSelected: _spaceType == 'room',
                              onTap: () {
                                setState(() {
                                  _spaceType =
                                      _spaceType == 'room' ? null : 'room';
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
                // 공간 목록
                Expanded(
                  child: _filteredSpaces.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconMapper.icon(
                                'briefcase',
                                size: 64,
                                color: AppTheme.textTertiary,
                              ) ??
                                  const Icon(
                                    Icons.business_outlined,
                                    size: 64,
                                    color: AppTheme.textTertiary,
                                  ),
                              const SizedBox(height: AppTheme.spacing4),
                              Text(
                                '공간이 없습니다',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: AppTheme.spacing(AppTheme.spacing4),
                          itemCount: _filteredSpaces.length,
                          itemBuilder: (context, index) {
                            final space = _filteredSpaces[index];
                            return SpaceRentalCard(
                              spaceRental: space,
                              onTap: () => _handleSpaceTap(space),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
