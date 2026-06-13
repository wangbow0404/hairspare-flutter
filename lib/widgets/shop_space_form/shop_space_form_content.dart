import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/region.dart';
import '../../models/space_rental.dart';
import '../../theme/app_theme.dart';
import '../../utils/region_helper.dart';
import '../../view_models/shop_space_form_view_model.dart';
import '../shop_job_new/shop_job_new_input_decoration.dart';
import '../shop_job_new/shop_job_new_ui_kit.dart';
import 'shop_space_closed_dates_section.dart';
import 'shop_space_min_hours_field.dart';
import 'shop_space_operating_schedule_section.dart';

/// 공간 등록·수정 폼 본문 (공고 등록 UI 키트 재사용).
class ShopSpaceFormContent extends StatelessWidget {
  const ShopSpaceFormContent({
    super.key,
    required this.formKey,
    required this.scrollController,
    required this.autovalidateMode,
  });

  final GlobalKey<FormState> formKey;
  final ScrollController scrollController;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopSpaceFormViewModel>();

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing4,
          AppTheme.spacing6,
        ),
        children: [
          _ImageSection(vm: vm),
          const SizedBox(height: AppTheme.spacing4),
          ShopJobNewSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShopJobNewFieldLabel(
                  label: '주소',
                  isRequired: true,
                  hasError: vm.showValidationErrors &&
                      vm.validateAddress(vm.addressController.text) != null,
                ),
                const SizedBox(height: AppTheme.spacing3),
                TextFormField(
                  controller: vm.addressController,
                  decoration: shopJobNewInputDecoration('주소를 입력하세요'),
                  validator: vm.validateAddress,
                ),
                const SizedBox(height: AppTheme.spacing4),
                const ShopJobNewFieldLabel(label: '상세 주소'),
                const SizedBox(height: AppTheme.spacing3),
                TextFormField(
                  controller: vm.detailAddressController,
                  decoration: shopJobNewInputDecoration('상세 주소를 입력하세요 (선택)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _RegionSection(vm: vm),
          const SizedBox(height: AppTheme.spacing4),
          ShopJobNewSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShopJobNewFieldLabel(
                  label: '시간당 가격 (원)',
                  isRequired: true,
                  hasError: vm.showValidationErrors &&
                      vm.validatePrice(vm.priceController.text) != null,
                ),
                const SizedBox(height: AppTheme.spacing3),
                TextFormField(
                  controller: vm.priceController,
                  keyboardType: TextInputType.number,
                  decoration: shopJobNewInputDecoration('30,000'),
                  validator: vm.validatePrice,
                  onChanged: vm.formatPriceInput,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          ShopSpaceOperatingScheduleSection(scrollController: scrollController),
          const SizedBox(height: AppTheme.spacing4),
          const ShopSpaceMinHoursField(),
          const SizedBox(height: AppTheme.spacing4),
          ShopSpaceClosedDatesSection(scrollController: scrollController),
          if (vm.isEditing) ...[
            const SizedBox(height: AppTheme.spacing4),
            _StatusSection(vm: vm),
          ],
          const SizedBox(height: AppTheme.spacing4),
          _FacilitiesSection(vm: vm),
          const SizedBox(height: AppTheme.spacing4),
          ShopJobNewSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShopJobNewFieldLabel(label: '공간 설명'),
                const SizedBox(height: AppTheme.spacing3),
                TextFormField(
                  controller: vm.descriptionController,
                  maxLines: 4,
                  decoration: shopJobNewInputDecoration('공간에 대한 설명을 입력하세요 (선택)', maxLines: 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          ShopJobNewSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShopJobNewFieldLabel(label: '이용 안내'),
                const SizedBox(height: AppTheme.spacing3),
                TextFormField(
                  controller: vm.usageNotesController,
                  maxLines: 3,
                  decoration: shopJobNewInputDecoration('예약·취소·이용 규칙 등 (선택)', maxLines: 3),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          ShopJobNewSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShopJobNewFieldLabel(label: '연락처'),
                const SizedBox(height: AppTheme.spacing3),
                TextFormField(
                  controller: vm.contactPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: shopJobNewInputDecoration('02-1234-5678 (선택)'),
                ),
                const SizedBox(height: AppTheme.spacing4),
                const ShopJobNewFieldLabel(label: '지하철 안내'),
                const SizedBox(height: AppTheme.spacing3),
                TextFormField(
                  controller: vm.subwayInfoController,
                  decoration: shopJobNewInputDecoration('역·출구·도보 시간 (선택)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.vm});

  final ShopSpaceFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    final totalCount = vm.selectedImages.length + vm.existingImageUrls.length;
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
            itemCount: totalCount + (totalCount < 5 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < vm.existingImageUrls.length) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: Image.network(
                    vm.existingImageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.backgroundGray,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                );
              }
              final fileIndex = index - vm.existingImageUrls.length;
              if (fileIndex < vm.selectedImages.length) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      child: Image.file(
                        vm.selectedImages[fileIndex],
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
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return GestureDetector(
                onTap: () => _showImagePicker(context, vm),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderGray, width: 2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryBlue),
                      SizedBox(height: AppTheme.spacing1),
                      Text(
                        '추가',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context, ShopSpaceFormViewModel vm) {
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
          ],
        ),
      ),
    );
  }
}

class _RegionSection extends StatelessWidget {
  const _RegionSection({required this.vm});

  final ShopSpaceFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    final provinces = RegionHelper.getAllRegions()
        .where((r) => r.type == RegionType.province)
        .toList();
    final districts = vm.selectedProvinceId != null
        ? RegionHelper.getDistrictsByProvince(vm.selectedProvinceId!)
        : <Region>[];
    final districtErr =
        vm.showValidationErrors ? vm.validateDistrict() : null;

    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShopJobNewFieldLabel(
            label: '지역',
            isRequired: true,
            hasError: districtErr != null,
          ),
          const SizedBox(height: AppTheme.spacing3),
          DropdownButtonFormField<String>(
            key: ValueKey('province-${vm.selectedProvinceId}'),
            initialValue: vm.selectedProvinceId,
            decoration: shopJobNewInputDecoration('시/도를 선택하세요'),
            items: provinces
                .map(
                  (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                )
                .toList(),
            onChanged: vm.setProvince,
          ),
          if (vm.selectedProvinceId != null) ...[
            const SizedBox(height: AppTheme.spacing3),
            DropdownButtonFormField<String>(
              key: ValueKey('district-${vm.selectedDistrictId}'),
              initialValue: vm.selectedDistrictId,
              decoration: shopJobNewInputDecoration('시/군/구를 선택하세요'),
              items: districts
                  .map(
                    (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                  )
                  .toList(),
              onChanged: vm.setDistrict,
              validator: (_) => vm.validateDistrict(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({required this.vm});

  final ShopSpaceFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShopJobNewFieldLabel(label: '상태'),
          const SizedBox(height: AppTheme.spacing3),
          DropdownButtonFormField<SpaceStatus>(
            key: ValueKey('status-${vm.selectedStatus.name}'),
            initialValue: vm.selectedStatus,
            decoration: shopJobNewInputDecoration('상태 선택'),
            items: SpaceStatus.values.map((status) {
              final label = switch (status) {
                SpaceStatus.available => '예약 가능',
                SpaceStatus.booked => '예약됨',
                SpaceStatus.unavailable => '사용 불가',
              };
              return DropdownMenuItem(value: status, child: Text(label));
            }).toList(),
            onChanged: (v) {
              if (v != null) vm.setStatus(v);
            },
          ),
        ],
      ),
    );
  }
}

class _FacilitiesSection extends StatelessWidget {
  const _FacilitiesSection({required this.vm});

  final ShopSpaceFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    final err = vm.showValidationErrors ? vm.validateFacilities() : null;
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShopJobNewFieldLabel(
            label: '시설',
            isRequired: true,
            hasError: err != null,
          ),
          const SizedBox(height: AppTheme.spacing3),
          Wrap(
            spacing: AppTheme.spacing2,
            runSpacing: AppTheme.spacing2,
            children: ShopSpaceFormViewModel.facilityOptions.map((facility) {
              final selected = vm.selectedFacilities.contains(facility);
              return FilterChip(
                label: Text(facility),
                selected: selected,
                onSelected: (_) => vm.toggleFacility(facility),
                selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                checkmarkColor: AppTheme.primaryBlue,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                ),
                side: BorderSide(
                  color: selected ? AppTheme.primaryBlue : AppTheme.borderGray,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              );
            }).toList(),
          ),
          if (err != null) ...[
            const SizedBox(height: AppTheme.spacing2),
            Text(
              err,
              style: const TextStyle(fontSize: 12, color: AppTheme.urgentRed),
            ),
          ],
        ],
      ),
    );
  }
}
