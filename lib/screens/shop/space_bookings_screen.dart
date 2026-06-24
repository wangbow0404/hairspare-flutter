import 'package:flutter/material.dart';

import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/shop_space_bookings/shop_space_bookings_filter_bar.dart';
import '../../widgets/shop_space_bookings/shop_space_bookings_pending_hint.dart';
import '../../widgets/stitch/stitch_empty_state.dart';
import '../../widgets/stitch/stitch_list_space_booking_card.dart';

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
  List<SpaceBooking> _allBookings = [];
  bool _isLoading = true;
  String? _error;
  BookingStatus? _selectedStatus;

  int get _pendingCount => _allBookings
      .where((b) => b.status == BookingStatus.pending)
      .length;

  int get _confirmedCount => _allBookings
      .where((b) => b.status == BookingStatus.confirmed)
      .length;

  int get _inProgressCount => _allBookings
      .where((b) => b.status == BookingStatus.inProgress)
      .length;

  int get _completedCount => _allBookings
      .where((b) => b.status == BookingStatus.completed)
      .length;

  List<SpaceBooking> get _filteredBookings {
    if (_selectedStatus == null) return _allBookings;
    return _allBookings.where((b) => b.status == _selectedStatus).toList();
  }

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
      );
      if (!mounted) return;
      setState(() {
        _allBookings = bookings;
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
      BookingStatus.confirmed => AppTheme.stitchPrimary,
      BookingStatus.inProgress => AppTheme.primaryBlue,
      BookingStatus.completed => AppTheme.green600,
      BookingStatus.cancelled => AppTheme.urgentRed,
    };
  }

  String get _emptyMessage {
    if (_allBookings.isEmpty) {
      return '아직 들어온 예약이 없습니다.\n스페어가 공간을 예약하면 여기에 표시됩니다.';
    }
    return '해당 상태의 예약이 없습니다.';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final listBottomPadding =
        kBottomNavigationBarHeight + bottomInset + AppTheme.spacing4;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: widget.spaceId == null ? '예약 관리' : '공간 예약 관리',
        showBackButton: Navigator.canPop(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ShopSpaceBookingsErrorState(
                  message: _error!,
                  onRetry: _loadBookings,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShopSpaceBookingsFilterBar(
                      selected: _selectedStatus,
                      totalCount: _allBookings.length,
                      pendingCount: _pendingCount,
                      confirmedCount: _confirmedCount,
                      inProgressCount: _inProgressCount,
                      completedCount: _completedCount,
                      onChanged: (status) =>
                          setState(() => _selectedStatus = status),
                      statusLabel: _statusLabel,
                    ),
                    ShopSpaceBookingsPendingHint(pendingCount: _pendingCount),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: _filteredBookings.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.only(
                                  bottom: listBottomPadding,
                                ),
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.28,
                                  ),
                                  StitchEmptyState(
                                    message: _emptyMessage,
                                    icon: Icons.event_note_outlined,
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  AppTheme.spacing5,
                                  AppTheme.spacing4,
                                  AppTheme.spacing5,
                                  listBottomPadding,
                                ),
                                itemCount: _filteredBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = _filteredBookings[index];
                                  return StitchListSpaceBookingCard(
                                    booking: booking,
                                    statusLabel: _statusLabel,
                                    statusColor: _statusColor,
                                    onApprove: () =>
                                        _approveBooking(booking.id),
                                    onReject: () =>
                                        _rejectBooking(booking.id),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
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
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.stitchTextSecondary,
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.stitchTextSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.stitchPrimaryContainer,
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
