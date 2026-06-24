import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/chat_provider.dart';
import 'package:hairspare/providers/favorite_provider.dart';
import 'package:hairspare/providers/job_provider.dart';
import 'package:hairspare/providers/notification_provider.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:hairspare/widgets/spare_home/spare_home_scroll_view.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

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

  testWidgets('SpareHomeScrollView builds quick menu when jobs not loading', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<JobProvider>.value(value: sl<JobProvider>()),
          ChangeNotifierProvider<FavoriteProvider>.value(
            value: sl<FavoriteProvider>(),
          ),
          ChangeNotifierProvider<ChatProvider>.value(value: sl<ChatProvider>()),
          ChangeNotifierProvider<NotificationProvider>.value(
            value: sl<NotificationProvider>(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SpareHomeScrollView(scrollController: scrollController),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('공고별'), findsOneWidget);
    expect(find.text('모델매칭'), findsOneWidget);
  });
}
