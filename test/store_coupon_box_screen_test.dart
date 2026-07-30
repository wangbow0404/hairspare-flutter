import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairspare/core/di/service_locator.dart';
import 'package:hairspare/providers/store_coupon_provider.dart';
import 'package:hairspare/screens/spare/store_coupon_box_screen.dart';
import 'package:hairspare/utils/api_client.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('보유 쿠폰 목록을 보여주고 받기를 누르면 받음으로 바뀐다', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<StoreCouponProvider>.value(
            value: sl<StoreCouponProvider>(),
          ),
        ],
        child: const MaterialApp(home: StoreCouponBoxScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('스토어 첫 구매 5,000원 할인'), findsOneWidget);

    await tester.tap(find.text('받기').first);
    await tester.pump();

    expect(find.text('받음'), findsOneWidget);
  });
}
