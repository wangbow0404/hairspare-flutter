import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../theme/app_theme.dart';
import '../../view_models/shop_education_new_view_model.dart';
import '../../widgets/shop_education_new/shop_education_new_form_content.dart';
import '../../widgets/shop_education_new/shop_education_new_form_sections.dart';
import '../../widgets/shop_job_new/shop_job_new_ui_kit.dart';

/// Shop 교육 등록 화면.
class ShopEducationNewScreen extends StatelessWidget {
  const ShopEducationNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopEducationNewViewModel(
        imagePicker: sl<ImagePicker>(),
      ),
      child: const _ShopEducationNewBody(),
    );
  }
}

class _ShopEducationNewBody extends StatefulWidget {
  const _ShopEducationNewBody();

  @override
  State<_ShopEducationNewBody> createState() => _ShopEducationNewBodyState();
}

class _ShopEducationNewBodyState extends State<_ShopEducationNewBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final Map<ShopEducationNewFormSection, GlobalKey> _sectionKeys = {
    for (final section in ShopEducationNewFormSection.values) section: GlobalKey(),
  };
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFirstInvalid(ShopEducationNewViewModel vm) {
    final section = vm.firstInvalidSection;
    if (section == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _sectionKeys[section]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.12,
      );
    });
  }

  Future<void> _submit() async {
    final vm = context.read<ShopEducationNewViewModel>();
    vm.markValidationAttempted();

    final formState = _formKey.currentState;
    if (formState == null) return;

    final formValid = formState.validate();
    final extraValid = vm.validateExtraFields() == null;

    if (!formValid || !extraValid) {
      setState(() => _autovalidateMode = AutovalidateMode.always);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollToFirstInvalid(vm);
      });
      return;
    }

    final ok = await vm.submit();
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopEducationNewViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const ShopJobNewAppBar(title: '교육 등록'),
      body: ShopEducationNewFormContent(
        formKey: _formKey,
        scrollController: _scrollController,
        autovalidateMode: _autovalidateMode,
        sectionKeys: _sectionKeys,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing2,
          AppTheme.spacing4,
          AppTheme.spacing4,
        ),
        child: ShopJobNewPrimaryButton(
          label: '교육 등록하기',
          isLoading: vm.isLoading,
          backgroundColor: AppTheme.stitchPrimaryContainer,
          onPressed: vm.isLoading ? null : _submit,
        ),
      ),
    );
  }
}
