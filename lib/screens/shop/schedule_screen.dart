import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/schedule.dart';
import '../../theme/app_theme.dart';
import '../../utils/schedule_cancel_flow.dart';
import '../../utils/schedule_cancellation_policy.dart';
import '../../view_models/shop_schedule_view_model.dart';
import '../../widgets/shop/shop_screen_safe_area.dart';
import '../../widgets/shop_schedule/shop_schedule_app_bar.dart';
import '../../widgets/shop_schedule/shop_schedule_modals.dart';
import '../../widgets/shop_schedule/shop_schedule_scroll_content.dart';

/// Shop용 스케줄 화면. 상태는 [ShopScheduleViewModel], 본문은 `lib/widgets/shop_schedule/` 위젯으로 분리.
class ShopScheduleScreen extends StatefulWidget {
  const ShopScheduleScreen({super.key});

  @override
  State<ShopScheduleScreen> createState() => _ShopScheduleScreenState();
}

class _ShopScheduleScreenState extends State<ShopScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShopScheduleViewModel(
        scheduleService: sl(),
        spareService: sl(),
      )..loadInitial(),
      child: const _ShopScheduleScaffold(),
    );
  }
}

class _ShopScheduleScaffold extends StatelessWidget {
  const _ShopScheduleScaffold();

  Future<void> _startShopCancel(
    BuildContext context,
    ShopScheduleViewModel vm,
    String scheduleId,
  ) async {
    vm.dismissThumbsUpModal();

    Schedule? schedule;
    for (final s in vm.schedules) {
      if (s.id == scheduleId) {
        schedule = s;
        break;
      }
    }
    if (schedule == null) return;

    await ScheduleCancelFlow.requestCancel(
      context: context,
      schedule: schedule,
      actor: CancellationActor.shop,
      onSuccess: () => vm.loadData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopScheduleViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: ShopScreenSafeArea(
        child: Column(
          children: [
            ShopScheduleAppBar(tierInfo: vm.tierInfo),
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: vm.loadData,
                    child: const CustomScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: ShopScheduleScrollContent(),
                        ),
                      ],
                    ),
                  ),
                  if (vm.showThumbsUpModal && vm.selectedSchedule != null)
                    ShopScheduleThumbsUpModal(
                      schedule: vm.selectedSchedule!,
                      onConfirm: vm.handleThumbsUpConfirm,
                      onCancel: vm.dismissThumbsUpModal,
                      onCancelSchedule: (scheduleId) =>
                          _startShopCancel(context, vm, scheduleId),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
