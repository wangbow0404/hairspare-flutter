/// 중앙 라우트 경로 (GoRouter).
abstract final class AppRoutes {
  static const roleSelect = '/';
  static const spareLogin = '/spare/login';
  static const shopLogin = '/shop/login';
  static const spareSignup = '/spare/signup';
  static const spareSignupSuccess = '/spare/signup/success';
  static const shopSignup = '/shop/signup';
  static const spareFindId = '/spare/find-id';
  static const spareFindPassword = '/spare/find-password';
  static const shopFindPassword = '/shop/find-password';

  static const spareHome = '/spare/home';
  static const spareMessages = '/spare/home/messages';
  static const spareSearch = '/spare/home/search';
  static const spareNotifications = '/spare/home/notifications';
  static const sparePayment = '/spare/payment';
  static const spareFavorites = '/spare/favorites';
  static const spareProfile = '/spare/profile';
  static const shopHome = '/shop/home';
  static const shopMessages = '/shop/home/messages';
  static const shopSearch = '/shop/home/search';
  static const shopNotifications = '/shop/home/notifications';
  static const shopPayment = '/shop/payment';
  static const shopFavorites = '/shop/favorites';
  static const shopProfile = '/shop/profile';

  // 모델 전용 탭 (스페어 하위 타입: 헤어모델). 2026-06 구조 분리 진행 중.
  // 탭 구성: 홈 · 메시지 · 스케줄 · 마이 (현재 동작과 동일하게 유지).
  static const modelHome = '/model/home';
  static const modelMessages = '/model/messages';
  static const modelSchedule = '/model/schedule';
  static const modelProfile = '/model/profile';

  static const admin = '/admin';
  static const adminUsers = '/admin/users';
  static const adminJobs = '/admin/jobs';
  static const adminPayments = '/admin/payments';
  static const adminEnergy = '/admin/energy';
  static const adminNoshow = '/admin/noshow';
  static const adminCheckin = '/admin/checkin';

  static String adminUserDetail(String userId) => '/admin/users/$userId';
  static String adminJobDetail(String jobId) => '/admin/jobs/$jobId';
  static String adminPaymentDetail(String paymentId) => '/admin/payments/$paymentId';
}
