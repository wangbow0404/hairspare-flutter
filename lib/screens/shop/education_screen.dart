import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/education_filter_dropdown.dart';
import '../../utils/region_helper.dart';
import '../../models/region.dart';
import 'education_new_screen.dart';

/// Shop용 교육 화면 (스페어 화면과 동일한 구조)
class ShopEducationScreen extends StatefulWidget {
  const ShopEducationScreen({super.key});

  @override
  State<ShopEducationScreen> createState() => _ShopEducationScreenState();
}

class _ShopEducationScreenState extends State<ShopEducationScreen> {
  List<_Education> _educations = [];
  List<_Education> _filteredEducations = [];
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
  final List<_Category> _categories = [
    _Category(id: 'cut', name: '컷트', subCategories: ['여성컷트', '남성컷트']),
    _Category(id: 'perm', name: '펌', subCategories: ['디지털펌', '볼륨펌', '스트레이트펌']),
    _Category(id: 'color', name: '염색', subCategories: ['탈색', '브릿지', '올리브염색']),
    _Category(id: 'styling', name: '스타일링', subCategories: ['웨딩스타일링', '일상스타일링']),
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
  void initState() {
    super.initState();
    _loadEducations();
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

  List<_Education> _generateMockEducations() {
    final provinces = _provinces;
    return List.generate(20, (index) {
      final province = provinces[index % provinces.length];
      final districts = RegionHelper.getDistrictsByProvince(province.id);
      final district = districts.isNotEmpty ? districts[index % districts.length] : null;
      
      return _Education(
        id: 'edu_$index',
        title: '교육 프로그램 ${index + 1}',
        description: '교육 프로그램 ${index + 1}에 대한 설명입니다.',
        category: _categories[index % _categories.length].name,
        subCategory: _categories[index % _categories.length].subCategories[0],
        province: province.name,
        district: district?.name,
        regionId: district?.id ?? province.id,
        price: (index + 1) * 10000,
        isUrgent: index % 3 == 0,
        isOnline: index % 2 == 0,
        deadline: DateTime.now().add(Duration(days: index + 1)),
        applicants: index * 2,
        maxApplicants: 20,
        createdAt: DateTime.now().subtract(Duration(days: index)),
      );
    });
  }

  void _applyFilters() {
    var filtered = List<_Education>.from(_educations);

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
    });
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
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(
        title: '교육',
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(AppTheme.spacing2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Icon(Icons.add, size: 20, color: Colors.white),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopEducationNewScreen()),
              );
              if (result == true) {
                _loadEducations();
              }
            },
          ),
          const SizedBox(width: AppTheme.spacing2),
        ],
      ),
      body: Column(
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
                : ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacing4),
                    itemCount: _filteredEducations.length,
                    itemBuilder: (context, index) {
                      final education = _filteredEducations[index];
                      return _buildEducationCard(education);
                    },
                  ),
          ),
        ],
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

  Widget _buildEducationCard(_Education education) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
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
                '${education.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
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
                '마감: ${education.deadline.toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 데이터 모델
class _Category {
  final String id;
  final String name;
  final List<String> subCategories;

  _Category({
    required this.id,
    required this.name,
    required this.subCategories,
  });
}

class _Education {
  final String id;
  final String title;
  final String description;
  final String category;
  final String subCategory;
  final String province;
  final String? district;
  final String? regionId;
  final int price;
  final bool isUrgent;
  final bool isOnline;
  final DateTime deadline;
  final int applicants;
  final int maxApplicants;
  final DateTime createdAt;

  _Education({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.province,
    this.district,
    this.regionId,
    required this.price,
    required this.isUrgent,
    required this.isOnline,
    required this.deadline,
    required this.applicants,
    required this.maxApplicants,
    required this.createdAt,
  });
}
