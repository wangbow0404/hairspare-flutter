import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/router/app_router.dart';
import 'package:hairspare/main.dart';
import 'package:hairspare/providers/auth_provider.dart';
import 'package:hairspare/utils/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ApiClient().init()은 path_provider(getApplicationDocumentsDirectory)를
  // 거치는데, 이 실제(미모킹) 플랫폼 채널 호출을 testWidgets 콜백 본문 안에서
  // 직접 await하면 응답이 영원히 오지 않아 테스트가 멈춘다(hang). setUp에서
  // 실행하면 정상적으로 완료된다 — 다른 라우터 테스트들
  // (model_route_redirect_test.dart 등)과 동일한 패턴.
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

  testWidgets('MyApp builds with GoRouter', (WidgetTester tester) async {
    final router = AppRouter.createRouter(sl<AuthProvider>());

    await tester.pumpWidget(MyApp(router: router));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
