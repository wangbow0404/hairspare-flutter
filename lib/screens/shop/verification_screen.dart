import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../services/verification_service.dart';
import 'profile_screen.dart';

/// Shop 인증 관리 화면 (사업자 인증, 본인인증, 대리인 인증)
class ShopVerificationScreen extends StatefulWidget {
  const ShopVerificationScreen({super.key});

  @override
  State<ShopVerificationScreen> createState() => _ShopVerificationScreenState();
}

class _ShopVerificationScreenState extends State<ShopVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNumberController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _representativeNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _businessCategoryController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _status = 'not_started'; // 'not_started' | 'pending' | 'approved' | 'rejected'
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _rejectionReason;
  String? _verifiedAt;
  String? _businessNumber;
  String? _businessName;
  String? _representativeName;
  String? _businessType;
  String? _businessCategory;
  String? _address;

  // 본인인증
  bool _identityVerified = false;
  String? _identityName;
  String? _identityPhone;
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _phoneVerificationSent = false;
  int _verificationTimer = 0;
  bool _isVerifyingPhone = false;

  // 대리인 인증 (점장 등 - 플랫폼 승인 필요)
  String _proxyStatus = 'not_started'; // 'not_started' | 'pending' | 'approved' | 'rejected'
  final _proxyNameController = TextEditingController();
  final _proxyRelationController = TextEditingController();
  final _proxyPhoneController = TextEditingController();
  bool _isSubmittingProxy = false;

  final VerificationService _verificationService = VerificationService();

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  @override
  void dispose() {
    _businessNumberController.dispose();
    _businessNameController.dispose();
    _representativeNameController.dispose();
    _businessTypeController.dispose();
    _businessCategoryController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _proxyNameController.dispose();
    _proxyRelationController.dispose();
    _proxyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadVerificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: API 호출하여 사업자 인증 상태 조회
      // final status = await VerificationService.getBusinessVerificationStatus();
      
      // 본인인증 상태 조회
      try {
        final identityStatus = await _verificationService.getVerificationStatus();
        if (mounted) {
          setState(() {
            _identityVerified = identityStatus['identityVerified'] == true;
            _identityName = identityStatus['identityName'];
            _identityPhone = identityStatus['identityPhone'];
          });
        }
      } catch (_) {}
      
      setState(() {
        _status = 'not_started';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendVerificationCode() async {
    final phone = _phoneController.text.replaceAll('-', '').trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 휴대폰 번호를 입력해주세요')),
      );
      return;
    }
    setState(() => _isVerifyingPhone = true);
    try {
      await _verificationService.sendVerificationCode(phone);
      if (mounted) {
        setState(() {
          _phoneVerificationSent = true;
          _verificationTimer = 300; // 5분
          _isVerifyingPhone = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증번호가 발송되었습니다'), backgroundColor: AppTheme.primaryGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifyingPhone = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증번호 발송 실패: $e'), backgroundColor: AppTheme.urgentRed),
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    final code = _verificationCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('인증번호를 입력해주세요')));
      return;
    }
    setState(() => _isVerifyingPhone = true);
    try {
      final verified = await _verificationService.verifyCode(
        _phoneController.text.replaceAll('-', ''),
        code,
      );
      if (mounted) {
        setState(() {
          _isVerifyingPhone = false;
          _verificationTimer = 0;
          if (verified) {
            _identityVerified = true;
            _identityPhone = _phoneController.text;
          }
        });
        if (verified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('본인인증이 완료되었습니다'), backgroundColor: AppTheme.primaryGreen),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('인증번호가 올바르지 않습니다'), backgroundColor: AppTheme.urgentRed),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifyingPhone = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 실패: $e'), backgroundColor: AppTheme.urgentRed),
        );
      }
    }
  }

  Future<void> _handleProxySubmit() async {
    if (_proxyNameController.text.trim().isEmpty ||
        _proxyRelationController.text.trim().isEmpty ||
        _proxyPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요')),
      );
      return;
    }
    setState(() => _isSubmittingProxy = true);
    try {
      // TODO: API 호출 - 대리인 인증 신청 (플랫폼 승인 필요)
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _proxyStatus = 'pending';
          _isSubmittingProxy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('대리인 인증 신청이 완료되었습니다. 검토 후 결과를 알려드리겠습니다.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmittingProxy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('신청 실패: $e'), backgroundColor: AppTheme.urgentRed),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: API 호출하여 사업자 인증 신청
      // await VerificationService.submitBusinessVerification(...);
      
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사업자 인증 신청이 완료되었습니다. 검토 후 결과를 알려드리겠습니다.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        setState(() {
          _status = 'pending';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인증 신청 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildVerificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String status,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Icon(icon, size: 24, color: iconColor),
              ),
              SizedBox(width: AppTheme.spacing3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing1),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          if (status != 'not_started') _buildStatusBadge(status),
          if (status != 'not_started') SizedBox(height: AppTheme.spacing4),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'approved':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '인증 완료',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        );
      case 'pending':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: Colors.yellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.orange.shade700),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '검토 중',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      case 'rejected':
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: AppTheme.urgentRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, size: 16, color: AppTheme.urgentRed),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '인증 거절',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.urgentRed,
                ),
              ),
            ],
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3, vertical: AppTheme.spacing1),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 16, color: AppTheme.textGray700),
              SizedBox(width: AppTheme.spacing1),
              Text(
                '미인증',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textGray700,
                ),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '인증 관리',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          '인증 관리',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인증 상태 카드
            Container(
              padding: EdgeInsets.all(AppTheme.spacing6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                        child: Icon(
                          Icons.shield,
                          size: 24,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '사업자 인증',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing1),
                            Text(
                              '사업자 등록증을 등록하여 인증을 받으세요',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  _buildStatusBadge(_status),
                  if (_status == 'rejected' && _rejectionReason != null) ...[
                    SizedBox(height: AppTheme.spacing4),
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      decoration: BoxDecoration(
                        color: AppTheme.urgentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.urgentRed.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '거절 사유',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.urgentRed,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing1),
                          Text(
                            _rejectionReason!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.urgentRed.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_status == 'approved' && _verifiedAt != null) ...[
                    SizedBox(height: AppTheme.spacing4),
                    Container(
                      padding: EdgeInsets.all(AppTheme.spacing4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '인증 완료일',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          SizedBox(height: AppTheme.spacing1),
                          Text(
                            _verifiedAt!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryGreen.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: AppTheme.spacing4),
            
            // 인증 폼 (인증 완료가 아닐 때만 표시)
            if (_status != 'approved')
              Container(
                padding: EdgeInsets.all(AppTheme.spacing6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사업자 정보 입력',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing6),
                      TextFormField(
                        controller: _businessNumberController,
                        decoration: const InputDecoration(
                          labelText: '사업자등록번호 *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '사업자등록번호를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      TextFormField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          labelText: '상호명 *',
                          border: OutlineInputBorder(),
                          hintText: '미용실 상호명',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '상호명을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      TextFormField(
                        controller: _representativeNameController,
                        decoration: const InputDecoration(
                          labelText: '대표자명 *',
                          border: OutlineInputBorder(),
                          hintText: '대표자 이름',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '대표자명을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      TextFormField(
                        controller: _businessTypeController,
                        decoration: const InputDecoration(
                          labelText: '업태 *',
                          border: OutlineInputBorder(),
                          hintText: '예: 서비스업',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '업태를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      TextFormField(
                        controller: _businessCategoryController,
                        decoration: const InputDecoration(
                          labelText: '종목 *',
                          border: OutlineInputBorder(),
                          hintText: '예: 미용실업',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '종목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: '사업장 주소 *',
                          border: OutlineInputBorder(),
                          hintText: '사업장 주소',
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '사업장 주소를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        '사업자등록증 사진 *',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing2),
                      GestureDetector(
                        onTap: () {
                          // TODO: 이미지 선택 기능
                        },
                        child: Container(
                          padding: EdgeInsets.all(AppTheme.spacing8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.borderGray,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.upload,
                                size: 32,
                                color: AppTheme.textTertiary,
                              ),
                              SizedBox(height: AppTheme.spacing2),
                              Text(
                                '사진을 클릭하여 업로드',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing1),
                              Text(
                                'JPG, PNG 형식 (최대 5MB)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppTheme.spacing6),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: AppTheme.spacing3),
                            disabledBackgroundColor: AppTheme.primaryGreen.withOpacity(0.5),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  '인증 신청하기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // 인증 완료 정보 (인증 완료일 때만 표시)
            if (_status == 'approved') ...[
              SizedBox(height: AppTheme.spacing4),
              Container(
                padding: EdgeInsets.all(AppTheme.spacing6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '인증된 사업자 정보',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    _buildInfoRow('사업자등록번호', _businessNumber ?? ''),
                    _buildInfoRow('상호명', _businessName ?? ''),
                    _buildInfoRow('대표자명', _representativeName ?? ''),
                    _buildInfoRow('업태/종목', '${_businessType ?? ''} / ${_businessCategory ?? ''}'),
                    _buildInfoRow('사업장 주소', _address ?? '', isAddress: true),
                  ],
                ),
              ),
            ],

            // 본인인증 섹션
            SizedBox(height: AppTheme.spacing6),
            _buildVerificationCard(
              icon: Icons.person,
              iconColor: AppTheme.primaryBlue,
              title: '본인인증',
              subtitle: '휴대폰 본인인증을 진행해주세요',
              status: _identityVerified ? 'approved' : 'not_started',
              child: _identityVerified
                  ? _buildInfoRow('인증 휴대폰', _identityPhone ?? '')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: '휴대폰 번호',
                            border: OutlineInputBorder(),
                            hintText: '010-1234-5678',
                          ),
                          keyboardType: TextInputType.phone,
                          enabled: !_phoneVerificationSent,
                        ),
                        if (_phoneVerificationSent) ...[
                          SizedBox(height: AppTheme.spacing4),
                          TextFormField(
                            controller: _verificationCodeController,
                            decoration: InputDecoration(
                              labelText: '인증번호',
                              border: const OutlineInputBorder(),
                              suffixText: _verificationTimer > 0
                                  ? '${(_verificationTimer / 60).floor()}:${(_verificationTimer % 60).toString().padLeft(2, '0')}'
                                  : null,
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                          ),
                          SizedBox(height: AppTheme.spacing2),
                          Row(
                            children: [
                              if (_verificationTimer > 0)
                                TextButton(
                                  onPressed: null,
                                  child: Text('재발송 ${(_verificationTimer / 60).floor()}분 후')),
                              if (_verificationTimer == 0)
                                TextButton(
                                  onPressed: _sendVerificationCode,
                                  child: const Text('인증번호 재발송')),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: _isVerifyingPhone ? null : _verifyCode,
                                child: _isVerifyingPhone
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('인증하기'),
                              ),
                            ],
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isVerifyingPhone ? null : _sendVerificationCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                              ),
                              child: _isVerifyingPhone
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('인증번호 발송'),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),

            // 대리인 인증 섹션 (점장 등 - 플랫폼 승인 필요)
            SizedBox(height: AppTheme.spacing4),
            _buildVerificationCard(
              icon: Icons.badge,
              iconColor: Colors.orange,
              title: '대리인 인증',
              subtitle: '점장, 매니저 등 대리인으로 운영하시나요? 플랫폼 승인 후 인증됩니다',
              status: _proxyStatus,
              child: _proxyStatus == 'approved'
                  ? const Text('대리인 인증이 완료되었습니다.')
                  : _proxyStatus == 'pending'
                      ? const Text('검토 중입니다. 승인 후 알려드리겠습니다.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _proxyNameController,
                              decoration: const InputDecoration(
                                labelText: '대리인 이름 *',
                                border: OutlineInputBorder(),
                                hintText: '홍길동',
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            TextFormField(
                              controller: _proxyRelationController,
                              decoration: const InputDecoration(
                                labelText: '관계 *',
                                border: OutlineInputBorder(),
                                hintText: '예: 점장, 매니저, 실장',
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            TextFormField(
                              controller: _proxyPhoneController,
                              decoration: const InputDecoration(
                                labelText: '연락처 *',
                                border: OutlineInputBorder(),
                                hintText: '010-1234-5678',
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            Text(
                              '대리인 인증은 플랫폼 검토 후 승인됩니다. 사업자 인증이 먼저 완료되어야 합니다.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmittingProxy ? null : _handleProxySubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isSubmittingProxy
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('대리인 인증 신청'),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAddress = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing3),
      child: Row(
        crossAxisAlignment: isAddress ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: isAddress ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
