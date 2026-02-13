import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../utils/region_helper.dart';
import '../../utils/icon_mapper.dart';
import '../../models/region.dart';
import 'education_screen.dart';
import 'address_search_screen.dart';

/// Shop/Designer 교육 올리기 화면
class ShopEducationNewScreen extends StatefulWidget {
  const ShopEducationNewScreen({super.key});

  @override
  State<ShopEducationNewScreen> createState() => _ShopEducationNewScreenState();
}

class _ShopEducationNewScreenState extends State<ShopEducationNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxApplicantsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  List<File> _selectedImages = [];
  String? _selectedProvinceId;
  String? _selectedDistrictId;
  String? _selectedCategoryId;
  String? _selectedSubCategory;
  bool _isOnline = false;
  bool _isUrgent = false;
  DateTime? _selectedDeadline;
  String _address = ''; // 주소 검색용
  String? _detailAddress; // 상세 주소
  
  final List<_Category> _categories = [
    _Category(id: 'cut', name: '컷트', subCategories: ['여성컷트', '남성컷트']),
    _Category(id: 'perm', name: '펌', subCategories: ['디지털펌', '볼륨펌', '스트레이트펌']),
    _Category(id: 'color', name: '염색', subCategories: ['탈색', '브릿지', '올리브염색']),
    _Category(id: 'styling', name: '스타일링', subCategories: ['웨딩스타일링', '일상스타일링']),
  ];

  List<String> get _availableSubCategories {
    if (_selectedCategoryId == null) return [];
    final category = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => _categories[0],
    );
    return category.subCategories;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxApplicantsController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final List<File> files = images.map((xFile) => File(xFile.path)).toList();
        final remainingSlots = 5 - _selectedImages.length;
        if (remainingSlots <= 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미지는 최대 5장까지 등록할 수 있습니다')),
            );
          }
          return;
        }

        final filesToAdd = files.take(remainingSlots).toList();
        for (final file in filesToAdd) {
          final fileSize = await file.length();
          if (fileSize > 10 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이미지 크기는 각 10MB 이하여야 합니다')),
              );
            }
            return;
          }
        }

        setState(() {
          _selectedImages.addAll(filesToAdd);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (_selectedImages.length >= 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미지는 최대 5장까지 등록할 수 있습니다')),
            );
          }
          return;
        }

        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미지 크기는 10MB 이하여야 합니다')),
            );
          }
          return;
        }

        setState(() {
          _selectedImages.add(file);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    // 오프라인일 때만 지역 선택 필수
    if (!_isOnline && (_selectedProvinceId == null || _selectedDistrictId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지역을 선택해주세요')),
      );
      return;
    }
    if (_selectedCategoryId == null || _selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요')),
      );
      return;
    }
    if (_selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('마감일을 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('교육이 등록되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('교육 등록 실패: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E8FF),
              Color(0xFFEFF6FF),
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  border: Border(
                    bottom: BorderSide(color: AppTheme.primaryPurpleLight),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        '교육 등록',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFF9333EA), Color(0xFFEC4899)],
                            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppTheme.spacing5),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 이미지 업로드 섹션
                        _buildImageUploadSection(),
                        SizedBox(height: AppTheme.spacing6),
                        // 제목
                        _buildFieldWithDot(
                          label: '교육 제목',
                          isRequired: true,
                          child: TextFormField(
                            controller: _titleController,
                            decoration: _buildInputDecoration('예) 여성컷트 전문 교육'),
                            validator: (value) => value?.isEmpty ?? true ? '제목을 입력해주세요' : null,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing5),
                        // 설명
                        _buildFieldWithDot(
                          label: '교육 설명',
                          isRequired: false,
                          dotColor: AppTheme.primaryBlue,
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: _buildInputDecoration('상세한 교육 내용을 입력해주세요', maxLines: 4),
                            maxLines: 4,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing5),
                        // 교육 유형 및 옵션 (카테고리보다 위로 이동)
                        _buildEducationTypeSection(),
                        SizedBox(height: AppTheme.spacing5),
                        // 카테고리 선택
                        _buildCategorySelector(),
                        SizedBox(height: AppTheme.spacing5),
                        // 지역 선택 (오프라인일 때만 표시)
                        if (!_isOnline) _buildRegionSelector(),
                        if (!_isOnline) SizedBox(height: AppTheme.spacing5),
                        // 가격 및 인원 섹션
                        _buildPriceSection(),
                        SizedBox(height: AppTheme.spacing5),
                        // 마감일
                        _buildDeadlineSelector(),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(AppTheme.spacing5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: AppTheme.primaryPurpleLight)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
              ).copyWith(
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFF7C3AED), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Text(
                          '교육 등록하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E8FF),
            Color(0xFFFDF2F8),
            Color(0xFFEFF6FF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius2xl + 4),
        border: Border.all(color: AppTheme.primaryPurpleLight),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Icon(Icons.add_photo_alternate, size: 16, color: Colors.white),
              ),
              SizedBox(width: AppTheme.spacing2),
              const Text(
                '이미지',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text(
                  '최대 5장',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppTheme.spacing3,
              mainAxisSpacing: AppTheme.spacing3,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length + (_selectedImages.length < 5 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _selectedImages.length) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      child: Image.file(
                        _selectedImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: EdgeInsets.all(AppTheme.spacing1),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.shadowMd,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('갤러리에서 선택'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImages();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('카메라로 촬영'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImageFromCamera();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.cancel),
                              title: const Text('취소'),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      color: Colors.white.withOpacity(0.6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryPurpleLight,
                                AppTheme.primaryPinkLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: AppTheme.primaryPurple),
                        ),
                        SizedBox(height: AppTheme.spacing2),
                        const Text(
                          '추가',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWithDot({
    required String label,
    required Widget child,
    bool isRequired = false,
    Color dotColor = AppTheme.primaryPurple,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppTheme.spacing2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: AppTheme.primaryPurple),
              ),
          ],
        ),
        SizedBox(height: AppTheme.spacing3),
        child,
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Icon(Icons.category, size: 14, color: Colors.white),
            ),
            SizedBox(width: AppTheme.spacing2),
            const Text(
              '카테고리',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: AppTheme.primaryPurple),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing3),
        DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: _buildInputDecoration('카테고리를 선택하세요'),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
              _selectedSubCategory = null;
            });
          },
          validator: (value) => value == null ? '카테고리를 선택해주세요' : null,
        ),
        if (_selectedCategoryId != null && _availableSubCategories.isNotEmpty) ...[
          SizedBox(height: AppTheme.spacing3),
          DropdownButtonFormField<String>(
            value: _selectedSubCategory,
            decoration: _buildInputDecoration('세부 카테고리를 선택하세요'),
            items: _availableSubCategories.map((subCategory) {
              return DropdownMenuItem(
                value: subCategory,
                child: Text(subCategory),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubCategory = value;
              });
            },
            validator: (value) => value == null ? '세부 카테고리를 선택해주세요' : null,
          ),
        ],
      ],
    );
  }

  Widget _buildRegionSelector() {
    final provinces = RegionHelper.getAllRegions().where((r) => r.type == RegionType.province).toList();
    final districts = _selectedProvinceId != null
        ? RegionHelper.getDistrictsByProvince(_selectedProvinceId!)
        : <Region>[];

    return _buildFieldWithIcon(
      icon: Icons.location_on,
      label: '지역',
      isRequired: true,
      gradientColors: const [Color(0xFFEC4899), Color(0xFF9333EA)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 주소 검색 섹션
          if (_address.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4, vertical: AppTheme.spacing3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: AppTheme.primaryPurpleLight, width: 2),
              ),
              child: Text(
                _address,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: AppTheme.spacing3),
          ],
          // 주소 검색 버튼
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<Map<String, String>>(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.all(AppTheme.spacing4),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radius2xl),
                          ),
                          child: AddressSearchScreen(initialAddress: _address),
                        ),
                      ),
                    );
                    if (result != null && result['address'] != null) {
                      setState(() {
                        _address = result['address']!;
                        _detailAddress = result['detailAddress'];
                        // 주소에서 지역 정보 추출하여 자동 선택 시도
                        _trySetRegionFromAddress(_address);
                      });
                    }
                  },
                  icon: const Icon(Icons.search, size: 18),
                  label: Text(_address.isEmpty ? '주소 검색' : '주소 변경'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing3),
          // 시/도 선택
          DropdownButtonFormField<String>(
            value: _selectedProvinceId,
            decoration: _buildInputDecoration('시/도를 선택하세요'),
            items: provinces.map((province) {
              return DropdownMenuItem(
                value: province.id,
                child: Text(province.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProvinceId = value;
                _selectedDistrictId = null;
              });
            },
            validator: !_isOnline ? (value) => value == null ? '시/도를 선택해주세요' : null : null,
          ),
          if (_selectedProvinceId != null) ...[
            SizedBox(height: AppTheme.spacing3),
            DropdownButtonFormField<String>(
              value: _selectedDistrictId,
              decoration: _buildInputDecoration('시/군/구를 선택하세요'),
              items: districts.map((district) {
                return DropdownMenuItem(
                  value: district.id,
                  child: Text(district.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrictId = value;
                });
              },
              validator: !_isOnline ? (value) => value == null ? '시/군/구를 선택해주세요' : null : null,
            ),
          ],
          // 상세 주소 입력
          if (_address.isNotEmpty) ...[
            SizedBox(height: AppTheme.spacing3),
            TextFormField(
              initialValue: _detailAddress,
              onChanged: (value) {
                _detailAddress = value;
              },
              decoration: _buildInputDecoration('상세 주소를 입력하세요 (선택)'),
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }

  void _trySetRegionFromAddress(String address) {
    // 주소에서 지역 정보 추출 시도
    final provinces = RegionHelper.getAllRegions().where((r) => r.type == RegionType.province).toList();
    
    for (final province in provinces) {
      if (address.contains(province.name)) {
        setState(() {
          _selectedProvinceId = province.id;
          _selectedDistrictId = null;
        });
        
        // 시/군/구 찾기
        final districts = RegionHelper.getDistrictsByProvince(province.id);
        for (final district in districts) {
          if (address.contains(district.name)) {
            setState(() {
              _selectedDistrictId = district.id;
            });
            break;
          }
        }
        break;
      }
    }
  }

  Widget _buildFieldWithIcon({
    required IconData icon,
    required String label,
    required Widget child,
    bool isRequired = false,
    required List<Color> gradientColors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Icon(icon, size: 14, color: Colors.white),
            ),
            SizedBox(width: AppTheme.spacing2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: AppTheme.primaryPurple),
              ),
          ],
        ),
        SizedBox(height: AppTheme.spacing3),
        child,
      ],
    );
  }

  Widget _buildPriceSection() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFEFCE8),
            Color(0xFFFFF7ED),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.yellow200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFACC15), Color(0xFFF97316)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Icon(Icons.attach_money, size: 14, color: Colors.white),
              ),
              SizedBox(width: AppTheme.spacing2),
              const Text(
                '가격 및 인원',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '가격 (원) *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _priceController,
                      decoration: _buildInputDecoration('0 (무료)', padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3)),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return '가격을 입력해주세요';
                        final price = int.tryParse(value.replaceAll(',', ''));
                        if (price == null || price < 0) return '올바른 가격을 입력해주세요';
                        return null;
                      },
                      onChanged: (value) {
                        final price = int.tryParse(value.replaceAll(',', ''));
                        if (price != null) {
                          _priceController.value = TextEditingValue(
                            text: NumberFormat('#,###').format(price),
                            selection: TextSelection.collapsed(
                              offset: NumberFormat('#,###').format(price).length,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '최대 인원 (명) *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _maxApplicantsController,
                      decoration: _buildInputDecoration('20', padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3)),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return '인원을 입력해주세요';
                        final count = int.tryParse(value);
                        if (count == null || count <= 0) return '올바른 인원 수를 입력해주세요';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationTypeSection() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFF3E8FF),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.blue100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Icon(Icons.school, size: 14, color: Colors.white),
              ),
              SizedBox(width: AppTheme.spacing2),
              const Text(
                '교육 유형',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          // 온라인/오프라인 선택
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isOnline = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                    decoration: BoxDecoration(
                      color: !_isOnline ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(
                        color: !_isOnline ? AppTheme.primaryGreen : AppTheme.borderGray,
                        width: !_isOnline ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '오프라인',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: !_isOnline ? FontWeight.bold : FontWeight.normal,
                          color: !_isOnline ? AppTheme.primaryGreen : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppTheme.spacing2),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isOnline = true;
                      // 온라인 선택 시 지역 선택 초기화
                      _selectedProvinceId = null;
                      _selectedDistrictId = null;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(
                        color: _isOnline ? AppTheme.primaryBlue : AppTheme.borderGray,
                        width: _isOnline ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '온라인',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _isOnline ? FontWeight.bold : FontWeight.normal,
                          color: _isOnline ? AppTheme.primaryBlue : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          // 급구 체크박스
          InkWell(
            onTap: () {
              setState(() {
                _isUrgent = !_isUrgent;
              });
            },
            child: Row(
              children: [
                Checkbox(
                  value: _isUrgent,
                  onChanged: (value) {
                    setState(() {
                      _isUrgent = value ?? false;
                    });
                  },
                  activeColor: AppTheme.urgentRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                SizedBox(width: AppTheme.spacing2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing2, vertical: AppTheme.spacing1),
                  decoration: BoxDecoration(
                    color: AppTheme.urgentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department, size: 16, color: AppTheme.urgentRed),
                      SizedBox(width: AppTheme.spacing1),
                      const Text(
                        '급구',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.urgentRed,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppTheme.spacing2),
                const Expanded(
                  child: Text(
                    '급구 교육으로 등록',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Icon(Icons.calendar_today, size: 14, color: Colors.white),
            ),
            SizedBox(width: AppTheme.spacing2),
            const Text(
              '마감일',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: AppTheme.primaryPurple),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing3),
        InkWell(
          onTap: _selectDeadline,
          child: Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.primaryPurpleLight, width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDeadline != null
                        ? DateFormat('yyyy년 M월 d일', 'ko_KR').format(_selectedDeadline!)
                        : '마감일을 선택하세요',
                    style: TextStyle(
                      color: _selectedDeadline != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, {int maxLines = 1, EdgeInsets? padding}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        borderSide: const BorderSide(color: AppTheme.primaryPurpleLight, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        borderSide: const BorderSide(color: AppTheme.primaryPurpleLight, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
      ),
      contentPadding: padding ?? EdgeInsets.symmetric(horizontal: AppTheme.spacing5, vertical: AppTheme.spacing4),
      isDense: true,
    );
  }
}

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
