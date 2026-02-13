import 'package:flutter/material.dart';
import '../models/space_rental.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';
import 'package:intl/intl.dart';

/// 공간대여 카드 위젯
class SpaceRentalCard extends StatelessWidget {
  final SpaceRental spaceRental;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const SpaceRentalCard({
    super.key,
    required this.spaceRental,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  String _formatPrice(int price) {
    return '₩${NumberFormat('#,###').format(price)}';
  }

  /// 예약 가능한 시간대 요약 텍스트 생성
  String _getAvailableTimeSummary() {
    if (spaceRental.availableSlots.isEmpty) {
      return '예약 불가';
    }

    final availableSlots = spaceRental.availableSlots
        .where((slot) => slot.isAvailable)
        .toList();

    if (availableSlots.isEmpty) {
      return '예약 불가';
    }

    // 오늘 날짜의 예약 가능한 시간대 찾기
    final today = DateTime.now();
    final todaySlots = availableSlots.where((slot) {
      final slotDate = DateTime(
        slot.startTime.year,
        slot.startTime.month,
        slot.startTime.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);
      return slotDate.isAtSameMomentAs(todayDate);
    }).toList();

    if (todaySlots.isNotEmpty) {
      // 오늘 예약 가능한 시간대가 있으면 표시
      final firstSlot = todaySlots.first;
      final lastSlot = todaySlots.last;
      return '오늘 ${DateFormat('HH:mm').format(firstSlot.startTime)}-${DateFormat('HH:mm').format(lastSlot.endTime)}';
    }

    // 오늘 없으면 가장 가까운 날짜의 시간대 표시
    availableSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
    final nearestSlot = availableSlots.first;
    final slotDate = DateTime(
      nearestSlot.startTime.year,
      nearestSlot.startTime.month,
      nearestSlot.startTime.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysDiff = slotDate.difference(todayDate).inDays;

    String dateStr;
    if (daysDiff == 0) {
      dateStr = '오늘';
    } else if (daysDiff == 1) {
      dateStr = '내일';
    } else {
      dateStr = DateFormat('M월 d일', 'ko_KR').format(slotDate);
    }

    return '$dateStr ${DateFormat('HH:mm').format(nearestSlot.startTime)}-${DateFormat('HH:mm').format(nearestSlot.endTime)}';
  }

  /// 시설 아이콘 매핑
  IconData? _getFacilityIcon(String facility) {
    final facilityLower = facility.toLowerCase();
    if (facilityLower.contains('의자') || facilityLower.contains('chair')) {
      return Icons.chair;
    } else if (facilityLower.contains('세트') || facilityLower.contains('set')) {
      return Icons.content_cut;
    } else if (facilityLower.contains('샴푸') || facilityLower.contains('shampoo')) {
      return Icons.water_drop;
    } else if (facilityLower.contains('드라이') || facilityLower.contains('dry')) {
      return Icons.air;
    } else if (facilityLower.contains('미러') || facilityLower.contains('mirror')) {
      return Icons.image; // mirror 대신 image 사용
    }
    return Icons.check_circle;
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = spaceRental.status == SpaceStatus.available &&
        spaceRental.availableSlots.any((slot) => slot.isAvailable);
    final availableTimeSummary = _getAvailableTimeSummary();

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(
          color: isAvailable
              ? AppTheme.primaryBlue.withOpacity(0.3)
              : AppTheme.borderGray,
          width: isAvailable ? 2 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
          child: Padding(
            padding: AppTheme.spacing(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 미용실명과 예약 가능 배지
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spaceRental.shopName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing1),
                          // 주소
                          Row(
                            children: [
                              IconMapper.icon(
                                'mappin',
                                size: 14,
                                color: AppTheme.textSecondary,
                              ) ??
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                              SizedBox(width: AppTheme.spacing1),
                              Expanded(
                                child: Text(
                                  spaceRental.fullAddress,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 예약 가능 배지
                    Container(
                      padding: AppTheme.spacingSymmetric(
                        horizontal: AppTheme.spacing2,
                        vertical: AppTheme.spacing1,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppTheme.primaryGreen.withOpacity(0.1)
                            : AppTheme.textTertiary.withOpacity(0.1),
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                      ),
                      child: Text(
                        isAvailable ? '예약 가능' : '예약 불가',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isAvailable
                              ? AppTheme.primaryGreen
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing3),

                // 예약 가능 시간대
                Container(
                  padding: AppTheme.spacing(AppTheme.spacing2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      IconMapper.icon(
                        'clock',
                        size: 16,
                        color: AppTheme.primaryBlue,
                      ) ??
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.primaryBlue,
                          ),
                      SizedBox(width: AppTheme.spacing2),
                      Text(
                        availableTimeSummary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.spacing3),

                // 하단: 가격과 시설
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 가격
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '시간당',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacing1 / 2),
                        Text(
                          _formatPrice(spaceRental.pricePerHour),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    // 시설 아이콘
                    if (spaceRental.facilities.isNotEmpty)
                      Wrap(
                        spacing: AppTheme.spacing2,
                        children: spaceRental.facilities.take(4).map((facility) {
                          final icon = _getFacilityIcon(facility);
                          return Container(
                            padding: AppTheme.spacingSymmetric(
                              horizontal: AppTheme.spacing2,
                              vertical: AppTheme.spacing1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundGray,
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  icon,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: AppTheme.spacing1 / 2),
                                Text(
                                  facility,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
