import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../screens/admin/admin_checkin_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/admin_energy_screen.dart';
import '../../screens/admin/admin_job_detail_screen.dart';
import '../../screens/admin/admin_jobs_screen.dart';
import '../../screens/admin/admin_noshow_screen.dart';
import '../../screens/admin/admin_payment_detail_screen.dart';
import '../../screens/admin/admin_payments_screen.dart';
import '../../screens/admin/admin_user_detail_screen.dart';
import '../../screens/admin/admin_users_screen.dart';
import '../../screens/common/role_select_screen.dart';
import '../../screens/shop/favorites_screen.dart';
import '../../screens/shop/home_screen.dart';
import '../../screens/shop/shop_command_search_screen.dart';
import '../../screens/shop/login_screen.dart';
import '../../screens/shop/messages_screen.dart';
import '../../screens/shop/payment_screen.dart';
import '../../screens/shop/profile_screen.dart';
import '../../screens/shop/signup_screen.dart';
import '../../screens/spare/favorites_screen.dart';
import '../../screens/spare/find_id_screen.dart';
import '../../screens/spare/find_password_screen.dart';
import '../../screens/spare/home_screen.dart';
import '../../screens/spare/login_screen.dart';
import '../../screens/spare/messages_screen.dart';
import '../../screens/spare/notifications_list_screen.dart';
import '../../screens/spare/payment_screen.dart';
import '../../screens/spare/profile_screen.dart';
import '../../screens/spare/search_screen.dart';
import '../../screens/spare/signup_screen.dart';
import '../di/service_locator.dart' show sl;
import '../shell/admin_shell.dart';
import '../shell/main_tab_shell.dart';
import 'app_routes.dart';
import 'auth_redirect.dart';

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
          path: AppRoutes.spareLogin,
          builder: (BuildContext context, GoRouterState state) =>
              const SpareLoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.spareSignup,
          builder: (BuildContext context, GoRouterState state) =>
              const SpareSignupScreen(),
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
              builder: (
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
                          builder: (
                            BuildContext context,
                            GoRouterState state,
                          ) =>
                              const MessagesScreen(),
                        ),
                        GoRoute(
                          path: 'search',
                          builder: (
                            BuildContext context,
                            GoRouterState state,
                          ) =>
                              const SearchScreen(),
                        ),
                        GoRoute(
                          path: 'notifications',
                          builder: (
                            BuildContext context,
                            GoRouterState state,
                          ) =>
                              const NotificationsListScreen(),
                        ),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'payment',
                      builder: (BuildContext context, GoRouterState state) =>
                          const PaymentScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'favorites',
                      builder: (BuildContext context, GoRouterState state) =>
                          const FavoritesScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'profile',
                      builder: (BuildContext context, GoRouterState state) =>
                          const ProfileScreen(),
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
              builder: (
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
                          builder: (
                            BuildContext context,
                            GoRouterState state,
                          ) =>
                              const ShopMessagesScreen(),
                        ),
                        GoRoute(
                          path: 'search',
                          builder: (
                            BuildContext context,
                            GoRouterState state,
                          ) =>
                              const ShopCommandSearchScreen(),
                        ),
                        GoRoute(
                          path: 'notifications',
                          builder: (
                            BuildContext context,
                            GoRouterState state,
                          ) =>
                              const NotificationsListScreen(),
                        ),
                      ],
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'payment',
                      builder: (BuildContext context, GoRouterState state) =>
                          const ShopPaymentScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'favorites',
                      builder: (BuildContext context, GoRouterState state) =>
                          const ShopFavoritesScreen(),
                    ),
                  ],
                ),
                StatefulShellBranch(
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'profile',
                      builder: (BuildContext context, GoRouterState state) =>
                          const ShopProfileScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        ShellRoute(
          builder: (
            BuildContext context,
            GoRouterState state,
            Widget child,
          ) {
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
              path: AppRoutes.adminJobs,
              builder: (BuildContext context, GoRouterState state) =>
                  const AdminJobsScreen(),
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
                return AdminJobDetailScreen(
                  jobId: jobId,
                  initialData: initial,
                );
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
          ],
        ),
      ],
    );
  }
}

/// [registerGoRouter]로 등록한 싱글톤 — [MaterialApp.router]에 넘긴 인스턴스와 동일.
GoRouter get appRouter => sl<GoRouter>();
