import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../theme/app_theme.dart';
import '../../view_models/shop_space_form_view_model.dart';
import '../../widgets/shop_job_new/shop_job_new_ui_kit.dart';
import '../../widgets/shop_space_form/shop_space_form_content.dart';

/// 샵 공간 수정 화면.
class ShopSpaceEditScreen extends StatelessWidget {
  const ShopSpaceEditScreen({
    super.key,
    required this.spaceId,
  });

  final String spaceId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopSpaceFormViewModel(
        imagePicker: sl<ImagePicker>(),
        editingSpaceId: spaceId,
      ),
      child: _ShopSpaceEditBody(spaceId: spaceId),
    );
  }
}

class _ShopSpaceEditBody extends StatefulWidget {
  const _ShopSpaceEditBody({required this.spaceId});

  final String spaceId;

  @override
  State<_ShopSpaceEditBody> createState() => _ShopSpaceEditBodyState();
}

class _ShopSpaceEditBodyState extends State<_ShopSpaceEditBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<ShopSpaceFormViewModel>();
      final ok = await vm.loadSpace(widget.spaceId);
      if (!mounted || ok) return;
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<ShopSpaceFormViewModel>();
    final messenger = sl<GlobalMessengerService>();
    final formState = _formKey.currentState;
    if (formState == null) {
      messenger.showError('폼을 불러오지 못했습니다. 다시 시도해주세요');
      return;
    }

    if (!formState.validate()) {
      vm.markValidationAttempted();
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      messenger.showMessage(vm.hintForInvalidForm() ?? '입력 내용을 확인해주세요');
      return;
    }

    final facErr = vm.validateFacilities();
    if (facErr != null) {
      vm.markValidationAttempted();
      messenger.showMessage(facErr);
      return;
    }

    final schedErr = vm.validateSchedule();
    if (schedErr != null) {
      vm.markValidationAttempted();
      messenger.showMessage(schedErr);
      return;
    }

    final ok = await vm.submitUpdate();
    if (!mounted || !ok) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopSpaceFormViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: ShopJobNewAppBar(title: '공간 수정'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const ShopJobNewAppBar(title: '공간 수정'),
      body: ShopSpaceFormContent(
        formKey: _formKey,
        scrollController: _scrollController,
        autovalidateMode: _autovalidateMode,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppTheme.spacing4,
          AppTheme.spacing2,
          AppTheme.spacing4,
          AppTheme.spacing4,
        ),
        child: ShopJobNewPrimaryButton(
          label: '수정 완료',
          isLoading: vm.isSubmitting,
          onPressed: vm.isSubmitting ? null : _submit,
        ),
      ),
    );
  }
}
