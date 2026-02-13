import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

/// 주소 검색 화면 (다음 주소 API - 간단한 입력 방식)
class AddressSearchScreen extends StatefulWidget {
  final String? initialAddress;
  
  const AddressSearchScreen({
    super.key,
    this.initialAddress,
  });

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _addressController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  Future<void> _openDaumPostcode() async {
    // 다음 주소 API를 외부 브라우저로 열기
    // 실제로는 웹뷰를 사용하는 것이 좋지만, 패키지가 없으므로
    // 사용자에게 주소를 직접 입력하도록 안내
    final url = Uri.parse('https://postcode.map.daum.net/guide');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('주소 검색 페이지를 열 수 없습니다. 주소를 직접 입력해주세요.'),
          ),
        );
      }
    }
  }

  void _handleSubmit() {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('주소를 입력해주세요'),
          backgroundColor: AppTheme.urgentRed,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'address': _addressController.text.trim(),
      'detailAddress': _detailAddressController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더
        Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radius2xl),
              topRight: Radius.circular(AppTheme.radius2xl),
            ),
            border: Border(
              bottom: BorderSide(color: AppTheme.borderGray),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  '주소 검색',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 48), // 균형 맞추기
            ],
          ),
        ),
        // 본문
        Expanded(
          child: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 주소 검색 안내
            Container(
              padding: EdgeInsets.all(AppTheme.spacing4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEFF6FF),
                    Color(0xFFF3E8FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(color: AppTheme.blue100),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: const Icon(Icons.search, size: 18, color: Colors.white),
                      ),
                      SizedBox(width: AppTheme.spacing2),
                      const Expanded(
                        child: Text(
                          '주소 검색',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing3),
                  ElevatedButton.icon(
                    onPressed: _openDaumPostcode,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('다음 주소 검색 열기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing4,
                        vertical: AppTheme.spacing3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                    ),
                  ),
                  SizedBox(height: AppTheme.spacing2),
                  const Text(
                    '또는 아래에 주소를 직접 입력하세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing6),
            // 주소 입력
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    const Text(
                      '주소',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(color: AppTheme.primaryPurple),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing3),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: '주소를 입력하세요',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      borderSide: const BorderSide(color: AppTheme.primaryPurpleLight, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      borderSide: const BorderSide(color: AppTheme.primaryPurpleLight, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing5,
                      vertical: AppTheme.spacing4,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: AppTheme.primaryPurple),
                      onPressed: _openDaumPostcode,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing5),
            // 상세 주소 입력
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    const Text(
                      '상세 주소',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing3),
                TextFormField(
                  controller: _detailAddressController,
                  decoration: InputDecoration(
                    hintText: '상세 주소를 입력하세요 (선택)',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      borderSide: const BorderSide(color: AppTheme.primaryPurpleLight, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      borderSide: const BorderSide(color: AppTheme.primaryPurpleLight, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing5,
                      vertical: AppTheme.spacing4,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing6),
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9333EA), Color(0xFF7C3AED), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '주소 적용하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
          ),
        ),
      ],
    );
  }
}
