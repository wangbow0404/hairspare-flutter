import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/icon_mapper.dart';

/// Next.js와 동일한 고객센터 섹션 위젯
class CustomerServiceSection extends StatefulWidget {
  const CustomerServiceSection({super.key});

  @override
  State<CustomerServiceSection> createState() => _CustomerServiceSectionState();
}

class _CustomerServiceSectionState extends State<CustomerServiceSection> {
  bool _showBusinessInfo = false;

  Future<void> _callCustomerService() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '010-2710-5603');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('전화를 걸 수 없습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 0, // pt-0
        bottom: AppTheme.spacing1 / 2, // pb-0.5
        left: AppTheme.spacing4, // px-4
        right: AppTheme.spacing4, // px-4
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray, // bg-gray-50
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 고객센터
          Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spacing1), // mb-1
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HairSpare 고객센터',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16, // text-base
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary, // text-gray-900
                        height: 1.2, // leading-tight
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _callCustomerService,
                        borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                        child: Container(
                          padding: AppTheme.spacingSymmetric(
                            horizontal: AppTheme.spacing2, // px-2
                            vertical: AppTheme.spacing1, // py-1
                          ),
                          constraints: const BoxConstraints(
                            minHeight: 28, // h-7 (28px)
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundWhite, // bg-white
                            border: Border.all(
                              color: AppTheme.borderGray300, // border-gray-300
                            ),
                            borderRadius: AppTheme.borderRadius(AppTheme.radiusLg),
                            boxShadow: AppTheme.shadowSm, // shadow-sm
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconMapper.icon('phone', size: 14, color: AppTheme.textGray700) ??
                                  const Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: AppTheme.textGray700,
                                  ),
                              SizedBox(width: AppTheme.spacing2), // gap-2
                              Text(
                                '연결하기',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 14, // text-sm
                                  fontWeight: FontWeight.w500, // font-medium
                                  color: AppTheme.textGray700, // text-gray-700
                                  height: 1.2, // leading-tight
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing1 / 2), // mb-0.5
                Text(
                  '평일 09:30~18:30 (점심시간 12:30~13:30)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14, // text-sm
                    color: AppTheme.textSecondary, // text-gray-600
                    height: 1.2, // leading-tight
                  ),
                ),
              ],
            ),
          ),

          // 구분선
          Container(
            height: 1,
            decoration: BoxDecoration(
              color: AppTheme.borderGray300, // border-gray-300 (Next.js에서는 border-gray-300)
            ),
            margin: EdgeInsets.symmetric(vertical: AppTheme.spacing1), // my-1
          ),

          // 사업자 정보 (드롭다운)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _showBusinessInfo = !_showBusinessInfo;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacing1 / 2), // py-0.5
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HairSpare 사업자 정보',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14, // text-sm
                        fontWeight: FontWeight.w600, // font-semibold
                        color: AppTheme.textPrimary, // text-gray-900
                        height: 1.2, // leading-tight
                      ),
                    ),
                    IconMapper.icon(
                      _showBusinessInfo ? 'chevronup' : 'chevrondown',
                      size: 16,
                      color: AppTheme.textSecondary,
                    ) ??
                        Icon(
                          _showBusinessInfo ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                  ],
                ),
              ),
            ),
          ),

          // 사업자 정보 내용
          if (_showBusinessInfo)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.only(top: AppTheme.spacing1 / 2), // mt-0.5
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BusinessInfoItem('법인명: 주식회사 빌라드블랑'),
                  _BusinessInfoItem('대표자: 홍종일, 김은수 (공동대표)'),
                  _BusinessInfoItem('사업자등록번호: 165-86-02139'),
                  _BusinessInfoItem('통신판매업신고번호: 2021-인천남동구-0738'),
                  _BusinessInfoItem('사업장 소재지: 경기도 파주시 청석로 272, 1004-575호(동패동, 센타프라자1)'),
                  _BusinessInfoItem('고객센터: 010-2710-5603'),
                  _BusinessInfoItem('제휴문의: villadeblanc@naver.com'),
                ],
              ),
            ),

          // 이용약관 및 개인정보 처리방침
          Padding(
            padding: EdgeInsets.only(top: AppTheme.spacing1), // mt-1
            child: Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final Uri termsUri = Uri.parse('https://www.hairspare.co.kr/terms');
                    if (await canLaunchUrl(termsUri)) {
                      await launchUrl(termsUri, mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('이용약관 페이지를 열 수 없습니다')),
                        );
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '이용약관',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14, // text-sm
                      color: AppTheme.primaryBlue, // text-blue-600
                      height: 1.2, // leading-tight
                    ),
                  ),
                ),
                Text(
                  '|',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14, // text-sm
                    color: AppTheme.textTertiary, // text-gray-400
                    height: 1.2, // leading-tight
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final Uri privacyUri = Uri.parse('https://www.hairspare.co.kr/privacy');
                    if (await canLaunchUrl(privacyUri)) {
                      await launchUrl(privacyUri, mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('개인정보 처리방침 페이지를 열 수 없습니다')),
                        );
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '개인정보 처리방침',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14, // text-sm
                      color: AppTheme.primaryBlue, // text-blue-600
                      height: 1.2, // leading-tight
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessInfoItem extends StatelessWidget {
  final String text;

  const _BusinessInfoItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing1 / 2), // space-y-1
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 14, // text-sm
          color: AppTheme.textGray700, // text-gray-700
          height: 1.2, // leading-tight
        ),
      ),
    );
  }
}
