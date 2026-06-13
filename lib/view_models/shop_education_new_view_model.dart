import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/create_education_request.dart';
import '../models/region.dart';
import '../services/education_service.dart';
import '../utils/error_handler.dart';
import '../utils/region_helper.dart';

/// 샵 교육 등록 폼. [dispose]에서 컨트롤러 정리.
class ShopEducationNewViewModel extends ChangeNotifier {
  ShopEducationNewViewModel({
    ImagePicker? imagePicker,
    EducationService? educationService,
  })  : _imagePicker = imagePicker ?? sl<ImagePicker>(),
        _educationService = educationService ?? sl<EducationService>();

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final ImagePicker _imagePicker;
  final EducationService _educationService;

  static const List<EducationCategoryOption> categories = [
    EducationCategoryOption(
      id: 'cut',
      name: '컷트',
      subCategories: ['여성컷트', '남성컷트'],
    ),
    EducationCategoryOption(
      id: 'perm',
      name: '펌',
      subCategories: ['디지털펌', '볼륨펌', '스트레이트펌'],
    ),
    EducationCategoryOption(
      id: 'color',
      name: '염색',
      subCategories: ['탈색', '브릿지', '올리브염색'],
    ),
    EducationCategoryOption(
      id: 'styling',
      name: '스타일링',
      subCategories: ['웨딩스타일링', '일상스타일링'],
    ),
  ];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController maxApplicantsController = TextEditingController();
  final TextEditingController detailAddressController = TextEditingController();

  List<File> selectedImages = [];
  String? selectedProvinceId;
  String? selectedDistrictId;
  String? selectedCategoryId;
  String? selectedSubCategory;
  bool isOnline = false;
  bool isUrgent = false;
  DateTime? selectedDeadline;
  String address = '';
  bool isLoading = false;

  List<String> get availableSubCategories {
    if (selectedCategoryId == null) return [];
    final category = categories.firstWhere(
      (c) => c.id == selectedCategoryId,
      orElse: () => categories[0],
    );
    return category.subCategories;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    maxApplicantsController.dispose();
    detailAddressController.dispose();
    super.dispose();
  }

  String? validateTitle(String? value) =>
      value == null || value.trim().isEmpty ? '제목을 입력해주세요' : null;

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return '가격을 입력해주세요';
    final price = int.tryParse(value.replaceAll(',', ''));
    if (price == null || price < 0) return '올바른 가격을 입력해주세요';
    return null;
  }

  String? validateMaxApplicants(String? value) {
    if (value == null || value.trim().isEmpty) return '인원을 입력해주세요';
    final count = int.tryParse(value);
    if (count == null || count <= 0) return '올바른 인원 수를 입력해주세요';
    return null;
  }

  /// 폼 외 필수값(지역·카테고리·마감일).
  String? validateExtraFields() {
    if (!isOnline &&
        (selectedProvinceId == null || selectedDistrictId == null)) {
      return '지역을 선택해주세요';
    }
    if (selectedCategoryId == null || selectedSubCategory == null) {
      return '카테고리를 선택해주세요';
    }
    if (selectedDeadline == null) {
      return '마감일을 선택해주세요';
    }
    return null;
  }

  void onPriceChanged(String value) {
    final parsed = int.tryParse(value.replaceAll(',', ''));
    if (parsed != null) {
      final formatted = NumberFormat('#,###').format(parsed);
      priceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    notifyListeners();
  }

  void setProvinceId(String? value) {
    selectedProvinceId = value;
    selectedDistrictId = null;
    notifyListeners();
  }

  void setDistrictId(String? value) {
    selectedDistrictId = value;
    notifyListeners();
  }

  void setCategoryId(String? value) {
    selectedCategoryId = value;
    selectedSubCategory = null;
    notifyListeners();
  }

  void setSubCategory(String? value) {
    selectedSubCategory = value;
    notifyListeners();
  }

  void setOnline(bool online) {
    isOnline = online;
    if (online) {
      selectedProvinceId = null;
      selectedDistrictId = null;
    }
    notifyListeners();
  }

  void toggleUrgent([bool? value]) {
    isUrgent = value ?? !isUrgent;
    notifyListeners();
  }

  void setDeadline(DateTime? d) {
    selectedDeadline = d;
    notifyListeners();
  }

  void removeImage(int index) {
    if (index < 0 || index >= selectedImages.length) return;
    selectedImages = List<File>.from(selectedImages)..removeAt(index);
    notifyListeners();
  }

  void applySearchAddress(String newAddress, {String? detail}) {
    address = newAddress;
    if (detail != null) {
      detailAddressController.text = detail;
    }
    _trySetRegionFromAddress(newAddress);
    notifyListeners();
  }

  void _trySetRegionFromAddress(String addr) {
    final provinces = RegionHelper.getAllRegions()
        .where((r) => r.type == RegionType.province)
        .toList();

    for (final province in provinces) {
      if (addr.contains(province.name)) {
        selectedProvinceId = province.id;
        selectedDistrictId = null;

        final districts = RegionHelper.getDistrictsByProvince(province.id);
        for (final district in districts) {
          if (addr.contains(district.name)) {
            selectedDistrictId = district.id;
            break;
          }
        }
        return;
      }
    }
  }

  Future<void> pickMultiImage() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isEmpty) return;

      final files = images.map((x) => File(x.path)).toList();
      final remaining = 5 - selectedImages.length;
      if (remaining <= 0) {
        _m.showMessage('이미지는 최대 5장까지 등록할 수 있습니다');
        return;
      }

      final toAdd = files.take(remaining).toList();
      for (final file in toAdd) {
        final size = await file.length();
        if (size > 10 * 1024 * 1024) {
          _m.showMessage('이미지 크기는 각 10MB 이하여야 합니다');
          return;
        }
      }

      selectedImages = [...selectedImages, ...toAdd];
      notifyListeners();
    } catch (e) {
      _m.showError('이미지 선택 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      if (selectedImages.length >= 5) {
        _m.showMessage('이미지는 최대 5장까지 등록할 수 있습니다');
        return;
      }

      final file = File(image.path);
      final size = await file.length();
      if (size > 10 * 1024 * 1024) {
        _m.showMessage('이미지 크기는 10MB 이하여야 합니다');
        return;
      }

      selectedImages = [...selectedImages, file];
      notifyListeners();
    } catch (e) {
      _m.showError('이미지 선택 중 오류가 발생했습니다: $e');
    }
  }

  Future<bool> submit(GlobalKey<FormState> formKey) async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return false;

    final extra = validateExtraFields();
    if (extra != null) {
      _m.showMessage(extra);
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final price = int.parse(priceController.text.replaceAll(',', ''));
      final maxApplicants = int.parse(maxApplicantsController.text.trim());

      final request = CreateEducationRequest(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: price,
        maxApplicants: maxApplicants,
        categoryId: selectedCategoryId!,
        subCategory: selectedSubCategory!,
        isOnline: isOnline,
        isUrgent: isUrgent,
        provinceId: isOnline ? null : selectedProvinceId,
        districtId: isOnline ? null : selectedDistrictId,
        address: address,
        detailAddress: detailAddressController.text.trim(),
        deadline: DateFormat('yyyy-MM-dd').format(selectedDeadline!),
        imageLocalPaths: selectedImages.map((f) => f.path).toList(),
      );

      final result = await _educationService.createEducation(request);
      _m.showSuccess('「${result.title}」 교육이 등록되었습니다');
      return true;
    } catch (e) {
      final ex = ErrorHandler.handleException(e);
      _m.showError(ErrorHandler.getUserFriendlyMessage(ex));
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class EducationCategoryOption {
  const EducationCategoryOption({
    required this.id,
    required this.name,
    required this.subCategories,
  });

  final String id;
  final String name;
  final List<String> subCategories;
}
