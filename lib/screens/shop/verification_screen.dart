import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../view_models/shop_verification_view_model.dart';
import '../../widgets/shop_verification/shop_verification_body.dart';

/// Shop 인증 관리 화면 (사업자 인증, 본인인증, 대리인 인증).
class ShopVerificationScreen extends StatelessWidget {
  const ShopVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopVerificationViewModel(),
      child: const _ShopVerificationScaffold(),
    );
  }
}

class _ShopVerificationScaffold extends StatefulWidget {
  const _ShopVerificationScaffold();

  @override
  State<_ShopVerificationScaffold> createState() =>
      _ShopVerificationScaffoldState();
}

class _ShopVerificationScaffoldState extends State<_ShopVerificationScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ShopVerificationViewModel>().loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopVerificationViewModel>();

    if (vm.isLoadingInitial) {
      return const Scaffold(
        appBar: SharedAppBar(title: '인증 관리'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(title: '인증 관리'),
      body: ShopVerificationBody(),
    );
  }
}
