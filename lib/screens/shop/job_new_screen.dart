import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../theme/app_theme.dart';
import '../../models/job.dart';
import '../../view_models/shop_job_new_view_model.dart';
import '../../core/router/route_extras.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/shop_job_new/shop_job_new_form_content.dart';
import '../../widgets/shop_job_new/shop_job_new_form_sections.dart';
import '../../widgets/shop_job_new/shop_job_new_ui_kit.dart';

/// Shop 공고 등록 화면.
class ShopJobNewScreen extends StatelessWidget {
  const ShopJobNewScreen({super.key, this.jobToEdit, this.jobToCopy});

  final Job? jobToEdit;
  final Job? jobToCopy;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopJobNewViewModel(
        imagePicker: sl<ImagePicker>(),
        jobToEdit: jobToEdit,
        jobToCopy: jobToCopy,
      ),
      child: const _ShopJobNewBody(),
    );
  }
}

/// Provider 하위에서만 [ShopJobNewViewModel]에 접근.
class _ShopJobNewBody extends StatefulWidget {
  const _ShopJobNewBody();

  @override
  State<_ShopJobNewBody> createState() => _ShopJobNewBodyState();
}

class _ShopJobNewBodyState extends State<_ShopJobNewBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final Map<ShopJobNewFormSection, GlobalKey> _sectionKeys = {
    for (final section in ShopJobNewFormSection.values) section: GlobalKey(),
  };
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFirstInvalid(ShopJobNewViewModel vm) {
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
    final vm = context.read<ShopJobNewViewModel>();
    final messenger = sl<GlobalMessengerService>();
    final formState = _formKey.currentState;

    if (formState == null) {
      messenger.showError('폼을 불러오지 못했습니다. 다시 시도해주세요');
      return;
    }

    if (vm.isEditing) {
      if (!formState.validate()) {
        vm.markValidationAttempted();
        setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
        messenger.showMessage(vm.hintForInvalidForm() ?? '입력 내용을 확인해주세요');
        _scrollToFirstInvalid(vm);
        return;
      }
      final selErr = vm.validateSelections();
      if (selErr != null) {
        vm.markValidationAttempted();
        messenger.showMessage(selErr);
        _scrollToFirstInvalid(vm);
        return;
      }
      final ok = await vm.updateJob(_formKey);
      if (!mounted || !ok) return;
      Navigator.pop(context, true);
      return;
    }

    if (!formState.validate()) {
      vm.markValidationAttempted();
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      messenger.showMessage(vm.hintForInvalidForm() ?? '입력 내용을 확인해주세요');
      _scrollToFirstInvalid(vm);
      return;
    }

    final selErr = vm.validateSelections();
    if (selErr != null) {
      vm.markValidationAttempted();
      messenger.showMessage(selErr);
      _scrollToFirstInvalid(vm);
      return;
    }

    if (!mounted) return;

    final submitted = await ShellNavigation.pushShopJobUrgentUpsell(
          context,
          ShopJobUrgentUpsellExtra(
            viewModel: vm,
            formKey: _formKey,
          ),
        ) ??
        false;

    if (!mounted || !submitted) return;
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopJobNewViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: ShopJobNewAppBar(
        title: vm.isEditing
            ? '공고 수정'
            : vm.isCopyMode
                ? '공고 복사 등록'
                : '공고 등록',
      ),
      body: ShopJobNewFormContent(
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
          label: vm.isEditing ? '수정 완료' : '공고 등록하기',
          isLoading: vm.isLoading,
          onPressed: vm.isLoading ? null : _submit,
        ),
      ),
    );
  }
}
