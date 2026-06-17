import 'package:flutter/material.dart';

import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/icon_mapper.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../widgets/shop_my_spaces/shop_my_space_card.dart';
import 'space_bookings_screen.dart';
import 'space_edit_screen.dart';
import 'space_new_screen.dart';

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
  ShopMySpacesFilter _filter = ShopMySpacesFilter.all;
  final Map<String, bool> _statusUpdating = {};

  List<SpaceRental> get _filteredSpaces {
    return switch (_filter) {
      ShopMySpacesFilter.all => _spaces,
      ShopMySpacesFilter.visible => _spaces.where((s) => !s.isHidden).toList(),
      ShopMySpacesFilter.hidden => _spaces.where((s) => s.isHidden).toList(),
    };
  }

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
      if (!mounted) return;
      setState(() {
        _spaces = spaces;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorMessage = ErrorHandler.getUserFriendlyMessage(
        ErrorHandler.handleException(e),
      );
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSpaceStatus(SpaceRental space) async {
    final newStatus = space.status == SpaceStatus.available
        ? SpaceStatus.unavailable
        : SpaceStatus.available;

    setState(() => _statusUpdating[space.id] = true);

    try {
      await _spaceRentalService.updateSpaceRental(
        spaceId: space.id,
        status: newStatus,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == SpaceStatus.available
                ? '예약 받기가 켜졌습니다'
                : '예약 받기가 꺼졌습니다',
          ),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      await _loadSpaces();
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
    } finally {
      if (mounted) {
        setState(() => _statusUpdating[space.id] = false);
      }
    }
  }

  Future<void> _confirmHide(SpaceRental space) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('공간 숨기기'),
        content: const Text(
          '숨기면 스페어 검색·목록에 노출되지 않습니다.\n'
          '예약 관리와 수정은 계속할 수 있어요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('숨기기'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await _spaceRentalService.hideSpaceRental(space.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공간이 숨김 처리되었습니다'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      await _loadSpaces();
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

  Future<void> _confirmUnhide(SpaceRental space) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('숨김 해제'),
        content: const Text('다시 스페어에게 공간이 노출됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('해제'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await _spaceRentalService.unhideSpaceRental(space.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('숨김이 해제되었습니다'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      await _loadSpaces();
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
            style: TextButton.styleFrom(foregroundColor: AppTheme.urgentRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _spaceRentalService.deleteSpaceRental(spaceId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공간이 삭제되었습니다'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      await _loadSpaces();
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

  Future<void> _openNewSpace() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const ShopSpaceNewScreen()),
    );
    if (result == true) await _loadSpaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(
        title: '공간관리',
        actions: [
          IconButton(
            icon: IconMapper.icon('plus', size: 24, color: AppTheme.primaryPurple) ??
                const Icon(Icons.add, color: AppTheme.primaryPurple),
            onPressed: _openNewSpace,
            tooltip: '공간 등록',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ShopMySpacesErrorState(
                  message: _error!,
                  onRetry: _loadSpaces,
                )
              : _spaces.isEmpty
                  ? _ShopMySpacesEmptyState(onAdd: _openNewSpace)
                  : RefreshIndicator(
                      onRefresh: _loadSpaces,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: ShopMySpacesHeroBanner(spaceCount: _spaces.length),
                          ),
                          SliverToBoxAdapter(
                            child: ShopMySpacesFilterBar(
                              selected: _filter,
                              onChanged: (f) => setState(() => _filter = f),
                            ),
                          ),
                          if (_filteredSpaces.isEmpty)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: _ShopMySpacesFilterEmptyState(),
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
                                    final space = _filteredSpaces[index];
                                    return ShopMySpaceCard(
                                      space: space,
                                      isStatusUpdating:
                                          _statusUpdating[space.id] ?? false,
                                      onToggleAvailability: () =>
                                          _toggleSpaceStatus(space),
                                      onBookings: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShopSpaceBookingsScreen(
                                              spaceId: space.id,
                                            ),
                                          ),
                                        );
                                      },
                                      onEdit: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShopSpaceEditScreen(
                                              spaceId: space.id,
                                            ),
                                          ),
                                        ).then((result) {
                                          if (result == true) _loadSpaces();
                                        });
                                      },
                                      onHide: () => _confirmHide(space),
                                      onUnhide: () => _confirmUnhide(space),
                                      onDelete: () => _deleteSpace(space.id),
                                    );
                                  },
                                  childCount: _filteredSpaces.length,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}

class _ShopMySpacesErrorState extends StatelessWidget {
  const _ShopMySpacesErrorState({
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
              '공간 정보를 불러올 수 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing6),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopMySpacesEmptyState extends StatelessWidget {
  const _ShopMySpacesEmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppTheme.primaryPurpleLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.meeting_room_outlined,
                size: 44,
                color: AppTheme.primaryPurple,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              '등록된 공간이 없습니다',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              '공간을 등록하고 스페어에게 대여해 보세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing6),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('공간 등록하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
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
}

class _ShopMySpacesFilterEmptyState extends StatelessWidget {
  const _ShopMySpacesFilterEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing6),
        child: Text(
          '해당 필터에 맞는 공간이 없습니다',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
