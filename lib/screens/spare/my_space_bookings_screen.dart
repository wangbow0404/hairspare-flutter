import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../utils/error_handler.dart';
import 'space_rental_detail_screen.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// 내 예약 내역 화면
class MySpaceBookingsScreen extends StatefulWidget {
  const MySpaceBookingsScreen({super.key});

  @override
  State<MySpaceBookingsScreen> createState() => _MySpaceBookingsScreenState();
}

class _MySpaceBookingsScreenState extends State<MySpaceBookingsScreen>
    with SingleTickerProviderStateMixin {
  int _currentNavIndex = 0;
  List<SpaceBooking> _bookings = [];
  bool _isLoading = true;
  final SpaceRentalService _spaceRentalService = SpaceRentalService();
  late TabController _tabController;
  BookingStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedStatus = null; // 전체
            break;
          case 1:
            _selectedStatus = BookingStatus.pending;
            break;
          case 2:
            _selectedStatus = BookingStatus.confirmed;
            break;
          case 3:
            _selectedStatus = BookingStatus.completed;
            break;
          case 4:
            _selectedStatus = BookingStatus.cancelled;
            break;
        }
      });
      _loadBookings();
    });
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final bookings = await _spaceRentalService.getMyBookings(
        status: _selectedStatus,
      );
      setState(() {
        _bookings = bookings;
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

  Future<void> _handleCancelBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: const Text('정말 예약을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.urgentRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('예, 취소합니다'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _spaceRentalService.cancelBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('예약이 취소되었습니다.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        _loadBookings();
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

  String _getStatusLabel(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return '대기중';
      case BookingStatus.confirmed:
        return '확정됨';
      case BookingStatus.inProgress:
        return '진행중';
      case BookingStatus.completed:
        return '완료됨';
      case BookingStatus.cancelled:
        return '취소됨';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return AppTheme.yellow400;
      case BookingStatus.confirmed:
        return AppTheme.primaryBlue;
      case BookingStatus.inProgress:
        return AppTheme.primaryGreen;
      case BookingStatus.completed:
        return AppTheme.textSecondary;
      case BookingStatus.cancelled:
        return AppTheme.urgentRed;
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

    final filteredBookings = _selectedStatus == null
        ? _bookings
        : _bookings.where((b) => b.status == _selectedStatus).toList();

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
          '내 예약 내역',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '대기중'),
            Tab(text: '확정됨'),
            Tab(text: '완료됨'),
            Tab(text: '취소됨'),
          ],
        ),
      ),
      body: filteredBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconMapper.icon('calendar', size: 64, color: AppTheme.textTertiary) ??
                      Icon(Icons.calendar_today, size: 64, color: AppTheme.textTertiary),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    '예약 내역이 없습니다',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: AppTheme.spacing(AppTheme.spacing4),
              itemCount: filteredBookings.length,
              itemBuilder: (context, index) {
                final booking = filteredBookings[index];
                final statusColor = _getStatusColor(booking.status);
                final canCancel = booking.canCancel;

                return Container(
                  margin: EdgeInsets.only(bottom: AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.borderGray),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (booking.spaceRental != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpaceRentalDetailScreen(
                                spaceId: booking.spaceRentalId,
                              ),
                            ),
                          );
                        }
                      },
                      borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      child: Padding(
                        padding: AppTheme.spacing(AppTheme.spacing4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking.spaceRental?.shopName ?? '미용실',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: AppTheme.spacing1),
                                      Text(
                                        booking.spaceRental?.fullAddress ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: AppTheme.spacingSymmetric(
                                    horizontal: AppTheme.spacing2,
                                    vertical: AppTheme.spacing1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                                  ),
                                  child: Text(
                                    _getStatusLabel(booking.status),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing3),
                            Divider(height: 1),
                            SizedBox(height: AppTheme.spacing3),
                            Row(
                              children: [
                                IconMapper.icon('clock', size: 16, color: AppTheme.textSecondary) ??
                                    Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                                SizedBox(width: AppTheme.spacing2),
                                Expanded(
                                  child: Text(
                                    '${DateFormat('yyyy년 M월 d일 HH:mm', 'ko_KR').format(booking.startTime)} - ${DateFormat('HH:mm', 'ko_KR').format(booking.endTime)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.spacing2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '총 금액',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${NumberFormat('#,###').format(booking.totalPrice)}원',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (canCancel && booking.status != BookingStatus.cancelled) ...[
                              SizedBox(height: AppTheme.spacing3),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _handleCancelBooking(booking.id),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppTheme.urgentRed),
                                    foregroundColor: AppTheme.urgentRed,
                                    padding: AppTheme.spacing(AppTheme.spacing2),
                                  ),
                                  child: const Text('예약 취소'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavBar(
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
    );
  }
}
