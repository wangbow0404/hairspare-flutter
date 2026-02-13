import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/space_rental.dart';
import '../../models/region.dart';
import '../../services/space_rental_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';

class ShopSpaceEditScreen extends StatefulWidget {
  final String spaceId;

  const ShopSpaceEditScreen({
    super.key,
    required this.spaceId,
  });

  @override
  State<ShopSpaceEditScreen> createState() => _ShopSpaceEditScreenState();
}

class _ShopSpaceEditScreenState extends State<ShopSpaceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final SpaceRentalService _spaceRentalService = SpaceRentalService();
  
  // 폼 필드
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  SpaceRental? _space;
  String? _selectedRegionId;
  List<String> _selectedFacilities = [];
  List<String> _imageUrls = [];
  SpaceStatus _selectedStatus = SpaceStatus.available;
  bool _isLoading = true;
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
  void initState() {
    super.initState();
    _loadSpace();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _detailAddressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSpace() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final space = await _spaceRentalService.getSpaceRentalById(widget.spaceId);
      setState(() {
        _space = space;
        _addressController.text = space.address;
        _detailAddressController.text = space.detailAddress ?? '';
        _priceController.text = NumberFormat('#,###').format(space.pricePerHour);
        _descriptionController.text = space.description ?? '';
        _selectedRegionId = space.regionId;
        _selectedFacilities = List.from(space.facilities);
        _imageUrls = List.from(space.imageUrls ?? []);
        _selectedStatus = space.status;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRegionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지역을 선택해주세요'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _spaceRentalService.updateSpaceRental(
        spaceId: widget.spaceId,
        address: _addressController.text.trim(),
        detailAddress: _detailAddressController.text.trim().isEmpty
            ? null
            : _detailAddressController.text.trim(),
        regionId: _selectedRegionId,
        pricePerHour: int.parse(_priceController.text.replaceAll(',', '')),
        facilities: _selectedFacilities,
        imageUrls: _imageUrls.isEmpty ? null : _imageUrls,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _selectedStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공간 정보가 수정되었습니다'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
            backgroundColor: AppTheme.urgentRed,
          ),
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('공간 수정'),
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('공간 수정'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spacing4),
          children: [
            // 주소
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '주소 *',
                hintText: '주소를 입력하세요',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '주소를 입력해주세요';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppTheme.spacing4),
            
            // 상세 주소
            TextFormField(
              controller: _detailAddressController,
              decoration: const InputDecoration(
                labelText: '상세 주소',
                hintText: '상세 주소를 입력하세요 (선택)',
                border: OutlineInputBorder(),
              ),
            ),
            
            SizedBox(height: AppTheme.spacing4),
            
            // 지역 선택
            DropdownButtonFormField<String>(
              value: _selectedRegionId,
              decoration: const InputDecoration(
                labelText: '지역 *',
                border: OutlineInputBorder(),
              ),
              items: RegionHelper.getAllRegions()
                  .where((r) => r.type == RegionType.district)
                  .map((region) {
                return DropdownMenuItem(
                  value: region.id,
                  child: Text(RegionHelper.getRegionName(region.id)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRegionId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return '지역을 선택해주세요';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppTheme.spacing4),
            
            // 시간당 가격
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '시간당 가격 (원) *',
                hintText: '10000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '가격을 입력해주세요';
                }
                final price = int.tryParse(value.replaceAll(',', ''));
                if (price == null || price <= 0) {
                  return '올바른 가격을 입력해주세요';
                }
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
            
            SizedBox(height: AppTheme.spacing4),
            
            // 상태 선택
            DropdownButtonFormField<SpaceStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: '상태',
                border: OutlineInputBorder(),
              ),
              items: SpaceStatus.values.map((status) {
                String label;
                switch (status) {
                  case SpaceStatus.available:
                    label = '예약 가능';
                    break;
                  case SpaceStatus.booked:
                    label = '예약됨';
                    break;
                  case SpaceStatus.unavailable:
                    label = '사용 불가';
                    break;
                }
                return DropdownMenuItem(
                  value: status,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            
            SizedBox(height: AppTheme.spacing4),
            
            // 시설 선택
            Text(
              '시설 *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: AppTheme.spacing2),
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
                );
              }).toList(),
            ),
            
            SizedBox(height: AppTheme.spacing4),
            
            // 설명
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '공간 설명',
                hintText: '공간에 대한 설명을 입력하세요 (선택)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            
            SizedBox(height: AppTheme.spacing6),
            
            // 수정 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppTheme.spacing4),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('수정하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
