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
import '../../widgets/spare_profile/spare_profile_scroll_view.dart';

/// 스페어 마이 탭 — [SpareProfileViewModel] + [SpareProfileScrollView].
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      child: const _SpareProfileBody(),
    );
  }
}

class _SpareProfileBody extends StatefulWidget {
  const _SpareProfileBody();

  @override
  State<_SpareProfileBody> createState() => _SpareProfileBodyState();
}

class _SpareProfileBodyState extends State<_SpareProfileBody> {
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
    return const Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        bottom: false,
        child: SpareProfileScrollView(),
      ),
    );
  }
}
