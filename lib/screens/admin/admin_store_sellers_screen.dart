import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/store_seller.dart';
import '../../services/store_seller_service.dart';
import '../../theme/admin_stitch_theme.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../widgets/admin/admin_action_dialog.dart';
import '../../widgets/admin/admin_stitch_list_screen_shell.dart';
import '../../widgets/admin/admin_stitch_widgets.dart';

/// 스토어 판매자(셀러) 신청 심사 큐.
class AdminStoreSellersScreen extends StatefulWidget {
  const AdminStoreSellersScreen({super.key});

  @override
  State<AdminStoreSellersScreen> createState() =>
      _AdminStoreSellersScreenState();
}

class _AdminStoreSellersScreenState extends State<AdminStoreSellersScreen> {
  final StoreSellerService _sellerService = StoreSellerService();
  final TextEditingController _searchController = TextEditingController();

  List<StoreSeller> _sellers = [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  StoreSellerStatus? _statusFilter = StoreSellerStatus.pending;
  String _searchQuery = '';
  Timer? _searchDebounceTimer;

  static const _statusTabs = ['대기', '승인', '반려', '전체'];
  static const _statusMap = {
    '대기': StoreSellerStatus.pending,
    '승인': StoreSellerStatus.approved,
    '반려': StoreSellerStatus.rejected,
  };

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSellers({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasLoadError = false;
      });
    }
    try {
      var sellers = await _sellerService.getSellers(status: _statusFilter);
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        sellers = sellers
            .where(
              (s) =>
                  s.shopName.toLowerCase().contains(q) ||
                  s.ownerName.toLowerCase().contains(q),
            )
            .toList();
      }
      if (!mounted) return;
      setState(() {
        _sellers = sellers;
        _isLoading = false;
        _hasLoadError = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (showLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '판매자 목록 조회 실패: ${ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e))}',
            ),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
      setState(() {
        _isLoading = false;
        _hasLoadError = true;
      });
    }
  }

  String _selectedStatusTab() {
    if (_statusFilter == null) return '전체';
    for (final entry in _statusMap.entries) {
      if (entry.value == _statusFilter) return entry.key;
    }
    return '대기';
  }

  String _requestId(String id) {
    final suffix = id.replaceAll(RegExp(r'[^0-9]'), '');
    final padded = suffix.padLeft(4, '0');
    return '#SELLER-$padded';
  }

  Future<void> _approve(StoreSeller seller) async {
    final confirmed = await AdminActionDialog.confirm(
      context,
      title: '판매자 승인',
      message: '${seller.shopName}의 스토어 판매자 신청을 승인하시겠습니까?',
      confirmLabel: '승인',
    );
    if (confirmed != true || !mounted) return;

    try {
      await _sellerService.approveSeller(seller.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('판매자를 승인했습니다.')));
      _loadSellers(showLoading: false);
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

  Future<void> _reject(StoreSeller seller) async {
    final reason = await AdminActionDialog.show(
      context,
      title: '판매자 반려',
      confirmLabel: '반려',
      summary: '${seller.shopName}의 스토어 판매자 신청을 반려합니다.',
      reasonLabel: '반려 사유 (필수)',
      isDanger: true,
    );
    if (reason == null || !mounted) return;

    try {
      await _sellerService.rejectSeller(seller.id, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('판매자 신청을 반려했습니다.')));
      _loadSellers(showLoading: false);
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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AdminStitchTheme.pageMargin,
            AdminStitchTheme.pageMargin,
            AdminStitchTheme.pageMargin,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminStitchPageHeader(
                  title: '스토어 판매자 승인',
                  subtitle: '스토어에 상품을 올리려는 판매자 신청 심사 큐',
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchSearchField(
                  controller: _searchController,
                  hint: '상호명, 대표자명 검색...',
                  onChanged: (value) {
                    _searchDebounceTimer?.cancel();
                    setState(() => _searchQuery = value.trim());
                    _searchDebounceTimer = Timer(
                      const Duration(milliseconds: 300),
                      () {
                        if (!mounted) return;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          _loadSellers(showLoading: false);
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
                AdminStitchFilterChips(
                  tabs: _statusTabs,
                  selectedTab: _selectedStatusTab(),
                  onTabChanged: (tab) {
                    setState(
                      () =>
                          _statusFilter = tab == '전체' ? null : _statusMap[tab],
                    );
                    _loadSellers();
                  },
                ),
                const SizedBox(height: AdminStitchTheme.sectionGap),
              ],
            ),
          ),
        ),
        if (_isLoading && _sellers.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_hasLoadError)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: FilledButton.icon(
                onPressed: () => _loadSellers(),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ),
          )
        else if (_sellers.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 64,
                    color: AdminStitchTheme.textSecondary,
                  ),
                  SizedBox(height: 12),
                  Text('해당 조건의 판매자 신청이 없습니다'),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AdminStitchTheme.pageMargin,
              0,
              AdminStitchTheme.pageMargin,
              AdminStitchListScreenShell.listPadding(context).bottom,
            ),
            sliver: SliverList.separated(
              itemCount: _sellers.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AdminStitchTheme.sectionGap),
              itemBuilder: (context, index) =>
                  _buildSellerCard(_sellers[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildSellerCard(StoreSeller seller) {
    final isPending = seller.status == StoreSellerStatus.pending;
    final ownerLine = seller.businessNumber != null
        ? '${seller.ownerName} · ${seller.businessNumber}'
        : seller.ownerName;

    return AdminStitchVerificationCard(
      requestId: _requestId(seller.id),
      typeLabel: '스토어 판매자',
      userName: seller.shopName,
      userEmail: ownerLine,
      roleLabel: '판매자 신청',
      statusLabel: seller.status.label,
      submittedAtLabel: DateFormat(
        'yyyy.MM.dd HH:mm',
        'ko_KR',
      ).format(seller.appliedAt),
      typeColor: const Color(0xFFEA580C),
      isPending: isPending,
      isApproved: seller.status == StoreSellerStatus.approved,
      onApprove: isPending ? () => _approve(seller) : null,
      onReject: isPending ? () => _reject(seller) : null,
    );
  }
}
