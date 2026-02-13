import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../utils/error_handler.dart';

class ShopSpaceBookingsScreen extends StatefulWidget {
  final String? spaceId; // null이면 모든 공간의 예약 조회

  const ShopSpaceBookingsScreen({
    super.key,
    this.spaceId,
  });

  @override
  State<ShopSpaceBookingsScreen> createState() => _ShopSpaceBookingsScreenState();
}

class _ShopSpaceBookingsScreenState extends State<ShopSpaceBookingsScreen> {
  final SpaceRentalService _spaceRentalService = SpaceRentalService();
  List<SpaceBooking> _bookings = [];
  bool _isLoading = true;
  String? _error;
  BookingStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookings = await _spaceRentalService.getSpaceBookings(
        spaceId: widget.spaceId,
        status: _selectedStatus,
      );
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e));
        _isLoading = false;
      });
    }
  }

  Future<void> _approveBooking(String bookingId) async {
    try {
      await _spaceRentalService.approveBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('예약이 승인되었습니다'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        _loadBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _rejectBooking(String bookingId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('예약 거절'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '거절 사유 (선택)',
              hintText: '거절 사유를 입력하세요',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.urgentRed,
              ),
              child: const Text('거절'),
            ),
          ],
        );
      },
    );

    if (reason != null || reason == null) {
      try {
        await _spaceRentalService.rejectBooking(bookingId, reason: reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('예약이 거절되었습니다'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          _loadBookings();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))),
              backgroundColor: AppTheme.urgentRed,
            ),
          );
        }
      }
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return '대기 중';
      case BookingStatus.confirmed:
        return '확정됨';
      case BookingStatus.inProgress:
        return '진행 중';
      case BookingStatus.completed:
        return '완료됨';
      case BookingStatus.cancelled:
        return '취소됨';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return AppTheme.primaryPurple;
      case BookingStatus.inProgress:
        return Colors.blue;
      case BookingStatus.completed:
        return AppTheme.primaryGreen;
      case BookingStatus.cancelled:
        return AppTheme.urgentRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spaceId == null ? '예약 관리' : '공간 예약 관리'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 필터
          Container(
            padding: EdgeInsets.all(AppTheme.spacing3),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: '전체',
                    isSelected: _selectedStatus == null,
                    onTap: () {
                      setState(() {
                        _selectedStatus = null;
                      });
                      _loadBookings();
                    },
                  ),
                  SizedBox(width: AppTheme.spacing2),
                  ...BookingStatus.values.map((status) {
                    return Padding(
                      padding: EdgeInsets.only(right: AppTheme.spacing2),
                      child: _buildFilterChip(
                        label: _getStatusText(status),
                        isSelected: _selectedStatus == status,
                        onTap: () {
                          setState(() {
                            _selectedStatus = status;
                          });
                          _loadBookings();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          
          // 예약 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
                            SizedBox(height: AppTheme.spacing4),
                            Text(
                              _error!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            ElevatedButton(
                              onPressed: _loadBookings,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : _bookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 64, color: AppTheme.textSecondary),
                                SizedBox(height: AppTheme.spacing4),
                                Text(
                                  '예약 내역이 없습니다',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadBookings,
                            child: ListView.builder(
                              padding: EdgeInsets.all(AppTheme.spacing4),
                              itemCount: _bookings.length,
                              itemBuilder: (context, index) {
                                final booking = _bookings[index];
                                return _buildBookingCard(booking);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing3,
          vertical: AppTheme.spacing2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : AppTheme.borderGray,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(SpaceBooking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing4),
      padding: EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.spareName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing2,
                  vertical: AppTheme.spacing1,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Text(
                  _getStatusText(booking.status),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(booking.status),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppTheme.spacing3),
          
          // 예약 시간
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '${DateFormat('yyyy-MM-dd HH:mm').format(booking.startTime)} ~ ${DateFormat('HH:mm').format(booking.endTime)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
          
          SizedBox(height: AppTheme.spacing2),
          
          // 예약 시간 (시간)
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: AppTheme.textSecondary),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '${booking.durationInHours.toStringAsFixed(1)}시간',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
          
          SizedBox(height: AppTheme.spacing2),
          
          // 총 금액
          Row(
            children: [
              const Icon(Icons.attach_money, size: 16, color: AppTheme.primaryPurple),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '총 ${NumberFormat('#,###').format(booking.totalPrice)}원',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          
          if (booking.status == BookingStatus.pending) ...[
            SizedBox(height: AppTheme.spacing4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectBooking(booking.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.urgentRed,
                      side: const BorderSide(color: AppTheme.urgentRed),
                    ),
                    child: const Text('거절'),
                  ),
                ),
                SizedBox(width: AppTheme.spacing2),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveBooking(booking.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('승인'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
