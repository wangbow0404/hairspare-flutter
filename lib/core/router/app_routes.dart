/// 중앙 라우트 경로 (GoRouter).
abstract final class AppRoutes {
  static const roleSelect = '/';
  static const autoLoginSplash = '/auto-login-splash';
  static const privacyPolicy = '/privacy';
  static const spareLogin = '/spare/login';
  static const shopLogin = '/shop/login';
  static const spareSignup = '/spare/signup';
  static const spareSignupProfessional = '/spare/signup/professional';
  static const spareSignupModel = '/spare/signup/model';
  static const spareSignupSuccess = '/spare/signup/success';
  static const spareSignupSuccessVerification =
      '/spare/signup/success/verification';
  static const shopSignup = '/shop/signup';
  static const shopSignupSuccess = '/shop/signup/success';
  static const spareFindId = '/spare/find-id';
  static const spareFindPassword = '/spare/find-password';
  static const shopFindPassword = '/shop/find-password';

  static const spareHome = '/spare/home';
  static const spareHomeJobs = '/spare/home/jobs';
  static const spareHomePoints = '/spare/home/points';
  static const spareHomeModelMatch = '/spare/home/model_match';
  static const spareHomeWorkCheck = '/spare/home/work_check';
  static const spareHomeRegionSelect = '/spare/home/region_select';
  static const spareHomeEducation = '/spare/home/education';
  static const spareHomeEducationDetail = '/spare/home/education/detail';
  static const spareHomeChallenge = '/spare/home/challenge';
  static const spareHomeEnergy = '/spare/home/energy';
  static String spareMessageChat(String chatId) =>
      '/spare/home/messages/chat/$chatId';
  static const spareWork = '/spare/work';
  static String spareWorkChat(String chatId) => '/spare/work/chat/$chatId';
  /// @deprecated Use [spareWork]
  static const sparePayment = '/spare/work';
  static String shopMessageChat(String chatId) =>
      '/shop/home/messages/chat/$chatId';
  static String modelMessageChat(String chatId) =>
      '/model/home/messages/chat/$chatId';
  static const spareHomeModelMatchSwipe = '/spare/home/model_match/swipe';
  static const spareMessages = '/spare/home/messages';
  static const spareSearch = '/spare/home/search';
  static const spareNotifications = '/spare/home/notifications';

  static String spareHomeJobDetail(String jobId) => '/spare/home/job/$jobId';
  static String spareHomeSpaceDetail(String spaceId) =>
      '/spare/home/space/$spaceId';

  /// 공고별 목록 — [filter], [sort](JobsListSortMode.name), [searchQuery](q),
  /// [premium](하이패스 프리셋).
  static String spareHomeJobsPath({
    String? filter,
    String? sort,
    String? searchQuery,
    bool premium = false,
  }) {
    final query = <String, String>{};
    if (filter != null && filter.isNotEmpty) {
      query['filter'] = filter;
    }
    if (sort != null && sort.isNotEmpty) {
      query['sort'] = sort;
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query['q'] = searchQuery;
    }
    if (premium) {
      query['premium'] = '1';
    }
    if (query.isEmpty) return spareHomeJobs;
    return Uri(path: spareHomeJobs, queryParameters: query).toString();
  }

  static String sparePaymentChat(String chatId) => spareWorkChat(chatId);
  static const spareFavorites = '/spare/favorites';
  static String spareFavoritesJobDetail(String jobId) =>
      '/spare/favorites/job/$jobId';
  static const spareProfile = '/spare/profile';
  static const spareProfilePortfolio = '/spare/profile/portfolio';
  static const spareProfileSettings = '/spare/profile/settings';
  static const spareProfileEdit = '/spare/profile/edit';
  static const spareProfileChallenge = '/spare/profile/challenge';
  static const spareProfileSubscriptions = '/spare/profile/subscriptions';
  static const spareProfileEnergy = '/spare/profile/energy';
  static const spareProfileWorkCheck = '/spare/profile/work_check';
  static const spareProfileApplications = '/spare/profile/applications';
  static const spareProfileSpaceBookings = '/spare/profile/space_bookings';
  static const spareProfilePayment = '/spare/profile/payment';
  static const spareProfileReferral = '/spare/profile/referral';
  static const spareProfileVerification = '/spare/profile/verification';

  static const shopHome = '/shop/home';
  static const shopHomeSpares = '/shop/home/spares';
  static const shopHomeSchedule = '/shop/home/schedule';
  static const shopHomePoints = '/shop/home/points';
  static const shopHomeSpaces = '/shop/home/spaces';
  static const shopHomeEducation = '/shop/home/education';
  static const shopHomeMatchingTips = '/shop/home/matching_tips';
  static const shopHomeChallenge = '/shop/home/challenge';
  static const shopHomeModelMatch = '/shop/home/model_match';
  static const shopHomeModelMatchSwipe = '/shop/home/model_match/swipe';
  static String shopHomeSpareDetail(String spareId) =>
      '/shop/home/shop_spare/$spareId';
  static const shopMessages = '/shop/home/messages';
  static const shopSearch = '/shop/home/search';
  static const shopNotifications = '/shop/home/notifications';
  static const shopPayment = '/shop/payment';
  static const shopFavorites = '/shop/favorites';
  static const shopProfile = '/shop/profile';
  static const shopProfilePortfolio = '/shop/profile/portfolio';
  static const shopProfileVip = '/shop/profile/vip';
  static const shopProfileSchedule = '/shop/profile/schedule';
  static const shopProfileJobs = '/shop/profile/jobs';
  static const shopProfileSpaces = '/shop/profile/spaces';
  static const shopProfileApplicants = '/shop/profile/applicants';
  static const shopProfilePayment = '/shop/profile/payment';
  static const shopProfileVerification = '/shop/profile/verification';
  static const shopProfileSettings = '/shop/profile/settings';
  static const shopProfileEdit = '/shop/profile/edit';

  static const modelHome = '/model/home';
  static const modelHomeProfileEdit = '/model/home/profile_edit';
  static const modelHomeEducation = '/model/home/education';
  static const modelHomeApplicationPosts = '/model/home/application_posts';
  static const modelHomeApplicationPostsNew =
      '/model/home/application_posts/new';
  static String modelHomeMatchLike(String likeId) =>
      '/model/home/match_like/$likeId';
  static String modelMatchingMatchLike(String likeId) =>
      '/model/matching/match_like/$likeId';
  static const modelMessages = '/model/home/messages';
  static const modelNotifications = '/model/home/notifications';
  static const modelMatching = '/model/matching';
  static const modelSchedule = '/model/schedule';
  static const modelProfile = '/model/profile';
  static const modelProfileSchedule = '/model/profile/schedule';
  static const modelProfileMatching = '/model/profile/matching';
  static const modelProfilePayment = '/model/profile/payment';
  static const modelProfileReferral = '/model/profile/referral';
  static const modelProfileVerification = '/model/profile/verification';
  static const modelProfileSettings = '/model/profile/settings';

  static const admin = '/admin';
  static const adminUsers = '/admin/users';
  static const adminJobs = '/admin/jobs';
  static const adminApplications = '/admin/applications';
  static const adminPayments = '/admin/payments';
  static const adminEnergy = '/admin/energy';
  static const adminSettlementCancelRequests =
      '/admin/settlement-cancel-requests';
  static const adminNoShowReports = '/admin/no-show-reports';
  static const adminCheckin = '/admin/checkin';
  static const adminVerifications = '/admin/verifications';
  static const adminReports = '/admin/reports';
  static const adminSettings = '/admin/settings';
  static const adminAuditLogs = '/admin/audit-logs';
  static const adminRecentActivities = '/admin/activities';
  static const adminMatches = '/admin/matches';
  static const adminSpaces = '/admin/spaces';
  static const adminEducations = '/admin/educations';
  static const adminPoints = '/admin/points';
  static const adminSubscriptions = '/admin/subscriptions';
  static const adminSanctions = '/admin/sanctions';
  static const adminContent = '/admin/content';
  static const adminNotifications = '/admin/notifications';
  static const adminChats = '/admin/chats';
  static const adminReference = '/admin/reference';

  static String adminUserDetail(String userId) => '/admin/users/$userId';
  static String adminChat(String chatId) => '/admin/chats/$chatId';
  static String adminJobDetail(String jobId) => '/admin/jobs/$jobId';
  static String adminApplicationDetail(String applicationId) =>
      '/admin/applications/$applicationId';
  static String adminMatchDetail(String matchId) => '/admin/matches/$matchId';
  static String adminPaymentDetail(String paymentId) =>
      '/admin/payments/$paymentId';
  static String adminVerificationDetail(String verificationId) =>
      '/admin/verifications/$verificationId';
  static String adminReportDetail(String reportId) =>
      '/admin/reports/$reportId';
  static String adminCreatorDetail(String creatorId) =>
      '/admin/subscriptions/creators/$creatorId';
  static String adminSubscriptionDetail(String subscriptionId) =>
      '/admin/subscriptions/items/$subscriptionId';
}
