import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/spare/education_screen.dart' show Education;
import '../../screens/common/portfolio_screen.dart';
import '../../screens/shop/applicants_screen.dart';
import '../../screens/spare/challenge_screen.dart';
import '../../screens/spare/model_match_filter_screen.dart';
import '../../screens/spare/challenge_profile_screen.dart';
import '../../screens/shop/education_screen.dart';
import '../../screens/shop/matching_tips_screen.dart';
import '../../screens/shop/jobs_list_screen.dart';
import '../../screens/shop/my_spaces_screen.dart';
import '../../screens/shop/payment_screen.dart';
import '../../screens/shop/points_screen.dart';
import '../../screens/shop/profile_edit_screen.dart';
import '../../screens/shop/schedule_screen.dart';
import '../../screens/shop/settings_screen.dart';
import '../../screens/shop/spare_detail_screen.dart';
import '../../screens/shop/spares_list_screen.dart';
import '../../screens/shop/verification_screen.dart';
import '../../screens/shop/vip_status_screen.dart';
import '../../screens/spare/chat_room_screen.dart';
import '../../screens/spare/match_profile_detail_screen.dart';
import '../../models/match_like.dart';
import '../../models/model_match_preference.dart';
import '../../screens/spare/model_match_swipe_screen.dart';
import '../../screens/spare/model_matching_status_screen.dart';
import '../../screens/spare/model_schedule_screen.dart';
import '../../screens/spare/education_detail_screen.dart';
import '../../screens/spare/education_screen.dart';
import '../../screens/spare/energy_screen.dart';
import '../../screens/spare/job_detail_screen.dart';
import '../../screens/spare/my_applications_screen.dart';
import '../../screens/spare/my_space_bookings_screen.dart';
import '../../screens/spare/payment_screen.dart';
import '../../screens/spare/profile_edit_screen.dart';
import '../../screens/spare/model_application_create_screen.dart';
import '../../screens/spare/model_application_list_screen.dart';
import '../../screens/spare/model_profile_edit_screen.dart';
import '../../screens/spare/referral_screen.dart';
import '../../screens/spare/region_select_screen.dart';
import '../../screens/spare/settings_screen.dart';
import '../../screens/spare/space_rental_detail_screen.dart';
import '../../screens/spare/subscriptions_screen.dart';
import '../../screens/spare/verification_screen.dart';
import '../../screens/spare/work_check_screen.dart';
import '../di/service_locator.dart' show sl;
import '../../providers/auth_provider.dart';
import 'shared_leaf_routes.dart';

/// StatefulShell 탭 하위 화면 — [Navigator.push] 대신 go_router 중첩 라우트.
abstract final class ShellSubRoutes {
  ShellSubRoutes._();

  static List<RouteBase> matchProfileDetailChildRoutes() => <RouteBase>[
        GoRoute(
          path: 'match_like/:likeId',
          builder: (BuildContext context, GoRouterState state) {
            final likeId = state.pathParameters['likeId'];
            if (likeId == null || likeId.isEmpty) {
              return const SizedBox.shrink();
            }
            final extra = state.extra;
            return MatchProfileDetailScreen(
              likeId: likeId,
              initialLike: extra is MatchLike ? extra : null,
            );
          },
        ),
      ];

  static List<RouteBase> chatRoomChildRoutes() => <RouteBase>[
        GoRoute(
          path: 'chat/:chatId',
          builder: (BuildContext context, GoRouterState state) {
            final chatId = state.pathParameters['chatId'];
            if (chatId == null || chatId.isEmpty) {
              return const SizedBox.shrink();
            }
            return ChatRoomScreen(chatId: chatId);
          },
        ),
      ];

  static List<RouteBase> modelMatchChildRoutes() => <RouteBase>[
        GoRoute(
          path: 'swipe',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is! ModelMatchPreference) {
              return const SizedBox.shrink();
            }
            return ModelMatchSwipeScreen(preference: extra);
          },
        ),
      ];

  static List<RouteBase> spareHomeChildRoutes() => <RouteBase>[
        GoRoute(
          path: 'work_check',
          builder: (_, __) => const WorkCheckScreen(),
        ),
        GoRoute(
          path: 'region_select',
          builder: (_, __) => const RegionSelectScreen(),
        ),
        GoRoute(
          path: 'education',
          builder: (_, __) => const EducationScreen(),
          routes: <RouteBase>[
            GoRoute(
              path: 'detail',
              builder: (BuildContext context, GoRouterState state) {
                final extra = state.extra;
                if (extra is! Education) {
                  return const SizedBox.shrink();
                }
                return EducationDetailScreen(education: extra);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'challenge',
          builder: (BuildContext context, GoRouterState state) {
            final creatorId = state.uri.queryParameters['creatorId'];
            final initialVideoId = state.uri.queryParameters['initialVideoId'];
            return ChallengeScreen(
              creatorId: creatorId,
              initialVideoId: initialVideoId,
            );
          },
        ),
        GoRoute(
          path: 'energy',
          builder: (_, __) => const EnergyScreen(),
        ),
        ...SharedLeafRoutes.all(),
      ];

  static List<RouteBase> spareProfileChildRoutes() => <RouteBase>[
        GoRoute(
          path: 'portfolio',
          builder: (BuildContext context, GoRouterState state) {
            final user = sl<AuthProvider>().currentUser;
            if (user == null) return const SizedBox.shrink();
            return PortfolioScreen(
              ownerId: user.id,
              ownerRole: user.role.name,
            );
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (_, __) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'edit',
          builder: (_, __) => const ProfileEditScreen(),
        ),
        GoRoute(
          path: 'challenge',
          builder: (_, __) => const ChallengeProfileScreen(),
        ),
        GoRoute(
          path: 'subscriptions',
          builder: (_, __) => const SubscriptionsScreen(),
        ),
        GoRoute(
          path: 'energy',
          builder: (_, __) => const EnergyScreen(),
        ),
        GoRoute(
          path: 'work_check',
          builder: (_, __) => const WorkCheckScreen(),
        ),
        GoRoute(
          path: 'applications',
          builder: (_, __) => const MyApplicationsScreen(),
        ),
        GoRoute(
          path: 'space_bookings',
          builder: (_, __) => const MySpaceBookingsScreen(),
        ),
        GoRoute(
          path: 'payment',
          builder: (_, __) => const PaymentScreen(),
        ),
        GoRoute(
          path: 'referral',
          builder: (_, __) => const ReferralScreen(),
        ),
        GoRoute(
          path: 'verification',
          builder: (_, __) => const VerificationScreen(),
        ),
        ...SharedLeafRoutes.all(),
      ];

  static List<RouteBase> spareFavoritesChildRoutes() =>
      SharedLeafRoutes.all();

  static List<RouteBase> shopHomeChildRoutes() => <RouteBase>[
        GoRoute(
          path: 'spares',
          builder: (_, __) => const ShopSparesListScreen(),
        ),
        GoRoute(
          path: 'schedule',
          builder: (_, __) => const ShopScheduleScreen(),
        ),
        GoRoute(
          path: 'points',
          builder: (_, __) => const ShopPointsScreen(),
        ),
        GoRoute(
          path: 'spaces',
          builder: (_, __) => const ShopMySpacesScreen(),
        ),
        GoRoute(
          path: 'education',
          builder: (_, __) => const ShopEducationScreen(),
        ),
        GoRoute(
          path: 'matching_tips',
          builder: (_, __) => const ShopMatchingTipsScreen(),
        ),
        GoRoute(
          path: 'challenge',
          builder: (BuildContext context, GoRouterState state) {
            final creatorId = state.uri.queryParameters['creatorId'];
            final initialVideoId = state.uri.queryParameters['initialVideoId'];
            return ChallengeScreen(
              creatorId: creatorId,
              initialVideoId: initialVideoId,
            );
          },
        ),
        GoRoute(
          path: 'model_match',
          builder: (_, __) => const ModelMatchFilterScreen(),
          routes: <RouteBase>[
            ...ShellSubRoutes.modelMatchChildRoutes(),
            ...SharedLeafRoutes.all(),
          ],
        ),
        ...SharedLeafRoutes.all(),
      ];

  static List<RouteBase> shopProfileChildRoutes() => <RouteBase>[
        GoRoute(
          path: 'portfolio',
          builder: (BuildContext context, GoRouterState state) {
            final user = sl<AuthProvider>().currentUser;
            if (user == null) return const SizedBox.shrink();
            return PortfolioScreen(
              ownerId: user.id,
              ownerRole: user.role.name,
            );
          },
        ),
        GoRoute(
          path: 'vip',
          builder: (_, __) => const ShopVipStatusScreen(),
        ),
        GoRoute(
          path: 'schedule',
          builder: (_, __) => const ShopScheduleScreen(),
        ),
        GoRoute(
          path: 'jobs',
          builder: (_, __) => const ShopJobsListScreen(),
        ),
        GoRoute(
          path: 'spaces',
          builder: (_, __) => const ShopMySpacesScreen(),
        ),
        GoRoute(
          path: 'applicants',
          builder: (_, __) => const ShopApplicantsScreen(),
        ),
        GoRoute(
          path: 'payment',
          builder: (_, __) => const ShopPaymentScreen(),
        ),
        GoRoute(
          path: 'verification',
          builder: (_, __) => const ShopVerificationScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (_, __) => const ShopSettingsScreen(),
        ),
        GoRoute(
          path: 'edit',
          builder: (_, __) => const ShopProfileEditScreen(),
        ),
        ...SharedLeafRoutes.all(),
      ];

  static List<RouteBase> modelHomeChildRoutes() => <RouteBase>[
        GoRoute(
          path: 'profile_edit',
          builder: (_, __) => const ModelProfileEditScreen(),
        ),
        GoRoute(
          path: 'education',
          builder: (_, __) => const EducationScreen(),
        ),
        GoRoute(
          path: 'application_posts',
          builder: (_, __) => const ModelApplicationListScreen(),
        ),
        GoRoute(
          path: 'application_posts/new',
          builder: (_, __) => const ModelApplicationCreateScreen(),
        ),
        ...SharedLeafRoutes.all(),
      ];

  static List<RouteBase> modelProfileChildRoutes() => <RouteBase>[
        GoRoute(
          path: 'schedule',
          builder: (_, __) => const ModelScheduleScreen(),
        ),
        GoRoute(
          path: 'matching',
          builder: (_, __) => const ModelMatchingStatusScreen(),
        ),
        GoRoute(
          path: 'payment',
          builder: (_, __) => const PaymentScreen(),
        ),
        GoRoute(
          path: 'referral',
          builder: (_, __) => const ReferralScreen(),
        ),
        GoRoute(
          path: 'verification',
          builder: (_, __) => const VerificationScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (_, __) => const SettingsScreen(),
        ),
        ...SharedLeafRoutes.all(),
      ];
}
