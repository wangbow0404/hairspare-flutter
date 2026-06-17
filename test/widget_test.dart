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

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('MyApp builds with GoRouter', (WidgetTester tester) async {
    dotenv.testLoad(fileInput: '');
    ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
    final router = AppRouter.createRouter(sl<AuthProvider>());

    await tester.pumpWidget(MyApp(router: router));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
