import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/chat_provider.dart';
import 'package:hairspare/providers/notification_provider.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:hairspare/view_models/shop_home_view_model.dart';
import 'package:hairspare/widgets/shop_home/shop_home_scroll_view.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    dotenv.testLoad(fileInput: '');
    ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('ShopHomeScrollView builds loaded dashboard and category area', (
    tester,
  ) async {
    final scrollController = ScrollController();
    final vm =
        ShopHomeViewModel(notificationProvider: sl<NotificationProvider>())
          ..isLoading = false
          ..activeJobCount = 3
          ..pendingApplicantsCount = 2
          ..todayScheduleCount = 1;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ShopHomeViewModel>.value(value: vm),
          ChangeNotifierProvider<ChatProvider>.value(value: sl<ChatProvider>()),
          ChangeNotifierProvider<NotificationProvider>.value(
            value: sl<NotificationProvider>(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ShopHomeScrollView(scrollController: scrollController),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.bySemanticsLabel('HairSpare'), findsOneWidget);
    expect(find.text('인력별'), findsOneWidget);
    expect(find.text('스케줄표'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(find.text('활성 공고'), findsOneWidget);
    expect(find.text('대기 지원자'), findsOneWidget);

    scrollController.dispose();
  });
}
