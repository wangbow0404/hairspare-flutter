import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_routes.dart';
import '../../models/spare_profile.dart';
import '../../services/chat_service.dart';
import '../../services/spare_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/spare_profile_thumbnail.dart';

/// 샵 — 스페어 상세 (지원자 이력서 뷰).
class ShopSpareDetailScreen extends StatefulWidget {
  const ShopSpareDetailScreen({
    super.key,
    required this.spareId,
    this.jobId,
  });

  final String spareId;
  final String? jobId;

  @override
  State<ShopSpareDetailScreen> createState() => _ShopSpareDetailScreenState();
}

class _ShopSpareDetailScreenState extends State<ShopSpareDetailScreen> {
  final SpareService _spareService = SpareService();
  late final ChatService _chatService = sl<ChatService>();
  SpareProfile? _spare;
  bool _isLoading = true;
  String? _error;
  bool _isContactLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSpare();
  }

  Future<void> _handleContact() async {
    final spare = _spare;
    if (spare == null || _isContactLoading) return;
    final jobId = widget.jobId;
    if (jobId == null) {
      // jobId 없으면 채팅 목록으로
      if (mounted) context.push(AppRoutes.shopMessages);
      return;
    }
    setState(() => _isContactLoading = true);
    try {
      final chatId = await _chatService.ensureChatForJobApplication(
        jobId: jobId,
        jobTitle: '',
        shopName: '',
        spareId: spare.id,
        spareName: spare.name,
      );
      if (!mounted) return;
      NavigationHelper.navigateToChat(context, chatId);
    } catch (e) {
      if (!mounted) return;
      final msg = ErrorHandler.getUserFriendlyMessage(ErrorHandler.handleException(e));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _isContactLoading = false);
    }
  }

  Future<void> _loadSpare() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final spare = await _spareService.getSpareById(widget.spareId);
      if (!mounted) return;
      setState(() {
        _spare = spare;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHandler.getUserFriendlyMessage(
          ErrorHandler.handleException(e),
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _spare == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => NavigationHelper.safePop(context),
          ),
          title: const Text('스페어 상세'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.stitchTextSecondary,
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                _error ?? '스페어 정보를 불러올 수 없습니다',
                style: const TextStyle(color: AppTheme.stitchTextSecondary),
              ),
              const SizedBox(height: AppTheme.spacing4),
              ElevatedButton(
                onPressed: _loadSpare,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final spare = _spare!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 히어로 이미지
                  _SpareDetailHero(spare: spare),
                  // 흰 카드가 히어로 위로 -16px 올라오며 시작
                  // Container는 음수 margin 불가 → Transform.translate 사용
                  Transform.translate(
                    offset: const Offset(0, -16),
                    child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 이름 + 역할 + 인증 뱃지
                        _SpareDetailProfileHeader(spare: spare),
                        // 3컬럼 지표 행
                        _SpareDetailMetricsRow(spare: spare),
                      ],
                    ),
                  ),
                  ),
                  // 섹션 카드들
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacing4,
                      AppTheme.spacing4,
                      AppTheme.spacing4,
                      AppTheme.spacing4,
                    ),
                    child: Column(
                      children: [
                        _SpareDetailSkillsSection(spare: spare),
                        const SizedBox(height: AppTheme.spacing3),
                        _SpareDetailPortfolioSection(spare: spare),
                        const SizedBox(height: AppTheme.spacing3),
                        _SpareDetailTrustSection(spare: spare),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _SpareDetailBottomBar(
                onContact: _handleContact,
                isLoading: _isContactLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 히어로 이미지
// ─────────────────────────────────────────

class _SpareDetailHero extends StatelessWidget {
  const _SpareDetailHero({required this.spare});

  final SpareProfile spare;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: 288,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SpareProfileThumbnail(
            spare: spare,
            width: screenWidth,
            height: 288,
            borderRadius: BorderRadius.zero,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            top: AppTheme.spacing4,
            left: AppTheme.spacing4,
            child: Material(
              color: Colors.white.withValues(alpha: 0.92),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                color: AppTheme.stitchTextPrimary,
                onPressed: () => NavigationHelper.safePop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 이름 + 역할 + 인증 뱃지
// ─────────────────────────────────────────

class _SpareDetailProfileHeader extends StatelessWidget {
  const _SpareDetailProfileHeader({required this.spare});

  final SpareProfile spare;

  @override
  Widget build(BuildContext context) {
    final roleLabel = spare.role == 'designer' ? '디자이너' : '스텝';
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacing6,
        AppTheme.spacing6,
        AppTheme.spacing6,
        AppTheme.spacing4,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderGray)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spare.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.stitchPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing1),
          Text(
            '$roleLabel · 경력 ${spare.experience}년',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
          if (spare.isVerified) ...[
            const SizedBox(height: AppTheme.spacing3),
            _VerificationBadge(label: '본인인증'),
          ],
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.stitchPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        '✓ $label',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.stitchPrimary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// 지표 행 (완료)
// ─────────────────────────────────────────

class _SpareDetailMetricsRow extends StatelessWidget {
  const _SpareDetailMetricsRow({required this.spare});

  final SpareProfile spare;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _MetricCell(
              label: '완료',
              value: '${spare.completedJobs}건',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing1),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 섹션 공통 카드 래퍼
// ─────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    this.trailing,
    required this.child,
  });

  final String title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing4 + 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.stitchTextPrimary,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppTheme.spacing3),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 전문 기술
// ─────────────────────────────────────────

class _SpareDetailSkillsSection extends StatelessWidget {
  const _SpareDetailSkillsSection({required this.spare});

  final SpareProfile spare;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '전문 기술',
      child: spare.specialties.isEmpty
          ? const Text(
              '등록된 전문 기술이 없습니다',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.stitchTextSecondary,
              ),
            )
          : Wrap(
              spacing: AppTheme.spacing2,
              runSpacing: AppTheme.spacing2,
              children: spare.specialties.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing3 + 4,
                    vertical: AppTheme.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.stitchPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.stitchPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ─────────────────────────────────────────
// 포트폴리오
// ─────────────────────────────────────────

class _SpareDetailPortfolioSection extends StatelessWidget {
  const _SpareDetailPortfolioSection({required this.spare});

  final SpareProfile spare;

  @override
  Widget build(BuildContext context) {
    final images = spare.images ?? [];

    return _SectionCard(
      title: '포트폴리오',
      trailing: images.isNotEmpty
          ? TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '전체보기',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.stitchPrimary,
                ),
              ),
            )
          : null,
      child: images.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: AppTheme.spacing4),
              child: Center(
                child: Text(
                  '등록된 포트폴리오가 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.stitchTextSecondary,
                  ),
                ),
              ),
            )
          : SizedBox(
              height: 128,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppTheme.spacing3),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: SizedBox(
                      width: 128,
                      height: 128,
                      child: AppNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        memCacheWidth: 256,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────
// 신뢰 정보 (노쇼이력·노쇼비율·가입일·최근활동·응답속도)
// ─────────────────────────────────────────

class _SpareDetailTrustSection extends StatelessWidget {
  const _SpareDetailTrustSection({required this.spare});

  final SpareProfile spare;

  static String _formatDate(DateTime dt) =>
      DateFormat('yyyy년 M월 d일', 'ko_KR').format(dt);

  static String _formatResponseTime(int? minutes) {
    if (minutes == null) return '응답 기록 없음';
    if (minutes < 60) return '평균 $minutes분 이내';
    final hours = (minutes / 60).round();
    return '평균 $hours시간 이내';
  }

  @override
  Widget build(BuildContext context) {
    final hasNoShow = spare.noShowCount > 0;
    final noShowRate = spare.completedJobs > 0
        ? (spare.noShowCount / spare.completedJobs * 100).round()
        : 0;

    return _SectionCard(
      title: '신뢰 정보',
      child: Column(
        children: [
          _TrustRow(
            label: '노쇼 이력',
            value: hasNoShow ? '${spare.noShowCount}회' : '없음',
            valueColor: hasNoShow ? AppTheme.urgentRed : AppTheme.green600,
          ),
          const _TrustDivider(),
          _TrustRow(
            label: '노쇼 비율',
            value: '$noShowRate%',
            valueColor: hasNoShow ? AppTheme.urgentRed : null,
          ),
          const _TrustDivider(),
          _TrustRow(
            label: '가입일',
            value: _formatDate(spare.createdAt),
          ),
          const _TrustDivider(),
          _TrustRow(
            label: '응답 속도',
            value: _formatResponseTime(spare.responseTimeMinutes),
          ),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing1 + 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.stitchTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustDivider extends StatelessWidget {
  const _TrustDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 20, color: AppTheme.borderGray);
  }
}

// ─────────────────────────────────────────
// 하단 연락하기 바
// ─────────────────────────────────────────

class _SpareDetailBottomBar extends StatelessWidget {
  const _SpareDetailBottomBar({required this.onContact, this.isLoading = false});

  final VoidCallback onContact;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: const Border(top: BorderSide(color: AppTheme.borderGray)),
        boxShadow: AppTheme.shadowLg,
      ),
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4,
        AppTheme.spacing4 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: isLoading ? null : onContact,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.stitchPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  '연락하기',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }
}
