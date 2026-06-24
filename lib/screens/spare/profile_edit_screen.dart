import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../view_models/profile_edit_view_model.dart';
import '../../widgets/common/app_screen_safe_area.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/spare_profile_edit/spare_profile_edit_avatar.dart';
import '../../widgets/spare_profile_edit/spare_profile_edit_basic_fields.dart';
import '../../widgets/spare_profile_edit/spare_profile_edit_link_cards.dart';
import '../../widgets/spare_profile_edit/spare_profile_edit_matching_fields.dart';
import '../../widgets/stitch/stitch_sticky_bottom_bar.dart';

/// 스페어·디자이너 프로필 수정.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final ProfileEditViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileEditViewModel(
      authProvider: sl<AuthProvider>(),
    )..loadInitial();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileEditViewModel>.value(
      value: _viewModel,
      child: const _ProfileEditBody(),
    );
  }
}

class _ProfileEditBody extends StatelessWidget {
  const _ProfileEditBody();

  Future<void> _save(BuildContext context) async {
    final vm = context.read<ProfileEditViewModel>();
    final ok = await vm.save();
    if (ok && context.mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileEditViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundGray,
            appBar: SpareSubpageAppBar(
              title: '프로필 수정',
              showToolbarActions: false,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userId = vm.userId ?? 'guest';

        return Scaffold(
          backgroundColor: AppTheme.backgroundGray,
          appBar: SpareSubpageAppBar(
            title: '프로필 수정',
            showToolbarActions: false,
            trailingActions: [
              TextButton(
                onPressed: vm.isSaving ? null : () => _save(context),
                child: Text(
                  '저장',
                  style: TextStyle(
                    color: vm.isSaving
                        ? AppTheme.textTertiary
                        : AppTheme.stitchPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          body: AppScreenSafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacing4,
                      AppTheme.spacing4,
                      AppTheme.spacing4,
                      AppTheme.spacing2,
                    ),
                    children: [
                      SpareProfileEditAvatar(userId: userId),
                      const SizedBox(height: AppTheme.spacing5),
                      const SpareProfileEditBasicFields(),
                      const SizedBox(height: AppTheme.spacing3),
                      const SpareProfileEditMatchingFields(),
                      const SizedBox(height: AppTheme.spacing3),
                      const SpareProfileEditLinkCards(),
                      const SizedBox(height: AppTheme.spacing4),
                    ],
                  ),
                ),
                StitchStickyBottomBar(
                  primaryLabel: '저장하기',
                  isLoading: vm.isSaving,
                  onPrimary: () => _save(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
