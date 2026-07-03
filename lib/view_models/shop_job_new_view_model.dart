import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/di/service_locator.dart';
import '../core/services/global_messenger_service.dart';
import '../models/create_job_request.dart';
import '../models/job.dart';
import '../models/region.dart';
import '../services/auth_service.dart';
import '../services/job_service.dart';
import '../utils/error_handler.dart';
import '../utils/region_helper.dart';
import '../utils/work_schedule_utils.dart';
import '../widgets/shop_job_new/shop_job_new_form_sections.dart';

/// 샵 구인 등록 폼 상태·검증·이미지 선택. [TextEditingController]는 [dispose]에서 정리.
class ShopJobNewViewModel extends ChangeNotifier {
  ShopJobNewViewModel({
    ImagePicker? imagePicker,
    JobService? jobService,
    AuthService? authService,
    Job? jobToEdit,
    Job? jobToCopy,
  })  : _imagePicker = imagePicker ?? sl<ImagePicker>(),
        _jobService = jobService ?? sl<JobService>(),
        _authService = authService ?? sl<AuthService>() {
    if (jobToEdit != null) {
      _loadFromJob(jobToEdit);
    } else if (jobToCopy != null) {
      _loadFromJobCopy(jobToCopy);
    } else {
      _trySetRegionFromAddress(address);
    }
  }

  GlobalMessengerService get _m => sl<GlobalMessengerService>();

  final ImagePicker _imagePicker;
  final JobService _jobService;
  final AuthService _authService;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController requiredCountController = TextEditingController();
  final TextEditingController detailAddressController = TextEditingController();

  final List<String> roleOptions = const ['스텝', '디자이너'];

  List<XFile> selectedImages = [];
  /// 수정 모드에서 이미 저장된 이미지 URL 목록 (삭제하지 않는 한 유지)
  List<String> existingImageUrls = [];
  String? selectedProvinceId;
  String? selectedDistrictId;
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  String? selectedRole;
  /// 수정 모드일 때만 설정.
  String? editingJobId;
  bool get isEditing => editingJobId != null;

  /// 지난 공고 복사 등록 모드(날짜·시간은 비움).
  bool isCopyMode = false;

  /// 급구 여부. 폼에서는 설정하지 않으며 [setUrgentForRegistration]은 업셀 화면에서만 호출.
  bool isUrgent = false;
  String wageType = 'hourly';

  /// 공고 등록 완료 후 업셀 화면에서 참조하는 값.
  String? lastCreatedJobId;
  String? lastCreatedJobTitle;
  bool isFirstJob = false;
  String address =
      '경기도 파주시 청석로 272, 1004-575호(동패동, 센타프라자1)';
  bool isLoading = false;

  /// 등록 시도 후 미입력 필드 빨간 강조.
  bool showValidationErrors = false;

  void markValidationAttempted() {
    if (showValidationErrors) return;
    showValidationErrors = true;
    notifyListeners();
  }

  bool get hasTitleError =>
      showValidationErrors && validateTitle(titleController.text) != null;

  bool get hasAddressError =>
      showValidationErrors && address.trim().isEmpty;

  bool get hasRegionError =>
      showValidationErrors &&
      (validateProvince(selectedProvinceId) != null ||
          validateDistrict(selectedDistrictId) != null);

  bool get hasDateError => showValidationErrors && selectedDate == null;

  bool get hasStartTimeEmptyError =>
      showValidationErrors && selectedStartTime == null;

  bool get hasStartTimePastError =>
      showValidationErrors && startTimeInPastMessage != null;

  bool get hasEndTimeError =>
      showValidationErrors && endTimeBeforeStartMessage != null;

  bool get hasAmountError =>
      showValidationErrors && validateAmount(amountController.text) != null;

  bool get hasRequiredCountError =>
      showValidationErrors &&
      validateRequiredCount(requiredCountController.text) != null;

  bool get hasRoleError =>
      showValidationErrors && validateRole(selectedRole) != null;

  bool get hasScheduleSectionError =>
      hasDateError ||
      hasStartTimeEmptyError ||
      hasStartTimePastError ||
      hasEndTimeError;

  bool get hasPaymentSectionError => hasAmountError || hasRequiredCountError;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    requiredCountController.dispose();
    detailAddressController.dispose();
    super.dispose();
  }

  // ——— Validators (폼 필드용) ———

  String? validateTitle(String? value) =>
      value == null || value.trim().isEmpty ? '제목을 입력해주세요' : null;

  String? validateProvince(String? value) =>
      value == null ? '시/도를 선택해주세요' : null;

  String? validateDistrict(String? value) =>
      value == null ? '시/군/구를 선택해주세요' : null;

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return '금액을 입력해주세요';
    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) return '올바른 금액을 입력해주세요';
    return null;
  }

  String? validateRequiredCount(String? value) {
    if (value == null || value.trim().isEmpty) return '인원을 입력해주세요';
    final count = int.tryParse(value);
    if (count == null || count <= 0) return '올바른 인원 수를 입력해주세요';
    return null;
  }

  String? validateRole(String? value) =>
      value == null ? '역할을 선택해주세요' : null;

  /// 오늘 날짜인데 시작 시각이 이미 지났을 때.
  String? get startTimeInPastMessage => WorkScheduleUtils.pastStartTimeMessage(
        workDate: selectedDate,
        startTime: selectedStartTime,
      );

  /// 종료 시각이 시작보다 이전/동일일 때.
  String? get endTimeBeforeStartMessage {
    if (selectedStartTime == null || selectedEndTime == null) return null;
    return WorkScheduleUtils.endTimeBeforeStartMessage(
      startTime: _formatTimeOfDay(selectedStartTime!),
      endTime: _formatTimeOfDay(selectedEndTime!),
    );
  }

  /// 드롭다운·날짜·시간 등 Form 외 필수값.
  String? validateSelections() {
    if (address.trim().isEmpty) {
      return '주소를 입력해주세요';
    }
    if (selectedProvinceId == null || selectedDistrictId == null) {
      return '지역(시/도·시/군/구)을 선택해주세요';
    }
    if (selectedDate == null ||
        selectedStartTime == null ||
        selectedRole == null) {
      return '필수 항목을 모두 입력해주세요';
    }
    if (selectedDate != null &&
        selectedStartTime != null &&
        WorkScheduleUtils.isStartTimeInPast(
          workDate: selectedDate!,
          startTime: selectedStartTime!,
        )) {
      return '시작 시간을 확인해 주세요';
    }
    if (endTimeBeforeStartMessage != null) {
      return '종료 시간을 확인해 주세요';
    }
    return null;
  }

  /// 화면 위→아래 순서로 첫 번째 미입력·오류 섹션.
  ShopJobNewFormSection? get firstInvalidSection {
    if (validateTitle(titleController.text) != null) {
      return ShopJobNewFormSection.title;
    }
    if (address.trim().isEmpty) {
      return ShopJobNewFormSection.address;
    }
    if (validateProvince(selectedProvinceId) != null ||
        validateDistrict(selectedDistrictId) != null) {
      return ShopJobNewFormSection.region;
    }
    if (selectedDate == null || selectedStartTime == null) {
      return ShopJobNewFormSection.schedule;
    }
    if (validateAmount(amountController.text) != null) {
      return ShopJobNewFormSection.payment;
    }
    if (validateRequiredCount(requiredCountController.text) != null) {
      return ShopJobNewFormSection.payment;
    }
    if (validateRole(selectedRole) != null) {
      return ShopJobNewFormSection.role;
    }
    if (startTimeInPastMessage != null || endTimeBeforeStartMessage != null) {
      return ShopJobNewFormSection.schedule;
    }
    return null;
  }

  /// [FormState.validate] 실패 시 사용자에게 보여줄 대표 메시지 (validate 재호출 없음).
  String? hintForInvalidForm() {
    if (titleController.text.trim().isEmpty) {
      return '공고 제목을 입력해주세요 (맨 위 항목)';
    }
    if (selectedProvinceId == null || selectedDistrictId == null) {
      return '지역(시/도·시/군/구)을 선택해주세요';
    }
    if (amountController.text.trim().isEmpty) {
      return '금액을 입력해주세요';
    }
    if (requiredCountController.text.trim().isEmpty) {
      return '필요 인원을 입력해주세요';
    }
    if (selectedRole == null) {
      return '역할을 선택해주세요';
    }
    if (startTimeInPastMessage != null) {
      return '시작 시간을 현재 시각 이후로 선택해 주세요';
    }
    if (endTimeBeforeStartMessage != null) {
      return '종료 시간을 시작 시간보다 이후로 선택해 주세요';
    }
    return '입력 내용을 확인해주세요. 빨간 안내가 있는 항목을 수정해 주세요';
  }

  void onAmountChanged(String value) {
    final parsed = int.tryParse(value.replaceAll(',', ''));
    if (parsed != null) {
      final formatted = NumberFormat('#,###').format(parsed);
      amountController.value = TextEditingValue(
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

  void setRole(String? value) {
    selectedRole = value;
    notifyListeners();
  }

  void setWageType(String type) {
    wageType = type;
    notifyListeners();
  }

  /// 급구 유도 화면에서 등록 직전에만 호출.
  void setUrgentForRegistration(bool urgent) {
    isUrgent = urgent;
    notifyListeners();
  }

  bool ensureDateBeforeTime() {
    if (selectedDate != null) return true;
    _m.showMessage('먼저 근무 날짜를 선택해 주세요.');
    return false;
  }

  /// true면 오늘 날짜로 바꾸며 기존 시작 시간이 과거라 초기화됨 (피커에서 안내).
  bool setSelectedDate(DateTime? d) {
    selectedDate = d;
    var clearedPastStart = false;
    if (d != null &&
        selectedStartTime != null &&
        WorkScheduleUtils.isStartTimeInPast(
          workDate: d,
          startTime: selectedStartTime!,
        )) {
      selectedStartTime = null;
      clearedPastStart = true;
    }
    notifyListeners();
    return clearedPastStart;
  }

  /// false면 과거 시각이라 반영하지 않음 (안내는 피커 콜백에서).
  bool setStartTimeIfValid(TimeOfDay t) {
    if (selectedDate != null &&
        WorkScheduleUtils.isStartTimeInPast(
          workDate: selectedDate!,
          startTime: t,
        )) {
      notifyListeners();
      return false;
    }
    selectedStartTime = t;
    notifyListeners();
    return true;
  }

  void setStartTime(TimeOfDay? t) {
    if (t == null) {
      selectedStartTime = null;
      notifyListeners();
      return;
    }
    setStartTimeIfValid(t);
  }

  void setEndTime(TimeOfDay? t) {
    if (t == null) {
      selectedEndTime = null;
      notifyListeners();
      return;
    }
    setEndTimeIfValid(t);
  }

  /// false면 종료 시각이 시작보다 이전/동일이라 반영하지 않음.
  bool setEndTimeIfValid(TimeOfDay t) {
    if (selectedStartTime != null) {
      final start = _formatTimeOfDay(selectedStartTime!);
      final end = _formatTimeOfDay(t);
      if (WorkScheduleUtils.isEndBeforeOrEqualStart(start, end)) {
        notifyListeners();
        return false;
      }
    }
    selectedEndTime = t;
    notifyListeners();
    return true;
  }

  void removeImage(int index) {
    if (index < 0 || index >= selectedImages.length) return;
    selectedImages = List<XFile>.from(selectedImages)..removeAt(index);
    notifyListeners();
  }

  void removeExistingImage(int index) {
    if (index < 0 || index >= existingImageUrls.length) return;
    existingImageUrls = List<String>.from(existingImageUrls)..removeAt(index);
    notifyListeners();
  }

  void applySearchAddress(String newAddress) {
    address = newAddress;
    _trySetRegionFromAddress(newAddress);
    notifyListeners();
  }

  String _formatTimeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _loadFromJob(Job job) {
    editingJobId = job.id;
    titleController.text = job.title;
    descriptionController.text = job.description ?? '';
    amountController.text = NumberFormat('#,###').format(job.amount);
    requiredCountController.text = job.requiredCount.toString();
    isUrgent = job.isUrgent;
    selectedRole = roleOptions.first;
    selectedDate = DateTime.tryParse(job.date);
    selectedStartTime = _parseTime(job.time);
    if (selectedDate != null &&
        selectedStartTime != null &&
        WorkScheduleUtils.isStartTimeInPast(
          workDate: selectedDate!,
          startTime: selectedStartTime!,
        )) {
      selectedStartTime = null;
    }
    selectedEndTime =
        job.endTime != null ? _parseTime(job.endTime!) : null;
    _setRegionFromDistrictId(job.regionId);
    // 기존 이미지 URL 보존 — 수정 시 새 이미지와 합산
    existingImageUrls = List<String>.from(job.images ?? []);
    notifyListeners();
  }

  /// 지난 공고 → 새 등록 폼 채우기(일정·급구는 초기화).
  void _loadFromJobCopy(Job job) {
    isCopyMode = true;
    editingJobId = null;
    isUrgent = false;
    titleController.text = job.title;
    descriptionController.text = job.description ?? '';
    amountController.text = NumberFormat('#,###').format(job.amount);
    requiredCountController.text = job.requiredCount.toString();
    selectedRole = roleOptions.first;
    selectedDate = null;
    selectedStartTime = null;
    selectedEndTime = null;
    _setRegionFromDistrictId(job.regionId);
    if (job.images != null) {
      selectedImages = job.images!.map(XFile.new).toList();
    }
    notifyListeners();
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  void _setRegionFromDistrictId(String districtId) {
    final provinces = RegionHelper.getAllRegions()
        .where((r) => r.type == RegionType.province)
        .toList();
    for (final province in provinces) {
      for (final district in RegionHelper.getDistrictsByProvince(province.id)) {
        if (district.id == districtId) {
          selectedProvinceId = province.id;
          selectedDistrictId = district.id;
          return;
        }
      }
    }
    selectedDistrictId = districtId;
  }

  void _trySetRegionFromAddress(String addr) {
    final provinces =
        RegionHelper.getAllRegions().where((r) => r.type == RegionType.province).toList();

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

      final remaining = 5 - selectedImages.length - existingImageUrls.length;
      if (remaining <= 0) {
        _m.showMessage('이미지는 최대 5장까지 등록할 수 있습니다');
        return;
      }

      final toAdd = images.take(remaining).toList();
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

      if (selectedImages.length + existingImageUrls.length >= 5) {
        _m.showMessage('이미지는 최대 5장까지 등록할 수 있습니다');
        return;
      }

      final size = await image.length();
      if (size > 10 * 1024 * 1024) {
        _m.showMessage('이미지 크기는 10MB 이하여야 합니다');
        return;
      }

      selectedImages = [...selectedImages, image];
      notifyListeners();
    } catch (e) {
      _m.showError('이미지 선택 중 오류가 발생했습니다: $e');
    }
  }

  CreateJobRequest _buildRequest({List<String> imageUrls = const []}) {
    return CreateJobRequest(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      amount: int.parse(amountController.text.replaceAll(',', '')),
      requiredCount: int.parse(requiredCountController.text.trim()),
      provinceId: selectedProvinceId!,
      districtId: selectedDistrictId!,
      address: address,
      detailAddress: detailAddressController.text.trim(),
      workDate: DateFormat('yyyy-MM-dd').format(selectedDate!),
      startTime: _formatTimeOfDay(selectedStartTime!),
      endTime:
          selectedEndTime != null ? _formatTimeOfDay(selectedEndTime!) : null,
      role: selectedRole!,
      wageType: wageType,
      isUrgent: isUrgent,
      imageLocalPaths: selectedImages.map((f) => f.path).toList(),
      imageUrls: imageUrls,
    );
  }

  /// true면 호출 측에서 [Navigator.pop] 등 성공 처리.
  Future<bool> updateJob(GlobalKey<FormState> formKey) async {
    if (editingJobId == null) return false;
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return false;

    final selErr = validateSelections();
    if (selErr != null) {
      _m.showMessage(selErr);
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      // 새로 선택한 이미지가 있으면 R2에 업로드
      List<String> newUrls = const [];
      if (selectedImages.isNotEmpty) {
        newUrls = await _authService.uploadJobImages(selectedImages);
      }
      // 기존 URL + 신규 URL 합산
      final allImageUrls = [...existingImageUrls, ...newUrls];
      final updated = await _jobService.updateJob(
        editingJobId!,
        _buildRequest(imageUrls: allImageUrls),
      );
      _m.showSuccess('「${updated.title}」 공고가 수정되었습니다');
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

  /// true면 호출 측에서 [Navigator.pop] 등 성공 처리.
  Future<bool> submit(GlobalKey<FormState> formKey) async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return false;

    final selErr = validateSelections();
    if (selErr != null) {
      _m.showMessage(selErr);
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      // 이미지가 있으면 R2에 먼저 업로드한 뒤 URL을 공고에 포함
      List<String> imageUrls = const [];
      if (selectedImages.isNotEmpty) {
        imageUrls = await _authService.uploadJobImages(selectedImages);
      }
      final (created, firstJob) =
          await _jobService.createJob(_buildRequest(imageUrls: imageUrls));
      lastCreatedJobId = created.id;
      lastCreatedJobTitle = created.title;
      isFirstJob = firstJob;
      _m.showSuccess('「${created.title}」 공고가 등록되었습니다');
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
