import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/region.dart';
import 'package:hairspare/utils/address_search_helper.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_date_picker.dart';
import '../../utils/region_helper.dart';
import '../../view_models/shop_education_new_view_model.dart';
import 'shop_education_new_input_decoration.dart';

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

/// 교육 등록 폼 전체.
class ShopEducationNewFormContent extends StatelessWidget {
  const ShopEducationNewFormContent({super.key, required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopEducationNewViewModel>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing5),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageUploadSection(context, vm),
            const SizedBox(height: AppTheme.spacing6),
            _buildFieldWithDot(
              label: '교육 제목',
              isRequired: true,
              child: TextFormField(
                controller: vm.titleController,
                decoration:
                    shopEducationNewInputDecoration('예) 여성컷트 전문 교육'),
                validator: vm.validateTitle,
              ),
            ),
            const SizedBox(height: AppTheme.spacing5),
            _buildFieldWithDot(
              label: '교육 설명',
              isRequired: false,
              dotColor: AppTheme.primaryBlue,
              child: TextFormField(
                controller: vm.descriptionController,
                decoration: shopEducationNewInputDecoration(
                  '상세한 교육 내용을 입력해주세요',
                  maxLines: 4,
                ),
                maxLines: 4,
              ),
            ),
            const SizedBox(height: AppTheme.spacing5),
            _buildEducationTypeSection(vm),
            const SizedBox(height: AppTheme.spacing5),
            _buildCategorySelector(vm),
            const SizedBox(height: AppTheme.spacing5),
            if (!vm.isOnline) _buildRegionSelector(context, vm),
            if (!vm.isOnline) const SizedBox(height: AppTheme.spacing5),
            _buildPriceSection(vm),
            const SizedBox(height: AppTheme.spacing5),
            _buildDeadlineSelector(context, vm),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

Widget _buildImageUploadSection(
  BuildContext context,
  ShopEducationNewViewModel vm,
) {
  return Container(
    padding: const EdgeInsets.all(AppTheme.spacing5),
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
              child: const Icon(Icons.add_photo_alternate,
                  size: 16, color: Colors.white),
            ),
            const SizedBox(width: AppTheme.spacing2),
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing3,
                vertical: AppTheme.spacing1,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Text(
                '최대 5장',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
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
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.shadowMd,
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }
            return GestureDetector(
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('갤러리에서 선택'),
                          onTap: () {
                            Navigator.pop(ctx);
                            vm.pickMultiImage();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('카메라로 촬영'),
                          onTap: () {
                            Navigator.pop(ctx);
                            vm.pickImageFromCamera();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.cancel),
                          title: const Text('취소'),
                          onTap: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
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
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 20, color: AppTheme.primaryPurple),
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
          const SizedBox(width: AppTheme.spacing2),
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
      const SizedBox(height: AppTheme.spacing3),
      child,
    ],
  );
}

Widget _buildCategorySelector(ShopEducationNewViewModel vm) {
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
          const SizedBox(width: AppTheme.spacing2),
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
      const SizedBox(height: AppTheme.spacing3),
      DropdownButtonFormField<String>(
        initialValue: vm.selectedCategoryId,
        decoration:
            shopEducationNewInputDecoration('카테고리를 선택하세요'),
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
          initialValue: vm.selectedSubCategory,
          decoration:
              shopEducationNewInputDecoration('세부 카테고리를 선택하세요'),
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
  );
}

Widget _buildRegionSelector(
  BuildContext context,
  ShopEducationNewViewModel vm,
) {
  final provinces = RegionHelper.getAllRegions()
      .where((r) => r.type == RegionType.province)
      .toList();
  final districts = vm.selectedProvinceId != null
      ? RegionHelper.getDistrictsByProvince(vm.selectedProvinceId!)
      : <Region>[];

  return _buildFieldWithIcon(
    icon: Icons.location_on,
    label: '지역',
    isRequired: true,
    gradientColors: const [Color(0xFFEC4899), Color(0xFF9333EA)],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vm.address.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing4,
              vertical: AppTheme.spacing3,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: AppTheme.primaryPurpleLight, width: 2),
            ),
            child: Text(
              vm.address,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppTheme.spacing3),
        ],
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
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
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing3),
        DropdownButtonFormField<String>(
          initialValue: vm.selectedProvinceId,
          decoration: shopEducationNewInputDecoration('시/도를 선택하세요'),
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
            initialValue: vm.selectedDistrictId,
            decoration:
                shopEducationNewInputDecoration('시/군/구를 선택하세요'),
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
            decoration: shopEducationNewInputDecoration('상세 주소를 입력하세요 (선택)'),
            maxLines: 1,
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
          const SizedBox(width: AppTheme.spacing2),
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
      const SizedBox(height: AppTheme.spacing3),
      child,
    ],
  );
}

Widget _buildPriceSection(ShopEducationNewViewModel vm) {
  return Container(
    padding: const EdgeInsets.all(AppTheme.spacing5),
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
              child: const Icon(Icons.attach_money,
                  size: 14, color: Colors.white),
            ),
            const SizedBox(width: AppTheme.spacing2),
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
        const SizedBox(height: AppTheme.spacing4),
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
                  const SizedBox(height: AppTheme.spacing2),
                  TextFormField(
                    controller: vm.priceController,
                    decoration: shopEducationNewInputDecoration(
                      '0 (무료)',
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing3,
                      ),
                    ),
                    keyboardType: TextInputType.number,
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
                  const Text(
                    '최대 인원 (명) *',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  TextFormField(
                    controller: vm.maxApplicantsController,
                    decoration: shopEducationNewInputDecoration(
                      '20',
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing3,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: vm.validateMaxApplicants,
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

Widget _buildEducationTypeSection(ShopEducationNewViewModel vm) {
  return Container(
    padding: const EdgeInsets.all(AppTheme.spacing5),
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
            const SizedBox(width: AppTheme.spacing2),
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
        const SizedBox(height: AppTheme.spacing4),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => vm.setOnline(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: !vm.isOnline
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: !vm.isOnline
                          ? AppTheme.primaryGreen
                          : AppTheme.borderGray,
                      width: !vm.isOnline ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '오프라인',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: !vm.isOnline
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: !vm.isOnline
                            ? AppTheme.primaryGreen
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
                onTap: () => vm.setOnline(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: vm.isOnline
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: vm.isOnline
                          ? AppTheme.primaryBlue
                          : AppTheme.borderGray,
                      width: vm.isOnline ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '온라인',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: vm.isOnline
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: vm.isOnline
                            ? AppTheme.primaryBlue
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing4),
        InkWell(
          onTap: () => vm.toggleUrgent(),
          child: Row(
            children: [
              Checkbox(
                value: vm.isUrgent,
                onChanged: (value) => vm.toggleUrgent(value),
                activeColor: AppTheme.urgentRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
              const SizedBox(width: AppTheme.spacing2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing2,
                  vertical: AppTheme.spacing1,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.urgentRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 16, color: AppTheme.urgentRed),
                    SizedBox(width: AppTheme.spacing1),
                    Text(
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
              const SizedBox(width: AppTheme.spacing2),
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

Widget _buildDeadlineSelector(
  BuildContext context,
  ShopEducationNewViewModel vm,
) {
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
            child: const Icon(Icons.calendar_today,
                size: 14, color: Colors.white),
          ),
          const SizedBox(width: AppTheme.spacing2),
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
      const SizedBox(height: AppTheme.spacing3),
      InkWell(
        onTap: () => shopEducationNewPickDeadline(context, vm),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.primaryPurpleLight, width: 2),
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
                    color: vm.selectedDeadline != null
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(Icons.calendar_today,
                  size: 18, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    ],
  );
}
