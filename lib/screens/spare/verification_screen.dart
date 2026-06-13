import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/shared_app_bar.dart';
import '../../utils/icon_mapper.dart';
import '../../services/verification_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/error_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'license_verification_screen.dart';

/// Next.js와 동일한 인증 관리 화면
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String _identityStatus = 'not_started'; // not_started, pending, completed
  String _licenseStatus = 'not_started';
  bool _isLoading = true;
  bool _isVerifying = false;
  final VerificationService _verificationService = VerificationService();

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final status = await _verificationService.getVerificationStatus();
      setState(() {
        _identityStatus = status['identityStatus']?.toString() ?? 'not_started';
        _licenseStatus = status['licenseStatus']?.toString() ?? 'not_started';
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
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleIdentityVerification() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final url = await _verificationService.requestIdentityVerification();
      // 웹에서는 새 창으로 열기
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        // 팝업이 닫히면 상태 새로고침 (실제로는 웹소켓이나 폴링으로 처리)
        await Future.delayed(const Duration(seconds: 2));
        await _loadVerificationStatus();
      }
    } catch (e) {
      if (mounted) {
        final appException = ErrorHandler.handleException(e);
        final userFriendlyMessage = ErrorHandler.getUserFriendlyMessage(appException);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage),
            backgroundColor: AppTheme.urgentRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _handleLicenseVerification() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LicenseVerificationScreen(),
      ),
    ).then((_) {
      // 면허 인증 화면에서 돌아왔을 때 상태 새로고침
      _loadVerificationStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      appBar: SharedAppBar(
        title: '인증 관리',
        onBackPressed: () => NavigationHelper.safePop(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppTheme.spacing(AppTheme.spacing4),
          child: Column(
            children: [
              // 본인인증 카드
              _buildVerificationCard(
                icon: IconMapper.icon('shield', size: 32, color: AppTheme.primaryGreen) ??
                    const Icon(Icons.shield, size: 32, color: AppTheme.primaryGreen),
                title: '본인인증',
                description: '휴대폰 본인인증을 진행해주세요',
                status: _identityStatus,
                onTap: _handleIdentityVerification,
                isVerifying: _isVerifying,
              ),
              const SizedBox(height: AppTheme.spacing4),
              // 면허 인증 카드
              _buildVerificationCard(
                icon: IconMapper.icon('award', size: 32, color: AppTheme.primaryBlue) ??
                    const Icon(Icons.workspace_premium, size: 32, color: AppTheme.primaryBlue),
                title: '면허 인증',
                description: '미용사 면허증을 인증해주세요',
                status: _licenseStatus,
                onTap: _handleLicenseVerification,
                isVerifying: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCard({
    required Widget icon,
    required String title,
    required String description,
    required String status,
    required VoidCallback onTap,
    required bool isVerifying,
  }) {
    Color statusColor;
    String statusText;
    Widget statusIcon;

    switch (status) {
      case 'completed':
        statusColor = AppTheme.primaryGreen;
        statusText = '인증 완료';
        statusIcon = IconMapper.icon('checkcircle', size: 20, color: AppTheme.primaryGreen) ??
            const Icon(Icons.check_circle, size: 20, color: AppTheme.primaryGreen);
        break;
      case 'pending':
        statusColor = AppTheme.yellow400;
        statusText = '인증 대기중';
        statusIcon = IconMapper.icon('clock', size: 20, color: AppTheme.yellow400) ??
            const Icon(Icons.access_time, size: 20, color: AppTheme.yellow400);
        break;
      default:
        statusColor = AppTheme.textTertiary;
        statusText = '미인증';
        statusIcon = IconMapper.icon('xcircle', size: 20, color: AppTheme.textTertiary) ??
            const Icon(Icons.cancel, size: 20, color: AppTheme.textTertiary);
    }

    return Container(
      padding: AppTheme.spacing(AppTheme.spacing6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                ),
                child: icon,
              ),
              const SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing1 / 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              statusIcon,
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          Row(
            children: [
              Container(
                padding: AppTheme.spacingSymmetric(
                  horizontal: AppTheme.spacing2,
                  vertical: AppTheme.spacing1,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusSm),
                ),
                child: Text(
                  statusText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              if (status != 'completed')
                ElevatedButton(
                  onPressed: isVerifying ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: AppTheme.spacingSymmetric(
                      horizontal: AppTheme.spacing4,
                      vertical: AppTheme.spacing2,
                    ),
                  ),
                  child: isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('인증하기'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

