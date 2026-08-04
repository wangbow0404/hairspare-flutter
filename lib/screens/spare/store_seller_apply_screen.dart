import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/di/service_locator.dart';
import '../../models/store_seller.dart';
import '../../providers/auth_provider.dart';
import '../../services/store_seller_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/hairspare_colors.dart';
import '../../widgets/common/spare_subpage_app_bar.dart';
import '../../widgets/design_system/hs_primary_button.dart';

/// 스토어 판매자 신청 화면 — 신청 후 관리자 승인을 기다리는 mock 플로우.
class StoreSellerApplyScreen extends StatefulWidget {
  const StoreSellerApplyScreen({super.key});

  @override
  State<StoreSellerApplyScreen> createState() => _StoreSellerApplyScreenState();
}

class _StoreSellerApplyScreenState extends State<StoreSellerApplyScreen> {
  final StoreSellerService _sellerService = sl<StoreSellerService>();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _shopNameController;
  late final TextEditingController _ownerNameController;
  final TextEditingController _businessNumberController =
      TextEditingController();
  final TextEditingController _introTextController = TextEditingController();

  bool _isSubmitting = false;
  StoreSeller? _submittedSeller;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _shopNameController = TextEditingController();
    _ownerNameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _businessNumberController.dispose();
    _introTextController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final seller = await _sellerService.applyAsSeller(
        shopName: _shopNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        businessNumber: _businessNumberController.text.trim().isEmpty
            ? null
            : _businessNumberController.text.trim(),
        introText: _introTextController.text.trim().isEmpty
            ? null
            : _introTextController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _submittedSeller = seller;
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('신청 중 문제가 발생했습니다. 다시 시도해주세요.'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: const SpareSubpageAppBar(
        title: '스토어 판매자 신청',
        showToolbarActions: false,
      ),
      body: _submittedSeller != null
          ? _SubmittedState(seller: _submittedSeller!)
          : SingleChildScrollView(
              padding: AppTheme.spacing(AppTheme.spacing4),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: AppTheme.spacing(AppTheme.spacing4),
                      decoration: BoxDecoration(
                        color: HairSpareColors.brandPrimarySoft,
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusXl),
                      ),
                      child: const Text(
                        '스토어 판매자로 신청하면 미용 도구·용품을 직접 등록해 판매할 수 있어요.\n신청 후 관리자 검토를 거쳐 승인되면 활동을 시작할 수 있습니다.',
                        style: TextStyle(
                          fontSize: 13,
                          color: HairSpareColors.brandPrimary,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing5),
                    const Text(
                      '상호명',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _shopNameController,
                      decoration: const InputDecoration(hintText: '예) 준가위 공구몰'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '상호명을 입력해주세요'
                          : null,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    const Text(
                      '대표자명',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(hintText: '대표자 이름'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '대표자명을 입력해주세요'
                          : null,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    const Text(
                      '사업자등록번호 (선택)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _businessNumberController,
                      decoration: const InputDecoration(
                        hintText: '000-00-00000',
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    const Text(
                      '스토어 소개글 (선택)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing2),
                    TextFormField(
                      controller: _introTextController,
                      decoration: const InputDecoration(
                        hintText: '스토어 프로필에 보여줄 한 줄 소개',
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing6),
                    HsPrimaryButton(
                      label: '신청하기',
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SubmittedState extends StatelessWidget {
  const _SubmittedState({required this.seller});

  final StoreSeller seller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppTheme.spacing(AppTheme.spacing6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              size: 56,
              color: HairSpareColors.brandPrimary,
            ),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              '${seller.shopName} 신청이 접수되었어요',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacing2),
            const Text(
              '관리자 검토 후 승인되면 스토어에서 상품을 등록할 수 있어요.\n승인 결과는 알림으로 안내드릴게요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppTheme.spacing4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing3,
                vertical: AppTheme.spacing2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray,
                borderRadius: AppTheme.borderRadius(999),
              ),
              child: Text(
                seller.status.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
