import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../models/spare_profile.dart';
import '../../services/spare_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_handler.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/region_helper.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/spare_profile_thumbnail.dart';

/// 샵 — 스페어 상세 (공고 상세와 동일 Stitch 레이아웃).
class ShopSpareDetailScreen extends StatefulWidget {
  const ShopSpareDetailScreen({
    super.key,
    required this.spareId,
  });

  final String spareId;

  @override
  State<ShopSpareDetailScreen> createState() => _ShopSpareDetailScreenState();
}

class _ShopSpareDetailScreenState extends State<ShopSpareDetailScreen> {
  final SpareService _spareService = SpareService();
  SpareProfile? _spare;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSpare();
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
    final split = _SpareDetailHelpers.splitAvailableDaysAndHours(
      spare.availableTimes,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SpareDetailHero(spare: spare),
                  _SpareDetailTitleSection(spare: spare),
                  _SpareDetailQuickInfoGrid(
                    spare: spare,
                    regionName: RegionHelper.getRegionName(spare.regionId),
                    availableDays: split.days,
                    availableHours: split.hours,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacing4,
                      AppTheme.spacing2,
                      AppTheme.spacing4,
                      AppTheme.spacing4,
                    ),
                    child: Column(
                      children: [
                        _SpareDetailPortfolioSection(spare: spare),
                        const SizedBox(height: AppTheme.spacing3),
                        _SpareDetailSkillsSection(spare: spare),
                        const SizedBox(height: AppTheme.spacing3),
                        _SpareDetailWorkInfoSection(
                          regionName: RegionHelper.getRegionName(spare.regionId),
                          days: split.days,
                          hours: split.hours,
                        ),
                        const SizedBox(height: AppTheme.spacing3),
                        _SpareDetailMatchingSection(spare: spare),
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
                onContact: () => context.push(AppRoutes.shopMessages),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
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

class _SpareDetailTitleSection extends StatelessWidget {
  const _SpareDetailTitleSection({required this.spare});

  final SpareProfile spare;

  @override
  Widget build(BuildContext context) {
    final roleLabel = spare.role == 'designer' ? '디자이너' : '스텝';

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spare.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            '$roleLabel · 경력 ${spare.experience}년',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing1),
          Text(
            '완료 ${spare.completedJobs}건',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpareDetailQuickInfoGrid extends StatelessWidget {
  const _SpareDetailQuickInfoGrid({
    required this.spare,
    required this.regionName,
    required this.availableDays,
    required this.availableHours,
  });

  final SpareProfile spare;
  final String regionName;
  final String availableDays;
  final String availableHours;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppTheme.spacing3,
        mainAxisSpacing: AppTheme.spacing3,
        childAspectRatio: 1.6,
        children: [
          _QuickInfoCard(
            icon: Icons.location_on_outlined,
            iconColor: AppTheme.stitchPrimaryContainer,
            label: '가능 지역',
            value: regionName,
          ),
          _QuickInfoCard(
            icon: Icons.schedule_outlined,
            iconColor: AppTheme.stitchPrimaryContainer,
            label: '가능 시간',
            value: availableHours == '—' ? availableDays : '$availableDays\n$availableHours',
          ),
          _QuickInfoCard(
            icon: Icons.work_outline,
            iconColor: AppTheme.green600,
            label: '완료 공고',
            value: '${spare.completedJobs}건',
          ),
          _QuickInfoCard(
            icon: Icons.payments_outlined,
            iconColor: AppTheme.yellow400,
            label: '희망 시급',
            value: (spare.hourlyRate ?? 0) > 0
                ? '${_SpareDetailHelpers.formatWon(spare.hourlyRate!)}원'
                : '협의',
          ),
        ],
      ),
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  const _QuickInfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppTheme.spacing2),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.stitchTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SpareDetailSectionCard extends StatelessWidget {
  const _SpareDetailSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          child,
        ],
      ),
    );
  }
}

class _SpareDetailPortfolioSection extends StatelessWidget {
  const _SpareDetailPortfolioSection({required this.spare});

  final SpareProfile spare;

  @override
  Widget build(BuildContext context) {
    final images = spare.images ?? [];

    return _SpareDetailSectionCard(
      title: '포트폴리오',
      child: images.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacing6),
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

class _SpareDetailSkillsSection extends StatelessWidget {
  const _SpareDetailSkillsSection({required this.spare});

  final SpareProfile spare;

  @override
  Widget build(BuildContext context) {
    return _SpareDetailSectionCard(
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
                    horizontal: AppTheme.spacing3,
                    vertical: AppTheme.spacing1 + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.stitchPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 13,
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

class _SpareDetailWorkInfoSection extends StatelessWidget {
  const _SpareDetailWorkInfoSection({
    required this.regionName,
    required this.days,
    required this.hours,
  });

  final String regionName;
  final String days;
  final String hours;

  @override
  Widget build(BuildContext context) {
    return _SpareDetailSectionCard(
      title: '근무 정보',
      child: Column(
        children: [
          _InfoRow(label: '가능 지역', value: regionName),
          const SizedBox(height: AppTheme.spacing3),
          _InfoRow(label: '가능 요일', value: days),
          const SizedBox(height: AppTheme.spacing3),
          _InfoRow(label: '가능 시간', value: hours),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.stitchTextSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.stitchTextPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpareDetailMatchingSection extends StatelessWidget {
  const _SpareDetailMatchingSection({required this.spare});

  final SpareProfile spare;

  @override
  Widget build(BuildContext context) {
    final hasNoShow = spare.noShowCount > 0;
    final noShowRate = spare.completedJobs > 0
        ? (spare.noShowCount / spare.completedJobs * 100).round()
        : 0;

    return _SpareDetailSectionCard(
      title: '매칭 정보',
      child: Column(
        children: [
          _MatchingRow(
            label: '노쇼 이력',
            value: hasNoShow ? '${spare.noShowCount}회' : '없음',
            valueColor: hasNoShow ? AppTheme.urgentRed : AppTheme.green600,
          ),
          const Divider(height: 24, color: AppTheme.borderGray),
          _MatchingRow(
            label: '노쇼율',
            value: '$noShowRate%',
            valueColor: hasNoShow ? AppTheme.urgentRed : AppTheme.green600,
          ),
          const Divider(height: 24, color: AppTheme.borderGray),
          const _MatchingRow(
            label: '응답 속도',
            value: '평균 1시간 이내',
          ),
          const Divider(height: 24, color: AppTheme.borderGray),
          const _MatchingRow(
            label: '평균 근무 시간',
            value: '4.0시간',
          ),
        ],
      ),
    );
  }
}

class _MatchingRow extends StatelessWidget {
  const _MatchingRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _SpareDetailBottomBar extends StatelessWidget {
  const _SpareDetailBottomBar({required this.onContact});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        border: const Border(top: BorderSide(color: AppTheme.borderGray)),
        boxShadow: AppTheme.shadowLg,
      ),
      padding: const EdgeInsets.all(AppTheme.spacing4),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: onContact,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.stitchPrimaryContainer,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
            ),
            child: const Text(
              '연락하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class _SpareDetailHelpers {
  static String formatWon(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  static ({String days, String hours}) splitAvailableDaysAndHours(
    List<String> availableTimes,
  ) {
    if (availableTimes.isEmpty) return (days: '—', hours: '—');
    const dayOnlyKeywords = [
      '주말',
      '평일',
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
      '일',
      '요일',
    ];
    final dayList = <String>[];
    final timeList = <String>[];
    for (final s in availableTimes) {
      final t = s.trim();
      if (t.isEmpty) continue;
      final looksLikeTime = t.contains(':') ||
          t.contains('~') ||
          t.contains('시') && !t.contains('요일');
      final looksLikeDayOnly =
          dayOnlyKeywords.any((k) => t == k || t.startsWith(k) || t.contains(k));
      if (looksLikeTime && !looksLikeDayOnly) {
        timeList.add(t);
      } else {
        dayList.add(t);
      }
    }
    return (
      days: dayList.isEmpty ? '—' : dayList.join(', '),
      hours: timeList.isEmpty ? '—' : timeList.join(', '),
    );
  }
}
