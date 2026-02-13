import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// 공간대여 상세 화면
class SpaceRentalDetailScreen extends StatefulWidget {
  final String spaceId;

  const SpaceRentalDetailScreen({
    super.key,
    required this.spaceId,
  });

  @override
  State<SpaceRentalDetailScreen> createState() => _SpaceRentalDetailScreenState();
}

class _SpaceRentalDetailScreenState extends State<SpaceRentalDetailScreen> {
  int _currentNavIndex = 0;
  SpaceRental? _spaceRental;
  bool _isLoading = true;
  DateTime? _selectedDate;
  TimeSlot? _selectedStartSlot;
  TimeSlot? _selectedEndSlot;
  final SpaceRentalService _spaceRentalService = SpaceRentalService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadSpaceRental();
  }

  Future<void> _loadSpaceRental() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final space = await _spaceRentalService.getSpaceRentalById(widget.spaceId);
      setState(() {
        _spaceRental = space;
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final appException = ErrorHandler.handleException(error);
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(appException);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  void _selectTimeSlot(TimeSlot slot) {
    setState(() {
      if (_selectedStartSlot == null) {
        _selectedStartSlot = slot;
        _selectedEndSlot = slot;
      } else if (_selectedStartSlot == slot) {
        // 같은 슬롯 클릭 시 선택 해제
        _selectedStartSlot = null;
        _selectedEndSlot = null;
      } else {
        // 다른 슬롯 클릭 시 범위 선택
        if (slot.startTime.isBefore(_selectedStartSlot!.startTime)) {
          _selectedStartSlot = slot;
        } else {
          _selectedEndSlot = slot;
        }
      }
    });
  }

  int _calculateTotalPrice() {
    if (_selectedStartSlot == null || _selectedEndSlot == null) {
      return 0;
    }
    final duration = _selectedEndSlot!.endTime.difference(_selectedStartSlot!.startTime).inHours;
    return duration * (_spaceRental?.pricePerHour ?? 0);
  }

  Future<void> _handleBooking() async {
    if (_selectedStartSlot == null || _selectedEndSlot == null || _spaceRental == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('예약할 시간대를 선택해주세요.'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }

    // 예약 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공간 예약'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('미용실: ${_spaceRental!.shopName}'),
            const SizedBox(height: 8),
            Text('예약 시간: ${DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(_selectedStartSlot!.startTime)} - ${DateFormat('HH:mm', 'ko_KR').format(_selectedEndSlot!.endTime)}'),
            const SizedBox(height: 8),
            Text('총 금액: ${NumberFormat('#,###').format(_calculateTotalPrice())}원'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('예약하기'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _spaceRentalService.bookSpace(
        spaceId: _spaceRental!.id,
        startTime: _selectedStartSlot!.startTime,
        endTime: _selectedEndSlot!.endTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공간 예약이 완료되었습니다.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        final appException = ErrorHandler.handleException(error);
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(appException);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_spaceRental == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(
            '공간 정보를 불러올 수 없습니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    final availableSlotsForDate = _selectedDate != null
        ? _spaceRental!.getAvailableSlotsForDate(_selectedDate!)
        : [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
              const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '공간 상세',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 공간 사진 (있으면)
            if (_spaceRental!.imageUrls != null && _spaceRental!.imageUrls!.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGray,
                ),
                child: Image.network(
                  _spaceRental!.imageUrls!.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.backgroundGray,
                      child: Icon(
                        Icons.store,
                        size: 64,
                        color: AppTheme.textTertiary,
                      ),
                    );
                  },
                ),
              ),

            // 미용실 정보
            Container(
              padding: AppTheme.spacing(AppTheme.spacing4),
              color: AppTheme.backgroundWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _spaceRental!.shopName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  Row(
                    children: [
                      IconMapper.icon('mappin', size: 16, color: AppTheme.textSecondary) ??
                          Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                      SizedBox(width: AppTheme.spacing1),
                      Expanded(
                        child: Text(
                          _spaceRental!.fullAddress,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 가격 정보
                  Container(
                    padding: AppTheme.spacing(AppTheme.spacing3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '시간당',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${NumberFormat('#,###').format(_spaceRental!.pricePerHour)}원',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacing2),

            // 시설 정보
            if (_spaceRental!.facilities.isNotEmpty)
              Container(
                padding: AppTheme.spacing(AppTheme.spacing4),
                color: AppTheme.backgroundWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '시설',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing3),
                    Wrap(
                      spacing: AppTheme.spacing2,
                      runSpacing: AppTheme.spacing2,
                      children: _spaceRental!.facilities.map((facility) {
                        return Container(
                          padding: AppTheme.spacingSymmetric(
                            horizontal: AppTheme.spacing3,
                            vertical: AppTheme.spacing2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundGray,
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                          ),
                          child: Text(
                            facility,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            SizedBox(height: AppTheme.spacing2),

            // 예약 가능 시간대
            Container(
              padding: AppTheme.spacing(AppTheme.spacing4),
              color: AppTheme.backgroundWhite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '예약 가능 시간',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  // 날짜 선택
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        locale: const Locale('ko', 'KR'),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _selectedStartSlot = null;
                          _selectedEndSlot = null;
                        });
                      }
                    },
                    icon: IconMapper.icon('calendar', size: 16, color: AppTheme.textSecondary) ??
                        const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                    label: Text(
                      _selectedDate != null
                          ? DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(_selectedDate!)
                          : '날짜 선택',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: _selectedDate != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.borderGray),
                      padding: AppTheme.spacing(AppTheme.spacing3),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  // 시간대 그리드
                  if (availableSlotsForDate.isEmpty)
                    Center(
                      child: Padding(
                        padding: AppTheme.spacing(AppTheme.spacing8),
                        child: Text(
                          '선택한 날짜에 예약 가능한 시간대가 없습니다.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: AppTheme.spacing2,
                      runSpacing: AppTheme.spacing2,
                      children: availableSlotsForDate.map((slot) {
                        final isSelected = _selectedStartSlot == slot || _selectedEndSlot == slot;
                        final isInRange = _selectedStartSlot != null &&
                            _selectedEndSlot != null &&
                            slot.startTime.isAfter(_selectedStartSlot!.startTime.subtract(const Duration(seconds: 1))) &&
                            slot.startTime.isBefore(_selectedEndSlot!.endTime.add(const Duration(seconds: 1)));

                        return GestureDetector(
                          onTap: () => _selectTimeSlot(slot),
                          child: Container(
                            padding: AppTheme.spacingSymmetric(
                              horizontal: AppTheme.spacing3,
                              vertical: AppTheme.spacing2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected || isInRange
                                  ? AppTheme.primaryBlue
                                  : AppTheme.backgroundGray,
                              borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                              border: Border.all(
                                color: isSelected || isInRange
                                    ? AppTheme.primaryBlue
                                    : AppTheme.borderGray,
                              ),
                            ),
                            child: Text(
                              '${DateFormat('HH:mm', 'ko_KR').format(slot.startTime)}-${DateFormat('HH:mm', 'ko_KR').format(slot.endTime)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                fontWeight: isSelected || isInRange ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected || isInRange
                                    ? Colors.white
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  // 선택된 시간대 요약
                  if (_selectedStartSlot != null && _selectedEndSlot != null) ...[
                    SizedBox(height: AppTheme.spacing4),
                    Container(
                      padding: AppTheme.spacing(AppTheme.spacing3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '예약 시간',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing1 / 2),
                              Text(
                                '${DateFormat('HH:mm', 'ko_KR').format(_selectedStartSlot!.startTime)} - ${DateFormat('HH:mm', 'ko_KR').format(_selectedEndSlot!.endTime)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '총 금액',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing1 / 2),
                              Text(
                                '${NumberFormat('#,###').format(_calculateTotalPrice())}원',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacing2),

            // 설명
            if (_spaceRental!.description != null && _spaceRental!.description!.isNotEmpty)
              Container(
                padding: AppTheme.spacing(AppTheme.spacing4),
                color: AppTheme.backgroundWhite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '상세 설명',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    Text(
                      _spaceRental!.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 80), // 하단 네비게이션 바 여백
          ],
        ),
      ),
      // 예약하기 버튼 (하단 고정)
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              boxShadow: AppTheme.shadowMd,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedStartSlot != null && _selectedEndSlot != null
                    ? _handleBooking
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedStartSlot != null && _selectedEndSlot != null
                      ? AppTheme.primaryBlue
                      : AppTheme.borderGray300,
                  foregroundColor: Colors.white,
                  padding: AppTheme.spacing(AppTheme.spacing4),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  ),
                ),
                child: Text(
                  _selectedStartSlot != null && _selectedEndSlot != null
                      ? '예약하기'
                      : '시간대를 선택해주세요',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          BottomNavBar(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              setState(() {
                _currentNavIndex = index;
              });
              
              // 네비게이션 처리
              switch (index) {
                case 0:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SpareHomeScreen()),
                  );
                  break;
                case 1:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentScreen()),
                  );
                  break;
                case 2:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritesScreen()),
                  );
                  break;
                case 3:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
