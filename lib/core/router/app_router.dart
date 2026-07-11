import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/admin/admin_audit_logs_screen.dart';
import '../../screens/admin/admin_application_detail_screen.dart';
import '../../screens/admin/admin_applications_screen.dart';
import '../../screens/admin/admin_chat_room_screen.dart';
import '../../screens/admin/admin_chats_screen.dart';
import '../../screens/admin/admin_checkin_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_energy_screen.dart';
import '../../screens/admin/admin_job_detail_screen.dart';
import '../../screens/admin/admin_jobs_screen.dart';
import '../../screens/admin/admin_noshow_screen.dart';
import '../../screens/admin/admin_payment_detail_screen.dart';
import '../../screens/admin/admin_payments_screen.dart';
import '../../screens/admin/admin_no_show_reports_screen.dart';
import '../../screens/admin/admin_reports_screen.dart';
import '../../screens/admin/admin_settlement_cancel_requests_screen.dart';
import '../../screens/admin/admin_settings_screen.dart';
import '../../screens/admin/admin_user_detail_screen.dart';
import '../../screens/admin/admin_users_screen.dart';
import '../../screens/admin/admin_verifications_screen.dart';
import '../../screens/admin/admin_verification_detail_screen.dart';
import '../../screens/admin/admin_report_detail_screen.dart';
import '../../screens/admin/admin_matches_screen.dart';
import '../../screens/admin/admin_spaces_screen.dart';
import '../../screens/admin/admin_educations_screen.dart';
import '../../screens/admin/admin_points_screen.dart';
import '../../screens/admin/admin_subscriptions_screen.dart';
import '../../screens/admin/admin_creator_detail_screen.dart';
import '../../screens/admin/admin_subscription_detail_screen.dart';
import '../../screens/admin/admin_sanctions_screen.dart';
import '../../screens/admin/admin_content_screen.dart';
import '../../screens/admin/admin_notifications_screen.dart';
import '../../screens/admin/admin_reference_screen.dart';
import '../../screens/common/privacy_policy_screen.dart';
import '../../screens/common/role_select_screen.dart';
import '../../screens/shop/favorites_screen.dart';
import '../../screens/shop/home_screen.dart';
import '../../screens/shop/shop_command_search_screen.dart';
import '../../screens/shop/login_screen.dart';
import '../../screens/shop/messages_screen.dart';
import '../../screens/shop/payment_screen.dart';
import '../../screens/shop/profile_screen.dart';
import '../../screens/shop/shop_signup_success_screen.dart';
import '../../screens/shop/signup_screen.dart';
import '../../screens/spare/favorites_screen.dart';
import '../../screens/spare/find_id_screen.dart';
import '../../screens/spare/find_password_screen.dart';
import '../../screens/spare/home_screen.dart';
import '../../screens/spare/jobs_list_screen.dart';
import '../../screens/spare/login_screen.dart';
import '../../screens/spare/model_match_entry_screen.dart';
import '../../screens/spare/messages_screen.dart';
import '../../screens/spare/model_home_screen.dart';
import '../../screens/spare/model_matching_status_screen.dart';
import '../../screens/spare/model_profile_screen.dart';
import '../../screens/spare/notifications_list_screen.dart';
import '../../screens/spare/payment_screen.dart';
import '../../screens/spare/points_screen.dart';
import '../../screens/spare/model_schedule_screen.dart';
import '../../screens/spare/profile_screen.dart';
import '../../screens/spare/search_screen.dart';
import '../../screens/spare/verification_screen.dart';
import '../../screens/spare/spare_signup_professional_screen.dart';
import '../../screens/spare/spare_signup_model_screen.dart';
import '../../screens/spare/spare_signup_type_screen.dart';
import '../../screens/spare/spare_signup_success_screen.dart';
import '../di/service_locator.dart' show sl;
import '../shell/admin_shell.dart';
import '../shell/lazy_shell_tab.dart';
import '../shell/main_tab_shell.dart';
import '../shell/model_tab_shell.dart';
import '../../utils/jobs_list_sort.dart';
import 'app_routes.dart';
import 'auth_redirect.dart';
import 'shared_leaf_routes.dart';
import 'shell_sub_routes.dart';

/// 앱 라우팅 (인증 가드 + 스페어/샵 StatefulShellRoute + 관리자 Shell).
final class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthProvider auth) {
    return GoRouter(
      initialLocation: AppRoutes.roleSelect,
      refreshListenable: auth,
      redirect: (BuildContext context, GoRouterState state) {
        return authRedirect(auth, state);
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.roleSelect,
          builder: (BuildContext context, GoRouterState state) =>
              const RoleSelectScreen(),
        ),
        GoRoute(
          path: AppRoutes.privacyPolicy,
          builder: (BuildContext context, GoRouterState state) =>
              const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: AppRoutes.spareLogin,
          builder: (BuildContext context, GoRouterState state) =>
              const SpareLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.spareSignup,
          builder: (BuildContext context, GoRouterState state) =>
              const SpareSignupTypeScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: 'professional',
              builder: (_, __) => const SpareSignupProfessionalScreen(),
            ),
            GoRoute(
              path: 'model',
              builder: (_, __) => const SpareSignupModelScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.spareSignupSuccess,
          builder: (BuildContext context, GoRouterState state) =>
              const SpareSignupSuccessScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: 'verification',
              builder: (_, __) => const VerificationScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.spareFindId,
          builder: (BuildContext context, GoRouterState state) =>
              const FindIdScreen(),
        ),
        GoRoute(
          path: AppRoutes.spareFindPassword,
          builder: (BuildContext context, GoRouterState state) {
            final foundId = state.uri.queryParameters['foundId'];
            return FindPasswordScreen(foundId: foundId);
          },
        ),
        GoRoute(
          path: AppRoutes.shopLogin,
          builder: (BuildContext context, GoRouterState state) =>
              const ShopLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.shopSignup,
          builder: (BuildContext context, GoRouterState state) =>
              const ShopSignupScreen(),
        ),
        GoRoute(
          path: AppRoutes.shopSignupSuccess,
          builder: (BuildContext context, GoRouterState state) =>
              const ShopSignupSuccessScreen(),
        ),
        GoRoute(
          path: AppRoutes.shopFindPassword,
          builder: (BuildContext context, GoRouterState state) {
            final foundId = state.uri.queryParameters['foundId'];
            return FindPasswordScreen(foundId: foundId);
          },
        ),
        GoRoute(
          path: '/spare',
          redirect: (BuildContext context, GoRouterState state) {
            if (state.uri.path == '/spare') return AppRoutes.spareHome;
            return null;
          },
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              builder:
                  (
                    BuildContext context,
                    GoRouterState state,
                    StatefulNavigationShell navigationShell,
                  ) {
                    return MainTabShell(navigationShell: navigationShell);
                  },
              branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'home',
                      builder: (BuildContext context, GoRouterState state) =>
                          const SpareHomeScreen(),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'messages',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const MessagesScreen(),
                          routes: ShellSubRoutes.chatRoomChildRoutes(),
                        ),
                        GoRoute(
                          path: 'search',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const SearchScreen(),
                        ),
                        GoRoute(
                          path: 'notifications',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const NotificationsListScreen(),
                        ),
                        GoRoute(
                          path: 'jobs',
                          builder: (BuildContext context, GoRouterState state) {
                            final query = state.uri.queryParameters;
                            return JobsListScreen(
                              filter: query['filter'],
                              searchQuery: query['q'],
                              initialSortMode: jobsListSortModeFromRouteQuery(
                                query['sort'],
                              ),
                            );
                          },
                        ),
                        GoRoute(
                          path: 'points',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const PointsScreen(),
                        ),
                        GoRoute(
                          path: 'model_match',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const ModelMatchEntryScreen(),
                          routes: <RouteBase>[
                            ...ShellSubRoutes.modelMatchChildRoutes(),
                            ...SharedLeafRoutes.all(),
                          ],
                        ),
                        ...ShellSubRoutes.spareHomeChildRoutes(),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'payment',
                      builder: (BuildContext context, GoRouterState state) {
                        final isModel =
                            sl<AuthProvider>().currentUser?.isModelAccount ??
                            false;
                        return LazyShellTab(
                          tabIndex: 1,
                          child: isModel
                              ? const MessagesScreen()
                              : const PaymentScreen(),
                        );
                      },
                      routes: <RouteBase>[
                        ...ShellSubRoutes.chatRoomChildRoutes(),
                        ...SharedLeafRoutes.all(),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'favorites',
                      builder: (BuildContext context, GoRouterState state) {
                        final isModel =
                            sl<AuthProvider>().currentUser?.isModelAccount ??
                            false;
                        return LazyShellTab(
                          tabIndex: 2,
                          child: isModel
                              ? const ModelScheduleScreen()
                              : const FavoritesScreen(),
                        );
                      },
                      routes: ShellSubRoutes.spareFavoritesChildRoutes(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'profile',
                      builder: (BuildContext context, GoRouterState state) =>
                          const LazyShellTab(
                            tabIndex: 3,
                            child: ProfileScreen(),
                          ),
                      routes: ShellSubRoutes.spareProfileChildRoutes(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/shop',
          redirect: (BuildContext context, GoRouterState state) {
            if (state.uri.path == '/shop') return AppRoutes.shopHome;
            return null;
          },
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              builder:
                  (
                    BuildContext context,
                    GoRouterState state,
                    StatefulNavigationShell navigationShell,
                  ) {
                    return MainTabShell(navigationShell: navigationShell);
                  },
              branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'home',
                      builder: (BuildContext context, GoRouterState state) =>
                          const ShopHomeScreen(),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'messages',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const ShopMessagesScreen(),
                          routes: ShellSubRoutes.chatRoomChildRoutes(),
                        ),
                        GoRoute(
                          path: 'search',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const ShopCommandSearchScreen(),
                        ),
                        GoRoute(
                          path: 'notifications',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const NotificationsListScreen(),
                        ),
                        ...ShellSubRoutes.shopHomeChildRoutes(),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'payment',
                      builder: (BuildContext context, GoRouterState state) =>
                          const LazyShellTab(
                            tabIndex: 1,
                            child: ShopPaymentScreen(),
                          ),
                      routes: SharedLeafRoutes.all(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'favorites',
                      builder: (BuildContext context, GoRouterState state) =>
                          const LazyShellTab(
                            tabIndex: 2,
                            child: ShopFavoritesScreen(),
                          ),
                      routes: SharedLeafRoutes.all(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'profile',
                      builder: (BuildContext context, GoRouterState state) =>
                          const LazyShellTab(
                            tabIndex: 3,
                            child: ShopProfileScreen(),
                          ),
                      routes: ShellSubRoutes.shopProfileChildRoutes(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/model',
          redirect: (BuildContext context, GoRouterState state) {
            if (state.uri.path == '/model') return AppRoutes.modelHome;
            return null;
          },
          routes: <RouteBase>[
            StatefulShellRoute.indexedStack(
              builder:
                  (
                    BuildContext context,
                    GoRouterState state,
                    StatefulNavigationShell navigationShell,
                  ) {
                    return ModelTabShell(navigationShell: navigationShell);
                  },
              branches: <StatefulShellBranch>[
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'home',
                      builder: (BuildContext context, GoRouterState state) =>
                          const ModelHomeScreen(),
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'messages',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const MessagesScreen(),
                          routes: ShellSubRoutes.chatRoomChildRoutes(),
                        ),
                        GoRoute(
                          path: 'notifications',
                          builder:
                              (BuildContext context, GoRouterState state) =>
                                  const NotificationsListScreen(),
                        ),
                        ...ShellSubRoutes.modelHomeChildRoutes(),
                        ...ShellSubRoutes.matchProfileDetailChildRoutes(),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'matching',
                      builder: (BuildContext context, GoRouterState state) =>
                          const LazyShellTab(
                            tabIndex: 1,
                            child: ModelMatchingStatusScreen(),
                          ),
                      routes: ShellSubRoutes.matchProfileDetailChildRoutes(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'schedule',
                      builder: (BuildContext context, GoRouterState state) =>
                          const LazyShellTab(
                            tabIndex: 2,
                            child: ModelScheduleScreen(),
                          ),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'profile',
                      builder: (BuildContext context, GoRouterState state) =>
                          const LazyShellTab(
                            tabIndex: 3,
                            child: ModelProfileScreen(),
                          ),
                      routes: ShellSubRoutes.modelProfileChildRoutes(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return AdminShell(location: state.uri.path, child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.admin,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminDashboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminUsers,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminUsersScreen(),
            ),
            GoRoute(
              path: '${AppRoutes.adminUsers}/:userId',
              builder: (BuildContext context, GoRouterState state) {
                final userId = state.pathParameters['userId']!;
                final extra = state.extra;
                Map<String, dynamic>? initial;
                if (extra is Map<String, dynamic>) {
                  initial = extra;
                }
                return AdminUserDetailScreen(
                  userId: userId,
                  initialData: initial,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.adminChats,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminChatsScreen(),
            ),
            GoRoute(
              path: '/admin/chats/:chatId',
              builder: (BuildContext context, GoRouterState state) {
                final chatId = state.pathParameters['chatId']!;
                Map<String, dynamic>? member;
                final extra = state.extra;
                if (extra is Map<String, dynamic>) {
                  member = extra;
                }
                return AdminChatRoomScreen(
                  chatId: chatId,
                  member: member,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.adminJobs,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminJobsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminApplications,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminApplicationsScreen(),
            ),
            GoRoute(
              path: '${AppRoutes.adminApplications}/:applicationId',
              builder: (BuildContext context, GoRouterState state) {
                final applicationId = state.pathParameters['applicationId']!;
                final extra = state.extra;
                Map<String, dynamic>? initial;
                if (extra is Map<String, dynamic>) {
                  initial = extra;
                }
                return AdminApplicationDetailScreen(
                  applicationId: applicationId,
                  initialData: initial,
                );
              },
            ),
            GoRoute(
              path: '${AppRoutes.adminJobs}/:jobId',
              builder: (BuildContext context, GoRouterState state) {
                final jobId = state.pathParameters['jobId']!;
                final extra = state.extra;
                Map<String, dynamic>? initial;
                if (extra is Map<String, dynamic>) {
                  initial = extra;
                }
                return AdminJobDetailScreen(jobId: jobId, initialData: initial);
              },
            ),
            GoRoute(
              path: AppRoutes.adminPayments,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminPaymentsScreen(),
            ),
            GoRoute(
              path: '${AppRoutes.adminPayments}/:paymentId',
              builder: (BuildContext context, GoRouterState state) {
                final paymentId = state.pathParameters['paymentId']!;
                final extra = state.extra;
                Map<String, dynamic>? initial;
                if (extra is Map<String, dynamic>) {
                  initial = extra;
                }
                return AdminPaymentDetailScreen(
                  paymentId: paymentId,
                  initialData: initial,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.adminEnergy,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminEnergyScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminNoshow,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminNoshowScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminCheckin,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminCheckinScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminSettlementCancelRequests,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminSettlementCancelRequestsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminNoShowReports,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminNoShowReportsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminVerifications,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminVerificationsScreen(),
              routes: [
                GoRoute(
                  path: ':verificationId',
                  builder: (BuildContext context, GoRouterState state) {
                    final verificationId =
                        state.pathParameters['verificationId']!;
                    Map<String, dynamic>? initial;
                    final extra = state.extra;
                    if (extra is Map<String, dynamic>) initial = extra;
                    return AdminVerificationDetailScreen(
                      verificationId: verificationId,
                      initialData: initial,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.adminReports,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminReportsScreen(),
              routes: [
                GoRoute(
                  path: ':reportId',
                  builder: (BuildContext context, GoRouterState state) {
                    final reportId = state.pathParameters['reportId']!;
                    Map<String, dynamic>? initial;
                    final extra = state.extra;
                    if (extra is Map<String, dynamic>) initial = extra;
                    return AdminReportDetailScreen(
                      reportId: reportId,
                      initialData: initial,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.adminSettings,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminSettingsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminAuditLogs,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminAuditLogsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminMatches,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminMatchesScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminSpaces,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminSpacesScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminEducations,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminEducationsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminPoints,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminPointsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminSubscriptions,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminSubscriptionsScreen(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'creators/:creatorId',
                  builder: (BuildContext context, GoRouterState state) {
                    final creatorId = state.pathParameters['creatorId']!;
                    Map<String, dynamic>? initial;
                    final extra = state.extra;
                    if (extra is Map<String, dynamic>) initial = extra;
                    return AdminCreatorDetailScreen(
                      creatorId: creatorId,
                      initialData: initial,
                    );
                  },
                ),
                GoRoute(
                  path: 'items/:subscriptionId',
                  builder: (BuildContext context, GoRouterState state) {
                    final subscriptionId = state.pathParameters['subscriptionId']!;
                    Map<String, dynamic>? initial;
                    final extra = state.extra;
                    if (extra is Map<String, dynamic>) initial = extra;
                    return AdminSubscriptionDetailScreen(
                      subscriptionId: subscriptionId,
                      initialData: initial,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.adminSanctions,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminSanctionsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminContent,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminContentScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminNotifications,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminNotificationsScreen(),
            ),
            GoRoute(
              path: AppRoutes.adminReference,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminReferenceScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

/// [registerGoRouter]로 등록한 싱글톤 — [MaterialApp.router]에 넘긴 인스턴스와 동일.
GoRouter get appRouter => sl<GoRouter>();
