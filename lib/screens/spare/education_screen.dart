import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../widgets/common/spare_subpage_app_bar_actions.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/education_filter_dropdown.dart';
import '../../widgets/date_filter_button.dart';
import '../../utils/region_helper.dart';
import '../../models/education_material.dart';
import '../../utils/deferred_route_body.dart';
import '../../utils/shell_navigation.dart';
import '../../models/region.dart';

/// Next.js와 동일한 교육 화면 (복잡한 필터링 시스템)
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with DeferredRouteBodyMixin {
  List<Education> _educations = [];
  List<Education> _filteredEducations = [];
  bool _isLoading = true;

  // 필터 상태
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedCategory;
  String? _selectedSubCategory;
  String _sortBy = 'latest';
  String _educationType = 'all';
  
  // 필터 버튼 상태
  bool _isUrgent = false;
  bool _reviewReward = false;
  bool _myNeighborhood = false;
  bool _insufficientApplicants = false;
  bool _deadlineImminent = false;
  bool _noReservation = false;

  // 드롭다운 상태
  bool _showProvinceDropdown = false;
  bool _showDistrictDropdown = false;
  bool _showCategoryDropdown = false;
  bool _showSubCategoryDropdown = false;
  bool _showSortDropdown = false;

  DateTime? _selectedDateStart;

  static const int _pageSize = 10;
  int _currentPage = 1;
  final ScrollController _listScrollController = ScrollController();

  // 드롭다운 버튼 키
  final GlobalKey _provinceButtonKey = GlobalKey();
  final GlobalKey _districtButtonKey = GlobalKey();
  final GlobalKey _categoryButtonKey = GlobalKey();
  final GlobalKey _subCategoryButtonKey = GlobalKey();
  final GlobalKey _sortButtonKey = GlobalKey();

  // 지역 데이터 (RegionHelper 사용)
  List<Region> get _provinces {
    return RegionHelper.getAllRegions()
        .where((r) => r.type == RegionType.province)
        .toList();
  }

  List<Region> get _districts {
    if (_selectedProvince == null) return [];
    return RegionHelper.getDistrictsByProvince(_selectedProvince!);
  }

  // 카테고리 데이터
  final List<Category> _categories = [
    Category(id: 'cut', name: '컷트', subCategories: ['여성컷트', '남성컷트']),
    Category(id: 'perm', name: '펌', subCategories: ['디지털펌', '볼륨펌', '스트레이트펌']),
    Category(id: 'color', name: '염색', subCategories: ['탈색', '브릿지', '올리브염색']),
    Category(id: 'styling', name: '스타일링', subCategories: ['웨딩스타일링', '일상스타일링']),
  ];

  List<String> get _availableSubCategories {
    if (_selectedCategory == null) return [];
    final category = _categories.firstWhere(
      (c) => c.id == _selectedCategory,
      orElse: () => _categories[0],
    );
    return category.subCategories;
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scheduleDataLoad();
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
    // Mock 데이터 생성 (백엔드 API 없음)
    await Future.delayed(const Duration(milliseconds: 500));
    
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
      final district = districts.isNotEmpty ? districts[index % districts.length] : null;
      final hasRichContent = index < 3;
      final isOnline = index % 2 == 0;
      final deadline = now.add(Duration(days: index + 5));
      final startDate = deadline.add(const Duration(days: 1));
      final endDate = startDate.add(const Duration(days: 1));
      final curriculumSchedule = hasRichContent
          ? [
              CurriculumDay(
                day: 1,
                date: startDate,
                content: '이론 (2시간)\n• 기초 이론 및 트렌드 분석\n• 실무 사례 연구',
              ),
              CurriculumDay(
                day: 2,
                date: endDate,
                content: '실습 (3시간)\n• 직접 실습 및 피드백\n• Q&A 및 수료',
              ),
            ]
          : null;
      final reviews = hasRichContent
          ? [
              EducationReview(
                userName: '김스타',
                rating: 5,
                comment: '실무에 바로 적용할 수 있는 내용이 많았어요. 강사님이 친절하시고 실습 비중이 좋았습니다.',
                createdAt: now.subtract(const Duration(days: 3)),
              ),
              EducationReview(
                userName: '이디자인',
                rating: 4,
                comment: '커리큘럼이 체계적이고 유익했습니다. 다음 교육도 신청할 예정이에요.',
                createdAt: now.subtract(const Duration(days: 7)),
              ),
              EducationReview(
                userName: '박헤어',
                rating: 5,
                comment: '강사님 설명이 정말 잘 되었어요. 실습 시간이 충분해서 좋았습니다.',
                createdAt: now.subtract(const Duration(days: 10)),
              ),
              EducationReview(
                userName: '최스타일',
                rating: 4,
                comment: '가격 대비 만족도 높아요. 추천합니다!',
                createdAt: now.subtract(const Duration(days: 14)),
              ),
            ]
          : null;
      return Education(
        id: 'edu_$index',
        title: '교육 프로그램 ${index + 1}',
        description: '교육 프로그램 ${index + 1}에 대한 설명입니다. 전문가 과정과 실습 위주의 커리큘럼으로 구성되어 있습니다. 미용 분야 실무 역량을 키우고 싶은 분들에게 적합한 과정입니다.',
        category: _categories[index % _categories.length].name,
        subCategory: _categories[index % _categories.length].subCategories[0],
        province: province.name,
        district: district?.name,
        regionId: district?.id ?? province.id,
        price: (index + 1) * 10000,
        energyCost: 2 + (index % 4),
        isUrgent: index % 3 == 0,
        isOnline: isOnline,
        isLive: hasRichContent && isOnline && index == 0, // 첫 번째 온라인만 LIVE
        deadline: deadline,
        startDate: hasRichContent ? startDate : null,
        endDate: hasRichContent ? endDate : null,
        applicants: index * 2,
        maxApplicants: 20,
        createdAt: now.subtract(Duration(days: index)),
        imageUrl: 'https://picsum.photos/seed/hairspare-edu-$index/800/400',
        materials: hasRichContent
            ? [
                const EducationMaterial(
                  title: '사전 학습 PDF',
                  url: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
                ),
                const EducationMaterial(
                  title: '실습 체크리스트',
                  url: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
                  fileType: 'pdf',
                ),
              ]
            : null,
        venueAddress: !isOnline && hasRichContent
            ? '${province.name} ${district?.name ?? ''} 테헤란로 123 교육센터 3층'
            : null,
        venueLat: !isOnline && hasRichContent ? 37.5012 : null,
        venueLng: !isOnline && hasRichContent ? 127.0396 : null,
        meetingUrl: isOnline && hasRichContent
            ? 'https://example.com/education/live/$index'
            : null,
        curriculum: null,
        curriculumSchedule: curriculumSchedule,
        duration: hasRichContent ? '2일 과정 (총 5시간)' : null,
        instructorName: hasRichContent ? '김미용 강사' : null,
        instructorBio: hasRichContent ? '15년 경력, 한국미용예술인협회 인증' : null,
        benefits: hasRichContent
            ? ['실무 중심 커리큘럼', '소수 정원 맞춤 교육', '수료증 발급', '재수강 50% 할인']
            : null,
        targetAudience: hasRichContent ? '1~3년차 디자이너, 이직 준비 중인 스타일리스트' : null,
        averageRating: reviews != null ? 4.5 : null,
        reviewCount: reviews?.length ?? 0,
        reviews: reviews,
      );
    });
  }

  void _applyFilters() {
    var filtered = List<Education>.from(_educations);

    // 지역 필터 (RegionHelper 사용)
    if (_selectedDistrict != null) {
      final district = _districts.firstWhere((d) => d.id == _selectedDistrict, orElse: () => _districts.first);
      filtered = filtered.where((e) => e.regionId == district.id || e.district == district.name).toList();
    } else if (_selectedProvince != null) {
      final province = _provinces.firstWhere((p) => p.id == _selectedProvince, orElse: () => _provinces.first);
      filtered = filtered.where((e) => e.regionId == province.id || 
          e.regionId?.startsWith(province.id) == true ||
          e.province == province.name).toList();
    }

    // 카테고리 필터
    if (_selectedSubCategory != null) {
      filtered = filtered.where((e) => e.subCategory == _selectedSubCategory).toList();
    } else if (_selectedCategory != null) {
      final categoryName = _categories.firstWhere((c) => c.id == _selectedCategory).name;
      filtered = filtered.where((e) => e.category == categoryName).toList();
    }

    // 교육 유형 필터
    if (_educationType == 'offline') {
      filtered = filtered.where((e) => !e.isOnline).toList();
    } else if (_educationType == 'online') {
      filtered = filtered.where((e) => e.isOnline).toList();
    }

    // 추가 필터
    if (_isUrgent) {
      filtered = filtered.where((e) => e.isUrgent).toList();
    }
    if (_reviewReward) {
      // Mock: 무료교육 필터 (가격이 0인 것)
      filtered = filtered.where((e) => e.price == 0).toList();
    }
    if (_insufficientApplicants) {
      filtered = filtered.where((e) => e.applicants < e.maxApplicants * 0.5).toList();
    }
    if (_deadlineImminent) {
      final now = DateTime.now();
      filtered = filtered.where((e) => e.deadline.difference(now).inDays <= 3).toList();
    }

    // 날짜 필터: 선택한 날짜에 진행되는 교육 (startDate~endDate) 또는 진행일 없으면 마감일 기준
    if (_selectedDateStart != null) {
      final targetDate = DateTime(_selectedDateStart!.year, _selectedDateStart!.month, _selectedDateStart!.day);
      final targetEnd = DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);
      filtered = filtered.where((e) {
        if (e.startDate != null) {
          final start = DateTime(e.startDate!.year, e.startDate!.month, e.startDate!.day);
          final end = e.endDate != null
              ? DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day)
              : start;
          return !targetDate.isBefore(start) && !targetDate.isAfter(end);
        }
        return e.deadline.isAfter(targetEnd);
      }).toList();
    }

    // 정렬
    switch (_sortBy) {
      case 'price':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'deadline':
        filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case 'applicants':
        filtered.sort((a, b) => b.applicants.compareTo(a.applicants));
        break;
      case 'latest':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    setState(() {
      _filteredEducations = filtered;
      _currentPage = 1;
    });
  }

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
      _selectedDistrict = null;
      _selectedCategory = null;
      _selectedSubCategory = null;
      _sortBy = 'latest';
      _educationType = 'all';
      _isUrgent = false;
      _reviewReward = false;
      _myNeighborhood = false;
      _insufficientApplicants = false;
      _deadlineImminent = false;
      _noReservation = false;
      _selectedDateStart = null;
      _currentPage = 1;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: SharedAppBar(
          title: '교육',
          actions: buildSpareSubpageAppBarActions(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(
        title: '교육',
        actions: buildSpareSubpageAppBarActions(context),
      ),
      body: deferredBody(
        loading: const Center(child: CircularProgressIndicator()),
        builder: (context) => Column(
        children: [
          // 필터 섹션
          Container(
            color: AppTheme.backgroundWhite,
            padding: const EdgeInsets.all(AppTheme.spacing3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 전체교육 개수
                Text(
                  '전체교육 총 ${_filteredEducations.length}개',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),

                // 첫 번째 줄: 새로고침, 지역, 상세지역, 카테고리, 세부카테고리
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // 새로고침 버튼
                      IconButton(
                        icon: IconMapper.icon('refresh', size: 20, color: AppTheme.textSecondary) ??
                            const Icon(Icons.refresh, size: 20, color: AppTheme.textSecondary),
                        onPressed: _handleRefresh,
                      ),
                      const SizedBox(width: AppTheme.spacing2),

                      // 지역 드롭다운
                      _buildProvinceDropdown(),
                      if (_selectedProvince != null && _districts.isNotEmpty) ...[
                        const SizedBox(width: AppTheme.spacing2),
                        _buildDistrictDropdown(),
                      ],
                      const SizedBox(width: AppTheme.spacing2),
                      _buildCategoryDropdown(),
                      if (_selectedCategory != null && _availableSubCategories.isNotEmpty) ...[
                        const SizedBox(width: AppTheme.spacing2),
                        _buildSubCategoryDropdown(),
                      ],
                      const SizedBox(width: AppTheme.spacing2),
                      DateFilterButton(
                        selectedDate: _selectedDateStart,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDateStart = date;
                            _applyFilters();
                          });
                        },
                        onClear: () {
                          setState(() {
                            _selectedDateStart = null;
                            _applyFilters();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3),

                // 두 번째 줄: 정렬, 오프라인/온라인, 필터 버튼들
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortDropdown(),
                      const SizedBox(width: AppTheme.spacing2),
                      _buildEducationTypeToggle(),
                      const SizedBox(width: AppTheme.spacing2),
                      _buildFilterButton('🚀', '급구', _isUrgent, () {
                        setState(() => _isUrgent = !_isUrgent);
                        _applyFilters();
                      }),
                      const SizedBox(width: AppTheme.spacing2),
                      _buildFilterButton('⭐', '무료교육', _reviewReward, () {
                        setState(() => _reviewReward = !_reviewReward);
                        _applyFilters();
                      }),
                      const SizedBox(width: AppTheme.spacing2),
                      _buildFilterButton('🏠', '우리동네', _myNeighborhood, () {
                        setState(() => _myNeighborhood = !_myNeighborhood);
                        _applyFilters();
                      }),
                      const SizedBox(width: AppTheme.spacing2),
                      _buildFilterButton('👥', '신청자부족', _insufficientApplicants, () {
                        setState(() => _insufficientApplicants = !_insufficientApplicants);
                        _applyFilters();
                      }),
                      const SizedBox(width: AppTheme.spacing2),
                      _buildFilterButton('⏰', '마감임박', _deadlineImminent, () {
                        setState(() => _deadlineImminent = !_deadlineImminent);
                        _applyFilters();
                      }),
                      const SizedBox(width: AppTheme.spacing2),
                      _buildFilterButton('📅', '예약불필요', _noReservation, () {
                        setState(() => _noReservation = !_noReservation);
                        _applyFilters();
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 교육 목록
          Expanded(
            child: _filteredEducations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconMapper.icon('book', size: 64, color: AppTheme.textTertiary) ??
                            const Icon(Icons.book, size: 64, color: AppTheme.textTertiary),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          '교육 목록이 없습니다',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _listScrollController,
                          padding: const EdgeInsets.all(AppTheme.spacing4),
                          itemCount: _paginatedEducations.length,
                          itemBuilder: (context, index) {
                            final education = _paginatedEducations[index];
                            return _buildEducationCard(education);
                          },
                        ),
                      ),
                      if (_totalPages > 1) _buildPaginationBar(),
                    ],
                  ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    return EducationFilterDropdown(
      label: '지역',
      options: _provinces.map((p) => p.name).toList(),
      selectedValue: _selectedProvince != null
          ? _provinces.firstWhere((p) => p.id == _selectedProvince, orElse: () => _provinces.first).name
          : null,
      onSelected: (value) {
        setState(() {
          _selectedProvince = value != null
              ? _provinces.firstWhere((p) => p.name == value, orElse: () => _provinces.first).id
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
          _showCategoryDropdown = false;
          _showSubCategoryDropdown = false;
          _showSortDropdown = false;
        });
      },
    );
  }

  Widget _buildDistrictDropdown() {
    return EducationFilterDropdown(
      label: '상세지역',
      options: _districts.map((d) => d.name).toList(),
      selectedValue: _selectedDistrict != null
          ? _districts.firstWhere((d) => d.id == _selectedDistrict, orElse: () => _districts.first).name
          : null,
      onSelected: (value) {
        setState(() {
          _selectedDistrict = value != null
              ? _districts.firstWhere((d) => d.name == value, orElse: () => _districts.first).id
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
          _showCategoryDropdown = false;
          _showSubCategoryDropdown = false;
          _showSortDropdown = false;
        });
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return EducationFilterDropdown(
      label: '카테고리',
      options: _categories.map((c) => c.name).toList(),
      selectedValue: _selectedCategory != null
          ? _categories.firstWhere((c) => c.id == _selectedCategory).name
          : null,
      onSelected: (value) {
        setState(() {
          _selectedCategory = value != null
              ? _categories.firstWhere((c) => c.name == value).id
              : null;
          _selectedSubCategory = null;
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
          _showDistrictDropdown = false;
          _showSubCategoryDropdown = false;
          _showSortDropdown = false;
        });
      },
    );
  }

  Widget _buildSubCategoryDropdown() {
    return EducationFilterDropdown(
      label: '세부카테고리',
      options: _availableSubCategories,
      selectedValue: _selectedSubCategory,
      onSelected: (value) {
        setState(() {
          _selectedSubCategory = value;
          _showSubCategoryDropdown = false;
        });
        _applyFilters();
      },
      buttonKey: _subCategoryButtonKey,
      isOpen: _showSubCategoryDropdown,
      onToggle: () {
        setState(() {
          _showSubCategoryDropdown = !_showSubCategoryDropdown;
          _showProvinceDropdown = false;
          _showDistrictDropdown = false;
          _showCategoryDropdown = false;
          _showSortDropdown = false;
        });
      },
    );
  }

  Widget _buildSortDropdown() {
    final sortLabels = {
      'latest': '최신순',
      'price': '가격순',
      'deadline': '마감순',
      'applicants': '지원자순',
    };

    return EducationFilterDropdown(
      label: '정렬',
      options: sortLabels.values.toList(),
      selectedValue: sortLabels[_sortBy],
      onSelected: (value) {
        setState(() {
          _sortBy = sortLabels.entries.firstWhere((e) => e.value == value).key;
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
          _showCategoryDropdown = false;
          _showSubCategoryDropdown = false;
        });
      },
    );
  }

  Widget _buildEducationTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTypeButton('전체', _educationType == 'all'),
          _buildTypeButton('오프라인', _educationType == 'offline'),
          _buildTypeButton('온라인', _educationType == 'online'),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == '전체') {
            _educationType = 'all';
          } else if (label == '오프라인') {
            _educationType = 'offline';
          } else {
            _educationType = 'online';
          }
        });
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.backgroundWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String emoji, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing2),
        decoration: BoxDecoration(
          color: isActive ? Colors.purple.shade100 : AppTheme.backgroundGray,
          border: Border.all(
            color: isActive ? Colors.purple.shade300 : AppTheme.borderGray,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppTheme.spacing1),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.purple.shade700 : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationBar() {
    final start = (_currentPage - 1) * _pageSize + 1;
    final end = (_currentPage * _pageSize).clamp(0, _filteredEducations.length);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing4,
        vertical: AppTheme.spacing3,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: Border(top: BorderSide(color: AppTheme.borderGray)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '총 ${_filteredEducations.length}개 중 $start-$end 표시',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                ...List.generate(_totalPages, (index) {
                  final page = index + 1;
                  final isActive = page == _currentPage;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: isActive
                          ? AppTheme.stitchPrimaryContainer
                          : AppTheme.backgroundGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      child: InkWell(
                        onTap: () => _goToPage(page),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$page',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: _currentPage < _totalPages
                      ? () => _goToPage(_currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(Education education) {
    return GestureDetector(
      onTap: () {
        deferAfterTap(
          () => ShellNavigation.pushEducationDetail(context, education),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역 (imageUrl 있으면 표시, 없으면 그라데이션)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
              child: education.imageUrl != null && education.imageUrl!.isNotEmpty
                  ? _buildEducationImage(education.imageUrl!)
                  : _buildEducationImagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
              if (education.isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing2, vertical: AppTheme.spacing1),
                  decoration: BoxDecoration(
                    color: AppTheme.urgentRed,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🚀', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Text(
                        '급구',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: AppTheme.spacing2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing2, vertical: AppTheme.spacing1),
                decoration: BoxDecoration(
                  color: education.isOnline ? Colors.blue.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  education.isOnline ? '온라인' : '오프라인',
                  style: TextStyle(
                    color: education.isOnline ? Colors.blue.shade700 : Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing3),
                  Text(
                    education.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Text(
                    education.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${education.province}${education.district != null ? ' ${education.district}' : ''}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: AppTheme.spacing3),
                      const Icon(Icons.attach_money, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '에너지 ${education.energyCost}개',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '신청 ${education.applicants}/${education.maxApplicants}명',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        '마감: ${DateFormat('yyyy-MM-dd').format(education.deadline)}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationImage(String url) {
    final isAsset = url.startsWith('assets/');
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: isAsset
          ? Image.asset(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildEducationImagePlaceholder(),
            )
          : Image.network(
              url,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _buildEducationImagePlaceholder(showSpinner: true);
              },
              errorBuilder: (_, __, ___) => _buildEducationImagePlaceholder(),
            ),
    );
  }

  Widget _buildEducationImagePlaceholder({bool showSpinner = false}) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.stitchPrimaryContainer.withValues(alpha: 0.35),
            AppTheme.primaryBlue.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Center(
        child: showSpinner
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.school_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.85),
              ),
      ),
    );
  }
}

// 데이터 모델
class Province {
  final String id;
  final String name;

  Province({required this.id, required this.name});
}

class District {
  final String id;
  final String name;

  District({required this.id, required this.name});
}

class Category {
  final String id;
  final String name;
  final List<String> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.subCategories,
  });
}

/// 커리큘럼 일차 (날짜 포함)
class CurriculumDay {
  final int day;
  final DateTime date;
  final String content;

  CurriculumDay({required this.day, required this.date, required this.content});
}

/// 교육 리뷰
class EducationReview {
  final String userName;
  final int rating; // 1~5
  final String comment;
  final DateTime createdAt;

  EducationReview({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

class Education {
  final String id;
  final String title;
  final String description;
  final String category;
  final String subCategory;
  final String province;
  final String? district;
  final String? regionId;
  final int price;
  /// 스페어 신청·결제 단위 (개). [`docs/yoram/EDUCATION_ENERGY_PRICING.md`]
  final int energyCost;
  final bool isUrgent;
  final bool isOnline;
  final bool isLive; // true: 실시간 라이브, false: 녹화/VOD
  final DateTime deadline;
  final DateTime? startDate; // 교육 진행 시작일
  final DateTime? endDate; // 교육 진행 종료일
  final int applicants;
  final int maxApplicants;
  final DateTime createdAt;
  final String? imageUrl;
  final String? curriculum;
  final List<CurriculumDay>? curriculumSchedule; // 일차별 날짜+내용
  final String? duration;
  final String? instructorName;
  final String? instructorBio;
  final List<String>? benefits;
  final String? targetAudience;
  final double? averageRating;
  final int? reviewCount;
  final List<EducationReview>? reviews;
  final List<EducationMaterial>? materials;
  final String? venueAddress;
  final double? venueLat;
  final double? venueLng;
  final String? meetingUrl;

  Education({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.province,
    this.district,
    this.regionId,
    required this.price,
    required this.energyCost,
    required this.isUrgent,
    required this.isOnline,
    this.isLive = false,
    required this.deadline,
    this.startDate,
    this.endDate,
    required this.applicants,
    required this.maxApplicants,
    required this.createdAt,
    this.imageUrl,
    this.curriculum,
    this.curriculumSchedule,
    this.duration,
    this.instructorName,
    this.instructorBio,
    this.benefits,
    this.targetAudience,
    this.averageRating,
    this.reviewCount,
    this.reviews,
    this.materials,
    this.venueAddress,
    this.venueLat,
    this.venueLng,
    this.meetingUrl,
  });
}
