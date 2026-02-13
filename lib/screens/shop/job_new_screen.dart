import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/job_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import '../../utils/icon_mapper.dart';
import '../../models/region.dart';
import '../../providers/auth_provider.dart';
import 'jobs_list_screen.dart';
import 'address_search_screen.dart';

/// Shop 공고 등록 화면 (Refine Job Posting Design 스타일)
class ShopJobNewScreen extends StatefulWidget {
  const ShopJobNewScreen({super.key});

  @override
  State<ShopJobNewScreen> createState() => _ShopJobNewScreenState();
}

class _ShopJobNewScreenState extends State<ShopJobNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _requiredCountController = TextEditingController();
  final JobService _jobService = JobService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  List<File> _selectedImages = [];
  String? _selectedProvinceId;
  String? _selectedDistrictId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedRole;
  bool _isUrgent = false;
  String _wageType = 'hourly'; // 'hourly' | 'daily'
  String _address = '경기도 파주시 청석로 272, 1004-575호(동패동, 센타프라자1)'; // 기본 주소 (사업자등록증 주소)
  String? _detailAddress;
  
  final List<String> _roleOptions = ['스텝', '디자이너'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _requiredCountController.dispose();
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProvinceId == null || _selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지역을 선택해주세요')),
      );
      return;
    }
    if (_selectedDate == null || _selectedStartTime == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 항목을 모두 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 실제 API 호출
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공고 등록 기능은 준비 중입니다')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공고 등록 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}')),
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
              Color(0xFFF3E8FF), // purple-50
              Color(0xFFEFF6FF), // blue-50
              Color(0xFFFDF2F8), // pink-50
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
                        '공고 등록',
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
                        // 공고 제목
                        _buildFieldWithDot(
                          label: '공고 제목',
                          isRequired: true,
                          child: TextFormField(
                            controller: _titleController,
                            decoration: _buildInputDecoration('예) 스텝 급구합니다'),
                            validator: (value) => value?.isEmpty ?? true ? '제목을 입력해주세요' : null,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing5),
                        // 공고 설명
                        _buildFieldWithDot(
                          label: '공고 설명',
                          isRequired: false,
                          dotColor: AppTheme.primaryBlue,
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: _buildInputDecoration('상세한 설명을 입력해주세요', maxLines: 4),
                            maxLines: 4,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing5),
                        // 주소 섹션
                        _buildAddressSection(),
                        SizedBox(height: AppTheme.spacing5),
                        // 지역 선택 (세분화)
                        _buildRegionSelector(),
                        SizedBox(height: AppTheme.spacing5),
                        // 일정 섹션
                        _buildScheduleSection(),
                        SizedBox(height: AppTheme.spacing5),
                        // 급여 및 인원 섹션
                        _buildPaymentSection(),
                        SizedBox(height: AppTheme.spacing5),
                        // 역할 선택
                        _buildRoleSelector(),
                        SizedBox(height: AppTheme.spacing5),
                        // 급구 체크박스
                        _buildUrgentCheckbox(),
                        SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // 하단 고정 버튼
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
                          '공고 등록하기',
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

  Widget _buildAddressSection() {
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
              '주소',
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
        // 기본 주소 표시 및 검색 버튼
        Row(
          children: [
            Expanded(
              child: Container(
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
            ),
            SizedBox(width: AppTheme.spacing2),
            ElevatedButton.icon(
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
                    // 주소에서 지역 정보 추출하여 자동 선택 시도
                    _trySetRegionFromAddress(_address);
                  });
                }
              },
              icon: const Icon(Icons.search, size: 18),
              label: const Text('검색'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppTheme.spacing3),
        // 상세 주소 입력
        TextFormField(
          initialValue: _detailAddress,
          onChanged: (value) {
            _detailAddress = value;
          },
          decoration: _buildInputDecoration('상세 주소를 입력하세요 (선택)'),
          maxLines: 1,
        ),
      ],
    );
  }

  void _trySetRegionFromAddress(String address) {
    // 주소에서 지역 정보 추출 시도
    // 예: "경기도 파주시" -> province: gyeonggi, district: gyeonggi-paju
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

  Widget _buildRegionSelector() {
    final provinces = RegionHelper.getAllRegions().where((r) => r.type == RegionType.province).toList();
    final districts = _selectedProvinceId != null
        ? RegionHelper.getDistrictsByProvince(_selectedProvinceId!)
        : <Region>[];

    return _buildFieldWithIcon(
      icon: Icons.map,
      label: '지역',
      isRequired: true,
      gradientColors: const [Color(0xFFEC4899), Color(0xFF9333EA)],
      child: Column(
        children: [
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
                _selectedDistrictId = null; // 시/도 변경 시 시/군/구 초기화
              });
            },
            validator: (value) => value == null ? '시/도를 선택해주세요' : null,
          ),
          if (_selectedProvinceId != null) ...[
            SizedBox(height: AppTheme.spacing3),
            // 시/군/구 선택
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

  Widget _buildScheduleSection() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF6FF), // blue-50
            Color(0xFFF3E8FF), // purple-50
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
                child: const Icon(Icons.calendar_today, size: 14, color: Colors.white),
              ),
              SizedBox(width: AppTheme.spacing2),
              const Text(
                '일정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          // 날짜
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '날짜 *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: AppTheme.spacing2),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.blue200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(_selectedDate!)
                              : '날짜를 선택하세요',
                          style: TextStyle(
                            color: _selectedDate != null ? AppTheme.textPrimary : AppTheme.textSecondary,
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
          ),
          SizedBox(height: AppTheme.spacing4),
          // 시간
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '시작 시간 *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    InkWell(
                      onTap: _selectStartTime,
                      child: Container(
                        height: 48,
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(color: AppTheme.blue200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedStartTime != null
                                    ? _selectedStartTime!.format(context)
                                    : '시간 선택',
                                style: TextStyle(
                                  color: _selectedStartTime != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(Icons.access_time, size: 18, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
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
                      '종료 시간',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    InkWell(
                      onTap: _selectEndTime,
                      child: Container(
                        height: 48,
                        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(color: AppTheme.blue200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedEndTime != null
                                    ? _selectedEndTime!.format(context)
                                    : '시간 선택',
                                style: TextStyle(
                                  color: _selectedEndTime != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(Icons.access_time, size: 18, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
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

  Widget _buildPaymentSection() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFEFCE8), // yellow-50
            Color(0xFFFFF7ED), // orange-50
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
                '급여 및 인원',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          // 시급/일급 선택
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '급여 유형 *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: AppTheme.spacing2),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _wageType = 'hourly';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                        decoration: BoxDecoration(
                          color: _wageType == 'hourly' ? Colors.white : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: _wageType == 'hourly' ? AppTheme.yellow400 : AppTheme.borderGray,
                            width: _wageType == 'hourly' ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '시급',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _wageType == 'hourly' ? FontWeight.bold : FontWeight.normal,
                              color: _wageType == 'hourly' ? AppTheme.yellow600 : AppTheme.textSecondary,
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
                          _wageType = 'daily';
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                        decoration: BoxDecoration(
                          color: _wageType == 'daily' ? Colors.white : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: _wageType == 'daily' ? AppTheme.yellow400 : AppTheme.borderGray,
                            width: _wageType == 'daily' ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '일급',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _wageType == 'daily' ? FontWeight.bold : FontWeight.normal,
                              color: _wageType == 'daily' ? AppTheme.yellow600 : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                    Text(
                      '금액 (${_wageType == 'hourly' ? '시' : '일'}급 원) *',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _amountController,
                      decoration: _buildInputDecoration('100,000', padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3)),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return '금액을 입력해주세요';
                        final amount = int.tryParse(value.replaceAll(',', ''));
                        if (amount == null || amount <= 0) return '올바른 금액을 입력해주세요';
                        return null;
                      },
                      onChanged: (value) {
                        final amount = int.tryParse(value.replaceAll(',', ''));
                        if (amount != null) {
                          _amountController.value = TextEditingValue(
                            text: NumberFormat('#,###').format(amount),
                            selection: TextSelection.collapsed(
                              offset: NumberFormat('#,###').format(amount).length,
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
                      '필요 인원 (명) *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _requiredCountController,
                      decoration: _buildInputDecoration('1', padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3)),
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

  Widget _buildRoleSelector() {
    return _buildFieldWithIcon(
      icon: Icons.person,
      label: '역할',
      isRequired: true,
      gradientColors: const [Color(0xFF10B981), Color(0xFF14B8A6)],
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: _buildInputDecoration('선택하세요'),
        items: _roleOptions.map((role) {
          return DropdownMenuItem(
            value: role,
            child: Text(role),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedRole = value;
          });
        },
        validator: (value) => value == null ? '역할을 선택해주세요' : null,
      ),
    );
  }

  Widget _buildUrgentCheckbox() {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFEF2F2), // red-50
            Color(0xFFFDF2F8), // pink-50
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.red200, width: 2),
        boxShadow: AppTheme.shadowSm,
      ),
      child: InkWell(
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
            SizedBox(width: AppTheme.spacing3),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: AppTheme.shadowMd,
              ),
              child: const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.white),
            ),
            SizedBox(width: AppTheme.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '급구',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Text(
                    '공고를 급구로 등록합니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
