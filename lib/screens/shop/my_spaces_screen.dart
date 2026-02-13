import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/region_helper.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'space_new_screen.dart';
import 'space_edit_screen.dart';
import 'space_bookings_screen.dart';

/// Shop 공간관리 화면
class ShopMySpacesScreen extends StatefulWidget {
  const ShopMySpacesScreen({super.key});

  @override
  State<ShopMySpacesScreen> createState() => _ShopMySpacesScreenState();
}

class _ShopMySpacesScreenState extends State<ShopMySpacesScreen> {
  final SpaceRentalService _spaceRentalService = SpaceRentalService();
  List<SpaceRental> _spaces = [];
  bool _isLoading = true;
  String? _error;
  int _currentNavIndex = 3; // 프로필 탭
  final Map<String, bool> _statusUpdating = {}; // 상태 업데이트 중인 공간 ID

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final spaces = await _spaceRentalService.getMySpaceRentals();
      setState(() {
        _spaces = spaces;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        final appException = ErrorHandler.handleException(e);
        final errorMessage = ErrorHandler.getUserFriendlyMessage(appException);
        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
        // 에러가 발생했을 때도 SnackBar로 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _toggleSpaceStatus(SpaceRental space) async {
    final newStatus = space.status == SpaceStatus.available
        ? SpaceStatus.unavailable
        : SpaceStatus.available;

    setState(() {
      _statusUpdating[space.id] = true;
    });

    try {
      await _spaceRentalService.updateSpaceRental(
        spaceId: space.id,
        status: newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == SpaceStatus.available
                  ? '공간이 예약 가능 상태로 변경되었습니다'
                  : '공간이 예약 불가능 상태로 변경되었습니다',
            ),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        _loadSpaces();
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
    } finally {
      if (mounted) {
        setState(() {
          _statusUpdating[space.id] = false;
        });
      }
    }
  }

  Future<void> _deleteSpace(String spaceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('공간 삭제'),
        content: const Text('정말 이 공간을 삭제하시겠습니까?\n삭제된 공간은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.urgentRed,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _spaceRentalService.deleteSpaceRental(spaceId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('공간이 삭제되었습니다'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
          _loadSpaces();
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

  @override
  Widget build(BuildContext context) {
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
          '공간관리',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: IconMapper.icon('plus', size: 24, color: AppTheme.primaryPurple) ??
                const Icon(Icons.add, color: AppTheme.primaryPurple),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShopSpaceNewScreen(),
                ),
              );
              if (result == true) {
                _loadSpaces();
              }
            },
            tooltip: '공간 등록',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _spaces.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadSpaces,
                      child: ListView.builder(
                        padding: EdgeInsets.all(AppTheme.spacing4),
                        itemCount: _spaces.length,
                        itemBuilder: (context, index) {
                          final space = _spaces[index];
                          return _buildSpaceCard(space);
                        },
                      ),
                    ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopPaymentScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopFavoritesScreen()),
              );
              break;
            case 3:
              // 현재 화면
              break;
          }
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              '공간 정보를 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacing2),
            Text(
              _error ?? '알 수 없는 오류가 발생했습니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacing6),
            ElevatedButton.icon(
              onPressed: _loadSpaces,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing5,
                  vertical: AppTheme.spacing3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: IconMapper.icon('building', size: 50, color: AppTheme.primaryPurple) ??
                  const Icon(Icons.business_outlined, size: 50, color: AppTheme.primaryPurple),
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              '등록된 공간이 없습니다',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppTheme.spacing2),
            Text(
              '공간을 등록하여 대여 서비스를 시작해보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacing6),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShopSpaceNewScreen(),
                  ),
                );
                if (result == true) {
                  _loadSpaces();
                }
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('공간 등록하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing5,
                  vertical: AppTheme.spacing3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceCard(SpaceRental space) {
    final hasImage = space.imageUrls != null && space.imageUrls!.isNotEmpty;
    final isUpdating = _statusUpdating[space.id] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 및 상태 배지
          Stack(
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusLg),
                    topRight: Radius.circular(AppTheme.radiusLg),
                  ),
                  child: Image.network(
                    space.imageUrls!.first,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  ),
                )
              else
                _buildPlaceholderImage(),
              // 상태 배지
              Positioned(
                top: AppTheme.spacing3,
                right: AppTheme.spacing3,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing3,
                    vertical: AppTheme.spacing1 + AppTheme.spacing1 / 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(space.status).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getStatusText(space.status),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 공간 정보
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 및 상태 토글
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        space.shopName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    // 상태 토글 스위치
                    if (!isUpdating)
                      Switch(
                        value: space.status == SpaceStatus.available,
                        onChanged: (value) => _toggleSpaceStatus(space),
                        activeColor: AppTheme.primaryGreen,
                      )
                    else
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),

                SizedBox(height: AppTheme.spacing3),

                // 주소
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(width: AppTheme.spacing1),
                    Expanded(
                      child: Text(
                        space.fullAddress,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.spacing2),

                // 지역
                Row(
                  children: [
                    Icon(
                      Icons.map,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(width: AppTheme.spacing1),
                    Text(
                      RegionHelper.getRegionName(space.regionId),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppTheme.spacing3),

                // 가격
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 20,
                        color: AppTheme.primaryPurple,
                      ),
                      SizedBox(width: AppTheme.spacing1),
                      Text(
                        '시간당 ${NumberFormat('#,###').format(space.pricePerHour)}원',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // 시설 목록
                if (space.facilities.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacing3),
                  Wrap(
                    spacing: AppTheme.spacing2,
                    runSpacing: AppTheme.spacing2,
                    children: space.facilities.map((facility) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing2 + AppTheme.spacing1,
                          vertical: AppTheme.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.purple100,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          facility,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.purple700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                SizedBox(height: AppTheme.spacing4),

                // 구분선
                Divider(color: AppTheme.borderGray),

                SizedBox(height: AppTheme.spacing3),

                // 액션 버튼
                Row(
                  children: [
                    // 예약 관리 버튼
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShopSpaceBookingsScreen(spaceId: space.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: const Text('예약 관리'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                          side: const BorderSide(color: AppTheme.primaryPurple),
                          padding: EdgeInsets.symmetric(
                            vertical: AppTheme.spacing2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    // 수정 버튼
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShopSpaceEditScreen(spaceId: space.id),
                            ),
                          ).then((result) {
                            if (result == true) {
                              _loadSpaces();
                            }
                          });
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('수정'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textSecondary,
                          side: const BorderSide(color: AppTheme.borderGray),
                          padding: EdgeInsets.symmetric(
                            vertical: AppTheme.spacing2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    // 삭제 버튼
                    IconButton(
                      onPressed: () => _deleteSpace(space.id),
                      icon: const Icon(Icons.delete_outline),
                      color: AppTheme.urgentRed,
                      tooltip: '삭제',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLg),
          topRight: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Center(
        child: IconMapper.icon('image', size: 48, color: AppTheme.textTertiary) ??
            const Icon(Icons.image_outlined, size: 48, color: AppTheme.textTertiary),
      ),
    );
  }

  Color _getStatusColor(SpaceStatus status) {
    switch (status) {
      case SpaceStatus.available:
        return AppTheme.primaryGreen;
      case SpaceStatus.booked:
        return AppTheme.primaryPurple;
      case SpaceStatus.unavailable:
        return AppTheme.urgentRed;
    }
  }

  String _getStatusText(SpaceStatus status) {
    switch (status) {
      case SpaceStatus.available:
        return '예약 가능';
      case SpaceStatus.booked:
        return '예약됨';
      case SpaceStatus.unavailable:
        return '사용 불가';
    }
  }
}
