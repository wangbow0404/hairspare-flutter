import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/energy_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/point_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../services/admin_service.dart';
import '../../services/application_service.dart';
import '../../services/auth_service.dart';
import '../../services/challenge_service.dart';
import '../../services/chat_service.dart';
import '../../services/block_service.dart';
import '../../services/contact_violation_service.dart';
import '../../services/education_service.dart';
import '../../services/energy_service.dart';
import '../../services/favorite_service.dart';
import '../../services/job_service.dart';
import '../../services/matching_service.dart';
import '../../services/model_designer_match_service.dart';
import '../../services/model_match_service.dart';
import '../../services/notification_service.dart';
import '../../services/payment_service.dart';
import '../../services/point_service.dart';
import '../../services/portfolio_service.dart';
import '../../services/review_service.dart';
import '../../services/schedule_service.dart';
import '../../services/search_service.dart';
import '../../services/space_rental_service.dart';
import '../../services/spare_service.dart';
import '../../services/spare_designer_profile_service.dart';
import '../../services/subscription_service.dart';
import '../../services/verification_service.dart';
import '../../services/work_check_service.dart';
import '../../utils/api_client.dart';
import '../services/global_messenger_service.dart';

final GetIt sl = GetIt.instance;

/// 서비스·Provider 등록.
void configureDependencies() {
  if (sl.isRegistered<AuthService>()) return;

  sl.registerLazySingleton<GlobalMessengerService>(
    () => GlobalMessengerService(),
  );
  sl.registerLazySingleton<Dio>(() => ApiClient().dio);
  sl.registerLazySingleton<CookieJar>(() => ApiClient().cookieJar);

  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<JobService>(() => JobService());
  sl.registerLazySingleton<ModelMatchService>(() => ModelMatchService());
  sl.registerLazySingleton<MatchingService>(() => MatchingService());
  sl.registerLazySingleton<ModelDesignerMatchService>(
    () => ModelDesignerMatchService(),
  );
  sl.registerLazySingleton<EducationService>(() => EducationService());
  sl.registerLazySingleton<FavoriteService>(() => FavoriteService());
  sl.registerLazySingleton<ScheduleService>(() => ScheduleService());
  sl.registerLazySingleton<EnergyService>(() => EnergyService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<BlockService>(() => BlockService());
  sl.registerLazySingleton<ChatService>(() => ChatService());
  sl.registerLazySingleton<ContactViolationService>(
    () => ContactViolationService(),
  );
  sl.registerLazySingleton<PointService>(() => PointService());
  sl.registerLazySingleton<ApplicationService>(() => ApplicationService());
  sl.registerLazySingleton<ChallengeService>(() => ChallengeService());
  sl.registerLazySingleton<PaymentService>(() => PaymentService());
  sl.registerLazySingleton<PortfolioService>(() => PortfolioService());
  sl.registerLazySingleton<ReviewService>(() => ReviewService());
  sl.registerLazySingleton<SearchService>(() => SearchService());
  sl.registerLazySingleton<SpaceRentalService>(() => SpaceRentalService());
  sl.registerLazySingleton<SpareService>(() => SpareService());
  sl.registerLazySingleton<SpareDesignerProfileService>(
    () => SpareDesignerProfileService(),
  );
  sl.registerLazySingleton<SubscriptionService>(() => SubscriptionService());
  sl.registerLazySingleton<VerificationService>(() => VerificationService());
  sl.registerLazySingleton<WorkCheckService>(() => WorkCheckService());
  sl.registerLazySingleton<AdminService>(() => AdminService());

  sl.registerLazySingleton<ImagePicker>(() => ImagePicker());

  sl.registerLazySingleton<AuthProvider>(
      () => AuthProvider(sl<AuthService>()));
  sl.registerLazySingleton<JobProvider>(() => JobProvider(sl<JobService>()));
  sl.registerLazySingleton<FavoriteProvider>(
      () => FavoriteProvider(sl<FavoriteService>()));
  sl.registerLazySingleton<ScheduleProvider>(
      () => ScheduleProvider(sl<ScheduleService>()));
  sl.registerLazySingleton<EnergyProvider>(
      () => EnergyProvider(sl<EnergyService>()));
  sl.registerLazySingleton<NotificationProvider>(
      () => NotificationProvider(sl<NotificationService>()));
  sl.registerLazySingleton<ChatProvider>(
      () => ChatProvider(sl<ChatService>()));
  sl.registerLazySingleton<PointProvider>(
      () => PointProvider(sl<PointService>()));
}

/// [MaterialApp.router]에 넘기는 인스턴스와 동일한 [GoRouter] (앱 시작 시 한 번 등록).
void registerGoRouter(GoRouter router) {
  if (sl.isRegistered<GoRouter>()) {
    sl.unregister<GoRouter>();
  }
  sl.registerSingleton<GoRouter>(router);
}
