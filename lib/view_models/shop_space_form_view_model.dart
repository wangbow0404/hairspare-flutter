import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/region.dart';
import '../models/space_operating_schedule.dart';
import '../models/space_rental.dart';
import '../services/space_rental_service.dart';
import '../utils/error_handler.dart';
import '../utils/region_helper.dart';
import '../utils/space_slot_builder.dart';

/// 공간 등록·수정 폼 상태.
class ShopSpaceFormViewModel extends ChangeNotifier {
  ShopSpaceFormViewModel({
    ImagePicker? imagePicker,
    SpaceRentalService? spaceRentalService,
    this.editingSpaceId,
  })  : _imagePicker = imagePicker ?? sl<ImagePicker>(),
        _spaceRentalService = spaceRentalService ?? sl<SpaceRentalService>(),
        isLoading = editingSpaceId != null;

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final ImagePicker _imagePicker;
  final SpaceRentalService _spaceRentalService;

  final String? editingSpaceId;
  bool get isEditing => editingSpaceId != null;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController detailAddressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController usageNotesController = TextEditingController();
  final TextEditingController contactPhoneController = TextEditingController();
  final TextEditingController subwayInfoController = TextEditingController();

  static const List<String> facilityOptions = [
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

  bool isLoading = false;
  bool isSubmitting = false;
  bool showValidationErrors = false;

  String? selectedProvinceId;
  String? selectedDistrictId;
  List<String> selectedFacilities = [];
  List<File> selectedImages = [];
  List<String> existingImageUrls = [];
  SpaceStatus selectedStatus = SpaceStatus.available;
  int minHours = 2;

  SpaceOperatingMode operatingMode = SpaceOperatingMode.everyDay;
  DayWindow everyDayWindow = DayWindow.defaultOpen;
  DayWindow weekdayWindow = DayWindow.defaultOpen;
  DayWindow weekendWindow = DayWindow.open(start: '11:00', end: '18:00');
  List<DayWindow> perWeekdayWindows =
      SpaceOperatingSchedule.defaultPerWeekday();
  List<DateTime> closedDates = [];

  void markValidationAttempted() {
    if (showValidationErrors) return;
    showValidationErrors = true;
    notifyListeners();
  }

  SpaceOperatingSchedule buildOperatingSchedule() {
    switch (operatingMode) {
      case SpaceOperatingMode.everyDay:
        return SpaceOperatingSchedule(
          mode: operatingMode,
          everyDay: everyDayWindow,
          closedDates: closedDates,
        );
      case SpaceOperatingMode.weekdayWeekend:
        return SpaceOperatingSchedule(
          mode: operatingMode,
          weekday: weekdayWindow,
          weekend: weekendWindow,
          closedDates: closedDates,
        );
      case SpaceOperatingMode.perWeekday:
        return SpaceOperatingSchedule(
          mode: operatingMode,
          byWeekday: List<DayWindow>.from(perWeekdayWindows),
          closedDates: closedDates,
        );
    }
  }

  void setOperatingMode(SpaceOperatingMode mode) {
    operatingMode = mode;
    notifyListeners();
  }

  void setEveryDayWindow(DayWindow window) {
    everyDayWindow = window;
    notifyListeners();
  }

  void setWeekdayWindow(DayWindow window) {
    weekdayWindow = window;
    notifyListeners();
  }

  void setWeekendWindow(DayWindow window) {
    weekendWindow = window;
    notifyListeners();
  }

  void setPerWeekdayWindow(int index, DayWindow window) {
    perWeekdayWindows[index] = window;
    notifyListeners();
  }

  void addClosedDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    if (closedDates.any(
      (c) => c.year == d.year && c.month == d.month && c.day == d.day,
    )) {
      return;
    }
    closedDates = [...closedDates, d]..sort();
    notifyListeners();
  }

  void removeClosedDate(DateTime date) {
    closedDates = closedDates
        .where(
          (c) =>
              !(c.year == date.year &&
                  c.month == date.month &&
                  c.day == date.day),
        )
        .toList();
    notifyListeners();
  }

  void setMinHours(int value) {
    minHours = value.clamp(1, 8);
    notifyListeners();
  }

  void setProvince(String? id) {
    selectedProvinceId = id;
    selectedDistrictId = null;
    notifyListeners();
  }

  void setDistrict(String? id) {
    selectedDistrictId = id;
    notifyListeners();
  }

  void toggleFacility(String facility) {
    if (selectedFacilities.contains(facility)) {
      selectedFacilities.remove(facility);
    } else {
      selectedFacilities.add(facility);
    }
    notifyListeners();
  }

  void setStatus(SpaceStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  void formatPriceInput(String value) {
    final price = int.tryParse(value.replaceAll(',', ''));
    if (price == null) return;
    priceController.value = TextEditingValue(
      text: NumberFormat('#,###').format(price),
      selection: TextSelection.collapsed(
        offset: NumberFormat('#,###').format(price).length,
      ),
    );
  }

  Future<void> pickMultiImage() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;
    final remaining = 5 - selectedImages.length;
    selectedImages.addAll(
      images.take(remaining).map((x) => File(x.path)),
    );
    notifyListeners();
  }

  Future<void> pickImageFromCamera() async {
    if (selectedImages.length >= 5) return;
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return;
    selectedImages.add(File(image.path));
    notifyListeners();
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
    notifyListeners();
  }

  /// false면 로드 실패(화면에서 pop).
  Future<bool> loadSpace(String spaceId) async {
    isLoading = true;
    notifyListeners();
    try {
      final space = await _spaceRentalService.getSpaceRentalById(spaceId);
      addressController.text = space.address;
      detailAddressController.text = space.detailAddress ?? '';
      priceController.text = NumberFormat('#,###').format(space.pricePerHour);
      descriptionController.text = space.description ?? '';
      usageNotesController.text = space.usageNotes ?? '';
      contactPhoneController.text = space.contactPhone ?? '';
      subwayInfoController.text = space.subwayInfo ?? '';
      selectedFacilities = List<String>.from(space.facilities);
      existingImageUrls = List<String>.from(space.imageUrls ?? []);
      selectedStatus = space.status;
      minHours = space.minHours;

      final allRegions = RegionHelper.getAllRegions();
      final district = allRegions.cast<Region?>().firstWhere(
            (r) => r?.id == space.regionId,
            orElse: () => null,
          );
      if (district != null && district.parentId != null) {
        selectedProvinceId = district.parentId;
        selectedDistrictId = district.id;
      } else {
        selectedDistrictId = space.regionId;
      }

      final schedule = space.effectiveOperatingSchedule;
      operatingMode = schedule.mode;
      everyDayWindow = schedule.everyDay ?? DayWindow.defaultOpen;
      weekdayWindow = schedule.weekday ?? DayWindow.defaultOpen;
      weekendWindow = schedule.weekend ?? DayWindow.open(start: '11:00', end: '18:00');
      perWeekdayWindows = List<DayWindow>.from(
        schedule.byWeekday ?? SpaceOperatingSchedule.defaultPerWeekday(),
      );
      closedDates = List<DateTime>.from(schedule.closedDates);
    } catch (e) {
      _m.showError(
        ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
      );
      isLoading = false;
      notifyListeners();
      return false;
    }
    isLoading = false;
    notifyListeners();
    return true;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return '주소를 입력해주세요';
    return null;
  }

  String? validateDistrict() {
    if (selectedDistrictId == null) return '지역을 선택해주세요';
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return '가격을 입력해주세요';
    final price = int.tryParse(value.replaceAll(',', ''));
    if (price == null || price <= 0) return '올바른 가격을 입력해주세요';
    return null;
  }

  String? validateFacilities() {
    if (selectedFacilities.isEmpty) return '시설을 최소 1개 이상 선택해주세요';
    return null;
  }

  String? validateSchedule() => buildOperatingSchedule().validate(minHours: minHours);

  String? hintForInvalidForm() {
    if (validateAddress(addressController.text) != null) {
      return '주소를 입력해주세요';
    }
    if (validateDistrict() != null) return '지역을 선택해주세요';
    if (validatePrice(priceController.text) != null) return '가격을 확인해주세요';
    if (validateFacilities() != null) return '시설을 선택해주세요';
    final schedErr = validateSchedule();
    if (schedErr != null) return schedErr;
    return null;
  }

  Future<bool> submitCreate() async {
    final schedErr = validateSchedule();
    if (schedErr != null) {
      _m.showMessage(schedErr);
      return false;
    }
    if (validateFacilities() != null) {
      _m.showMessage('시설을 최소 1개 이상 선택해주세요');
      return false;
    }
    if (selectedDistrictId == null) {
      _m.showMessage('지역을 선택해주세요');
      return false;
    }

    isSubmitting = true;
    notifyListeners();
    try {
      final schedule = buildOperatingSchedule();
      await _spaceRentalService.createSpaceRental(
        address: addressController.text.trim(),
        detailAddress: detailAddressController.text.trim().isEmpty
            ? null
            : detailAddressController.text.trim(),
        regionId: selectedDistrictId!,
        pricePerHour:
            int.parse(priceController.text.replaceAll(',', '')),
        facilities: selectedFacilities,
        imageUrls: const [],
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        operatingSchedule: schedule,
        minHours: minHours,
        usageNotes: usageNotesController.text.trim().isEmpty
            ? null
            : usageNotesController.text.trim(),
        contactPhone: contactPhoneController.text.trim().isEmpty
            ? null
            : contactPhoneController.text.trim(),
        subwayInfo: subwayInfoController.text.trim().isEmpty
            ? null
            : subwayInfoController.text.trim(),
        availableSlots: SpaceSlotBuilder.build(schedule: schedule),
      );
      _m.showMessage('공간이 등록되었습니다');
      return true;
    } catch (e) {
      _m.showError(
        ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
      );
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> submitUpdate() async {
    if (editingSpaceId == null) return false;
    final schedErr = validateSchedule();
    if (schedErr != null) {
      _m.showMessage(schedErr);
      return false;
    }
    if (validateFacilities() != null) {
      _m.showMessage('시설을 최소 1개 이상 선택해주세요');
      return false;
    }
    if (selectedDistrictId == null) {
      _m.showMessage('지역을 선택해주세요');
      return false;
    }

    isSubmitting = true;
    notifyListeners();
    try {
      final schedule = buildOperatingSchedule();
      final slots = SpaceSlotBuilder.build(schedule: schedule);
      await _spaceRentalService.updateSpaceRental(
        spaceId: editingSpaceId!,
        address: addressController.text.trim(),
        detailAddress: detailAddressController.text.trim().isEmpty
            ? null
            : detailAddressController.text.trim(),
        regionId: selectedDistrictId,
        pricePerHour:
            int.parse(priceController.text.replaceAll(',', '')),
        facilities: selectedFacilities,
        imageUrls: existingImageUrls.isEmpty ? null : existingImageUrls,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        operatingSchedule: schedule,
        minHours: minHours,
        usageNotes: usageNotesController.text.trim().isEmpty
            ? null
            : usageNotesController.text.trim(),
        contactPhone: contactPhoneController.text.trim().isEmpty
            ? null
            : contactPhoneController.text.trim(),
        subwayInfo: subwayInfoController.text.trim().isEmpty
            ? null
            : subwayInfoController.text.trim(),
        availableSlots: slots,
        status: selectedStatus,
      );
      _m.showMessage('공간 정보가 수정되었습니다');
      return true;
    } catch (e) {
      _m.showError(
        ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e)),
      );
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    detailAddressController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    usageNotesController.dispose();
    contactPhoneController.dispose();
    subwayInfoController.dispose();
    super.dispose();
  }
}
