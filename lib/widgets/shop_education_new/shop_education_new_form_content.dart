import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/region.dart';
import '../../theme/app_theme.dart';
import '../../utils/address_search_helper.dart';
import '../../utils/app_date_picker.dart';
import '../../utils/region_helper.dart';
import '../../view_models/shop_education_new_view_model.dart';
import '../shop_job_new/shop_job_new_input_decoration.dart';
import '../shop_job_new/shop_job_new_ui_kit.dart';
import 'shop_education_new_form_sections.dart';

Future<void> shopEducationNewPickDeadline(
  BuildContext context,
  ShopEducationNewViewModel vm,
) async {
  final picked = await showAppDatePicker(
    context,
    initialDate:
        vm.selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (picked != null) vm.setDeadline(picked);
}

/// 교육 등록 폼 — 공간/공고 등록과 동일 Stitch 톤.
class ShopEducationNewFormContent extends StatelessWidget {
  const ShopEducationNewFormContent({
    super.key,
    required this.formKey,
    required this.scrollController,
    this.autovalidateMode = AutovalidateMode.disabled,
    required this.sectionKeys,
  });

  final GlobalKey<FormState> formKey;
  final ScrollController scrollController;
  final AutovalidateMode autovalidateMode;
  final Map<ShopEducationNewFormSection, GlobalKey> sectionKeys;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopEducationNewViewModel>();

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
          KeyedSubtree(
            key: sectionKeys[ShopEducationNewFormSection.title],
            child: Column(
              children: [
                _EducationImageSection(vm: vm),
                const SizedBox(height: AppTheme.spacing4),
                ShopJobNewSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShopJobNewFieldLabel(
                        label: '교육 제목',
                        isRequired: true,
                      ),
                      const SizedBox(height: AppTheme.spacing3),
                      TextFormField(
                        controller: vm.titleController,
                        decoration:
                            shopJobNewInputDecoration('예) 여성컷트 전문 교육'),
                        validator: vm.validateTitle,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      const ShopJobNewFieldLabel(label: '교육 설명'),
                      const SizedBox(height: AppTheme.spacing3),
                      TextFormField(
                        controller: vm.descriptionController,
                        maxLines: 4,
                        decoration: shopJobNewInputDecoration(
                          '상세한 교육 내용을 입력해주세요',
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          _EducationTypeSection(vm: vm),
          const SizedBox(height: AppTheme.spacing4),
          KeyedSubtree(
            key: sectionKeys[ShopEducationNewFormSection.category],
            child: ShopJobNewSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShopJobNewFieldLabel(label: '카테고리', isRequired: true),
                  const SizedBox(height: AppTheme.spacing3),
                  DropdownButtonFormField<String>(
                    key: ValueKey('edu-category-${vm.selectedCategoryId}'),
                    initialValue: vm.selectedCategoryId,
                    decoration: shopJobNewInputDecoration('카테고리를 선택하세요'),
                    items: ShopEducationNewViewModel.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: vm.setCategoryId,
                    validator: (value) =>
                        value == null ? '카테고리를 선택해주세요' : null,
                  ),
                  if (vm.selectedCategoryId != null &&
                      vm.availableSubCategories.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacing3),
                    DropdownButtonFormField<String>(
                      key: ValueKey('edu-sub-${vm.selectedSubCategory}'),
                      initialValue: vm.selectedSubCategory,
                      decoration:
                          shopJobNewInputDecoration('세부 카테고리를 선택하세요'),
                      items: vm.availableSubCategories.map((subCategory) {
                        return DropdownMenuItem(
                          value: subCategory,
                          child: Text(subCategory),
                        );
                      }).toList(),
                      onChanged: vm.setSubCategory,
                      validator: (value) =>
                          value == null ? '세부 카테고리를 선택해주세요' : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!vm.isOnline) ...[
            const SizedBox(height: AppTheme.spacing4),
            KeyedSubtree(
              key: sectionKeys[ShopEducationNewFormSection.region],
              child: _EducationRegionSection(vm: vm),
            ),
          ],
          const SizedBox(height: AppTheme.spacing4),
          KeyedSubtree(
            key: sectionKeys[ShopEducationNewFormSection.priceAndApplicants],
            child: ShopJobNewSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShopJobNewFieldLabel(label: '가격 및 인원'),
                  const SizedBox(height: AppTheme.spacing4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ShopJobNewSubFieldLabel(
                              label: '가격 (원)',
                              isRequired: true,
                            ),
                            const SizedBox(height: AppTheme.spacing2),
                            TextFormField(
                              controller: vm.priceController,
                              keyboardType: TextInputType.number,
                              decoration: shopJobNewInputDecoration('0 (무료)'),
                              validator: vm.validatePrice,
                              onChanged: vm.onPriceChanged,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ShopJobNewSubFieldLabel(
                              label: '최대 인원 (명)',
                              isRequired: true,
                            ),
                            const SizedBox(height: AppTheme.spacing2),
                            TextFormField(
                              controller: vm.maxApplicantsController,
                              keyboardType: TextInputType.number,
                              decoration: shopJobNewInputDecoration('20'),
                              validator: vm.validateMaxApplicants,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          KeyedSubtree(
            key: sectionKeys[ShopEducationNewFormSection.deadline],
            child: ShopJobNewSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShopJobNewFieldLabel(label: '마감일', isRequired: true),
                  const SizedBox(height: AppTheme.spacing3),
                  InkWell(
                    onTap: () => shopEducationNewPickDeadline(context, vm),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundGray,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: vm.deadlineError != null
                              ? AppTheme.urgentRed
                              : AppTheme.borderGray,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              vm.selectedDeadline != null
                                  ? DateFormat('yyyy년 M월 d일', 'ko_KR')
                                      .format(vm.selectedDeadline!)
                                  : '마감일을 선택하세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: vm.selectedDeadline != null
                                    ? AppTheme.stitchTextPrimary
                                    : AppTheme.stitchTextSecondary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: AppTheme.stitchTextSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (vm.deadlineError != null) ...[
                    const SizedBox(height: AppTheme.spacing2),
                    Padding(
                      padding: const EdgeInsets.only(left: AppTheme.spacing2),
                      child: Text(
                        vm.deadlineError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.urgentRed,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationImageSection extends StatelessWidget {
  const _EducationImageSection({required this.vm});

  final ShopEducationNewViewModel vm;

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.stitchTextSecondary,
                ),
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
            itemCount: vm.selectedImages.length +
                (vm.selectedImages.length < 5 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < vm.selectedImages.length) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      child: Image.file(
                        vm.selectedImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => vm.removeImage(index),
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
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    color: AppTheme.backgroundGray,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: AppTheme.stitchPrimary,
                      ),
                      SizedBox(height: AppTheme.spacing1),
                      Text(
                        '추가',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.stitchPrimary,
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

  void _showImagePicker(BuildContext context, ShopEducationNewViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(ctx);
                vm.pickMultiImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(ctx);
                vm.pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationTypeSection extends StatelessWidget {
  const _EducationTypeSection({required this.vm});

  final ShopEducationNewViewModel vm;

  @override
  Widget build(BuildContext context) {
    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShopJobNewFieldLabel(label: '교육 유형', isRequired: true),
          const SizedBox(height: AppTheme.spacing3),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TypeOptionButton(
                    label: '오프라인',
                    isSelected: !vm.isOnline,
                    onTap: () => vm.setOnline(false),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: _TypeOptionButton(
                    label: '온라인',
                    isSelected: vm.isOnline,
                    onTap: () => vm.setOnline(true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          InkWell(
            onTap: () => vm.toggleUrgent(),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing1),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: vm.isUrgent,
                      onChanged: vm.toggleUrgent,
                      activeColor: AppTheme.urgentRed,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.urgentRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '🚀 급구',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.urgentRed,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing2),
                  const Expanded(
                    child: Text(
                      '급구 교육으로 등록',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.stitchTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeOptionButton extends StatelessWidget {
  const _TypeOptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.stitchTextPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing3),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.stitchTextSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EducationRegionSection extends StatelessWidget {
  const _EducationRegionSection({required this.vm});

  final ShopEducationNewViewModel vm;

  @override
  Widget build(BuildContext context) {
    final provinces = RegionHelper.getAllRegions()
        .where((r) => r.type == RegionType.province)
        .toList();
    final districts = vm.selectedProvinceId != null
        ? RegionHelper.getDistrictsByProvince(vm.selectedProvinceId!)
        : <Region>[];

    return ShopJobNewSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShopJobNewFieldLabel(label: '지역', isRequired: true),
          const SizedBox(height: AppTheme.spacing3),
          if (vm.address.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing4,
                vertical: AppTheme.spacing3,
              ),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Text(
                vm.address,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.stitchTextPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppTheme.spacing3),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await AddressSearchHelper.pickAddress(
                  context,
                  initialDetailAddress: vm.detailAddressController.text,
                );
                if (result != null && result['address'] != null) {
                  vm.applySearchAddress(
                    result['address']!,
                    detail: result['detailAddress'],
                  );
                }
              },
              icon: const Icon(Icons.search, size: 18),
              label: Text(vm.address.isEmpty ? '주소 검색' : '주소 변경'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.stitchPrimary,
                side: const BorderSide(color: AppTheme.stitchPrimary),
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacing3,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
          DropdownButtonFormField<String>(
            key: ValueKey('edu-province-${vm.selectedProvinceId}'),
            initialValue: vm.selectedProvinceId,
            decoration: shopJobNewInputDecoration('시/도를 선택하세요'),
            items: provinces.map((province) {
              return DropdownMenuItem(
                value: province.id,
                child: Text(province.name),
              );
            }).toList(),
            onChanged: vm.setProvinceId,
            validator: !vm.isOnline
                ? (value) => value == null ? '시/도를 선택해주세요' : null
                : null,
          ),
          if (vm.selectedProvinceId != null) ...[
            const SizedBox(height: AppTheme.spacing3),
            DropdownButtonFormField<String>(
              key: ValueKey('edu-district-${vm.selectedDistrictId}'),
              initialValue: vm.selectedDistrictId,
              decoration: shopJobNewInputDecoration('시/군/구를 선택하세요'),
              items: districts.map((district) {
                return DropdownMenuItem(
                  value: district.id,
                  child: Text(district.name),
                );
              }).toList(),
              onChanged: vm.setDistrictId,
              validator: !vm.isOnline
                  ? (value) => value == null ? '시/군/구를 선택해주세요' : null
                  : null,
            ),
          ],
          if (vm.address.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacing3),
            TextFormField(
              controller: vm.detailAddressController,
              decoration: shopJobNewInputDecoration('상세 주소를 입력하세요 (선택)'),
            ),
          ],
        ],
      ),
    );
  }
}
