import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/router/app_routes.dart';
import 'package:hairspare/core/router/app_router.dart';
import 'package:hairspare/core/shell/model_tab_shell.dart';
import 'package:hairspare/main.dart';
import 'package:hairspare/mocks/mock_auth_data.dart';
import 'package:hairspare/providers/auth_provider.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:hairspare/widgets/model_bottom_nav_bar.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ko_KR');
  });

  // ApiClient().init()은 path_provider(getApplicationDocumentsDirectory)를
  // 거치는데, 이 실제(미모킹) 플랫폼 채널 호출을 testWidgets 콜백 본문 안에서
  // 직접 await하면 응답이 영원히 오지 않아 테스트가 멈춘다(hang). setUp에서
  // 실행하면 정상적으로 완료된다.
  setUp(() async {
    dotenv.testLoad(fileInput: '');
    await ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
  });

  Future<void> pumpModelApp(WidgetTester tester) async {
    final auth = sl<AuthProvider>();
    await auth.setUser(MockAuthData.modelUser());
    final router = AppRouter.createRouter(auth);
    registerGoRouter(router);
    await tester.pumpWidget(MyApp(router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('모델 스케줄 탭이 에러 없이 렌더링된다', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpModelApp(tester);

    appRouter.go(AppRoutes.modelSchedule);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.takeException(), isNull);
    expect(find.text('스케줄 관리'), findsOneWidget);
    expect(find.byType(ModelTabShell), findsOneWidget);
    expect(find.byType(ModelBottomNavBar), findsOneWidget);
  });
}
