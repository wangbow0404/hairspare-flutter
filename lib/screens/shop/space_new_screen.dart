import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/space_rental.dart';
import '../../models/region.dart';
import '../../services/space_rental_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import '../../utils/icon_mapper.dart';

class ShopSpaceNewScreen extends StatefulWidget {
  const ShopSpaceNewScreen({super.key});

  @override
  State<ShopSpaceNewScreen> createState() => _ShopSpaceNewScreenState();
}

class _ShopSpaceNewScreenState extends State<ShopSpaceNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final SpaceRentalService _spaceRentalService = SpaceRentalService();
  final ImagePicker _imagePicker = ImagePicker();
  
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _selectedProvinceId;
  String? _selectedDistrictId;
  List<String> _selectedFacilities = [];
  List<File> _selectedImages = [];
  bool _isSubmitting = false;
  
  final List<String> _availableFacilities = [
    '의자',
    '세트',
    '샴푸대',
    '드라이어',
    '거울',
    '수도',
    '에어컨',
    '히터',
    '주차장',
    'Wi-Fi',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _detailAddressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProvinceId == null || _selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지역을 선택해주세요')),
      );
      return;
    }
    if (_selectedFacilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('시설을 최소 1개 이상 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final now = DateTime.now();
      final slots = <TimeSlot>[];
      for (int day = 0; day < 30; day++) {
        final date = now.add(Duration(days: day));
        for (int hour = 9; hour < 21; hour++) {
          final startTime = DateTime(date.year, date.month, date.day, hour);
          final endTime = startTime.add(const Duration(hours: 1));
          slots.add(TimeSlot(
            startTime: startTime,
            endTime: endTime,
            isAvailable: true,
          ));
        }
      }

      await _spaceRentalService.createSpaceRental(
        address: _addressController.text.trim(),
        detailAddress: _detailAddressController.text.trim().isEmpty
            ? null
            : _detailAddressController.text.trim(),
        regionId: _selectedDistrictId!,
        pricePerHour: int.parse(_priceController.text.replaceAll(',', '')),
        facilities: _selectedFacilities,
        imageUrls: [],
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        availableSlots: slots,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공간이 등록되었습니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
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
                        '공간 등록',
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
                        // 주소
                        _buildFieldWithDot(
                          label: '주소',
                          isRequired: true,
                          child: TextFormField(
                            controller: _addressController,
                            decoration: _buildInputDecoration('주소를 입력하세요'),
                            validator: (value) => value?.isEmpty ?? true ? '주소를 입력해주세요' : null,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing5),
                        // 상세 주소
                        _buildFieldWithDot(
                          label: '상세 주소',
                          isRequired: false,
                          dotColor: AppTheme.primaryBlue,
                          child: TextFormField(
                            controller: _detailAddressController,
                            decoration: _buildInputDecoration('상세 주소를 입력하세요 (선택)'),
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing5),
                        // 지역 선택 (세분화)
                        _buildRegionSelector(),
                        SizedBox(height: AppTheme.spacing5),
                        // 가격 섹션
                        _buildPriceSection(),
                        SizedBox(height: AppTheme.spacing5),
                        // 시설 선택
                        _buildFacilitiesSection(),
                        SizedBox(height: AppTheme.spacing5),
                        // 설명
                        _buildFieldWithDot(
                          label: '공간 설명',
                          isRequired: false,
                          dotColor: AppTheme.primaryBlue,
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: _buildInputDecoration('공간에 대한 설명을 입력하세요 (선택)', maxLines: 4),
                            maxLines: 4,
                          ),
                        ),
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
              onPressed: _isSubmitting ? null : _submit,
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
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Text(
                          '공간 등록하기',
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
        children: [
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
            validator: (value) => value == null ? '시/도를 선택해주세요' : null,
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
              validator: (value) => value == null ? '시/군/구를 선택해주세요' : null,
            ),
          ],
        ],
      ),
    );
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
                '가격',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          TextFormField(
            controller: _priceController,
            decoration: _buildInputDecoration('10000'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return '가격을 입력해주세요';
              final price = int.tryParse(value.replaceAll(',', ''));
              if (price == null || price <= 0) return '올바른 가격을 입력해주세요';
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
    );
  }

  Widget _buildFacilitiesSection() {
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
              child: const Icon(Icons.home, size: 14, color: Colors.white),
            ),
            SizedBox(width: AppTheme.spacing2),
            const Text(
              '시설',
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
        Wrap(
          spacing: AppTheme.spacing2,
          runSpacing: AppTheme.spacing2,
          children: _availableFacilities.map((facility) {
            final isSelected = _selectedFacilities.contains(facility);
            return FilterChip(
              label: Text(facility),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFacilities.add(facility);
                  } else {
                    _selectedFacilities.remove(facility);
                  }
                });
              },
              selectedColor: AppTheme.primaryPurple.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryPurple,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryPurple : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryPurple : AppTheme.borderGray,
                  width: isSelected ? 2 : 1,
                ),
              ),
            );
          }).toList(),
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
