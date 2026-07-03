import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../screens/spare/education_screen.dart' show Education;
import '../../screens/shop/applicants_screen.dart';
import '../../screens/shop/education_new_screen.dart';
import '../../screens/shop/job_detail_screen.dart';
import '../../screens/shop/job_new_screen.dart';
import '../../screens/shop/job_opening_soon_upsell_screen.dart';
import '../../screens/shop/job_urgent_payment_screen.dart';
import '../../screens/shop/job_urgent_upsell_screen.dart';
import '../../screens/shop/messages_screen.dart';
import '../../screens/shop/space_bookings_screen.dart';
import '../../screens/shop/space_edit_screen.dart';
import '../../screens/shop/space_new_screen.dart';
import '../../screens/shop/spare_detail_screen.dart';
import '../../screens/shop/verification_screen.dart';
import '../../screens/spare/change_password_screen.dart';
import '../../screens/spare/challenge_profile_edit_screen.dart';
import '../../screens/spare/challenge_profile_screen.dart';
import '../../screens/spare/delete_account_screen.dart';
import '../../screens/spare/education_detail_screen.dart';
import '../../screens/spare/education_energy_checkout_screen.dart';
import '../../screens/spare/education_enrollment_detail_screen.dart';
import '../../screens/spare/energy_purchase_checkout_screen.dart';
import '../../screens/spare/energy_purchase_screen.dart';
import '../../screens/spare/job_detail_screen.dart';
import '../../screens/spare/notifications_settings_screen.dart';
import '../../screens/spare/point_history_screen.dart';
import '../../screens/spare/profile_edit_screen.dart';
import '../../screens/spare/reviews_list_screen.dart';
import '../../screens/spare/space_rental_detail_screen.dart';
import '../../screens/spare/verification_screen.dart';
import '../../view_models/shop_job_new_view_model.dart';
import 'route_extras.dart';

/// 모든 StatefulShell 탭 브랜치에 공통으로 붙이는 2depth 라우트.
abstract final class SharedLeafRoutes {
  SharedLeafRoutes._();

  static List<RouteBase> all() => <RouteBase>[
        GoRoute(
          path: 'job/:jobId',
          builder: (BuildContext context, GoRouterState state) {
            final jobId = state.pathParameters['jobId'];
            if (jobId == null || jobId.isEmpty) {
              return const SizedBox.shrink();
            }
            return JobDetailScreen(jobId: jobId);
          },
        ),
        GoRoute(
          path: 'shop_job/:jobId',
          builder: (BuildContext context, GoRouterState state) {
            final jobId = state.pathParameters['jobId'];
            if (jobId == null || jobId.isEmpty) {
              return const SizedBox.shrink();
            }
            return ShopJobDetailScreen(jobId: jobId);
          },
        ),
        GoRoute(
          path: 'shop_job_new',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is ShopJobNewRouteArgs) {
              return ShopJobNewScreen(
                jobToEdit: extra.jobToEdit,
                jobToCopy: extra.jobToCopy,
              );
            }
            return const ShopJobNewScreen();
          },
        ),
        GoRoute(
          path: 'shop_applicants',
          builder: (BuildContext context, GoRouterState state) {
            return ShopApplicantsScreen(
              initialJobId: state.uri.queryParameters['jobId'],
            );
          },
        ),
        GoRoute(
          path: 'shop_spare/:spareId',
          builder: (BuildContext context, GoRouterState state) {
            final spareId = state.pathParameters['spareId'];
            if (spareId == null || spareId.isEmpty) {
              return const SizedBox.shrink();
            }
            final jobId = state.uri.queryParameters['jobId'];
            return ShopSpareDetailScreen(spareId: spareId, jobId: jobId);
          },
        ),
        GoRoute(
          path: 'space/:spaceId',
          builder: (BuildContext context, GoRouterState state) {
            final spaceId = state.pathParameters['spaceId'];
            if (spaceId == null || spaceId.isEmpty) {
              return const SizedBox.shrink();
            }
            return SpaceRentalDetailScreen(spaceId: spaceId);
          },
        ),
        GoRoute(
          path: 'education_detail',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is! Education) return const SizedBox.shrink();
            return EducationDetailScreen(education: extra);
          },
        ),
        GoRoute(
          path: 'enrollment/:enrollmentId',
          builder: (BuildContext context, GoRouterState state) {
            final id = state.pathParameters['enrollmentId'];
            if (id == null || id.isEmpty) return const SizedBox.shrink();
            return EducationEnrollmentDetailScreen(enrollmentId: id);
          },
        ),
        GoRoute(
          path: 'energy_purchase',
          builder: (_, __) => const EnergyPurchaseScreen(),
        ),
        GoRoute(
          path: 'energy_checkout',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is! EnergyPurchaseCheckoutArgs) {
              return const SizedBox.shrink();
            }
            return EnergyPurchaseCheckoutScreen(
              energyAmount: extra.energyAmount,
              cashPrice: extra.cashPrice,
              packageId: extra.packageId,
            );
          },
        ),
        GoRoute(
          path: 'education_checkout',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is! EducationEnergyCheckoutArgs) {
              return const SizedBox.shrink();
            }
            return EducationEnergyCheckoutScreen(education: extra.education);
          },
        ),
        GoRoute(
          path: 'point_history',
          builder: (_, __) => const PointHistoryScreen(),
        ),
        GoRoute(
          path: 'verification',
          builder: (_, __) => const VerificationScreen(),
        ),
        GoRoute(
          path: 'shop_verification',
          builder: (_, __) => const ShopVerificationScreen(),
        ),
        GoRoute(
          path: 'challenge_profile',
          builder: (BuildContext context, GoRouterState state) {
            final userId = state.uri.queryParameters['userId'];
            return ChallengeProfileScreen(userId: userId);
          },
        ),
        GoRoute(
          path: 'challenge_profile_edit',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is ChallengeProfileEditRouteArgs) {
              return ChallengeProfileEditScreen(profile: extra.profile);
            }
            return const SizedBox.shrink();
          },
        ),
        GoRoute(
          path: 'settings_profile_edit',
          builder: (_, __) => const ProfileEditScreen(),
        ),
        GoRoute(
          path: 'settings_notifications',
          builder: (_, __) => const NotificationsSettingsScreen(),
        ),
        GoRoute(
          path: 'settings_change_password',
          builder: (_, __) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: 'settings_delete_account',
          builder: (_, __) => const DeleteAccountScreen(),
        ),
        GoRoute(
          path: 'shop_education_new',
          builder: (_, __) => const ShopEducationNewScreen(),
        ),
        GoRoute(
          path: 'shop_space_new',
          builder: (_, __) => const ShopSpaceNewScreen(),
        ),
        GoRoute(
          path: 'shop_space_edit/:spaceId',
          builder: (BuildContext context, GoRouterState state) {
            final spaceId = state.pathParameters['spaceId'];
            if (spaceId == null || spaceId.isEmpty) {
              return const SizedBox.shrink();
            }
            return ShopSpaceEditScreen(spaceId: spaceId);
          },
        ),
        GoRoute(
          path: 'shop_space_bookings/:spaceId',
          builder: (BuildContext context, GoRouterState state) {
            final spaceId = state.pathParameters['spaceId'];
            if (spaceId == null || spaceId.isEmpty) {
              return const SizedBox.shrink();
            }
            return ShopSpaceBookingsScreen(spaceId: spaceId);
          },
        ),
        GoRoute(
          path: 'shop_job_urgent_upsell',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is! ShopJobUrgentUpsellExtra) {
              return const SizedBox.shrink();
            }
            return ChangeNotifierProvider<ShopJobNewViewModel>.value(
              value: extra.viewModel,
              child: ShopJobUrgentUpsellScreen(formKey: extra.formKey),
            );
          },
        ),
        GoRoute(
          path: 'shop_job_urgent_payment',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is! ShopJobUrgentPaymentExtra) {
              return const SizedBox.shrink();
            }
            return ChangeNotifierProvider<ShopJobNewViewModel>.value(
              value: extra.viewModel,
              child: ShopJobUrgentPaymentScreen(formKey: extra.formKey),
            );
          },
        ),
        GoRoute(
          path: 'shop_job_opening_soon_upsell',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is! ShopJobOpeningSoonExtra) {
              return const SizedBox.shrink();
            }
            return ShopJobOpeningSoonUpsellScreen(
              jobId: extra.jobId,
              jobTitle: extra.jobTitle,
            );
          },
        ),
        GoRoute(
          path: 'reviews',
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra;
            if (extra is! ReviewsListRouteArgs) {
              return const SizedBox.shrink();
            }
            return ReviewsListScreen(
              title: extra.title,
              averageRating: extra.averageRating,
              reviews: extra.reviews
                  .map(
                    (r) => ReviewItem(
                      userName: r.userName,
                      rating: r.rating,
                      comment: r.comment,
                      createdAt: r.createdAt,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        GoRoute(
          path: 'shop_messages',
          builder: (_, __) => const ShopMessagesScreen(),
        ),
      ];
}
