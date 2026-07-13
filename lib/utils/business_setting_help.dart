import 'package:flutter/material.dart';

import '../theme/admin_stitch_theme.dart';

/// 비즈니스 설정 항목별 안내 문구 (M15).
abstract final class BusinessSettingHelp {
  BusinessSettingHelp._();

  static const Map<String, String> byKey = {
    'energyPointCostPerUnit':
        '스페어가 포인트로 에너지를 구매할 때 1에너지당 차감되는 포인트입니다. '
        '에너지 구매·결제 화면에 반영됩니다.',
    'urgentJobListingFee':
        '샵이 공고를 급구로 등록할 때 부과되는 수수료(원)입니다. '
        '급구 결제 화면과 공고 등록 플로우에 사용됩니다.',
    'hipassListingFee':
        '샵이 첫 번째 공고를 등록한 뒤 하이패스(HIPASS) 프리미엄 노출 구역에 '
        '올릴 때 결제하는 수수료입니다. 홈 하이패스 섹션 노출과 별도 상품입니다.',
    'subscriptionMonthlyFee':
        '샵 월 구독 플랜의 기준 가격(원)입니다. 구독·결제 화면에 표시됩니다.',
    'premiumJobFee':
        '프리미엄 매장 공고 등록 시 추가로 부과되는 수수료(원)입니다.',
    'chatAddonFee':
        '구독 플랜 외 채팅 기능을 별도 구매할 때의 수수료(원)입니다.',
    'modelDepositAmount':
        '모델 매칭·시술 예약 시 기준이 되는 보증금 금액(원)입니다.',
    'jobEnergyFormulaDivisor':
        '공고 일당(원)을 에너지 개수로 환산할 때 나누는 값입니다. '
        '예: 100,000원 ÷ 1000 = 100에너지. 공고 등록 시 에너지 산정에 사용됩니다.',
    'modelDailyMatchLimit':
        '모델이 하루에 스와이프·매칭을 시도할 수 있는 최대 횟수입니다.',
    'maxEnergyPurchaseAmount':
        '한 번에 구매할 수 있는 에너지 최대 개수입니다. '
        '패키지는 1·3·5개 단위로 제공됩니다.',
    'shopTierBronzeMaxJobs':
        '브론즈 등급 샵이 동시에 등록·유지할 수 있는 최대 공고 수입니다.',
    'shopTierSilverMaxJobs': '실버 등급 샵의 최대 공고 수입니다.',
    'shopTierGoldMaxJobs': '골드 등급 샵의 최대 공고 수입니다.',
    'shopTierPlatinumMaxJobs':
        '플래티넘·VIP 등급의 공고 상한입니다. 999는 UI에서 「무제한」으로 표시됩니다.',
    'contactMaxAttemptsPerChat':
        '채팅방에서 연락처(전화·카톡 등) 전송을 시도할 수 있는 최대 횟수입니다. '
        '초과 시 대화방 삭제·지원 취소 등 제재가 적용됩니다.',
    'shopContactPenaltyDays':
        '미용실(샵)이 연락처 유출로 적발됐을 때 대화·공고 등록이 제한되는 일수입니다.',
    'maxShopRoomPenaltiesBeforeBan':
        '동일 사업자·샵이 연락처 제재를 누적했을 때 계정 탈퇴·블랙리스트에 '
        '도달하는 기준 횟수입니다.',
    'shopUnilateralCancelLimit30d':
        '샵이 확정된 근무를 30일 내 일방 취소할 수 있는 허용 횟수입니다. '
        '초과 시 공고 등록 정지가 적용됩니다.',
    'shopJobPostingSuspensionDays':
        '일방 취소 한도를 초과한 샵에 적용되는 신규 공고 등록 정지 기간(일)입니다.',
    'lateCancelCutoffHours':
        '근무 시작 N시간 이내에 취소하면 노쇼·위약금과 동일하게 처리하는 기준 시간입니다.',
    'jobPopularityTopN':
        '스페어 홈 등에 「인기」 배지가 붙는 공고의 상위 개수입니다.',
    'newJobBonusWindowHours':
        '공고 등록 후 N시간 동안 인기도 점수에 신규 보너스가 적용되는 기간입니다.',
    'jobPopularityAppWeight':
        '인기도 점수 계산 시 지원 1건당 더해지는 가중치입니다. (지원 수 × 이 값)',
    'jobPopularityViewWeight':
        '인기도 점수 계산 시 조회 1건당 더해지는 가중치입니다.',
    'jobPopularityPremiumBonus':
        '프리미엄 매장 공고에 추가되는 인기도 가산점입니다.',
    'jobPopularityLowEnergyBonus':
        '에너지가 낮은(진입 장벽이 낮은) 공고에 추가되는 인기도 가산점입니다.',
    'spaceMinBookingHours':
        '공간 1건 예약 시 최소 이용 시간(시간)입니다. 샵별 설정이 없으면 이 값이 기본입니다.',
    'spaceBookingWindowDays':
        '오늘부터 며칠 이내의 슬롯만 예약 가능한지 정하는 기간(일)입니다.',
    'spaceDefaultOpenHour':
        '공간 시간대 그리드의 기본 운영 시작 시각(0~23시)입니다.',
    'spaceDefaultCloseHour':
        '공간 시간대 그리드의 기본 운영 종료 시각(0~23시)입니다.',
  };

  static const Map<String, String> groupSectionTitle = {
    'pricing': '수수료 및 가격 설정',
    'quota': '한도 및 쿼터 설정',
    'sanction': '제재 정책 설정',
    'ranking': '랭킹·노출 설정',
    'space': '공간대여 설정',
  };

  static String helpFor(String key) =>
      byKey[key] ?? '이 항목은 서버 비즈니스 정책에 저장되며, 관련 앱 기능에 반영됩니다.';

  static String sectionTitleFor(String groupId, String fallback) =>
      groupSectionTitle[groupId] ?? fallback;

  static Future<void> showHelp(
    BuildContext context, {
    required String label,
    required String key,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label, style: AdminStitchTheme.sectionHeader),
        content: Text(
          helpFor(key),
          style: AdminStitchTheme.bodyMd.copyWith(
            color: AdminStitchTheme.onSurface,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
