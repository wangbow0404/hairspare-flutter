import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/spare_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: SpareAppBar(
        showBackButton: true,
        showSearch: false,
        showTrailingIcons: false,
        title: '개인정보처리방침',
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _PrivacyPolicyContent(),
      ),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textGray700,
          height: 1.7,
        );
    const sectionGap = SizedBox(height: 24);
    const itemGap = SizedBox(height: 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주식회사 빌라드블랑(이하 "회사")은 헤어스페어(HairSpare) 서비스를 운영하면서 이용자의 개인정보를 소중히 여기며, 「개인정보 보호법」을 준수합니다.',
          style: bodyStyle,
        ),
        sectionGap,

        Text('시행일: 2026년 07월 01일', style: bodyStyle),
        sectionGap,

        Text('제1조 수집하는 개인정보 항목', style: titleStyle),
        itemGap,
        Text(
          '회사는 서비스 제공을 위해 다음의 개인정보를 수집합니다.\n\n'
          '■ 필수 항목\n'
          '• 아이디, 비밀번호, 이름, 휴대폰 번호, 역할(스페어/샵)\n\n'
          '■ 선택 항목\n'
          '• 이메일, 프로필 사진, 생년월일, 성별, 포트폴리오 이미지, 사업자등록번호(샵 전용)\n\n'
          '■ 자동 수집 항목\n'
          '• 서비스 이용 기록, 접속 로그, 기기 정보, 앱 버전',
          style: bodyStyle,
        ),
        sectionGap,

        Text('제2조 개인정보 수집 및 이용 목적', style: titleStyle),
        itemGap,
        Text(
          '• 서비스 회원가입 및 관리\n'
          '• 스페어(헤어 디자이너) ↔ 샵 매칭 서비스 제공\n'
          '• 채팅 및 공고 기능 제공\n'
          '• 본인 확인 및 부정 이용 방지\n'
          '• 고객 문의 처리 및 분쟁 해결\n'
          '• 서비스 개선 및 신규 서비스 개발',
          style: bodyStyle,
        ),
        sectionGap,

        Text('제3조 개인정보 보유 및 이용 기간', style: titleStyle),
        itemGap,
        Text(
          '회원 탈퇴 시 지체 없이 파기합니다.\n'
          '단, 관련 법령에 따라 아래 정보는 일정 기간 보관됩니다.\n\n'
          '• 계약 또는 청약철회 기록: 5년 (전자상거래법)\n'
          '• 대금결제 및 재화 공급 기록: 5년 (전자상거래법)\n'
          '• 소비자 불만 또는 분쟁 처리 기록: 3년 (전자상거래법)\n'
          '• 표시·광고 기록: 6개월 (전자상거래법)\n'
          '• 접속 로그: 3개월 (통신비밀보호법)',
          style: bodyStyle,
        ),
        sectionGap,

        Text('제4조 개인정보 제3자 제공', style: titleStyle),
        itemGap,
        Text(
          '회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다.\n'
          '다만, 이용자의 동의가 있거나 법령에 따른 경우에는 예외로 합니다.',
          style: bodyStyle,
        ),
        sectionGap,

        Text('제5조 개인정보처리 위탁', style: titleStyle),
        itemGap,
        Text(
          '회사는 서비스 향상을 위해 다음과 같이 개인정보 처리를 위탁할 수 있습니다.\n\n'
          '• 수탁사: Amazon Web Services (클라우드 서버 운영)\n'
          '• 수탁사: Neon Technologies (데이터베이스 운영)\n\n'
          '위탁 계약 시 개인정보 보호 관련 사항을 명시하고 있습니다.',
          style: bodyStyle,
        ),
        sectionGap,

        Text('제6조 정보주체의 권리', style: titleStyle),
        itemGap,
        Text(
          '이용자는 언제든지 다음의 권리를 행사할 수 있습니다.\n\n'
          '• 개인정보 열람 요청\n'
          '• 오류 정정 요청\n'
          '• 삭제 요청 (앱 내 회원탈퇴 기능 제공)\n'
          '• 처리 정지 요청\n\n'
          '권리 행사는 앱 내 [프로필 > 계정 관리 > 회원탈퇴] 또는 고객센터(010-2710-5603)로 문의하시면 됩니다.',
          style: bodyStyle,
        ),
        sectionGap,

        Text('제7조 개인정보의 파기 절차 및 방법', style: titleStyle),
        itemGap,
        Text(
          '• 전자 파일 형태: 복구 불가능한 방법으로 영구 삭제\n'
          '• 회원탈퇴 시 지체 없이 DB에서 삭제 처리',
          style: bodyStyle,
        ),
        sectionGap,

        Text('제8조 개인정보 보호책임자', style: titleStyle),
        itemGap,
        Text(
          '성명: 홍종일\n'
          '소속: 주식회사 빌라드블랑\n'
          '이메일: villadeblanc@naver.com\n'
          '전화: 010-2710-5603',
          style: bodyStyle,
        ),
        sectionGap,

        Text('제9조 개인정보처리방침 변경', style: titleStyle),
        itemGap,
        Text(
          '본 방침은 법령·정책 변경 또는 서비스 변경에 따라 내용이 변경될 수 있습니다. 변경 시 앱 공지사항을 통해 사전 안내합니다.',
          style: bodyStyle,
        ),
        const SizedBox(height: 40),
        Text(
          '주식회사 빌라드블랑\n경기도 파주시 청석로 272, 1004-575호\n사업자등록번호: 165-86-02139',
          style: bodyStyle?.copyWith(color: AppTheme.textTertiary, fontSize: 12),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
