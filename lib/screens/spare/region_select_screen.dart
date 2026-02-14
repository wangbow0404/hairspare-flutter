import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/date_filter_button.dart';
import '../../widgets/space_rental_card.dart';
import '../../widgets/job_filter_dropdown.dart';
import '../../widgets/spare_app_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/space_rental.dart';
import '../../models/region.dart';
import '../../services/space_rental_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import 'space_rental_detail_screen.dart';
import 'home_screen.dart';
import 'messages_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// 공간대여 목록 화면 (공고 목록 스타일)
class RegionSelectScreen extends StatefulWidget {
  const RegionSelectScreen({super.key});

  @override
  State<RegionSelectScreen> createState() => _RegionSelectScreenState();
}

class _RegionSelectScreenState extends State<RegionSelectScreen> {
  int _currentNavIndex = 0;
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
  String? _spaceType; // 'chair', 'room'
  List<String> _selectedFacilities = [];
  
  // 날짜 필터
  DateTime? _selectedDateStart;
  DateTime? _selectedDateEnd;
  
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

    // 검색 필터
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((space) {
        return space.shopName.toLowerCase().contains(query) ||
            space.address.toLowerCase().contains(query);
      }).toList();
    }

    // 급구 필터
    if (_activeFilter == 'urgent') {
      filtered = filtered.where((space) {
        // 오늘 예약 가능한 시간대가 있는 경우 급구로 간주
        final today = DateTime.now();
        return space.availableSlots.any((slot) {
          final slotDate = DateTime(
            slot.startTime.year,
            slot.startTime.month,
            slot.startTime.day,
          );
          return slotDate.isAtSameMomentAs(DateTime(today.year, today.month, today.day)) &&
              slot.isAvailable;
        });
      }).toList();
    }

    // 마감임박 필터
    if (_activeFilter == 'deadline') {
      filtered = filtered.where((space) {
        // 24시간 이내 예약 가능한 시간대가 있는 경우
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return space.availableSlots.any((slot) {
          return slot.startTime.isBefore(tomorrow) && slot.isAvailable;
        });
      }).toList();
    }

    // 날짜 필터
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

    // 공간 유형 필터
    if (_spaceType != null) {
      filtered = filtered.where((space) {
        if (_spaceType == 'chair') {
          return space.facilities.contains('의자');
        } else if (_spaceType == 'room') {
          return space.facilities.contains('개인실');
        }
        return true;
      }).toList();
    }

    // 정렬
    if (_sortBy == 'latest') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'price') {
      filtered.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
    } else if (_sortBy == 'deadline') {
      filtered.sort((a, b) {
        final aNextSlot = a.availableSlots
            .where((s) => s.isAvailable && s.startTime.isAfter(DateTime.now()))
            .fold<DateTime?>(null, (prev, slot) {
          if (prev == null) return slot.startTime;
          return slot.startTime.isBefore(prev) ? slot.startTime : prev;
        });
        final bNextSlot = b.availableSlots
            .where((s) => s.isAvailable && s.startTime.isAfter(DateTime.now()))
            .fold<DateTime?>(null, (prev, slot) {
          if (prev == null) return slot.startTime;
          return slot.startTime.isBefore(prev) ? slot.startTime : prev;
        });
        if (aNextSlot == null && bNextSlot == null) return 0;
        if (aNextSlot == null) return 1;
        if (bNextSlot == null) return -1;
        return aNextSlot.compareTo(bNextSlot);
      });
    }

    return filtered;
  }

  void _handleRefresh() {
    setState(() {
      _selectedProvince = null;
      _selectedDistrict = null;
      _activeFilter = null;
      _sortBy = 'latest';
      _spaceType = null;
      _selectedFacilities = [];
      _selectedDateStart = null;
      _selectedDateEnd = null;
      _searchController.clear();
    });
    _loadSpaces();
  }

  void _handleSpaceTap(SpaceRental space) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpaceRentalDetailScreen(spaceId: space.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareAppBar(),
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
                      // 전체공간 개수 및 새로고침
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '전체공간 총 ${_allSpaces.length}개',
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
                      // 검색
                      TextField(
                        controller: _searchController,
                        onChanged: (_) {
                          setState(() {
                            _filteredSpaces = _getFilteredSpaces(_allSpaces);
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '미용실명 또는 주소 검색',
                          prefixIcon: Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing4,
                            vertical: AppTheme.spacing2,
                          ),
                          isDense: true,
                        ),
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
                                  _loadSpaces();
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
                            // 날짜 선택
                            DateFilterButton(
                              selectedDate: _selectedDateStart,
                              onDateSelected: (date) {
                                setState(() {
                                  _selectedDateStart = date;
                                  _selectedDateEnd = null;
                                });
                                _loadSpaces();
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
                                });
                              },
                              onClear: () {
                                setState(() {
                                  _selectedDateStart = null;
                                  _selectedDateEnd = null;
                                });
                                _loadSpaces();
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
                                });
                              },
                            ),
                            SizedBox(width: AppTheme.spacing2),
                            // 정렬 드롭다운
                            JobFilterDropdown(
                              label: '정렬',
                              options: ['최신순', '가격순', '마감순'],
                              selectedValue: _sortBy == 'latest' ? '최신순'
                                  : _sortBy == 'price' ? '가격순'
                                  : '마감순',
                              onSelected: (value) {
                                setState(() {
                                  if (value == '최신순') {
                                    _sortBy = 'latest';
                                  } else if (value == '가격순') {
                                    _sortBy = 'price';
                                  } else if (value == '마감순') {
                                    _sortBy = 'deadline';
                                  }
                                  _showSortDropdown = false;
                                });
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
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
                              isSelected: _activeFilter == null && _spaceType == null,
                              onTap: () {
                                setState(() {
                                  _activeFilter = null;
                                  _spaceType = null;
                                });
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
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
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
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
                                  _sortBy = 'latest';
                                });
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
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
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
                                });
                              },
                            ),
                            SizedBox(width: AppTheme.spacing2),
                            _FilterChip(
                              label: '가격순',
                              emoji: '💵',
                              isSelected: _sortBy == 'price',
                              onTap: () {
                                setState(() {
                                  _sortBy = _sortBy == 'price' ? 'latest' : 'price';
                                });
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
                                });
                              },
                            ),
                            SizedBox(width: AppTheme.spacing2),
                            _FilterChip(
                              label: '의자',
                              emoji: '🪑',
                              isSelected: _spaceType == 'chair',
                              onTap: () {
                                setState(() {
                                  _spaceType = _spaceType == 'chair' ? null : 'chair';
                                });
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
                                });
                              },
                            ),
                            SizedBox(width: AppTheme.spacing2),
                            _FilterChip(
                              label: '개인실',
                              emoji: '🚪',
                              isSelected: _spaceType == 'room',
                              onTap: () {
                                setState(() {
                                  _spaceType = _spaceType == 'room' ? null : 'room';
                                });
                                setState(() {
                                  _filteredSpaces = _getFilteredSpaces(_allSpaces);
                                });
                              },
                            ),
                            SizedBox(width: AppTheme.spacing2),
                            _FilterChip(
                              label: '샴푸대',
                              emoji: '💧',
                              isSelected: _selectedFacilities.contains('샴푸대'),
                              onTap: () {
                                setState(() {
                                  if (_selectedFacilities.contains('샴푸대')) {
                                    _selectedFacilities.remove('샴푸대');
                                  } else {
                                    _selectedFacilities.add('샴푸대');
                                  }
                                });
                                _loadSpaces();
                              },
                            ),
                            SizedBox(width: AppTheme.spacing2),
                            _FilterChip(
                              label: '드라이어',
                              emoji: '💨',
                              isSelected: _selectedFacilities.contains('드라이어'),
                              onTap: () {
                                setState(() {
                                  if (_selectedFacilities.contains('드라이어')) {
                                    _selectedFacilities.remove('드라이어');
                                  } else {
                                    _selectedFacilities.add('드라이어');
                                  }
                                });
                                _loadSpaces();
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
                                  Icon(
                                    Icons.business_outlined,
                                    size: 64,
                                    color: AppTheme.textTertiary,
                                  ),
                              SizedBox(height: AppTheme.spacing4),
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
                MaterialPageRoute(builder: (context) => const SpareHomeScreen()),
              );
              break;
            case 1:
              // 결제로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PaymentScreen()),
              );
              break;
            case 2:
              // 찜으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
              break;
            case 3:
              // 마이(프로필)로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
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
              Text(emoji!),
              SizedBox(width: AppTheme.spacing1),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected && emoji == null
                    ? Colors.white
                    : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
