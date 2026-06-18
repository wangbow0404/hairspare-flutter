import '../models/model_home_data.dart';
import '../models/user.dart';
import 'mock_auth_data.dart';

/// 모델 홈 목 데이터.
abstract final class MockModelHomeData {
  static ModelHomeProfileSummary profileForUser(User? user) {
    final name = user?.name ?? user?.username ?? '모델';
    return ModelHomeProfileSummary(
      name: name,
      regionLabel: '강남구/청담',
      hairLength: '롱 레이어드',
      intro: '세련된 롱 레이어드 컷 모델 가능합니다. 다양한 스타일링 환영해요!',
      completionPercent: 0.95,
      isIdentityVerified: true,
      todayInterestCount: 3,
      matchingVisible: true,
    );
  }

  static List<ModelHomeInterest> get interests => const [
        ModelHomeInterest(
          id: 'interest-1',
          designerName: '김수민 디자이너',
          treatment: '전체염색',
          region: '강남구',
          isPrimaryCta: true,
        ),
        ModelHomeInterest(
          id: 'interest-2',
          designerName: '박준호 디자이너',
          treatment: '레이어드 컷',
          region: '서초구',
          isPrimaryCta: false,
        ),
      ];

  static List<ModelHomeUpcomingSchedule> get upcomingSchedules {
    final now = DateTime.now();
    return [
      ModelHomeUpcomingSchedule(
        id: 'sched-1',
        shopName: '차홍룸 강남점',
        treatment: '전체염색',
        dateTime: DateTime(now.year, 10, 24, 14),
        paymentType: ModelTreatmentPayment.deposit,
        depositAmount: 30000,
      ),
      ModelHomeUpcomingSchedule(
        id: 'sched-2',
        shopName: '민트살롱',
        treatment: '컷',
        dateTime: DateTime(now.year, 11, 2, 11),
        paymentType: ModelTreatmentPayment.free,
      ),
    ];
  }

  static bool get isModelSession =>
      MockAuthData.isRegisteredModel ||
      MockAuthData.userForCredentials('4', '4') != null;
}
