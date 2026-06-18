import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/core/router/app_router.dart';
import 'package:hairspare/core/shell/main_tab_shell.dart';
import 'package:hairspare/core/shell/model_tab_shell.dart';
import 'package:hairspare/main.dart';
import 'package:hairspare/mocks/mock_auth_data.dart';
import 'package:hairspare/providers/auth_provider.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:hairspare/widgets/bottom_nav_bar.dart';
import 'package:hairspare/widgets/model_bottom_nav_bar.dart';

/// 3단계 검증: 모델 계정은 전용 /model 셸로, 일반 스페어는 공통 셸로 라우팅된다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAppForUser(WidgetTester tester, dynamic user) async {
    dotenv.testLoad(fileInput: '');
    ApiClient().init(
      onSessionExpired: () async {},
      onSessionExpiredMessage: (_) {},
    );
    configureDependencies();
    final auth = sl<AuthProvider>();
    await auth.setUser(user);
    final router = AppRouter.createRouter(auth);
    await tester.pumpWidget(MyApp(router: router));
    // 스페어 홈은 배너 자동스크롤 타이머가 있어 pumpAndSettle이 끝나지 않으므로
    // 리다이렉트가 적용될 만큼만 고정 프레임을 진행한다.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('모델 계정은 ModelTabShell(모델 전용 하단탭)로 진입한다', (tester) async {
    await pumpAppForUser(tester, MockAuthData.modelUser());

    expect(find.byType(ModelTabShell), findsOneWidget);
    expect(find.byType(ModelBottomNavBar), findsOneWidget);
    // 옛 스페어 공통 셸로 새지 않아야 한다.
    expect(find.byType(MainTabShell), findsNothing);
  });

  testWidgets('일반 스페어 계정은 공통 MainTabShell로 진입한다', (tester) async {
    await pumpAppForUser(tester, MockAuthData.spareUser());

    expect(find.byType(MainTabShell), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(find.byType(ModelTabShell), findsNothing);
  });
}
