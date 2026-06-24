import 'package:flutter/material.dart';

import '../../models/challenge_profile.dart';
import '../../models/job.dart';
import '../../screens/spare/education_screen.dart';
import '../../view_models/shop_job_new_view_model.dart';

/// go_router [extra] 페이로드 — 공고 등록·수정.
final class ShopJobNewRouteArgs {
  const ShopJobNewRouteArgs({this.jobToEdit, this.jobToCopy});

  final Job? jobToEdit;
  final Job? jobToCopy;
}

/// 긴급 공고 결제 화면 — ViewModel·formKey 전달.
final class ShopJobUrgentPaymentExtra {
  const ShopJobUrgentPaymentExtra({
    required this.viewModel,
    required this.formKey,
  });

  final ShopJobNewViewModel viewModel;
  final GlobalKey<FormState> formKey;
}

/// 긴급 업셀 화면.
final class ShopJobUrgentUpsellExtra {
  const ShopJobUrgentUpsellExtra({
    required this.viewModel,
    required this.formKey,
  });

  final ShopJobNewViewModel viewModel;
  final GlobalKey<FormState> formKey;
}

/// 에너지 구매 결제.
final class EnergyPurchaseCheckoutArgs {
  const EnergyPurchaseCheckoutArgs({
    required this.energyAmount,
    required this.cashPrice,
    required this.packageId,
  });

  final int energyAmount;
  final int cashPrice;
  final String packageId;
}

/// 교육 에너지 결제.
final class EducationEnergyCheckoutArgs {
  const EducationEnergyCheckoutArgs({required this.education});

  final Education education;
}

/// 챌린지 프로필 편집.
final class ChallengeProfileEditRouteArgs {
  const ChallengeProfileEditRouteArgs({required this.profile});

  final ChallengeProfile profile;
}

/// 리뷰 목록.
final class ReviewsListRouteArgs {
  const ReviewsListRouteArgs({
    required this.title,
    required this.averageRating,
    required this.reviews,
  });

  final String title;
  final double averageRating;
  final List<EducationReview> reviews;
}
