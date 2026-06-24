import 'package:flutter/material.dart';

import '../../models/region.dart';
import '../../screens/spare/education_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/deferred_route_body.dart';
import '../../utils/region_helper.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/date_filter_button.dart';
import '../../widgets/education/education_list_pagination_bar.dart';
import '../../widgets/education/education_type_segment.dart';
import '../../widgets/job_filter_dropdown.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_filter_bar.dart';
import '../../widgets/stitch/stitch_filter_chip.dart';
import '../../widgets/stitch/stitch_list_education_card.dart';

/// Shop 교육 목록 — Stitch 필터 + 카드 + 페이지네이션.
class ShopEducationScreen extends StatefulWidget {
  const ShopEducationScreen({super.key});

  @override
  State<ShopEducationScreen> createState() => _ShopEducationScreenState();
}

class _ShopEducationScreenState extends State<ShopEducationScreen>
    with DeferredRouteBodyMixin {
  List<Education> _educations = [];
  List<Education> _filteredEducations = [];
  bool _isLoading = true;

  String? _selectedProvince;
  String? _selectedCategory;
  String _sortBy = 'latest';
  String _educationType = 'all';
  bool _isUrgent = false;
  DateTime? _selectedDateStart;

  bool _showProvinceDropdown = false;
  bool _showCategoryDropdown = false;
  bool _showSortDropdown = false;

  final GlobalKey _provinceButtonKey = GlobalKey();
  final GlobalKey _categoryButtonKey = GlobalKey();
  final GlobalKey _sortButtonKey = GlobalKey();

  static const int _pageSize = 10;
  int _currentPage = 1;
  final ScrollController _listScrollController = ScrollController();

  final List<Category> _categories = [
    Category(id: 'cut', name: '컷트', subCategories: ['여성컷트', '남성컷트']),
    Category(id: 'perm', name: '펌', subCategories: ['디지털펌', '볼륨펌', '스트레이트펌']),
    Category(id: 'color', name: '염색', subCategories: ['탈색', '브릿지', '올리브염색']),
    Category(id: 'styling', name: '스타일링', subCategories: ['웨딩스타일링', '일상스타일링']),
  ];

  List<Region> get _provinces => RegionHelper.getAllRegions()
      .where((r) => r.type == RegionType.province)
      .toList();

  int get _totalPages {
    if (_filteredEducations.isEmpty) return 0;
    return (_filteredEducations.length / _pageSize).ceil();
  }

  List<Education> get _paginatedEducations {
    if (_filteredEducations.isEmpty) return const [];
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, _filteredEducations.length);
    return _filteredEducations.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _scheduleDataLoad();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  void _scheduleDataLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final animation = ModalRoute.of(context)?.animation;
      void run() {
        if (!mounted) return;
        _loadEducations();
      }

      if (animation != null && !animation.isCompleted) {
        late AnimationStatusListener listener;
        listener = (status) {
          if (status == AnimationStatus.completed) {
            animation.removeStatusListener(listener);
            Future<void>.delayed(const Duration(milliseconds: 150), run);
          }
        };
        animation.addStatusListener(listener);
      } else {
        Future<void>.delayed(const Duration(milliseconds: 450), run);
      }
    });
  }

  Future<void> _loadEducations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _educations = _generateMockEducations();
      _filteredEducations = _educations;
      _isLoading = false;
    });
    _applyFilters();
  }

  List<Education> _generateMockEducations() {
    final provinces = _provinces;
    final now = DateTime.now();
    return List.generate(20, (index) {
      final province = provinces[index % provinces.length];
      final districts = RegionHelper.getDistrictsByProvince(province.id);
      final district =
          districts.isNotEmpty ? districts[index % districts.length] : null;
      final isOnline = index % 2 == 0;
      final deadline = now.add(Duration(days: index + 5));

      return Education(
        id: 'shop_edu_$index',
        title: '교육 프로그램 ${index + 1}',
        description:
            '교육 프로그램 ${index + 1}에 대한 설명입니다. 전문가 과정과 실습 위주의 커리큘럼으로 구성되어 있습니다. 미용 분야 실무 역량을 키우고 싶은 분들에게 적합한 과정입니다.',
        category: _categories[index % _categories.length].name,
        subCategory: _categories[index % _categories.length].subCategories[0],
        province: province.name,
        district: district?.name,
        regionId: district?.id ?? province.id,
        price: (index + 1) * 10000,
        energyCost: 2 + (index % 4),
        isUrgent: index % 3 == 0,
        isOnline: isOnline,
        deadline: deadline,
        startDate: deadline.add(const Duration(days: 1)),
        endDate: deadline.add(const Duration(days: 2)),
        applicants: index * 2,
        maxApplicants: 20,
        createdAt: now.subtract(Duration(days: index)),
        imageUrl: 'https://picsum.photos/seed/hairspare-shop-edu-$index/800/400',
      );
    });
  }

  void _applyFilters() {
    var filtered = List<Education>.from(_educations);

    if (_selectedProvince != null) {
      final province = _provinces.firstWhere(
        (p) => p.id == _selectedProvince,
        orElse: () => _provinces.first,
      );
      filtered = filtered
          .where(
            (e) =>
                e.regionId == province.id ||
                e.regionId?.startsWith(province.id) == true ||
                e.province == province.name,
          )
          .toList();
    }

    if (_selectedCategory != null) {
      final categoryName =
          _categories.firstWhere((c) => c.id == _selectedCategory).name;
      filtered = filtered.where((e) => e.category == categoryName).toList();
    }

    if (_educationType == 'offline') {
      filtered = filtered.where((e) => !e.isOnline).toList();
    } else if (_educationType == 'online') {
      filtered = filtered.where((e) => e.isOnline).toList();
    }

    if (_isUrgent) {
      filtered = filtered.where((e) => e.isUrgent).toList();
    }

    if (_selectedDateStart != null) {
      final targetDate = DateTime(
        _selectedDateStart!.year,
        _selectedDateStart!.month,
        _selectedDateStart!.day,
      );
      filtered = filtered.where((e) {
        if (e.startDate != null) {
          final start = DateTime(
            e.startDate!.year,
            e.startDate!.month,
            e.startDate!.day,
          );
          final end = e.endDate != null
              ? DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day)
              : start;
          return !targetDate.isBefore(start) && !targetDate.isAfter(end);
        }
        return e.deadline.isAfter(targetDate);
      }).toList();
    }

    switch (_sortBy) {
      case 'price':
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case 'deadline':
        filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
      case 'applicants':
        filtered.sort((a, b) => b.applicants.compareTo(a.applicants));
      case 'latest':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    setState(() {
      _filteredEducations = filtered;
      _currentPage = 1;
    });
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    setState(() => _currentPage = page);
    if (_listScrollController.hasClients) {
      _listScrollController.jumpTo(0);
    }
  }

  void _handleRefresh() {
    setState(() {
      _selectedProvince = null;
      _selectedCategory = null;
      _sortBy = 'latest';
      _educationType = 'all';
      _isUrgent = false;
      _selectedDateStart = null;
      _currentPage = 1;
    });
    _applyFilters();
  }

  Future<void> _openNewEducation() async {
    final result = await ShellNavigation.pushShopEducationNew(context);
    if (result == true) await _loadEducations();
  }

  String? get _sortLabel {
    return switch (_sortBy) {
      'price' => '가격순',
      'deadline' => '마감순',
      'applicants' => '지원자순',
      _ => '최신순',
    };
  }

  @override
  Widget build(BuildContext context) {
    const fabBottomPadding = AppTheme.spacing4;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '교육',
        showBackButton: Navigator.canPop(context),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: fabBottomPadding),
        child: FloatingActionButton(
          onPressed: () => deferAfterTap(_openNewEducation),
          backgroundColor: AppTheme.stitchPrimaryContainer,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      body: deferredBody(
        loading: const Center(child: CircularProgressIndicator()),
        builder: (context) => _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StitchFilterBar(
                    totalCount: _filteredEducations.length,
                    countLabel: '전체교육',
                    countUnit: '개',
                    onRefresh: _handleRefresh,
                    dropdownRow: Row(
                      children: [
                        JobFilterDropdown(
                          label: '지역',
                          options: _provinces.map((p) => p.name).toList(),
                          selectedValue: _selectedProvince != null
                              ? _provinces
                                  .firstWhere(
                                    (p) => p.id == _selectedProvince,
                                    orElse: () => _provinces.first,
                                  )
                                  .name
                              : null,
                          onSelected: (value) {
                            setState(() {
                              _selectedProvince = value != null
                                  ? _provinces
                                      .firstWhere((p) => p.name == value)
                                      .id
                                  : null;
                              _showProvinceDropdown = false;
                            });
                            _applyFilters();
                          },
                          buttonKey: _provinceButtonKey,
                          isOpen: _showProvinceDropdown,
                          onToggle: () {
                            setState(() {
                              _showProvinceDropdown = !_showProvinceDropdown;
                              _showCategoryDropdown = false;
                              _showSortDropdown = false;
                            });
                          },
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        JobFilterDropdown(
                          label: '카테고리',
                          options: _categories.map((c) => c.name).toList(),
                          selectedValue: _selectedCategory != null
                              ? _categories
                                  .firstWhere((c) => c.id == _selectedCategory)
                                  .name
                              : null,
                          onSelected: (value) {
                            setState(() {
                              _selectedCategory = value != null
                                  ? _categories
                                      .firstWhere((c) => c.name == value)
                                      .id
                                  : null;
                              _showCategoryDropdown = false;
                            });
                            _applyFilters();
                          },
                          buttonKey: _categoryButtonKey,
                          isOpen: _showCategoryDropdown,
                          onToggle: () {
                            setState(() {
                              _showCategoryDropdown = !_showCategoryDropdown;
                              _showProvinceDropdown = false;
                              _showSortDropdown = false;
                            });
                          },
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        DateFilterButton(
                          selectedDate: _selectedDateStart,
                          onDateSelected: (date) {
                            setState(() => _selectedDateStart = date);
                            _applyFilters();
                          },
                          onClear: () {
                            setState(() => _selectedDateStart = null);
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                    chipRow: Row(
                      children: [
                        JobFilterDropdown(
                          label: '정렬',
                          options: const [
                            '최신순',
                            '가격순',
                            '마감순',
                            '지원자순',
                          ],
                          selectedValue: _sortLabel,
                          onSelected: (value) {
                            setState(() {
                              _sortBy = switch (value) {
                                '가격순' => 'price',
                                '마감순' => 'deadline',
                                '지원자순' => 'applicants',
                                _ => 'latest',
                              };
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
                              _showCategoryDropdown = false;
                            });
                          },
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        EducationTypeSegment(
                          value: _educationType,
                          onChanged: (type) {
                            setState(() => _educationType = type);
                            _applyFilters();
                          },
                        ),
                        const SizedBox(width: AppTheme.spacing2),
                        StitchFilterChip(
                          label: '급구',
                          emoji: '🚀',
                          isSelected: _isUrgent,
                          urgent: true,
                          onTap: () {
                            setState(() => _isUrgent = !_isUrgent);
                            _applyFilters();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredEducations.isEmpty
                        ? const StitchEmptyState(
                            message: '조건에 맞는 교육이 없습니다',
                            icon: Icons.school_outlined,
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  controller: _listScrollController,
                                  padding: EdgeInsets.fromLTRB(
                                    AppTheme.spacing4,
                                    AppTheme.spacing4,
                                    AppTheme.spacing4,
                                    AppTheme.spacing2,
                                  ),
                                  itemCount: _paginatedEducations.length,
                                  itemBuilder: (context, index) {
                                    final education =
                                        _paginatedEducations[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppTheme.spacing4,
                                      ),
                                      child: StitchListEducationCard(
                                        education: education,
                                        onTap: () {
                                          deferAfterTap(
                                            () => ShellNavigation
                                                .pushEducationDetail(
                                              context,
                                              education,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              EducationListPaginationBar(
                                totalCount: _filteredEducations.length,
                                currentPage: _currentPage,
                                pageSize: _pageSize,
                                onPageChanged: _goToPage,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
