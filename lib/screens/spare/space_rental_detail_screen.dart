import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/spare_app_bar.dart';
import '../../widgets/custom_date_picker_dialog.dart';
import '../../utils/icon_mapper.dart';
import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../utils/error_handler.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'messages_screen.dart';
import 'reviews_list_screen.dart';

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
  bool _hasBooking = false; // 예약 완료 시 연락하기 활성화
  DateTime? _selectedDate;
  TimeSlot? _selectedStartSlot;
  TimeSlot? _selectedEndSlot;
  final SpaceRentalService _spaceRentalService = SpaceRentalService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadSpaceRental();
    _checkHasBooking();
  }

  Future<void> _checkHasBooking() async {
    try {
      final bookings = await _spaceRentalService.getMyBookings();
      if (mounted) {
        final hasBooking = bookings.any((b) => b.spaceRentalId == widget.spaceId);
        setState(() => _hasBooking = hasBooking);
      }
    } catch (_) {}
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
        setState(() => _hasBooking = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('공간 예약이 완료되었습니다. 연락하기로 미용실과 소통할 수 있습니다.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
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
        appBar: const SpareAppBar(showSearch: false, showBackButton: true),
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
      appBar: SpareAppBar(
        showSearch: false,
        showBackButton: true,
        actions: [
          IconButton(
            icon: IconMapper.icon('share', size: 22, color: AppTheme.textPrimary) ??
                Icon(Icons.share, size: 22, color: AppTheme.textPrimary),
            onPressed: () => Share.share(
              '${_spaceRental!.shopName}\n${_spaceRental!.fullAddress}\n시간당 ${NumberFormat('#,###').format(_spaceRental!.pricePerHour)}원',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 공간 사진
            _buildImageSection(),

            // 미용실 정보
            Padding(
              padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing4, vertical: AppTheme.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTags(),
                  SizedBox(height: AppTheme.spacing3),
                  Text(
                    _spaceRental!.shopName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  _buildQuickInfoGrid(),
                  SizedBox(height: AppTheme.spacing4),
                  _buildDetailInfoBox(),
                  SizedBox(height: AppTheme.spacing4),
                ],
              ),
            ),

            // 시설 박스
            if (_spaceRental!.facilities.isNotEmpty)
              Padding(
                padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing4, vertical: 0),
                child: _buildSectionBox(
                  '시설',
                  Icons.apartment,
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
                ),
              ),

            // 예약 가능 시간 박스
            Padding(
              padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing4, vertical: 0),
              child: Container(
                width: double.infinity,
                padding: AppTheme.spacing(AppTheme.spacing4),
                margin: EdgeInsets.only(bottom: AppTheme.spacing4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '예약 가능 시간',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing3),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await CustomDatePickerDialog.show(
                          context,
                          initialDate: _selectedDate ?? now,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 30)),
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
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    if (availableSlotsForDate.isEmpty)
                      Center(
                        child: Padding(
                          padding: AppTheme.spacing(AppTheme.spacing6),
                          child: Text(
                            '선택한 날짜에 예약 가능한 시간대가 없습니다.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
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
            ),

            if (_spaceRental!.usageNotes != null && _spaceRental!.usageNotes!.isNotEmpty)
              Padding(
                padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing4, vertical: 0),
                child: _buildSectionBox(
                  '이용 안내',
                  Icons.info_outline,
                  Text(
                    _spaceRental!.usageNotes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),

            if (_spaceRental!.description != null && _spaceRental!.description!.isNotEmpty)
              Padding(
                padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing4, vertical: 0),
                child: _buildSectionBox(
                  '상세 설명',
                  Icons.description,
                  Text(
                    _spaceRental!.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

            if (_spaceRental!.reviews != null && _spaceRental!.reviews!.isNotEmpty)
              Padding(
                padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing4, vertical: 0),
                child: _SpaceRentalReviewsSection(
                  title: _spaceRental!.shopName,
                  reviews: _spaceRental!.reviews!,
                  averageRating: _spaceRental!.averageRating ?? 0.0,
                ),
              ),

            SizedBox(height: 80),
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

  Widget _buildImageSection() {
    final hasImage = _spaceRental!.imageUrls != null && _spaceRental!.imageUrls!.isNotEmpty;
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: hasImage ? null : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue.withOpacity(0.7),
            AppTheme.primaryPurple.withOpacity(0.6),
          ],
        ),
        color: hasImage ? AppTheme.backgroundGray : null,
      ),
      child: hasImage
          ? Image.network(
              _spaceRental!.imageUrls!.first,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
            )
          : _buildPlaceholderIcon(),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Center(
      child: Icon(
        Icons.store,
        size: 72,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: AppTheme.spacing2,
      runSpacing: AppTheme.spacing2,
      children: [
        if (_spaceRental!.isPremium)
          _tag('프리미엄', AppTheme.primaryPurple, Colors.white),
        _tag('시간당 ${NumberFormat('#,###').format(_spaceRental!.pricePerHour)}원', AppTheme.primaryBlue.withOpacity(0.15), AppTheme.primaryBlue),
        _tag('${_spaceRental!.facilities.length}개 시설', AppTheme.backgroundGray, AppTheme.textSecondary),
      ],
    );
  }

  Widget _tag(String label, Color bg, Color fg) {
    return Container(
      padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _buildQuickInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: _quickInfoItem(Icons.payments, '시간당', '${NumberFormat('#,###').format(_spaceRental!.pricePerHour)}원', AppTheme.primaryBlue),
        ),
        SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: _quickInfoItem(Icons.apartment, '시설', '${_spaceRental!.facilities.length}개', null),
        ),
      ],
    );
  }

  Widget _quickInfoItem(IconData icon, String label, String value, Color? valueColor) {
    return Container(
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.textSecondary),
              SizedBox(width: AppTheme.spacing2),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ],
          ),
          SizedBox(height: AppTheme.spacing2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor ?? AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildDetailInfoBox() {
    return Container(
      width: double.infinity,
      padding: AppTheme.spacing(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.08),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.location_on, '지역', _spaceRental!.regionName ?? _spaceRental!.address.split(' ').take(2).join(' ')),
          if (_spaceRental!.subwayInfo != null) ...[
            SizedBox(height: AppTheme.spacing3),
            _infoRow(Icons.directions_transit, '교통', _spaceRental!.subwayInfo!),
          ],
          SizedBox(height: AppTheme.spacing3),
          _infoRow(Icons.access_time, '최소 이용', '${_spaceRental!.minHours}시간'),
          SizedBox(height: AppTheme.spacing4),
          _buildContactButton(),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    final canContact = _hasBooking;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: canContact
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                );
              }
            : null,
        icon: Icon(
          Icons.chat_bubble_outline,
          size: 18,
          color: canContact ? AppTheme.primaryBlue : AppTheme.textTertiary,
        ),
        label: Text(
          canContact ? '연락하기' : '예약 후 연락 가능',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: canContact ? AppTheme.primaryBlue : AppTheme.textTertiary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: canContact ? AppTheme.primaryBlue : AppTheme.borderGray),
          padding: AppTheme.spacingSymmetric(horizontal: AppTheme.spacing4, vertical: AppTheme.spacing3),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              children: [
                TextSpan(text: '$label  ', style: TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(text: value, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBox(String title, IconData icon, Widget child) {
    return Container(
      width: double.infinity,
      padding: AppTheme.spacing(AppTheme.spacing4),
      margin: EdgeInsets.only(bottom: AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryPurple),
              SizedBox(width: AppTheme.spacing2),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          child,
        ],
      ),
    );
  }
}

class _SpaceRentalReviewsSection extends StatefulWidget {
  final String title;
  final List<SpaceRentalReview> reviews;
  final double averageRating;

  const _SpaceRentalReviewsSection({required this.title, required this.reviews, required this.averageRating});

  @override
  State<_SpaceRentalReviewsSection> createState() => _SpaceRentalReviewsSectionState();
}

class _SpaceRentalReviewsSectionState extends State<_SpaceRentalReviewsSection> {
  static const int _initialCount = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final displayed = _expanded ? widget.reviews : widget.reviews.take(_initialCount).toList();
    final hasMore = widget.reviews.length > _initialCount;

    return Container(
      width: double.infinity,
      padding: AppTheme.spacing(AppTheme.spacing4),
      margin: EdgeInsets.only(bottom: AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, size: 18, color: AppTheme.yellow500),
              SizedBox(width: AppTheme.spacing2),
              Text('리뷰', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              SizedBox(width: AppTheme.spacing2),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewsListScreen(
                        title: '${widget.title} 리뷰',
                        averageRating: widget.averageRating,
                        reviews: widget.reviews
                            .map((r) => ReviewItem(
                                  userName: r.userName,
                                  rating: r.rating,
                                  comment: r.comment,
                                  createdAt: r.createdAt,
                                ))
                            .toList(),
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('+더보기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.star, size: 18, color: AppTheme.yellow500),
                  SizedBox(width: AppTheme.spacing1),
                  Text('${widget.averageRating.toStringAsFixed(1)} (${widget.reviews.length}개)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          ...displayed.map((r) => Padding(
                padding: EdgeInsets.only(bottom: AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 16, color: AppTheme.yellow500)),
                        SizedBox(width: AppTheme.spacing2),
                        Text(r.userName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        const Spacer(),
                        Text(DateFormat('M/d', 'ko_KR').format(r.createdAt), style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing2),
                    Text(r.comment, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
                  ],
                ),
              )),
          if (hasMore)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? '접기' : '열기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
              ),
            ),
        ],
      ),
    );
  }
}
