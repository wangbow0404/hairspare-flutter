import 'package:flutter/material.dart';

import '../../models/space_rental.dart';
import '../../services/space_rental_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/deferred_route_body.dart';
import '../../utils/error_handler.dart';
import '../../utils/shell_navigation.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/shop_my_spaces/shop_my_spaces_filter_bar.dart';
import '../../widgets/stitch/stitch_list_space_card.dart';

/// Shop 공간관리 화면
class ShopMySpacesScreen extends StatefulWidget {
  const ShopMySpacesScreen({super.key});

  @override
  State<ShopMySpacesScreen> createState() => _ShopMySpacesScreenState();
}

class _ShopMySpacesScreenState extends State<ShopMySpacesScreen>
    with DeferredRouteBodyMixin {
  final SpaceRentalService _spaceRentalService = SpaceRentalService();
  List<SpaceRental> _spaces = [];
  Map<String, int> _pendingBookingCounts = {};
  bool _isLoading = true;
  String? _error;
  ShopMySpacesFilter _filter = ShopMySpacesFilter.all;
  final Map<String, bool> _visibilityUpdating = {};

  int get _visibleCount => _spaces.where((s) => !s.isHidden).length;
  int get _hiddenCount => _spaces.where((s) => s.isHidden).length;

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
      final results = await Future.wait([
        _spaceRentalService.getMySpaceRentals(),
        _spaceRentalService.getSpaceBookings(status: BookingStatus.pending),
      ]);
      if (!mounted) return;

      final spaces = results[0] as List<SpaceRental>;
      final pendingBookings = results[1] as List<SpaceBooking>;
      final pendingBySpace = <String, int>{};
      for (final booking in pendingBookings) {
        pendingBySpace.update(
          booking.spaceRentalId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      setState(() {
        _spaces = spaces;
        _pendingBookingCounts = pendingBySpace;
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

  Future<void> _toggleVisibility(SpaceRental space, bool visible) async {
    setState(() => _visibilityUpdating[space.id] = true);

    try {
      if (visible) {
        await _spaceRentalService.unhideSpaceRental(space.id);
      } else {
        await _spaceRentalService.hideSpaceRental(space.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(visible ? '공간이 노출됩니다' : '공간이 숨김 처리되었습니다'),
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
        setState(() => _visibilityUpdating[space.id] = false);
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
    await _toggleVisibility(space, false);
  }

  Future<void> _confirmUnhide(SpaceRental space) async {
    await _toggleVisibility(space, true);
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
    final result = await ShellNavigation.pushShopSpaceNew(context);
    if (result == true) await _loadSpaces();
  }

  @override
  Widget build(BuildContext context) {
    const fabBottomPadding = AppTheme.spacing4;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SpareSubpageAppBar(
        title: '공간관리',
        showBackButton: Navigator.canPop(context),
      ),
      floatingActionButton: _spaces.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: fabBottomPadding),
              child: FloatingActionButton(
                onPressed: _openNewSpace,
                backgroundColor: AppTheme.stitchPrimaryContainer,
                foregroundColor: Colors.white,
                elevation: 4,
                child: const Icon(Icons.add, size: 28),
              ),
            ),
      body: deferredBody(
        loading: const Center(child: CircularProgressIndicator()),
        builder: (context) => _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ShopMySpacesErrorState(
                    message: _error!,
                    onRetry: _loadSpaces,
                  )
                : _spaces.isEmpty
                    ? _ShopMySpacesEmptyState(onAdd: _openNewSpace)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ShopMySpacesFilterBar(
                            selected: _filter,
                            totalCount: _spaces.length,
                            visibleCount: _visibleCount,
                            hiddenCount: _hiddenCount,
                            onChanged: (f) => setState(() => _filter = f),
                          ),
                          Expanded(
                            child: _filteredSpaces.isEmpty
                                ? const _ShopMySpacesFilterEmptyState()
                                : RefreshIndicator(
                                    onRefresh: _loadSpaces,
                                    child: ListView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                        AppTheme.spacing5,
                                        AppTheme.spacing4,
                                        AppTheme.spacing5,
                                        88,
                                      ),
                                      itemCount: _filteredSpaces.length,
                                      itemBuilder: (context, index) {
                                        final space = _filteredSpaces[index];
                                        return StitchListSpaceCard(
                                          space: space,
                                          pendingBookingCount:
                                              _pendingBookingCounts[
                                                      space.id] ??
                                                  0,
                                          isVisibilityUpdating:
                                              _visibilityUpdating[space.id] ??
                                                  false,
                                          onToggleVisibility: (visible) =>
                                              _toggleVisibility(
                                            space,
                                            visible,
                                          ),
                                          onBookings: () {
                                            ShellNavigation
                                                .pushShopSpaceBookings(
                                              context,
                                              space.id,
                                            );
                                          },
                                          onEdit: () {
                                            ShellNavigation.pushShopSpaceEdit(
                                              context,
                                              space.id,
                                            ).then((_) => _loadSpaces());
                                          },
                                          onHide: () => _confirmHide(space),
                                          onUnhide: () =>
                                              _confirmUnhide(space),
                                          onDelete: () =>
                                              _deleteSpace(space.id),
                                        );
                                      },
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
                backgroundColor: AppTheme.stitchPrimaryContainer,
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
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 32,
                color: AppTheme.stitchTextSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              '등록된 공간이 없습니다',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            Text(
              '스페어 디자이너를 맞이할\n새로운 공간을 등록해주세요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.stitchTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing6),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.stitchPrimaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '공간 등록하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
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
            color: AppTheme.stitchTextSecondary,
          ),
        ),
      ),
    );
  }
}
