import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/region.dart';
import 'package:hairspare/utils/address_search_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/region_helper.dart';
import '../../utils/app_date_picker.dart';
import '../../utils/work_schedule_utils.dart';
import '../../view_models/shop_job_new_view_model.dart';
import '../common/app_network_image.dart';
import 'shop_job_new_form_sections.dart';
import 'shop_job_new_input_decoration.dart';
import 'shop_job_new_ui_kit.dart';

/// 피커 닫힌 뒤 포커스·스크롤이 맨 위(설명 필드)로 튀는 현상 방지.
Future<T?> shopJobNewRunPicker<T>(
  ScrollController? scrollController,
  Future<T?> Function() showPicker,
) async {
  FocusManager.instance.primaryFocus?.unfocus();
  final savedOffset = scrollController != null && scrollController.hasClients
      ? scrollController.offset
      : null;

  final result = await showPicker();

  if (savedOffset != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController == null || !scrollController.hasClients) return;
      final max = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(savedOffset.clamp(0.0, max));
    });
  }
  FocusManager.instance.primaryFocus?.unfocus();
  return result;
}

Future<void> shopJobNewPickDate(
  BuildContext context,
  ShopJobNewViewModel vm, {
  ScrollController? scrollController,
}) async {
  final picked = await shopJobNewRunPicker<DateTime?>(
    scrollController,
    () => showAppDatePicker(
      context,
      initialDate: vm.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 5)),
    ),
  );
  if (picked == null) return;
  final clearedPastStart = vm.setSelectedDate(picked);
  if (!clearedPastStart) return;
  vm.markValidationAttempted();
  if (!context.mounted) return;
  shopJobNewShowSchedulePickerMessage(
    context,
    WorkScheduleUtils.pastStartAfterDateChangeMessage,
  );
}

Future<void> shopJobNewPickStartTime(
  BuildContext context,
  ShopJobNewViewModel vm, {
  ScrollController? scrollController,
}) async {
  if (!vm.ensureDateBeforeTime()) return;

  final now = DateTime.now();
  var initialTime = vm.selectedStartTime ?? TimeOfDay.fromDateTime(now);
  if (WorkScheduleUtils.isSameCalendarDay(vm.selectedDate!, now) &&
      WorkScheduleUtils.isStartTimeInPast(
        workDate: vm.selectedDate!,
        startTime: initialTime,
        now: now,
      )) {
    initialTime = TimeOfDay.fromDateTime(now);
  }

  final picked = await shopJobNewRunPicker<TimeOfDay?>(
    scrollController,
    () => showTimePicker(
      context: context,
      initialTime: initialTime,
    ),
  );
  if (picked == null) return;
  if (vm.setStartTimeIfValid(picked)) return;
  vm.markValidationAttempted();
  if (!context.mounted) return;
  shopJobNewShowSchedulePickerMessage(
    context,
    WorkScheduleUtils.pastStartTimeUserMessage,
  );
}

Future<void> shopJobNewPickEndTime(
  BuildContext context,
  ShopJobNewViewModel vm, {
  ScrollController? scrollController,
}) async {
  final picked = await shopJobNewRunPicker<TimeOfDay?>(
    scrollController,
    () => showTimePicker(
      context: context,
      initialTime: vm.selectedEndTime ?? TimeOfDay.now(),
    ),
  );
  if (picked == null) return;
  if (vm.setEndTimeIfValid(picked)) return;
  vm.markValidationAttempted();
  if (!context.mounted) return;
  shopJobNewShowSchedulePickerMessage(
    context,
    WorkScheduleUtils.endBeforeStartUserMessage,
  );
}

void shopJobNewShowSchedulePickerMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// 공고 등록 폼 전체 (이미지 ~ 역할).
class ShopJobNewFormContent extends StatelessWidget {
  const ShopJobNewFormContent({
    super.key,
    required this.formKey,
    this.scrollController,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.sectionKeys,
  });

  final GlobalKey<FormState> formKey;
  final ScrollController? scrollController;
  final AutovalidateMode autovalidateMode;
  final Map<ShopJobNewFormSection, GlobalKey>? sectionKeys;

  void _revalidateForm() {
    formKey.currentState?.validate();
  }

  Widget _sectionAnchor(ShopJobNewFormSection section, Widget child) {
    final key = sectionKeys?[section];
    if (key == null) return child;
    return KeyedSubtree(key: key, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopJobNewViewModel>();
    return SingleChildScrollView(
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing6,
      ),
      child: Form(
        key: formKey,
        autovalidateMode: autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 업로드 섹션
            _buildImageUploadSection(context, vm),
            const SizedBox(height: AppTheme.spacing6),
            // 공고 제목
            _sectionAnchor(
              ShopJobNewFormSection.title,
              _buildFieldWithDot(
                vm,
                label: '공고 제목',
                isRequired: true,
                hasError: vm.hasTitleError,
                child: TextFormField(
                  controller: vm.titleController,
                  decoration: shopJobNewInputDecoration('예) 스텝 급구합니다'),
                  validator: vm.validateTitle,
                  onChanged: (_) => _revalidateForm(),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing5),
            // 공고 설명
            _buildFieldWithDot(
              vm,
              label: '공고 설명',
              isRequired: false,
              dotColor: AppTheme.primaryBlue,
              child: TextFormField(
                controller: vm.descriptionController,
                decoration: shopJobNewInputDecoration(
                  '상세한 설명을 입력해주세요',
                  maxLines: 4,
                ),
                maxLines: 4,
                scrollPadding: const EdgeInsets.only(bottom: 120),
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ),
            const SizedBox(height: AppTheme.spacing5),
            // 주소 섹션
            _sectionAnchor(
              ShopJobNewFormSection.address,
              _buildAddressSection(context, vm),
            ),
            const SizedBox(height: AppTheme.spacing5),
            // 지역 선택 (세분화)
            _sectionAnchor(
              ShopJobNewFormSection.region,
              _buildRegionSelector(vm),
            ),
            const SizedBox(height: AppTheme.spacing5),
            // 일정 섹션
            _sectionAnchor(
              ShopJobNewFormSection.schedule,
              _buildScheduleSection(context, vm, scrollController),
            ),
            const SizedBox(height: AppTheme.spacing5),
            // 급여 및 인원 섹션
            _sectionAnchor(
              ShopJobNewFormSection.payment,
              _buildPaymentSection(vm),
            ),
            const SizedBox(height: AppTheme.spacing5),
            // 역할 선택
            _sectionAnchor(
              ShopJobNewFormSection.role,
              _buildRoleSelector(vm),
            ),
            const SizedBox(height: AppTheme.spacing4),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(
    BuildContext context,
    ShopJobNewViewModel vm,
  ) {
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              ShopJobNewFieldLabel(label: '이미지'),
              Spacer(),
              Text(
                '최대 5장',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppTheme.spacing3,
              mainAxisSpacing: AppTheme.spacing3,
              childAspectRatio: 1,
            ),
            itemCount: () {
                final total = vm.existingImageUrls.length + vm.selectedImages.length;
                return total + (total < 5 ? 1 : 0);
              }(),
            itemBuilder: (context, index) {
              final existingCount = vm.existingImageUrls.length;
              final newCount = vm.selectedImages.length;
              final total = existingCount + newCount;

              if (index < existingCount) {
                // 이미 저장된 R2 이미지 표시
                final url = vm.existingImageUrls[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: AppNetworkImage(imageUrl: url, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => vm.removeExistingImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.spacing1),
                          decoration: const BoxDecoration(
                            color: AppTheme.urgentRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (index < total) {
                // 새로 선택한 로컬 이미지 표시
                final fileIndex = index - existingCount;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      child: kIsWeb
                          ? Image.network(
                              vm.selectedImages[fileIndex].path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.file(
                              File(vm.selectedImages[fileIndex].path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => vm.removeImage(fileIndex),
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.spacing1),
                          decoration: const BoxDecoration(
                            color: AppTheme.urgentRed,
                            shape: BoxShape.circle,
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
                                vm.pickMultiImage();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('카메라로 촬영'),
                              onTap: () {
                                Navigator.pop(context);
                                vm.pickImageFromCamera();
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
                      border: Border.all(
                        color: AppTheme.borderGray,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryPurpleLight,
                                AppTheme.primaryPinkLight,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing2),
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

  Widget _buildFieldWithDot(
    ShopJobNewViewModel vm, {
    required String label,
    required Widget child,
    bool isRequired = false,
    bool hasError = false,
    Color dotColor = AppTheme.primaryPurple,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShopJobNewFieldLabel(
          label: label,
          isRequired: isRequired,
          hasError: hasError,
        ),
        const SizedBox(height: AppTheme.spacing2),
        child,
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context, ShopJobNewViewModel vm) {
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
            const SizedBox(width: AppTheme.spacing2),
            Text(
              '주소',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: vm.hasAddressError
                    ? AppTheme.urgentRed
                    : AppTheme.textPrimary,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: vm.hasAddressError
                    ? AppTheme.urgentRed
                    : AppTheme.primaryPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing3),
        // 기본 주소 표시 및 검색 버튼
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing4,
                  vertical: AppTheme.spacing3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(
                    color: vm.hasAddressError
                        ? AppTheme.urgentRed
                        : AppTheme.primaryPurpleLight,
                    width: 2,
                  ),
                ),
                child: Text(
                  vm.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: vm.hasAddressError
                        ? AppTheme.urgentRed
                        : AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacing2),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await AddressSearchHelper.pickAddress(
                  context,
                  initialDetailAddress: vm.detailAddressController.text,
                );
                if (result != null && result['address'] != null) {
                  vm.applySearchAddress(result['address']!);
                }
              },
              icon: const Icon(Icons.search, size: 18),
              label: const Text('검색'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing3),
        // 상세 주소 입력
        TextFormField(
          controller: vm.detailAddressController,
          decoration: shopJobNewInputDecoration('상세 주소를 입력하세요 (선택)'),
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildRegionSelector(ShopJobNewViewModel vm) {
    final provinces = RegionHelper.getAllRegions()
        .where((r) => r.type == RegionType.province)
        .toList();
    final districts = vm.selectedProvinceId != null
        ? RegionHelper.getDistrictsByProvince(vm.selectedProvinceId!)
        : <Region>[];

    return _buildFieldWithIcon(
      vm,
      icon: Icons.map,
      label: '지역',
      isRequired: true,
      hasError: vm.hasRegionError,
      gradientColors: const [Color(0xFFEC4899), Color(0xFF9333EA)],
      child: Column(
        children: [
          // 시/도 선택
          DropdownButtonFormField<String>(
            key: ValueKey('province-${vm.selectedProvinceId}'),
            initialValue: vm.selectedProvinceId,
            decoration: shopJobNewInputDecoration('시/도를 선택하세요'),
            items: provinces.map((province) {
              return DropdownMenuItem(
                value: province.id,
                child: Text(province.name),
              );
            }).toList(),
            onChanged: (value) {
              vm.setProvinceId(value);
              _revalidateForm();
            },
            validator: vm.validateProvince,
          ),
          if (vm.selectedProvinceId != null) ...[
            const SizedBox(height: AppTheme.spacing3),
            DropdownButtonFormField<String>(
              key: ValueKey('district-${vm.selectedDistrictId}'),
              initialValue: vm.selectedDistrictId,
              decoration: shopJobNewInputDecoration('시/군/구를 선택하세요'),
              items: districts.map((district) {
                return DropdownMenuItem(
                  value: district.id,
                  child: Text(district.name),
                );
              }).toList(),
              onChanged: (value) {
                vm.setDistrictId(value);
                _revalidateForm();
              },
              validator: vm.validateDistrict,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldWithIcon(
    ShopJobNewViewModel vm, {
    required IconData icon,
    required String label,
    required Widget child,
    bool isRequired = false,
    bool hasError = false,
    required List<Color> gradientColors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShopJobNewFieldLabel(
          label: label,
          isRequired: isRequired,
          hasError: hasError,
        ),
        const SizedBox(height: AppTheme.spacing2),
        child,
      ],
    );
  }

  Widget _buildScheduleSection(
    BuildContext context,
    ShopJobNewViewModel vm,
    ScrollController? scrollController,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing5),
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
        border: Border.all(
          color: vm.hasScheduleSectionError
              ? AppTheme.urgentRed
              : AppTheme.blue100,
        ),
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
                child: const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                '일정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: vm.hasScheduleSectionError
                      ? AppTheme.urgentRed
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          // 날짜
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShopJobNewSubFieldLabel(
                label: '날짜',
                isRequired: true,
                hasError: vm.hasDateError,
              ),
              const SizedBox(height: AppTheme.spacing2),
              InkWell(
                onTap: () => shopJobNewPickDate(
                  context,
                  vm,
                  scrollController: scrollController,
                ),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: shopJobNewPickerBorderColor(
                        hasError: vm.hasDateError,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          vm.selectedDate != null
                              ? DateFormat(
                                  'yyyy년 M월 d일 (E)',
                                  'ko_KR',
                                ).format(vm.selectedDate!)
                              : '날짜를 선택하세요',
                          style: TextStyle(
                            color: vm.selectedDate != null
                                ? AppTheme.textPrimary
                                : vm.hasDateError
                                    ? AppTheme.urgentRed
                                    : AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          // 시간
          Builder(
            builder: (context) {
              final startTimePast = vm.startTimeInPastMessage;
              final endTimeError = vm.endTimeBeforeStartMessage;
              final startHasError = vm.hasStartTimeEmptyError ||
                  vm.hasStartTimePastError;
              return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShopJobNewSubFieldLabel(
                      label: '시작 시간',
                      isRequired: true,
                      hasError: startHasError,
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    InkWell(
                      onTap: () => shopJobNewPickStartTime(
                        context,
                        vm,
                        scrollController: scrollController,
                      ),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                          border: Border.all(
                            color: shopJobNewPickerBorderColor(
                              hasError: startHasError,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                vm.selectedStartTime != null
                                    ? vm.selectedStartTime!.format(context)
                                    : '시간 선택',
                                style: TextStyle(
                                  color: vm.selectedStartTime != null
                                      ? AppTheme.textPrimary
                                      : startHasError
                                          ? AppTheme.urgentRed
                                          : AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.access_time,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (startTimePast != null && vm.showValidationErrors) ...[
                      const SizedBox(height: AppTheme.spacing1),
                      Text(
                        '현재 시각 이후로 선택해 주세요',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.urgentRed,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShopJobNewSubFieldLabel(
                      label: '종료 시간',
                      hasError: vm.hasEndTimeError,
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    InkWell(
                      onTap: () => shopJobNewPickEndTime(
                        context,
                        vm,
                        scrollController: scrollController,
                      ),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                          border: Border.all(
                            color: shopJobNewPickerBorderColor(
                              hasError: vm.hasEndTimeError,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                vm.selectedEndTime != null
                                    ? vm.selectedEndTime!.format(context)
                                    : '시간 선택',
                                style: TextStyle(
                                  color: vm.selectedEndTime != null
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.access_time,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (endTimeError != null && vm.showValidationErrors) ...[
                      const SizedBox(height: AppTheme.spacing1),
                      Text(
                        endTimeError,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.urgentRed,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(ShopJobNewViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing5),
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
        border: Border.all(
          color: vm.hasPaymentSectionError
              ? AppTheme.urgentRed
              : AppTheme.yellow200,
        ),
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
                child: const Icon(
                  Icons.attach_money,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              Text(
                '급여 및 인원',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: vm.hasPaymentSectionError
                      ? AppTheme.urgentRed
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
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
              const SizedBox(height: AppTheme.spacing2),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => vm.setWageType('hourly'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing3,
                        ),
                        decoration: BoxDecoration(
                          color: vm.wageType == 'hourly'
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                          border: Border.all(
                            color: vm.wageType == 'hourly'
                                ? AppTheme.yellow400
                                : AppTheme.borderGray,
                            width: vm.wageType == 'hourly' ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '시급',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: vm.wageType == 'hourly'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: vm.wageType == 'hourly'
                                  ? AppTheme.yellow600
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  Expanded(
                    child: InkWell(
                      onTap: () => vm.setWageType('daily'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacing3,
                        ),
                        decoration: BoxDecoration(
                          color: vm.wageType == 'daily'
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusLg,
                          ),
                          border: Border.all(
                            color: vm.wageType == 'daily'
                                ? AppTheme.yellow400
                                : AppTheme.borderGray,
                            width: vm.wageType == 'daily' ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '일급',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: vm.wageType == 'daily'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: vm.wageType == 'daily'
                                  ? AppTheme.yellow600
                                  : AppTheme.textSecondary,
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
          const SizedBox(height: AppTheme.spacing4),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShopJobNewSubFieldLabel(
                      label: '금액 (${vm.wageType == 'hourly' ? '시' : '일'}급 원)',
                      isRequired: true,
                      hasError: vm.hasAmountError,
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: vm.amountController,
                      decoration: shopJobNewInputDecoration(
                        '100,000',
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing3,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: vm.validateAmount,
                      onChanged: (value) {
                        vm.onAmountChanged(value);
                        _revalidateForm();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShopJobNewSubFieldLabel(
                      label: '필요 인원 (명)',
                      isRequired: true,
                      hasError: vm.hasRequiredCountError,
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: vm.requiredCountController,
                      decoration: shopJobNewInputDecoration(
                        '1',
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing3,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: vm.validateRequiredCount,
                      onChanged: (_) => _revalidateForm(),
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

  Widget _buildRoleSelector(ShopJobNewViewModel vm) {
    return _buildFieldWithIcon(
      vm,
      icon: Icons.person,
      label: '역할',
      isRequired: true,
      hasError: vm.hasRoleError,
      gradientColors: const [Color(0xFF10B981), Color(0xFF14B8A6)],
      child: DropdownButtonFormField<String>(
        key: ValueKey('role-${vm.selectedRole}'),
        initialValue: vm.selectedRole,
        decoration: shopJobNewInputDecoration('선택하세요'),
        items: vm.roleOptions.map((role) {
          return DropdownMenuItem(value: role, child: Text(role));
        }).toList(),
        onChanged: (value) {
          vm.setRole(value);
          _revalidateForm();
        },
        validator: vm.validateRole,
      ),
    );
  }

}
