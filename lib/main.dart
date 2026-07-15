import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/job_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/energy_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/point_provider.dart';
import 'package:go_router/go_router.dart';

import 'config/business_config.dart';
import 'core/di/service_locator.dart'
    show configureDependencies, registerGoRouter, sl;
import 'core/router/app_routes.dart';
import 'core/services/global_messenger_service.dart';
import 'core/router/app_router.dart';
import 'utils/api_client.dart';
import 'utils/env_config.dart';
import 'theme/app_theme.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  await dotenv.load(fileName: 'assets/env/app.env');

  final kakaoKey = EnvConfig.kakaoNativeAppKey;
  if (kakaoKey.isEmpty) {
    assert(() {
      debugPrint(
        '[HairSpare] KAKAO_NATIVE_APP_KEY 가 비어 있어 카카오 SDK 초기화를 건너뜁니다. '
        '카카오 로그인을 쓰려면 --dart-define=KAKAO_NATIVE_APP_KEY=... 를 설정하세요.',
      );
      return true;
    }());
  } else {
    kakao.KakaoSdk.init(nativeAppKey: kakaoKey);
  }

  if (!EnvConfig.isGoogleSignInConfigured) {
    assert(() {
      debugPrint(
        '[HairSpare] GOOGLE_WEB_CLIENT_ID / GOOGLE_IOS_CLIENT_ID 가 비어 있어 '
        '구글 로그인을 쓰려면 --dart-define=GOOGLE_WEB_CLIENT_ID=... '
        '--dart-define=GOOGLE_IOS_CLIENT_ID=... 를 설정하세요.',
      );
      return true;
    }());
  }
  
  // API 클라이언트 초기화를 가장 먼저 (Dio _dio 초기화 필요)
  await ApiClient().init(
    onSessionExpiredMessage: (message) {
      sl<GlobalMessengerService>().showError(message);
    },
    onSessionExpired: () async {
      await sl<AuthProvider>().logout();
      appRouter.go(AppRoutes.roleSelect);
    },
  );
  configureDependencies();
  await BusinessConfig.load(sl<Dio>());
  final router = AppRouter.createRouter(sl<AuthProvider>());
  registerGoRouter(router);
  await sl<AuthProvider>().checkAuth();

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<AuthProvider>()),
        ChangeNotifierProvider.value(value: sl<JobProvider>()),
        ChangeNotifierProvider.value(value: sl<FavoriteProvider>()),
        ChangeNotifierProvider.value(value: sl<ScheduleProvider>()),
        ChangeNotifierProvider.value(value: sl<EnergyProvider>()),
        ChangeNotifierProvider.value(value: sl<NotificationProvider>()),
        ChangeNotifierProvider.value(value: sl<ChatProvider>()),
        ChangeNotifierProvider.value(value: sl<PointProvider>()),
      ],
      child: MaterialApp.router(
        title: 'HairSpare',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: sl<GlobalMessengerService>().messengerKey,
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ko', 'KR'),
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
