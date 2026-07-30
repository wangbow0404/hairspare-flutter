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

  setUp(() async {
    dotenv.testLoad(fileInput: '');
    await ApiClient().init(
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
    // 공고 섹션들이 StaggeredFadeIn(순차 페이드인, 최대 지연 180ms)으로
    // 감싸여 있어, 그 안의 Future.delayed 타이머가 모두 발화할 시간만큼
    // 프레임을 더 진행해야 테스트 종료 시 "Timer is still pending" 오류가
    // 나지 않는다.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('공고정보'), findsOneWidget);
    expect(find.text('모델매칭'), findsOneWidget);
  });
}
