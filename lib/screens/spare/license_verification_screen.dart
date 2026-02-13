import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../utils/icon_mapper.dart';
import '../../utils/navigation_helper.dart';
import '../../services/verification_service.dart';
import '../../utils/error_handler.dart';
import '../../utils/app_exception.dart';
import 'package:dio/dio.dart';
import '../../utils/api_client.dart';

/// Next.js와 동일한 면허 인증 화면
class LicenseVerificationScreen extends StatefulWidget {
  const LicenseVerificationScreen({super.key});

  @override
  State<LicenseVerificationScreen> createState() => _LicenseVerificationScreenState();
}

class _LicenseVerificationScreenState extends State<LicenseVerificationScreen> {
  final VerificationService _verificationService = VerificationService();
  final ImagePicker _imagePicker = ImagePicker();
  final ApiClient _apiClient = ApiClient();
  
  bool _isLoading = true;
  bool _isUploading = false;
  String? _identityName;
  String? _identityPhone;
  String _licenseStatus = 'not_started'; // not_started, pending, approved, rejected, under_review
  String? _licenseNumber;
  String? _licenseName;
  DateTime? _licenseSubmittedAt;
  String? _licenseRejectionReason;
  File? _selectedImage;
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 본인인증 정보 조회
      final identityStatus = await _verificationService.getVerificationStatus();
      setState(() {
        _identityName = identityStatus['identityName']?.toString();
        _identityPhone = identityStatus['identityPhone']?.toString();
      });

      // 면허 인증 상태 조회
      try {
        final response = await _apiClient.dio.get('/api/verification/license/status');
        if (response.statusCode == 200) {
          final data = response.data['data'] ?? response.data;
          setState(() {
            _licenseStatus = data['status']?.toString() ?? 'not_started';
            _licenseNumber = data['licenseNumber']?.toString();
            _licenseName = data['licenseName']?.toString();
            _licenseSubmittedAt = data['submittedAt'] != null
                ? DateTime.parse(data['submittedAt'].toString())
                : null;
            _licenseRejectionReason = data['rejectionReason']?.toString();
          });
        }
      } catch (e) {
        // 면허 인증 API가 없어도 계속 진행
      }
    } catch (error) {
      if (mounted) {
        final appException = ErrorHandler.handleException(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        
        // 파일 크기 검증 (10MB)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('이미지 크기는 10MB 이하여야 합니다'),
                backgroundColor: AppTheme.urgentRed,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = file;
          _previewUrl = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    }
  }

  Future<void> _submitLicense() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('면허증 이미지를 선택해주세요'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: 'license.jpg',
        ),
      });

      final response = await _apiClient.dio.post(
        '/api/verification/license/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 상태 새로고침
        await _loadData();

        // 이미지 초기화
        setState(() {
          _selectedImage = null;
          _previewUrl = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('면허증이 제출되었습니다'),
              backgroundColor: AppTheme.primaryBlue,
            ),
          );
        }
      } else {
        throw ServerException(
          '면허증 업로드 실패: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (error) {
      if (mounted) {
        final appException = ErrorHandler.handleException(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(appException)),
            backgroundColor: AppTheme.urgentRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
            onPressed: () => NavigationHelper.safePop(context),
          ),
          title: Text(
            '면허 인증',
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

    // 본인인증이 완료되지 않은 경우
    if (_identityName == null || _identityName!.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: IconMapper.icon('chevronleft', size: 24, color: AppTheme.textSecondary) ??
                const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary),
            onPressed: () => NavigationHelper.safePop(context),
          ),
          title: Text(
            '면허 인증',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        body: Padding(
          padding: AppTheme.spacing(AppTheme.spacing4),
          child: Container(
            padding: AppTheme.spacing(AppTheme.spacing4),
            decoration: BoxDecoration(
              color: AppTheme.yellow50,
              border: Border.all(color: AppTheme.yellow200),
              borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconMapper.icon('alertcircle', size: 20, color: AppTheme.yellow600) ??
                        const Icon(Icons.warning_amber_rounded, size: 20, color: AppTheme.yellow600),
                    SizedBox(width: AppTheme.spacing3),
                    Text(
                      '본인인증 필요',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.yellow900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing2),
                Text(
                  '면허 인증을 진행하려면 먼저 본인인증을 완료해주세요.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.yellow800,
                  ),
                ),
                SizedBox(height: AppTheme.spacing3),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.yellow600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('본인인증 하기'),
                ),
              ],
            ),
          ),
        ),
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
          onPressed: () => NavigationHelper.safePop(context),
        ),
        title: Text(
          '면허 인증',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.spacing(AppTheme.spacing4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 본인인증 정보
            Container(
              padding: AppTheme.spacing(AppTheme.spacing4),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '본인인증 정보',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  Text(
                    '이름: $_identityName',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (_identityPhone != null && _identityPhone!.isNotEmpty)
                    Text(
                      '전화번호: $_identityPhone',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing6),

            // 면허 인증 상태
            if (_licenseStatus != 'not_started' && _licenseStatus != 'pending')
              Container(
                padding: AppTheme.spacing(AppTheme.spacing4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_licenseStatus == 'approved')
                          IconMapper.icon('checkcircle2', size: 20, color: AppTheme.green600) ??
                              const Icon(Icons.check_circle, size: 20, color: AppTheme.green600),
                        if (_licenseStatus == 'under_review')
                          IconMapper.icon('clock', size: 20, color: AppTheme.yellow600) ??
                              const Icon(Icons.access_time, size: 20, color: AppTheme.yellow600),
                        if (_licenseStatus == 'rejected')
                          IconMapper.icon('xcircle', size: 20, color: AppTheme.urgentRed) ??
                              const Icon(Icons.cancel, size: 20, color: AppTheme.urgentRed),
                        SizedBox(width: AppTheme.spacing3),
                        Text(
                          _licenseStatus == 'approved'
                              ? '인증 완료'
                              : _licenseStatus == 'under_review'
                                  ? '심사 중'
                                  : '인증 거절',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (_licenseNumber != null && _licenseNumber!.isNotEmpty) ...[
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        '면허번호: $_licenseNumber',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    if (_licenseRejectionReason != null && _licenseRejectionReason!.isNotEmpty) ...[
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        '거절 사유: $_licenseRejectionReason',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.urgentRed,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // 면허증 업로드
            if (_licenseStatus == 'not_started' || _licenseStatus == 'rejected') ...[
              SizedBox(height: AppTheme.spacing6),
              Container(
                padding: AppTheme.spacing(AppTheme.spacing6),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundWhite,
                  borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '국가기술자격증 업로드',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    if (_previewUrl == null)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          padding: AppTheme.spacing(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.borderGray300,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                ),
                                child: IconMapper.icon('camera', size: 32, color: AppTheme.primaryBlue) ??
                                    const Icon(Icons.camera_alt, size: 32, color: AppTheme.primaryBlue),
                              ),
                              SizedBox(height: AppTheme.spacing3),
                              Text(
                                '카메라로 촬영',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacing1),
                              Text(
                                '면허증을 카메라로 직접 촬영해주세요',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: AppTheme.spacing2,
                            right: AppTheme.spacing2,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                  _previewUrl = null;
                                });
                              },
                              child: Container(
                                padding: AppTheme.spacing(AppTheme.spacing2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: AppTheme.borderRadius(AppTheme.radiusFull),
                                ),
                                child: IconMapper.icon('xcircle', size: 20, color: Colors.white) ??
                                    const Icon(Icons.cancel, size: 20, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: IconMapper.icon('camera', size: 20, color: AppTheme.textGray700) ??
                            const Icon(Icons.camera_alt, size: 20, color: AppTheme.textGray700),
                        label: const Text('다시 촬영'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textGray700,
                          side: BorderSide(color: AppTheme.borderGray300),
                        ),
                      ),
                    ],
                    SizedBox(height: AppTheme.spacing4),
                    Container(
                      padding: AppTheme.spacing(AppTheme.spacing3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                      ),
                      child: Text(
                        '심사 기간 안내: 영업일 기준 최대 1~3일 소요될 수 있습니다.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    if (_previewUrl != null) ...[
                      SizedBox(height: AppTheme.spacing4),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isUploading ? null : _submitLicense,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: AppTheme.spacing(AppTheme.spacing4),
                          ),
                          child: _isUploading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.spacing2),
                                    const Text('업로드 중...'),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconMapper.icon('upload', size: 20, color: Colors.white) ??
                                        const Icon(Icons.upload, size: 20, color: Colors.white),
                                    SizedBox(width: AppTheme.spacing2),
                                    const Text('제출하기'),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
