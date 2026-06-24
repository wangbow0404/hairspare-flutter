import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/energy_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../view_models/spare_profile_view_model.dart';
import '../../widgets/customer_service_section.dart';
import '../../widgets/model_profile/model_profile_menu_section.dart';
import '../../widgets/spare_profile/spare_profile_header.dart';
import '../../widgets/spare_profile/spare_profile_identity_section.dart';
import '../../widgets/spare_profile/spare_profile_logout_section.dart';

/// 모델 마이 탭 — 모델 전용 프로필 화면.
///
/// 헤더·인증 섹션은 스페어와 공유하고, 메뉴만 모델에 맞게 별도 구성.
class ModelProfileScreen extends StatefulWidget {
  const ModelProfileScreen({super.key});

  @override
  State<ModelProfileScreen> createState() => _ModelProfileScreenState();
}

class _ModelProfileScreenState extends State<ModelProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SpareProfileViewModel(
        imagePicker: sl<ImagePicker>(),
        authService: sl<AuthService>(),
        authProvider: Provider.of<AuthProvider>(context, listen: false),
        energyProvider: Provider.of<EnergyProvider>(context, listen: false),
        scheduleProvider: Provider.of<ScheduleProvider>(context, listen: false),
      ),
      child: const _ModelProfileBody(),
    );
  }
}

class _ModelProfileBody extends StatefulWidget {
  const _ModelProfileBody();

  @override
  State<_ModelProfileBody> createState() => _ModelProfileBodyState();
}

class _ModelProfileBodyState extends State<_ModelProfileBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<SpareProfileViewModel>().loadInitial());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + 70;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: Column(
        children: [
          const SpareProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: const Column(
                children: [
                  SpareProfileIdentitySection(),
                  ModelProfileMenuSection(),
                  SpareProfileLogoutSection(),
                  CustomerServiceSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
