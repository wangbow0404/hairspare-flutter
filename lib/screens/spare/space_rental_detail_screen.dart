import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../widgets/spare_app_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/global_messenger_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/space_booking_rules.dart';
import '../../utils/space_hourly_slot_grid.dart';
import '../../widgets/space_rental/space_booking_confirm_modal.dart';
import '../../widgets/space_rental/space_rental_time_slot_picker.dart';
import '../../utils/app_bar_navigation.dart';
import '../../core/router/route_extras.dart';
import '../../utils/shell_navigation.dart';
import 'education_screen.dart' show EducationReview;
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
  SpaceRental? _spaceRental;
  bool _isLoading = true;
  bool _hasBooking = false; // 예약 완료 시 연락하기 활성화
  DateTime? _selectedDate;
  HourlySlotCell? _rangeStart;
  HourlySlotCell? _rangeEnd;
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

  List<HourlySlotCell> _cellsForSelectedDate() {
    if (_spaceRental == null || _selectedDate == null) return [];
    return SpaceHourlySlotGrid.buildCells(
      space: _spaceRental!,
      date: _selectedDate!,
      now: DateTime.now(),
    );
  }

  void _clearRange() {
    _rangeStart = null;
    _rangeEnd = null;
  }

  bool _isCellInSelectedRange(HourlySlotCell cell) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    final inRange = SpaceHourlySlotGrid.cellsInRange(
      _cellsForSelectedDate(),
      _rangeStart!,
      _rangeEnd!,
    );
    return inRange.any((c) => c.startTime == cell.startTime);
  }

  /// 선택 범위 안 재탭: 시작 칸 → 앞만 제거, 끝 칸 → 뒤만 제거, 가운데 → 전체 해제.
  void _applyDeselectTap(HourlySlotCell cell, List<HourlySlotCell> cells) {
    final inRange = SpaceHourlySlotGrid.cellsInRange(
      cells,
      _rangeStart!,
      _rangeEnd!,
    );
    final isStart = cell.startTime == _rangeStart!.startTime;
    final isEnd = cell.startTime == _rangeEnd!.startTime;
    final isSingle = inRange.length == 1;
    final isMiddle = !isSingle && !isStart && !isEnd;

    if (isMiddle || isSingle) {
      setState(_clearRange);
      return;
    }

    if (isStart) {
      setState(() {
        _rangeStart = inRange[1];
      });
      return;
    }

    if (isEnd) {
      setState(() {
        _rangeEnd = inRange[inRange.length - 2];
      });
    }
  }

  bool _selectionMeetsMinHours() {
    if (_rangeStart == null || _rangeEnd == null || _spaceRental == null) {
      return false;
    }
    final hours =
        SpaceHourlySlotGrid.durationHours(_rangeStart!, _rangeEnd!);
    return SpaceBookingRules.meetsMinHours(
      selectedHours: hours,
      minHours: _spaceRental!.minHours,
    );
  }

  void _onHourlyCellTap(HourlySlotCell cell) {
    if (!cell.isTappable || _spaceRental == null) return;

    final cells = _cellsForSelectedDate();
    final messenger = sl<GlobalMessengerService>();

    if (_rangeStart == null) {
      setState(() {
        _rangeStart = cell;
        _rangeEnd = cell;
      });
      return;
    }

    if (_isCellInSelectedRange(cell)) {
      _applyDeselectTap(cell, cells);
      return;
    }

    final currentRange = SpaceHourlySlotGrid.cellsInRange(
      cells,
      _rangeStart!,
      _rangeEnd!,
    );
    final rangeFirst = currentRange.first;
    final rangeLast = currentRange.last;

    final HourlySlotCell newStart;
    final HourlySlotCell newEnd;
    if (cell.startTime.isBefore(rangeFirst.startTime)) {
      newStart = cell;
      newEnd = rangeLast;
    } else {
      newStart = rangeFirst;
      newEnd = cell;
    }

    if (!SpaceHourlySlotGrid.isContiguousAvailableRange(
      cells,
      newStart,
      newEnd,
    )) {
      messenger.showInfo('연속된 예약 가능 시간만 선택할 수 있습니다.');
      return;
    }

    setState(() {
      _rangeStart = newStart;
      _rangeEnd = newEnd;
    });
  }

  int _calculateTotalPrice() {
    if (_rangeStart == null || _rangeEnd == null) return 0;
    final hours = SpaceHourlySlotGrid.durationHours(_rangeStart!, _rangeEnd!);
    return hours * (_spaceRental?.pricePerHour ?? 0);
  }

  Future<void> _handleBooking() async {
    if (_rangeStart == null || _rangeEnd == null || _spaceRental == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('예약할 시간대를 선택해주세요.'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }

    final hours = SpaceHourlySlotGrid.durationHours(_rangeStart!, _rangeEnd!);
    if (!SpaceBookingRules.meetsMinHours(
      selectedHours: hours,
      minHours: _spaceRental!.minHours,
    )) {
      sl<GlobalMessengerService>().showInfo(
        SpaceBookingRules.belowMinHoursMessage(_spaceRental!.minHours),
      );
      return;
    }

    final confirmed = await showSpaceBookingConfirmModal(
      context,
      shopName: _spaceRental!.shopName,
      startTime: _rangeStart!.startTime,
      endTime: _rangeEnd!.endTime,
      totalPrice: _calculateTotalPrice(),
    );

    if (!confirmed) return;

    try {
      await _spaceRentalService.bookSpace(
        spaceId: _spaceRental!.id,
        startTime: _rangeStart!.startTime,
        endTime: _rangeEnd!.endTime,
      );

      if (mounted) {
        setState(() => _hasBooking = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('선결제가 완료되었습니다. 샵 승인 후 채팅방이 열리며 예약이 확정됩니다.'),
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
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
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

    final hourlyCells = _cellsForSelectedDate();
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareAppBar(
        showSearch: false,
        showBackButton: true,
        actions: [
          IconButton(
            icon: IconMapper.icon('share', size: 22, color: AppTheme.textPrimary) ??
                const Icon(Icons.share, size: 22, color: AppTheme.textPrimary),
            onPressed: () => Share.share(
              '${_spaceRental!.shopName}\n${_spaceRental!.fullAddress}\n시간당 ${NumberFormat('#,###').format(_spaceRental!.pricePerHour)}원',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                  const SizedBox(height: AppTheme.spacing3),
                  Text(
                    _spaceRental!.shopName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing2),
                  Row(
                    children: [
                      IconMapper.icon('mappin', size: 16, color: AppTheme.textSecondary) ??
                          const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: AppTheme.spacing1),
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
                  const SizedBox(height: AppTheme.spacing4),
                  _buildQuickInfoGrid(),
                  const SizedBox(height: AppTheme.spacing4),
                  _buildDetailInfoBox(),
                  const SizedBox(height: AppTheme.spacing4),
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

            Padding(
              padding: AppTheme.spacingSymmetric(
                horizontal: AppTheme.spacing4,
                vertical: 0,
              ),
              child: SpaceRentalTimeSlotPicker(
                selectedDate: _selectedDate,
                cells: hourlyCells,
                rangeStart: _rangeStart,
                rangeEnd: _rangeEnd,
                totalPrice: _calculateTotalPrice(),
                minHours: _spaceRental!.minHours,
                firstDate: now,
                lastDate: now.add(const Duration(days: 30)),
                onDateChanged: (picked) {
                  setState(() {
                    _selectedDate = picked;
                    _clearRange();
                  });
                },
                onCellTap: _onHourlyCellTap,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),

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

                  const SizedBox(height: AppTheme.spacing4),
                ],
              ),
            ),
          ),
          Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              boxShadow: AppTheme.shadowMd,
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectionMeetsMinHours()
                      ? _handleBooking
                      : (_rangeStart != null && _rangeEnd != null
                          ? () {
                              sl<GlobalMessengerService>().showInfo(
                                SpaceBookingRules.belowMinHoursMessage(
                                  _spaceRental!.minHours,
                                ),
                              );
                            }
                          : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectionMeetsMinHours()
                        ? AppTheme.primaryBlue
                        : (_rangeStart != null && _rangeEnd != null
                            ? AppTheme.orange500
                            : AppTheme.borderGray300),
                    foregroundColor: Colors.white,
                    padding: AppTheme.spacing(AppTheme.spacing4),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                    ),
                  ),
                  child: Text(
                    _selectionMeetsMinHours()
                        ? '예약하기'
                        : (_rangeStart != null && _rangeEnd != null
                            ? '최소 ${_spaceRental!.minHours}시간 선택'
                            : '시간대를 선택해주세요'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
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
            AppTheme.primaryBlue.withValues(alpha: 0.7),
            AppTheme.primaryPurple.withValues(alpha: 0.6),
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
        color: Colors.white.withValues(alpha: 0.6),
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
        _tag('시간당 ${NumberFormat('#,###').format(_spaceRental!.pricePerHour)}원', AppTheme.primaryBlue.withValues(alpha: 0.15), AppTheme.primaryBlue),
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
        const SizedBox(width: AppTheme.spacing3),
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
              const SizedBox(width: AppTheme.spacing2),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
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
        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.location_on, '지역', _spaceRental!.regionName ?? _spaceRental!.address.split(' ').take(2).join(' ')),
          if (_spaceRental!.subwayInfo != null) ...[
            const SizedBox(height: AppTheme.spacing3),
            _infoRow(Icons.directions_transit, '교통', _spaceRental!.subwayInfo!),
          ],
          const SizedBox(height: AppTheme.spacing3),
          _infoRow(
            Icons.access_time,
            '최소 이용',
            _spaceRental!.minHours <= 1
                ? '1시간부터'
                : '${_spaceRental!.minHours}시간',
          ),
          const SizedBox(height: AppTheme.spacing3),
          _infoRow(
            Icons.schedule,
            '운영 시간',
            _spaceRental!.effectiveOperatingSchedule.displaySummary,
          ),
          const SizedBox(height: AppTheme.spacing4),
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
            ? () => AppBarNavigation.pushMessages(context)
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
        const SizedBox(width: AppTheme.spacing3),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              children: [
                TextSpan(text: '$label  ', style: const TextStyle(fontWeight: FontWeight.w500)),
                TextSpan(text: value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
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
      margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
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
              const SizedBox(width: AppTheme.spacing2),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
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
      margin: const EdgeInsets.only(bottom: AppTheme.spacing4),
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
              const Icon(Icons.star, size: 18, color: AppTheme.yellow500),
              const SizedBox(width: AppTheme.spacing2),
              const Text('리뷰', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(width: AppTheme.spacing2),
              TextButton(
                onPressed: () {
                  ShellNavigation.pushReviews(
                    context,
                    ReviewsListRouteArgs(
                      title: '${widget.title} 리뷰',
                      averageRating: widget.averageRating,
                      reviews: widget.reviews
                          .map(
                            (r) => EducationReview(
                              userName: r.userName,
                              rating: r.rating,
                              comment: r.comment,
                              createdAt: r.createdAt,
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('+더보기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: AppTheme.yellow500),
                  const SizedBox(width: AppTheme.spacing1),
                  Text('${widget.averageRating.toStringAsFixed(1)} (${widget.reviews.length}개)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          ...displayed.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 16, color: AppTheme.yellow500)),
                        const SizedBox(width: AppTheme.spacing2),
                        Text(r.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        const Spacer(),
                        Text(DateFormat('M/d', 'ko_KR').format(r.createdAt), style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    Text(r.comment, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
                  ],
                ),
              )),
          if (hasMore)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? '접기' : '열기', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
              ),
            ),
        ],
      ),
    );
  }
}
