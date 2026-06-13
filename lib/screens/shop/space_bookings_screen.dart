import 'package:flutter/material.dart';

import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../widgets/shop_space_bookings/shop_space_booking_card.dart';

class ShopSpaceBookingsScreen extends StatefulWidget {
  const ShopSpaceBookingsScreen({
    super.key,
    this.spaceId,
  });

  final String? spaceId;

  @override
  State<ShopSpaceBookingsScreen> createState() => _ShopSpaceBookingsScreenState();
}

class _ShopSpaceBookingsScreenState extends State<ShopSpaceBookingsScreen> {
  final SpaceRentalService _spaceRentalService = SpaceRentalService();
  List<SpaceBooking> _bookings = [];
  bool _isLoading = true;
  String? _error;
  BookingStatus? _selectedStatus;

  int get _pendingCount =>
      _bookings.where((b) => b.status == BookingStatus.pending).length;

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
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(
          ErrorHandler.handleException(e),
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _approveBooking(String bookingId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('예약 승인'),
        content: const Text('이 예약을 승인하시겠습니까?\n승인 후 예약이 확정됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('승인'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _spaceRentalService.approveBooking(bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('예약이 승인되었습니다. 채팅방이 열렸고 스케줄 현황에 반영됩니다.'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      await _loadBookings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.getUserFriendlyMessage(
              ErrorHandler.handleException(e),
            ),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
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
              style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
              child: const Text('거절'),
            ),
          ],
        );
      },
    );

    if (reason == null) return;

    try {
      await _spaceRentalService.rejectBooking(bookingId, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('예약이 거절되었습니다'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      await _loadBookings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ErrorHandler.getUserFriendlyMessage(
              ErrorHandler.handleException(e),
            ),
          ),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  String _statusLabel(BookingStatus status) {
    return switch (status) {
      BookingStatus.pending => '승인 대기',
      BookingStatus.confirmed => '확정',
      BookingStatus.inProgress => '이용 중',
      BookingStatus.completed => '완료',
      BookingStatus.cancelled => '취소',
    };
  }

  Color _statusColor(BookingStatus status) {
    return switch (status) {
      BookingStatus.pending => AppTheme.orange600,
      BookingStatus.confirmed => AppTheme.primaryPurple,
      BookingStatus.inProgress => AppTheme.primaryBlue,
      BookingStatus.completed => AppTheme.primaryGreen,
      BookingStatus.cancelled => AppTheme.urgentRed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(
        title: widget.spaceId == null ? '예약 관리' : '공간 예약 관리',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ShopSpaceBookingsErrorState(
                  message: _error!,
                  onRetry: _loadBookings,
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: ShopSpaceBookingsHero(
                          pendingCount: _pendingCount,
                          totalCount: _bookings.length,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: ShopSpaceBookingFilterBar(
                          selected: _selectedStatus,
                          onChanged: (status) {
                            setState(() => _selectedStatus = status);
                            _loadBookings();
                          },
                          statusLabel: _statusLabel,
                        ),
                      ),
                      if (_bookings.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _ShopSpaceBookingsEmptyState(),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.spacing4,
                            0,
                            AppTheme.spacing4,
                            AppTheme.spacing6,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final booking = _bookings[index];
                                return ShopSpaceBookingCard(
                                  booking: booking,
                                  statusLabel: _statusLabel,
                                  statusColor: _statusColor,
                                  onApprove: () => _approveBooking(booking.id),
                                  onReject: () => _rejectBooking(booking.id),
                                );
                              },
                              childCount: _bookings.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _ShopSpaceBookingsErrorState extends StatelessWidget {
  const _ShopSpaceBookingsErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopSpaceBookingsEmptyState extends StatelessWidget {
  const _ShopSpaceBookingsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 56,
              color: AppTheme.textTertiary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: AppTheme.spacing3),
            Text(
              '예약 내역이 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
